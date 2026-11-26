<?php

namespace App\Sync;

use App\Models\Device;
use App\Models\Member;
use App\Support\Hlc;
use App\Support\SyncColumns;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

/**
 * Server half of docs/sync-protocol.md: applies pushed ops with the conflict
 * rules in §6 and serves the change log to pull and bootstrap.
 */
class SyncService
{
    public function __construct(private readonly EntityRegistry $registry) {}

    // ---------------------------------------------------------------- push

    /**
     * @param  list<array<string, mixed>>  $ops
     * @return list<array<string, mixed>>
     */
    public function push(Device $device, array $ops): array
    {
        $member = $device->member;

        return DB::transaction(function () use ($device, $member, $ops) {
            $results = [];
            foreach ($ops as $op) {
                $results[] = $this->applyOne($device, $member, $op);
            }
            $device->forceFill(['last_seen_at' => now()])->save();

            return $results;
        });
    }

    /** @param array<string, mixed> $op */
    private function applyOne(Device $device, Member $member, array $op): array
    {
        $opId = strtolower((string) ($op['op_id'] ?? ''));

        $done = DB::table('processed_ops')->where('op_id', $opId)->first();
        if ($done) {
            return ['op_id' => $opId, 'status' => 'duplicate', 'server_version' => (int) $done->server_version];
        }

        try {
            // Savepoint: a rejected op leaves no partial writes behind.
            [$status, $seq, $conflictId] = DB::transaction(fn () => $this->applyOp($device, $member, $opId, $op));
        } catch (OpRejected $e) {
            return array_filter([
                'op_id' => $opId,
                'status' => 'rejected',
                'error' => $e->error,
                'details' => $e->details ?: null,
            ]);
        }

        DB::table('processed_ops')->insert([
            'op_id' => $opId,
            'household_id' => $device->household_id,
            'status' => $status,
            'server_version' => $seq,
        ]);

        return array_filter([
            'op_id' => $opId,
            'status' => $status,
            'server_version' => $seq,
            'conflict_id' => $conflictId,
        ], fn ($v) => $v !== null);
    }

    /**
     * @param  array<string, mixed>  $op
     * @return array{0: string, 1: int, 2: ?string} status, change seq, conflict id
     */
    private function applyOp(Device $device, Member $member, string $opId, array $op): array
    {
        $this->validateShape($opId, $op);

        $entity = $op['entity'];
        if (! $this->registry->has($entity)) {
            throw new OpRejected('unknown_entity');
        }
        if (! $this->registry->canWrite($entity, $member->role)) {
            throw new OpRejected('forbidden');
        }
        if ($op['op'] === 'insert' && $this->registry->isServerCreated($entity)) {
            throw new OpRejected('forbidden');
        }

        $table = $this->registry->table($entity);
        $id = strtolower($op['entity_id']);
        $row = DB::table($table)->where('id', $id)->first();
        if ($row && $row->household_id !== $device->household_id) {
            throw new OpRejected('household_mismatch');
        }

        // An insert onto an existing row (derived ids, sync-protocol §2.1) comes
        // from a device that never saw the row: base version 0, so a reviewed
        // value it overwrites is kept for review.
        $base = $op['op'] === 'insert' && $row ? 0 : ($op['base_version'] ?? null);
        $ctx = new OpContext($device, $member, $entity, $table, $id, $op['hlc'], $base);
        $fields = $op['fields'] ?? [];

        [$status, $conflictId] = match ($op['op']) {
            'insert' => $row ? $this->update($ctx, $row, $fields) : $this->insert($ctx, $fields),
            'update' => $this->update($ctx, $this->mustExist($row), $fields),
            'delete' => $this->delete($ctx, $this->mustExist($row)),
            'increment' => $this->increment($ctx, $this->mustExist($row), $fields),
        };

        $seq = $this->logChange($ctx, $op['op']);

        return [$status, $seq, $conflictId];
    }

