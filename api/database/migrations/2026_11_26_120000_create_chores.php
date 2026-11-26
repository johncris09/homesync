<?php

use App\Support\SyncColumns;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/*
 * Chores (Phase 1). A chore repeats daily, weekly on one weekday, or happens
 * once on a date. Doing it appends a completion (who, which day); a chore is
 * done for a day when it has a completion for that day.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('chores', function (Blueprint $table) {
            SyncColumns::add($table);
            $table->string('name');
            $table->uuid('assigned_to')->nullable();
            $table->string('repeat', 16)->default('daily');
            $table->unsignedTinyInteger('weekday')->nullable();
            $table->date('due_on')->nullable();
        });

        Schema::create('chore_completions', function (Blueprint $table) {
            SyncColumns::add($table);
            $table->uuid('chore_id')->index();
            $table->uuid('member_id')->nullable();
            $table->date('done_on');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('chore_completions');
        Schema::dropIfExists('chores');
    }
};
