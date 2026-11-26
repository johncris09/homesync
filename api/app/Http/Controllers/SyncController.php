<?php

namespace App\Http\Controllers;

use App\Models\Device;
use App\Sync\SyncService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SyncController extends Controller
{
    public function __construct(private readonly SyncService $sync) {}

    public function push(Request $request): JsonResponse
    {
        $max = (int) config('homesync.push_max_ops');
        $data = $request->validate([
            'ops' => ['present', 'array', "max:$max"],
            'ops.*' => ['array'],
        ]);

        /** @var Device $device */
        $device = $request->user();

        return response()->json([
            'server_time_ms' => SyncService::serverTimeMs(),
            'results' => $this->sync->push($device, array_values($data['ops'])),
        ]);
    }

    public function pull(Request $request): JsonResponse
    {
        $max = (int) config('homesync.pull_max_limit');
        $data = $request->validate([
            'cursor' => ['sometimes', 'integer', 'min:0'],
            'limit' => ['sometimes', 'integer', 'min:1', "max:$max"],
        ]);

        /** @var Device $device */
        $device = $request->user();

        return response()->json([
            'server_time_ms' => SyncService::serverTimeMs(),
        ] + $this->sync->pull($device, (int) ($data['cursor'] ?? 0), (int) ($data['limit'] ?? $max)));
    }

    public function bootstrap(Request $request): JsonResponse
    {
        /** @var Device $device */
        $device = $request->user();

        return response()->json([
            'server_time_ms' => SyncService::serverTimeMs(),
        ] + $this->sync->bootstrap($device));
    }
}
