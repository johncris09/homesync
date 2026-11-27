<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/*
 * Calendar event colours: color is a palette name the app knows (ube, dagat,
 * dahon, narra, rosas, tubig); null = the default look.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('events', function (Blueprint $table) {
            $table->string('color', 16)->nullable()->after('repeat');
        });
    }

    public function down(): void
    {
        Schema::table('events', function (Blueprint $table) {
            $table->dropColumn('color');
        });
    }
};
