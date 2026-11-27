<?php

use App\Support\SyncColumns;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/*
 * Home Maintenance (Phase 3): upkeep tasks that repeat every so many months
 * (or once), a log of upkeep done and repairs (append-only; a cost is also
 * posted to the ledger as a `transactions` row with `source_type`
 * `maintenance`), and the household's contractors. Tasks and log entries may
 * point to an Inventory item and a contractor.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('contractors', function (Blueprint $table) {
            SyncColumns::add($table);
            $table->string('name');
            $table->string('trade', 16);
            $table->string('phone', 32)->nullable();
            $table->text('note')->nullable();
        });

        Schema::create('maintenance_tasks', function (Blueprint $table) {
            SyncColumns::add($table);
            $table->string('name');
            $table->string('area', 16);
            $table->unsignedSmallInteger('every_months')->nullable();
            $table->date('next_due_on')->nullable();
            $table->date('last_done_on')->nullable();
            $table->uuid('inventory_item_id')->nullable()->index();
            $table->uuid('contractor_id')->nullable();
            $table->text('note')->nullable();
        });

        Schema::create('maintenance_logs', function (Blueprint $table) {
            SyncColumns::add($table);
            $table->string('kind', 8);
            $table->uuid('task_id')->nullable()->index();
            $table->string('area', 16);
            $table->string('title');
            $table->date('done_on');
            $table->date('due_on')->nullable();
            $table->bigInteger('cost_minor')->nullable();
            $table->string('currency', 3)->default('PHP');
            $table->uuid('member_id')->nullable();
            $table->uuid('contractor_id')->nullable();
            $table->uuid('inventory_item_id')->nullable()->index();
            $table->text('note')->nullable();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('maintenance_logs');
        Schema::dropIfExists('maintenance_tasks');
        Schema::dropIfExists('contractors');
    }
};
