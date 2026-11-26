<?php

use App\Http\Middleware\SendHubVersion;
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        // First in the group, so it also wraps the auth check (moved up by middleware priority).
        $middleware->api(prepend: [SendHubVersion::class]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        //
    })->create();
