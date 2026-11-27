<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\FileController;
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

        // Encrypted vault files (sync-protocol §7), named by their SHA-256.
        Route::where(['sha256' => '[0-9a-f]{64}', 'index' => '[0-9]+'])->group(function () {
            Route::get('/files/{sha256}/chunks', [FileController::class, 'status']);
            Route::put('/files/{sha256}/chunks/{index}', [FileController::class, 'chunk'])->middleware('throttle:600,1');
            Route::post('/files/{sha256}/complete', [FileController::class, 'complete']);
            Route::get('/files/{sha256}', [FileController::class, 'show'])->middleware('throttle:300,1');
        });
    });
});
