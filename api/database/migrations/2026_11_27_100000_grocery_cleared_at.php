<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/*
 * Grocery history. "Clear bought" now sets cleared_at instead of deleting the
 * row, so past groceries stay for the history view (grouped by bought_at).
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('grocery_items', function (Blueprint $table) {
            $table->timestamp('cleared_at', 3)->nullable();
        });
    }

    public function down(): void
    {
        Schema::table('grocery_items', function (Blueprint $table) {
            $table->dropColumn('cleared_at');
        });
    }
};
