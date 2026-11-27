<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/*
 * Planned shopping day for a grocery item still to buy (any day, also in the
 * future). The list groups by it; null = no date.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('grocery_items', function (Blueprint $table) {
            $table->date('planned_on')->nullable();
        });
    }

    public function down(): void
    {
        Schema::table('grocery_items', function (Blueprint $table) {
            $table->dropColumn('planned_on');
        });
    }
};
