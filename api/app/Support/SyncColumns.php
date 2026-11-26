<?php

namespace App\Support;

use Illuminate\Database\Schema\Blueprint;

/**
 * The columns every synced table carries (docs/sync-protocol.md §2).
 */
class SyncColumns
{
    public const NAMES = [
        'id', 'household_id', 'created_at', 'updated_at', 'deleted_at',
        'hlc', 'server_version', 'updated_by', 'device_id',
    ];

    public static function add(Blueprint $table): void
    {
        $table->uuid('id')->primary();
        $table->uuid('household_id')->index();
        $table->timestamp('created_at')->nullable();
        $table->timestamp('updated_at')->nullable();
        $table->timestamp('deleted_at')->nullable();
        $table->string('hlc', 32)->nullable();
        $table->unsignedBigInteger('server_version')->nullable();
        $table->uuid('updated_by')->nullable();
        $table->uuid('device_id')->nullable();
    }
}
