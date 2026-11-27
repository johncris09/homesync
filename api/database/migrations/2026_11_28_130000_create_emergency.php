<?php

use App\Support\SyncColumns;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/*
 * Emergency & Disaster Preparedness (Phase 2). Contacts, one plan row per
 * household (meeting points, evacuation centre), go-bag checklists per
 * member, ticks on the built-in hazard checklists, and append-only "I'm
 * safe" / "Need help" check-ins. Everything is on every device, so it all
 * works with no signal.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('emergency_contacts', function (Blueprint $table) {
            SyncColumns::add($table);
            $table->string('name');
            $table->string('kind', 16);
            $table->string('phone', 32);
            $table->text('note')->nullable();
            $table->integer('position')->default(0);
        });

        Schema::create('emergency_plans', function (Blueprint $table) {
            SyncColumns::add($table);
            $table->string('meeting_point')->nullable();
            $table->string('meeting_point_far')->nullable();
            $table->string('evacuation_center')->nullable();
            $table->text('note')->nullable();
        });

        Schema::create('go_bag_items', function (Blueprint $table) {
            SyncColumns::add($table);
            $table->uuid('member_id')->nullable()->index();
            $table->string('name');
            $table->boolean('packed')->default(false);
            $table->date('expires_on')->nullable();
            $table->integer('position')->default(0);
        });

        Schema::create('emergency_checks', function (Blueprint $table) {
            SyncColumns::add($table);
            $table->string('hazard', 16);
            $table->string('item', 32);
            $table->boolean('done')->default(false);
            $table->uuid('done_by')->nullable();
            $table->timestamp('done_at', 3)->nullable();
        });

        Schema::create('safety_checkins', function (Blueprint $table) {
            SyncColumns::add($table);
            $table->uuid('member_id')->index();
            $table->string('status', 8);
            $table->text('note')->nullable();
            $table->timestamp('checked_at', 3);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('safety_checkins');
        Schema::dropIfExists('emergency_checks');
        Schema::dropIfExists('go_bag_items');
        Schema::dropIfExists('emergency_plans');
        Schema::dropIfExists('emergency_contacts');
    }
};
