<?php

use Illuminate\Support\Facades\Schedule;

/*
| Hostinger shared hosting has no long-running workers: one cron entry runs
| `php artisan schedule:run` every minute (docs/deploy.md).
*/

// Drain the database queue, then exit.
Schedule::command('queue:work --stop-when-empty --max-time=50')
    ->everyMinute()
    ->withoutOverlapping();
