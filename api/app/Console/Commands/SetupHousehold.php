<?php

namespace App\Console\Commands;

use App\Models\Household;
use App\Models\User;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

/**
 * One-time setup: creates the household and its owner account. HomeSync has
 * no public sign-up; the owner adds everyone else from the app.
 */
class SetupHousehold extends Command
{
    protected $signature = 'homesync:setup
        {--household= : Household name}
        {--name= : Owner name}
        {--email= : Owner email}
        {--password= : Owner password (asked if left out)}';

    protected $description = 'Create the household and its owner account';

    public function handle(): int
    {
        if (Household::exists()) {
            $this->error('A household already exists. HomeSync serves one household.');

            return self::FAILURE;
        }

        $householdName = $this->option('household') ?: $this->ask('Household name', 'Our home');
        $name = $this->option('name') ?: $this->ask('Owner name');
        $email = $this->option('email') ?: $this->ask('Owner email');
        $password = $this->option('password') ?: $this->secret('Owner password (min 8 characters)');

        if (! $name || ! filter_var($email, FILTER_VALIDATE_EMAIL) || strlen((string) $password) < 8) {
            $this->error('Name, a valid email and a password of at least 8 characters are required.');

            return self::FAILURE;
        }

        DB::transaction(function () use ($householdName, $name, $email, $password) {
            $user = User::create(['name' => $name, 'email' => $email, 'password' => Hash::make($password)]);
            $household = Household::create(['id' => (string) Str::uuid7(), 'name' => $householdName]);
            $now = now();
            DB::table('members')->insert([
                'id' => (string) Str::uuid7(),
                'household_id' => $household->id,
                'name' => $name,
                'role' => 'owner',
                'user_id' => $user->id,
                'created_at' => $now,
                'updated_at' => $now,
            ]);
        });

        $this->info("Household \"$householdName\" is ready. Sign in on the app as $email.");

        return self::SUCCESS;
    }
}