    /** @param array<string, mixed> $op */
    private function validateShape(string $opId, array $op): void
    {
        $errors = [];
        if (! Str::isUuid($opId)) {
            $errors['op_id'] = 'must be a UUID';
        }
        if (! is_string($op['entity'] ?? null)) {
            $errors['entity'] = 'required';
        }
        if (! is_string($op['entity_id'] ?? null) || ! Str::isUuid($op['entity_id'])) {
            $errors['entity_id'] = 'must be a UUID';
        }
        if (! in_array($op['op'] ?? null, ['insert', 'update', 'delete', 'increment'], true)) {
            $errors['op'] = 'must be insert, update, delete or increment';
        }
        if (! Hlc::isValid($op['hlc'] ?? null)) {
            $errors['hlc'] = 'must be <13-digit ms>-<4 hex>-<8 hex>';
        }
        if (isset($op['fields']) && ! is_array($op['fields'])) {
            $errors['fields'] = 'must be an object';
        }
        if (isset($op['base_version']) && ! is_int($op['base_version'])) {
            $errors['base_version'] = 'must be an integer';
        }
        if ($errors) {
            throw new OpRejected('validation', $errors);
        }
    }

    private function mustExist(?object $row): object
    {
        if (! $row) {
            throw new OpRejected('validation', ['entity_id' => 'record not found']);
        }

        return $row;
    }

    // ------------------------------------------------------------ op kinds

    /** @return array{0: string, 1: null} */
    private function insert(OpContext $ctx, array $fields): array
    {
        $values = $this->castFields($ctx->entity, $fields, allowCounters: true);
        $now = now();

        DB::table($ctx->table)->insert($values + [
            'id' => $ctx->id,
            'household_id' => $ctx->device->household_id,
            'created_at' => $now,
            'updated_at' => $now,
            'hlc' => $ctx->hlc,
            'updated_by' => $ctx->member->id,
            'device_id' => $ctx->device->id,
        ]);

        foreach (array_keys($values) as $field) {
            if (! $this->registry->isCounter($ctx->entity, $field)) {
                $this->setClock($ctx, $field);
            }
        }

        return ['applied', null];
    }

    /** @return array{0: string, 1: ?string} */
    private function update(OpContext $ctx, object $row, array $fields): array
    {
        foreach (array_keys($fields) as $field) {
            if ($this->registry->isCounter($ctx->entity, $field)) {
                throw new OpRejected('not_counter', [$field => 'send an increment op for counter fields']);
            }
            if ($this->registry->isAppendOnly($ctx->entity) && ! $this->registry->isMutableAfterInsert($ctx->entity, $field)) {
                throw new OpRejected('validation', [$field => 'this record is append-only']);
            }
        }

        $values = $this->castFields($ctx->entity, $fields, allowCounters: false);
        $clocks = $this->clocks($ctx);
        $changes = [];
        $merged = false;
        $conflictId = null;

        // Delete vs edit: an edit newer than the delete brings the record back;
        // an older edit loses to the delete entirely.
        if ($row->deleted_at !== null) {
            if (Hlc::isNewer($ctx->hlc, $clocks['deleted_at']->hlc ?? null)) {
                $changes['deleted_at'] = null;
                $this->setClock($ctx, 'deleted_at');
            } else {
                return ['merged', null];
            }
        }

        foreach ($values as $field => $value) {
            $clock = $clocks[$field] ?? null;
            $current = $row->{$field};

            if ($this->registry->isForwardOnly($ctx->entity, $field)) {
                $isDone = (bool) $current;
                $wantsDone = (bool) $value;
                if ($isDone && ! $wantsDone) {
                    // Undo is allowed only by the person who marked it done, and only if newer.
                    $sameMember = $clock && $clock->updated_by === $ctx->member->id;
                    if (! ($sameMember && Hlc::isNewer($ctx->hlc, $clock->hlc))) {
                        $merged = true;

                        continue;
                    }
                } elseif ($isDone === $wantsDone) {
                    continue;
                }
                // Not done -> done always wins.
                $changes[$field] = $value;
                $this->setClock($ctx, $field);

                continue;
            }

            $differs = $this->differs($current, $value);
            if (Hlc::isNewer($ctx->hlc, $clock->hlc ?? null)) {
                if ($differs && $this->registry->isReviewed($ctx->entity, $field)
                    && $clock && $clock->updated_by !== $ctx->member->id
                    && $ctx->baseVersion !== null && $ctx->baseVersion < (int) $row->server_version) {
                    // Concurrent change: the newer value wins, the overwritten one is kept for review.
                    $conflictId = $this->recordConflict($ctx, $field, $value, $ctx->member->id, $current, $clock->updated_by);
                }
                if ($differs) {
                    $changes[$field] = $value;
                }
                $this->setClock($ctx, $field);
            } else {
                $merged = true;
                if ($differs && $this->registry->isReviewed($ctx->entity, $field)) {
                    $conflictId = $this->recordConflict($ctx, $field, $current, $clock->updated_by ?? null, $value, $ctx->member->id);
                }
            }
        }

        if ($changes) {
            DB::table($ctx->table)->where('id', $ctx->id)->update($changes + $this->touch($ctx, $row));
        }

        return [$merged ? 'merged' : 'applied', $conflictId];
    }

