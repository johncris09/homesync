<?php

use App\Support\SyncColumns;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/*
 * Monthly budget per spending category (Budget module, Phase 1). One row per
 * household and category; the app derives the id from both, so two devices
 * setting the same category offline update one row (sync-protocol §2.1).
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('budgets', function (Blueprint $table) {
            SyncColumns::add($table);
            $table->string('category', 32);
            $table->bigInteger('limit_minor')->default(0);
            $table->string('currency', 3)->default('PHP');
            $table->index(['household_id', 'category']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('budgets');
    }
};
