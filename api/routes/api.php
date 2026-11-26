<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\SyncController;
use App\Http\Middleware\EnsureProtocolVersion;
use Illuminate\Support\Facades\Route;

Route::middleware(EnsureProtocolVersion::class)->group(function () {
    Route::post('/auth/login', [AuthController::class, 'login'])->middleware('throttle:10,1');

    Route::middleware('auth:sanctum')->group(function () {
        Route::post('/auth/pin', [AuthController::class, 'pin'])->middleware('throttle:20,1');
        Route::get('/auth/me', [AuthController::class, 'me']);
        Route::post('/auth/logout', [AuthController::class, 'logout']);

        Route::post('/sync/push', [SyncController::class, 'push'])->middleware('throttle:120,1');
        Route::get('/sync/pull', [SyncController::class, 'pull'])->middleware('throttle:120,1');
        Route::get('/sync/bootstrap', [SyncController::class, 'bootstrap'])->middleware('throttle:10,1');
    });
});
