<?php

namespace App\Sync;

use App\Models\Device;
use App\Models\Member;

/** The facts about one op that every handler needs. */
final class OpContext
{
    public function __construct(
        public readonly Device $device,
        public readonly Member $member,
        public readonly string $entity,
        public readonly string $table,
        public readonly string $id,
        public readonly string $hlc,
        public readonly ?int $baseVersion,
    ) {}
}
