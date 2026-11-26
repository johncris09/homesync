<?php

use App\Support\SyncColumns;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/*
 * First synced tables. They exercise every conflict rule in the protocol
 * (forward-only status, counters, reviewed money, append-only) and are
 * extended by their modules in Phase 1.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('grocery_items', function (Blueprint $table) {
            SyncColumns::add($table);
            $table->string('name');
            $table->string('quantity_text')->nullable();
            $table->string('store')->nullable();
            $table->boolean('is_bought')->default(false);
            $table->timestamp('bought_at')->nullable();
            $table->uuid('requested_by')->nullable();
            $table->text('note')->nullable();
        });

        Schema::create('pantry_items', function (Blueprint $table) {
            SyncColumns::add($table);
            $table->string('name');
            $table->string('unit', 16)->nullable();
            $table->decimal('quantity', 12, 3)->default(0);
            $table->decimal('min_quantity', 12, 3)->nullable();
            $table->string('location')->nullable();
            $table->date('expires_on')->nullable();
        });

        Schema::create('bills', function (Blueprint $table) {
            SyncColumns::add($table);
            $table->string('name');
            $table->string('provider')->nullable();
            $table->bigInteger('amount_minor')->default(0);
            $table->string('currency', 3)->default('PHP');
            $table->date('due_on')->nullable();
            $table->boolean('is_paid')->default(false);
            $table->timestamp('paid_at')->nullable();
        });

        Schema::create('transactions', function (Blueprint $table) {
            SyncColumns::add($table);
            $table->uuid('account_id')->nullable();
            $table->string('category')->nullable();
            $table->bigInteger('amount_minor');
            $table->string('currency', 3)->default('PHP');
            $table->timestamp('occurred_at');
            $table->uuid('member_id')->nullable();
            $table->string('source_type', 32)->nullable();
            $table->uuid('source_id')->nullable();
            $table->text('note')->nullable();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('transactions');
        Schema::dropIfExists('bills');
        Schema::dropIfExists('pantry_items');
        Schema::dropIfExists('grocery_items');
    }
};