    /** @return array{0: string, 1: null} */
    private function delete(OpContext $ctx, object $row): array
    {
        $newestEdit = DB::table('field_clocks')
            ->where('entity', $ctx->entity)->where('entity_id', $ctx->id)
            ->max('hlc');

        // Delete wins unless an edit is newer than the delete.
        if (Hlc::compare($ctx->hlc, $newestEdit) < 0) {
            return ['merged', null];
        }

        if ($row->deleted_at === null) {
            DB::table($ctx->table)->where('id', $ctx->id)
                ->update(['deleted_at' => now()] + $this->touch($ctx, $row));
        }
        $this->setClock($ctx, 'deleted_at');

        return ['applied', null];
    }

    /** @return array{0: string, 1: null} */
    private function increment(OpContext $ctx, object $row, array $fields): array
    {
        if ($fields === []) {
            throw new OpRejected('validation', ['fields' => 'at least one counter is required']);
        }
        $changes = [];
        foreach ($fields as $field => $delta) {
            if (! $this->registry->isCounter($ctx->entity, $field)) {
                throw new OpRejected('not_counter', [$field => 'not a counter field']);
            }
            if (! is_int($delta) && ! is_float($delta)) {
                throw new OpRejected('validation', [$field => 'increment must be a number']);
            }
            $changes[$field] = DB::raw(sprintf('%s + (%s)', DB::getQueryGrammar()->wrap($field), (string) (0 + $delta)));
        }

        DB::table($ctx->table)->where('id', $ctx->id)->update($changes + $this->touch($ctx, $row));

        return ['applied', null];
    }

    // ------------------------------------------------------------- helpers

    /** @return array<string, mixed> */
    private function castFields(string $entity, array $fields, bool $allowCounters): array
    {
        $types = $this->registry->fields($entity);
        $values = [];
        $errors = [];

        foreach ($fields as $field => $value) {
            if (in_array($field, SyncColumns::NAMES, true) || ! isset($types[$field])) {
                $errors[$field] = 'not a writable field';

                continue;
            }
            if (! $allowCounters && $this->registry->isCounter($entity, $field)) {
                $errors[$field] = 'send an increment op for counter fields';

                continue;
            }
            try {
                $values[$field] = FieldCaster::toDb($types[$field], $value);
            } catch (InvalidFieldValue $e) {
                $errors[$field] = $e->getMessage();
            }
        }

        if ($errors) {
            throw new OpRejected('validation', $errors);
        }

        return $values;
    }

    /** @return array<string, object> field => clock row */
    private function clocks(OpContext $ctx): array
    {
        return DB::table('field_clocks')
            ->where('entity', $ctx->entity)->where('entity_id', $ctx->id)
            ->get()->keyBy('field')->all();
    }

    private function setClock(OpContext $ctx, string $field): void
    {
        DB::table('field_clocks')->upsert(
            [['entity' => $ctx->entity, 'entity_id' => $ctx->id, 'field' => $field, 'hlc' => $ctx->hlc, 'updated_by' => $ctx->member->id]],
            ['entity', 'entity_id', 'field'],
            ['hlc', 'updated_by'],
        );
    }

    /** @return array<string, mixed> */
    private function touch(OpContext $ctx, object $row): array
    {
        return [
            'updated_at' => now(),
            'hlc' => Hlc::isNewer($ctx->hlc, $row->hlc) ? $ctx->hlc : $row->hlc,
            'updated_by' => $ctx->member->id,
            'device_id' => $ctx->device->id,
        ];
    }

    private function differs(mixed $current, mixed $new): bool
    {
        if ($current === null || $new === null) {
            return $current !== $new;
        }

        return (string) $current !== (string) $new;
    }

