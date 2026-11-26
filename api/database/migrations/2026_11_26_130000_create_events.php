<?php

use App\Support\SyncColumns;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/*
 * Calendar events (Phase 1). An event is on a local date, all day or at a
 * local time, and may repeat weekly, monthly or yearly (birthdays). Times are
 * kept as "HH:MM" text so time zones never move them.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('events', function (Blueprint $table) {
            SyncColumns::add($table);
            $table->string('title');
            $table->date('starts_on');
            $table->string('start_time', 5)->nullable();
            $table->string('end_time', 5)->nullable();
            $table->string('repeat', 16)->default('none');
            $table->uuid('member_id')->nullable();
            $table->string('location')->nullable();
            $table->text('note')->nullable();
            $table->uuid('created_by')->nullable();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('events');
    }
};
