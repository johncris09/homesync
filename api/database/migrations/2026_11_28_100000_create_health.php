<?php

use App\Support\SyncColumns;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/*
 * Health (Phase 2). health_profiles: one row per member, the sensitive
 * fields sealed on the device with the household vault key (docs/vault.md),
 * never auto-merged. medicines: who it is for, dose times and a stock
 * counter. med_doses: append-only, one per dose given. checkups: checkups
 * and vaccines with a due date (sync-protocol §6).
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('health_profiles', function (Blueprint $table) {
            SyncColumns::add($table);
            $table->uuid('member_id')->index();
            $table->text('sealed');
        });

        Schema::create('medicines', function (Blueprint $table) {
            SyncColumns::add($table);
            $table->string('name');
            $table->string('strength', 64)->nullable();
            $table->uuid('member_id')->nullable();
            $table->string('times', 64)->nullable();
            $table->decimal('dose_qty', 8, 2)->default(1);
            $table->date('ends_on')->nullable();
            $table->decimal('stock', 10, 2)->default(0);
            $table->decimal('min_stock', 10, 2)->nullable();
            $table->string('unit', 32)->nullable();
            $table->date('expires_on')->nullable();
            $table->text('note')->nullable();
        });

        Schema::create('med_doses', function (Blueprint $table) {
            SyncColumns::add($table);
            $table->uuid('medicine_id')->index();
            $table->uuid('member_id')->nullable();
            $table->uuid('given_by')->nullable();
            $table->date('taken_on');
            $table->string('slot', 5)->nullable();
            $table->timestamp('taken_at')->nullable();
            $table->text('note')->nullable();
        });

        Schema::create('checkups', function (Blueprint $table) {
            SyncColumns::add($table);
            $table->uuid('member_id')->nullable();
            $table->string('kind', 16);
            $table->string('title');
            $table->date('due_on')->nullable();
            $table->string('due_time', 5)->nullable();
            $table->string('place')->nullable();
            $table->timestamp('done_at')->nullable();
            $table->uuid('done_by')->nullable();
            $table->text('note')->nullable();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('checkups');
        Schema::dropIfExists('med_doses');
        Schema::dropIfExists('medicines');
        Schema::dropIfExists('health_profiles');
    }
};
