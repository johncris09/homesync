<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Every server-applied change, in order. `id` is the pull cursor (seq).
        Schema::create('change_log', function (Blueprint $table) {
            $table->id();
            $table->uuid('household_id');
            $table->string('entity', 64);
            $table->uuid('entity_id');
            $table->string('op', 16);
            $table->json('row')->nullable();
            $table->string('hlc', 32)->nullable();
            $table->uuid('device_id')->nullable();
            $table->timestamp('created_at')->useCurrent();
            $table->index(['household_id', 'id']);
        });

        // Ops already applied, so a re-sent batch is never applied twice.
        Schema::create('processed_ops', function (Blueprint $table) {
            $table->uuid('op_id')->primary();
            $table->uuid('household_id');
            $table->string('status', 16);
            $table->unsignedBigInteger('server_version')->nullable();
            $table->timestamp('created_at')->useCurrent();
        });

        // The HLC of the last accepted write per field, for field-level merge.
        Schema::create('field_clocks', function (Blueprint $table) {
            $table->string('entity', 64);
            $table->uuid('entity_id');
            $table->string('field', 64);
            $table->string('hlc', 32);
            $table->uuid('updated_by')->nullable();
            $table->primary(['entity', 'entity_id', 'field']);
        });

        // Values that lost a merge and need an adult to confirm or revert.
        Schema::create('conflicts', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('household_id');
            $table->string('entity', 64);
            $table->uuid('entity_id');
            $table->string('field', 64);
            $table->json('kept_value')->nullable();
            $table->uuid('kept_by')->nullable();
            $table->json('lost_value')->nullable();
            $table->uuid('lost_by')->nullable();
            $table->timestamp('resolved_at')->nullable();
            $table->uuid('resolved_by')->nullable();
            $table->timestamps();
            $table->index(['household_id', 'resolved_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('conflicts');
        Schema::dropIfExists('field_clocks');
        Schema::dropIfExists('processed_ops');
        Schema::dropIfExists('change_log');
    }
};
