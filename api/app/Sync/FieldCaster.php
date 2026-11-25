<?php

namespace App\Sync;

use Carbon\CarbonImmutable;
use Illuminate\Support\Str;
use Throwable;

/**
 * Converts values between the wire format and the database, per field type.
 * `toDb` throws InvalidFieldValue for a value that doesn't fit its type.
 */
class FieldCaster
{
    public static function toDb(string $type, mixed $value): mixed
    {
        if ($value === null) {
            return null;
        }

        return match ($type) {
            'string' => self::string($value, 255),
            'text' => self::string($value, 65535),
            'int' => self::int($value),
            'bool' => self::bool($value),
            'decimal' => self::decimal($value),
            'date' => self::date($value),
            'datetime' => self::datetime($value),
            'uuid' => self::uuid($value),
            'json' => json_encode($value, JSON_THROW_ON_ERROR),
            default => throw new InvalidFieldValue("unknown type $type"),
        };
    }

    public static function fromDb(string $type, mixed $value): mixed
    {
        if ($value === null) {
            return null;
        }

        return match ($type) {
            'int' => (int) $value,
            'bool' => (bool) $value,
            'decimal' => (float) $value,
            'datetime' => CarbonImmutable::parse($value, 'UTC')->toIso8601ZuluString(),
            'date' => substr((string) $value, 0, 10),
            'json' => is_string($value) ? json_decode($value, true) : $value,
            default => $value,
        };
    }

    public static function datetime(mixed $value): string
    {
        try {
            return CarbonImmutable::parse((string) $value)->utc()->format('Y-m-d H:i:s');
        } catch (Throwable) {
            throw new InvalidFieldValue('not a date-time');
        }
    }

    private static function string(mixed $value, int $max): string
    {
        if (! is_string($value) && ! is_numeric($value)) {
            throw new InvalidFieldValue('not a string');
        }
        $value = (string) $value;
        if (mb_strlen($value) > $max) {
            throw new InvalidFieldValue("longer than $max characters");
        }

        return $value;
    }

    private static function int(mixed $value): int
    {
        if (is_int($value) || (is_string($value) && preg_match('/^-?\d+$/', $value))) {
            return (int) $value;
        }
        throw new InvalidFieldValue('not an integer');
    }

    private static function bool(mixed $value): int
    {
        if (is_bool($value)) {
            return $value ? 1 : 0;
        }
        if ($value === 0 || $value === 1) {
            return $value;
        }
        throw new InvalidFieldValue('not a boolean');
    }

    private static function decimal(mixed $value): string
    {
        if (! is_numeric($value)) {
            throw new InvalidFieldValue('not a number');
        }

        return (string) $value;
    }

    private static function date(mixed $value): string
    {
        if (! is_string($value) || ! preg_match('/^\d{4}-\d{2}-\d{2}$/', $value)) {
            throw new InvalidFieldValue('not a date (YYYY-MM-DD)');
        }

        return $value;
    }

    private static function uuid(mixed $value): string
    {
        if (! is_string($value) || ! Str::isUuid($value)) {
            throw new InvalidFieldValue('not a UUID');
        }

        return strtolower($value);
    }
}
