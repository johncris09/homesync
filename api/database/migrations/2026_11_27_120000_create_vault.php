<?php

use App\Support\SyncColumns;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/*
 * Document Vault (Phase 2). Everything secret is encrypted on the device
 * with the household vault key before it is pushed (docs/vault.md); the hub
 * stores ciphertext only. vault_keys holds that key wrapped twice (by the
 * vault passphrase and by the owner's recovery code), one row per household.
 *
 * field_clocks.seq records which change set each field, so a never
 * auto-merged entity can tell a real concurrent edit from a stale base
 * version (sync-protocol §6).
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('vault_keys', function (Blueprint $table) {
            SyncColumns::add($table);
            $table->text('passphrase_wrap');
            $table->string('kdf_salt', 64);
            $table->unsignedInteger('kdf_iterations');
            $table->text('recovery_wrap');
            $table->string('recovery_salt', 64);
            $table->uuid('created_by')->nullable();
        });

        Schema::create('vault_items', function (Blueprint $table) {
            SyncColumns::add($table);
            $table->string('kind', 16);
            $table->uuid('member_id')->nullable();
            $table->date('expires_on')->nullable();
            $table->mediumText('sealed');
            $table->uuid('created_by')->nullable();
        });

        Schema::create('vault_files', function (Blueprint $table) {
            SyncColumns::add($table);
            $table->uuid('item_id')->index();
            $table->char('sha256', 64)->index();
            $table->unsignedBigInteger('size');
            $table->text('key_wrap');
            $table->text('sealed');
            $table->integer('position')->default(0);
        });

        Schema::table('field_clocks', function (Blueprint $table) {
            $table->unsignedBigInteger('seq')->nullable();
        });
    }

    public function down(): void
    {
        Schema::table('field_clocks', function (Blueprint $table) {
            $table->dropColumn('seq');
        });
        Schema::dropIfExists('vault_files');
        Schema::dropIfExists('vault_items');
        Schema::dropIfExists('vault_keys');
    }
};