    private function recordConflict(OpContext $ctx, string $field, mixed $kept, ?string $keptBy, mixed $lost, ?string $lostBy): string
    {
        $id = (string) Str::uuid7();
        DB::table('conflicts')->insert([
            'id' => $id,
            'household_id' => $ctx->device->household_id,
            'entity' => $ctx->entity,
            'entity_id' => $ctx->id,
            'field' => $field,
            'kept_value' => json_encode($kept),
            'kept_by' => $keptBy,
            'lost_value' => json_encode($lost),
            'lost_by' => $lostBy,
            'created_at' => now(),
            'updated_at' => now(),
            'hlc' => $ctx->hlc,
            'updated_by' => $ctx->member->id,
            'device_id' => $ctx->device->id,
        ]);

        // Synced like any record, so adults see it in the Conflict Inbox.
        $this->logChange(new OpContext($ctx->device, $ctx->member, 'conflicts', 'conflicts', $id, $ctx->hlc, null), 'insert');

        return $id;
    }

    /**
     * Every accepted op, merged or not, writes the record's current state to
     * the change log, so the sender pulls the server's final value.
     */
    private function logChange(OpContext $ctx, string $op): int
    {
        $seq = DB::table('change_log')->insertGetId([
            'household_id' => $ctx->device->household_id,
            'entity' => $ctx->entity,
            'entity_id' => $ctx->id,
            'op' => $op,
            'hlc' => $ctx->hlc,
            'device_id' => $ctx->device->id,
        ]);

        DB::table($ctx->table)->where('id', $ctx->id)->update(['server_version' => $seq]);
        $row = DB::table($ctx->table)->where('id', $ctx->id)->first();
        DB::table('change_log')->where('id', $seq)->update(['row' => json_encode($row)]);

        return $seq;
    }

    // ---------------------------------------------------------------- pull

    /** @return array{changes: list<array<string, mixed>>, cursor: int, has_more: bool} */
    public function pull(Device $device, int $cursor, int $limit): array
    {
        $role = $device->member->role;
        $rows = DB::table('change_log')
            ->where('household_id', $device->household_id)
            ->where('id', '>', $cursor)
            ->orderBy('id')
            ->limit($limit + 1)
            ->get();

        $hasMore = $rows->count() > $limit;
        $page = $rows->take($limit);
        $next = $page->isEmpty() ? $cursor : (int) $page->last()->id;

        $changes = $page
            ->filter(fn ($c) => $this->registry->has($c->entity) && $this->registry->canRead($c->entity, $role))
            ->map(fn ($c) => [
                'seq' => (int) $c->id,
                'entity' => $c->entity,
                'entity_id' => $c->entity_id,
                'op' => $c->op,
                'row' => $this->presentRow($c->entity, json_decode($c->row, true) ?? []),
            ])
            ->values()->all();

        $device->forceFill(['last_pull_cursor' => $next, 'last_seen_at' => now()])->save();

        return ['changes' => $changes, 'cursor' => $next, 'has_more' => $hasMore];
    }

    /** @return array{entities: array<string, list<array<string, mixed>>>, cursor: int} */
    public function bootstrap(Device $device): array
    {
        $role = $device->member->role;

        return DB::transaction(function () use ($device, $role) {
            $cursor = (int) DB::table('change_log')->where('household_id', $device->household_id)->max('id');
            $entities = [];
            foreach ($this->registry->names() as $entity) {
                if (! $this->registry->canRead($entity, $role)) {
                    continue;
                }
                $entities[$entity] = DB::table($this->registry->table($entity))
                    ->where('household_id', $device->household_id)
                    ->get()
                    ->map(fn ($r) => $this->presentRow($entity, (array) $r))
                    ->all();
            }

            return ['entities' => $entities, 'cursor' => $cursor];
        });
    }

    /** @param array<string, mixed> $row */
    private function presentRow(string $entity, array $row): array
    {
        $out = [];
        foreach ($this->registry->fields($entity) as $field => $type) {
            if (array_key_exists($field, $row)) {
                $out[$field] = FieldCaster::fromDb($type, $row[$field]);
            }
        }
        foreach (['created_at', 'updated_at', 'deleted_at'] as $ts) {
            $out[$ts] = isset($row[$ts]) ? FieldCaster::fromDb('datetime', $row[$ts]) : null;
        }

        return [
            'id' => $row['id'] ?? null,
            'household_id' => $row['household_id'] ?? null,
        ] + $out + [
            'hlc' => $row['hlc'] ?? null,
            'server_version' => isset($row['server_version']) ? (int) $row['server_version'] : null,
            'updated_by' => $row['updated_by'] ?? null,
            'device_id' => $row['device_id'] ?? null,
        ];
    }

    public static function serverTimeMs(): int
    {
        return (int) floor(Carbon::now()->getPreciseTimestamp(3));
    }
}
