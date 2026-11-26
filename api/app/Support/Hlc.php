<?php

namespace App\Support;

/**
 * Hybrid logical clock strings: "<13-digit ms>-<4 hex counter>-<8 hex node>".
 * Each part is fixed width, so plain string comparison gives the right order.
 */
class Hlc
{
    public const PATTERN = '/^\d{13}-[0-9a-f]{4}-[0-9a-f]{8}$/';

    public static function isValid(?string $hlc): bool
    {
        return $hlc !== null && preg_match(self::PATTERN, $hlc) === 1;
    }

    /** -1 if $a is older, 0 if equal, 1 if newer. A null clock is older than any clock. */
    public static function compare(?string $a, ?string $b): int
    {
        if ($a === $b) {
            return 0;
        }
        if ($a === null) {
            return -1;
        }
        if ($b === null) {
            return 1;
        }

        return strcmp($a, $b) <=> 0;
    }

    public static function isNewer(?string $a, ?string $b): bool
    {
        return self::compare($a, $b) > 0;
    }
}
