<?php

namespace App\Sync;

use InvalidArgumentException;

/**
 * Read-only view of config('homesync.entities'): which tables sync, their
 * fields and types, who may read or write them, and their conflict rules.
 */
class EntityRegistry
{
    /** @param array<string, array<string, mixed>> $entities */
    public function __construct(private readonly array $entities) {}

    public static function fromConfig(): self
    {
        return new self(config('homesync.entities', []));
    }

    /** @return list<string> */
    public function names(): array
    {
        return array_keys($this->entities);
    }

    public function has(string $entity): bool
    {
        return isset($this->entities[$entity]);
    }

    public function table(string $entity): string
    {
        return $this->def($entity)['table'] ?? $entity;
    }

    /** @return array<string, string> field => type */
    public function fields(string $entity): array
    {
        return $this->def($entity)['fields'] ?? [];
    }

    public function canRead(string $entity, string $role): bool
    {
        return in_array($role, $this->def($entity)['read'] ?? [], true);
    }

    public function canWrite(string $entity, string $role): bool
    {
        return in_array($role, $this->def($entity)['write'] ?? [], true);
    }

    public function isCounter(string $entity, string $field): bool
    {
        return in_array($field, $this->def($entity)['counters'] ?? [], true);
    }

    public function isForwardOnly(string $entity, string $field): bool
    {
        return in_array($field, $this->def($entity)['forward_only'] ?? [], true);
    }

    public function isReviewed(string $entity, string $field): bool
    {
        return in_array($field, $this->def($entity)['reviewed'] ?? [], true);
    }

    public function isAppendOnly(string $entity): bool
    {
        return (bool) ($this->def($entity)['append_only'] ?? false);
    }

    public function isMutableAfterInsert(string $entity, string $field): bool
    {
        return in_array($field, $this->def($entity)['mutable'] ?? [], true);
    }

    /** @return array<string, mixed> */
    private function def(string $entity): array
    {
        if (! isset($this->entities[$entity])) {
            throw new InvalidArgumentException("Unknown entity [$entity]");
        }

        return $this->entities[$entity];
    }
}
