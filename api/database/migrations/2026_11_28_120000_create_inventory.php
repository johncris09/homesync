<?php

use App\Support\SyncColumns;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/*
 * Household Inventory (Phase 2): durable things the household owns
 * (appliances, electronics, furniture, tools). One row per item with its
 * room, purchase details, warranty end and who borrowed it. The photo is a
 * plain (not encrypted) file uploaded to /api/files/{photo_sha256}
 * (sync-protocol §7).
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('inventory_items', function (Blueprint $table) {
            SyncColumns::add($table);
            $table->string('name');
            $table->string('category', 16);
            $table->string('room', 64)->nullable();
            $table->string('brand', 64)->nullable();
            $table->string('model', 64)->nullable();
            $table->string('serial_no', 64)->nullable();
            $table->date('bought_on')->nullable();
            $table->bigInteger('price_minor')->nullable();
            $table->string('currency', 3)->default('PHP');
            $table->date('warranty_until')->nullable();
            $table->char('photo_sha256', 64)->nullable()->index();
            $table->unsignedBigInteger('photo_size')->nullable();
            $table->string('lent_to', 64)->nullable();
            $table->date('lent_on')->nullable();
            $table->text('note')->nullable();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('inventory_items');
    }
};
