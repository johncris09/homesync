<?php

use App\Support\SyncColumns;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/*
 * Debts & Loans (Phase 2). One debts row per loan, credit card, pawn ticket or
 * money lent; every payment, interest-only payment and added charge is an
 * append-only debt_payments row, and the balance is worked out from them on
 * the device (sync-protocol §6).
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('debts', function (Blueprint $table) {
            SyncColumns::add($table);
            $table->string('kind', 16);
            $table->string('name');
            $table->string('counterparty')->nullable();
            $table->string('reference')->nullable();
            $table->bigInteger('principal_minor')->default(0);
            $table->string('currency', 3)->default('PHP');
            $table->bigInteger('installment_minor')->nullable();
            $table->date('next_due_on')->nullable();
            $table->string('repeat', 16)->nullable();
            $table->date('started_on')->nullable();
            $table->boolean('is_closed')->default(false);
            $table->timestamp('closed_at')->nullable();
            $table->uuid('closed_by')->nullable();
            $table->text('note')->nullable();
        });

        Schema::create('debt_payments', function (Blueprint $table) {
            SyncColumns::add($table);
            $table->uuid('debt_id')->index();
            $table->string('kind', 16);
            $table->bigInteger('amount_minor');
            $table->string('currency', 3)->default('PHP');
            $table->date('paid_on');
            $table->uuid('member_id')->nullable();
            $table->text('note')->nullable();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('debt_payments');
        Schema::dropIfExists('debts');
    }
};
