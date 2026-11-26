<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/*
 * Conflicts become a synced entity (sync-protocol §6.1) so adults can review
 * them in the app's Conflict Inbox. The server creates them; devices only
 * mark them resolved.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('conflicts', function (Blueprint $table) {
            $table->timestamp('deleted_at')->nullable();
            $table->string('hlc', 32)->nullable();
            $table->unsignedBigInteger('server_version')->nullable();
            $table->uuid('updated_by')->nullable();
            $table->uuid('device_id')->nullable();
        });
    }

    public function down(): void
    {
        Schema::table('conflicts', function (Blueprint $table) {
            $table->dropColumn(['deleted_at', 'hlc', 'server_version', 'updated_by', 'device_id']);
        });
    }
};
