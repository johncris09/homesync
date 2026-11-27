<?php

use App\Support\SyncColumns;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/*
 * Rent the household collects (Phase 2). A rental_units row per room, house
 * or stall (kept while vacant); a leases row per tenant in a unit; every
 * payment is an append-only rent_payments row. What a tenant owes is worked
 * out on the device: the rent due from move-in to now minus everything paid
 * (sync-protocol §6).
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('rental_units', function (Blueprint $table) {
            SyncColumns::add($table);
            $table->string('name');
            $table->text('note')->nullable();
        });

        Schema::create('leases', function (Blueprint $table) {
            SyncColumns::add($table);
            $table->uuid('unit_id')->index();
            $table->string('tenant_name');
            $table->string('phone', 32)->nullable();
            $table->bigInteger('rent_minor');
            $table->bigInteger('prev_rent_minor')->nullable();
            $table->date('rent_since')->nullable();
            $table->string('currency', 3)->default('PHP');
            $table->unsignedTinyInteger('due_day');
            $table->date('starts_on');
            $table->date('ends_on')->nullable();
            $table->bigInteger('deposit_minor')->nullable();
            $table->bigInteger('deposit_returned_minor')->nullable();
            $table->date('deposit_returned_on')->nullable();
            $table->text('note')->nullable();
        });

        Schema::create('rent_payments', function (Blueprint $table) {
            SyncColumns::add($table);
            $table->uuid('lease_id')->index();
            $table->string('kind', 16);
            $table->bigInteger('amount_minor');
            $table->string('currency', 3)->default('PHP');
            $table->date('paid_on');
            $table->string('method', 16)->nullable();
            $table->uuid('member_id')->nullable();
            $table->text('note')->nullable();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('rent_payments');
        Schema::dropIfExists('leases');
        Schema::dropIfExists('rental_units');
    }
};
