<?php

use App\Support\SyncColumns;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/*
 * Vehicles (Phase 2). One vehicles row per car or motorcycle with its due
 * dates (LTO registration, insurance, PMS by date and/or odometer); every
 * cost and odometer reading is an append-only vehicle_logs row. The odometer
 * is the highest reading in the logs, worked out on the device
 * (sync-protocol §6).
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('vehicles', function (Blueprint $table) {
            SyncColumns::add($table);
            $table->string('kind', 16);
            $table->string('name');
            $table->string('plate', 32)->nullable();
            $table->string('color', 32)->nullable();
            $table->date('registration_due_on')->nullable();
            $table->date('insurance_due_on')->nullable();
            $table->date('pms_due_on')->nullable();
            $table->integer('pms_due_km')->nullable();
            $table->integer('pms_every_months')->nullable();
            $table->integer('pms_every_km')->nullable();
            $table->text('note')->nullable();
        });

        Schema::create('vehicle_logs', function (Blueprint $table) {
            SyncColumns::add($table);
            $table->uuid('vehicle_id')->index();
            $table->string('kind', 16);
            $table->bigInteger('amount_minor')->nullable();
            $table->string('currency', 3)->default('PHP');
            $table->date('logged_on');
            $table->integer('odometer_km')->nullable();
            $table->decimal('litres', 8, 2)->nullable();
            $table->uuid('member_id')->nullable();
            $table->text('note')->nullable();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('vehicle_logs');
        Schema::dropIfExists('vehicles');
    }
};
