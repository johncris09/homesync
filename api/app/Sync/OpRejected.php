<?php

namespace App\Sync;

use RuntimeException;

/** Thrown inside op handling; becomes a `rejected` result with this error code. */
class OpRejected extends RuntimeException
{
    /** @param array<string, string> $details */
    public function __construct(public readonly string $error, public readonly array $details = [])
    {
        parent::__construct($error);
    }
}
