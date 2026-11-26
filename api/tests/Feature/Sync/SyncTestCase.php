<?php

namespace Tests\Feature\Sync;

use App\Models\Device;
use App\Models\Household;
use App\Models\Member;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Illuminate\Testing\TestResponse;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

abstract class SyncTestCase extends TestCase
{
    use RefreshDatabase;

    protected Household $household;

    protected function setUp(): void
    {
        parent::setUp();
        $this->household = Household::create(['id' => (string) Str::uuid7(), 'name' => 'Test home']);
    }

    protected function device(string $role = 'owner', ?Household $household = null): Device
    {
        $household ??= $this->household;
        $member = Member::create([
            'id' => (string) Str::uuid7(),
            'household_id' => $household->id,
            'name' => ucfirst($role).' '.Str::random(4),
            'role' => $role,
        ]);

        return Device::create([
            'id' => (string) Str::uuid7(),
            'household_id' => $household->id,
            'member_id' => $member->id,
            'name' => 'Phone',
            'platform' => 'android',
        ]);
    }

    protected function hlc(int $step, int $counter = 0, string $node = 'aaaaaaaa'): string
    {
        return sprintf('%013d-%04x-%s', 1795500000000 + $step * 1000, $counter, $node);
    }

    /** @param array<string, mixed> $fields */
    protected function op(string $entity, string $id, string $op, array $fields, string $hlc, ?int $base = null): array
    {
        return array_filter([
            'op_id' => (string) Str::uuid7(),
            'entity' => $entity,
            'entity_id' => $id,
            'op' => $op,
            'fields' => $fields,
            'hlc' => $hlc,
            'base_version' => $base,
        ], fn ($v) => $v !== null);
    }

    protected function push(Device $device, array $ops): TestResponse
    {
        Sanctum::actingAs($device);

        return $this->postJson('/api/sync/push', ['ops' => $ops], ['X-HomeSync-Protocol' => '1']);
    }

    /** @return list<string> */
    protected function statuses(TestResponse $response): array
    {
        return array_column($response->assertOk()->json('results'), 'status');
    }

    protected function pull(Device $device, int $cursor = 0, int $limit = 500): TestResponse
    {
        Sanctum::actingAs($device);

        return $this->getJson("/api/sync/pull?cursor=$cursor&limit=$limit", ['X-HomeSync-Protocol' => '1']);
    }

    /** The latest row for an entity id, as a device would see it after pulling. */
    protected function latest(Device $device, string $id): ?array
    {
        $changes = collect($this->pull($device)->assertOk()->json('changes'))->where('entity_id', $id);

        return $changes->last()['row'] ?? null;
    }
}
