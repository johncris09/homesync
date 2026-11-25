<?php

use App\Support\SyncColumns;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('households', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('name');
            $table->timestamps();
        });

        Schema::create('members', function (Blueprint $table) {
            SyncColumns::add($table);
            $table->string('name');
            $table->string('role', 16);            // owner, adult, teen, child, helper, viewer
            $table->string('color', 16)->nullable();
            $table->string('pin_hash')->nullable(); // bcrypt; checked on the device for offline PIN switching
            $table->foreignId('user_id')->nullable()->constrained()->nullOnDelete();
        });

        Schema::create('devices', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('household_id')->constrained()->cascadeOnDelete();
            $table->foreignUuid('member_id')->constrained('members')->cascadeOnDelete();
            $table->string('name');
            $table->string('platform', 16);         // android, web
            $table->boolean('is_shared')->default(false); // shared household tablet with PIN profiles
            $table->unsignedBigInteger('last_pull_cursor')->default(0);
            $table->timestamp('last_seen_at')->nullable();
            $table->timestamp('revoked_at')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('devices');
        Schema::dropIfExists('members');
        Schema::dropIfExists('households');
    }
};
