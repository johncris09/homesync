<?php

use App\Support\SyncColumns;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/*
 * Food Planner (Phase 3): family recipes with their ingredients (one row per
 * ingredient, so two phones can edit different lines), and the meal plan
 * (one row per dish in a meal slot of a day: a recipe or a typed dish).
 * The grocery list from the plan is worked out on the device.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('recipes', function (Blueprint $table) {
            SyncColumns::add($table);
            $table->string('name');
            $table->unsignedSmallInteger('servings')->nullable();
            $table->text('steps')->nullable();
            $table->text('note')->nullable();
        });

        Schema::create('recipe_ingredients', function (Blueprint $table) {
            SyncColumns::add($table);
            $table->uuid('recipe_id')->index();
            $table->string('name', 64);
            $table->decimal('quantity', 12, 3)->nullable();
            $table->string('unit', 16)->nullable();
            $table->unsignedSmallInteger('position')->default(0);
        });

        Schema::create('meals', function (Blueprint $table) {
            SyncColumns::add($table);
            $table->date('planned_on')->index();
            $table->string('slot', 16);
            $table->uuid('recipe_id')->nullable()->index();
            $table->string('dish', 64)->nullable();
            $table->text('note')->nullable();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('meals');
        Schema::dropIfExists('recipe_ingredients');
        Schema::dropIfExists('recipes');
    }
};
