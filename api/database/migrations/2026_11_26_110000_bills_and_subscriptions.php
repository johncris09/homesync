<?php

use App\Support\SyncColumns;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/*
 * Bills & Subscriptions (Phase 1). A bill row is one due date; a monthly bill
 * links its occurrences by series_id, and the next one has an id derived from
 * the series and due date (sync-protocol §2.1). Paying posts to the ledger.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('bills', function (Blueprint $table) {
            $table->string('category', 32)->nullable();
            $table->string('repeat', 16)->nullable();
            $table->uuid('series_id')->nullable()->index();
        });

        Schema::create('subscriptions', function (Blueprint $table) {
            SyncColumns::add($table);
            $table->string('name');
            $table->bigInteger('price_minor')->default(0);
            $table->string('currency', 3)->default('PHP');
            $table->string('cycle', 16)->default('monthly');
            $table->date('next_due_on')->nullable();
            $table->string('category', 32)->nullable();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('subscriptions');
        Schema::table('bills', function (Blueprint $table) {
            $table->dropIndex(['series_id']);
            $table->dropColumn(['category', 'repeat', 'series_id']);
        });
    }
};
