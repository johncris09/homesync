<?php

namespace App\Http\Controllers;

use App\Files\FileStore;
use App\Models\Device;
use App\Sync\EntityRegistry;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Symfony\Component\HttpFoundation\BinaryFileResponse;

/**
 * Files named by their SHA-256 (sync-protocol §7): encrypted vault files
 * (the hub never sees plaintext) and plain inventory photos. A file is
 * served to a member who can read a record that uses it.
 */
class FileController extends Controller
{
    public function __construct(private readonly FileStore $files, private readonly EntityRegistry $registry) {}

    /** Which chunks the hub already has, so an interrupted upload resumes. */
    public function status(Request $request, string $sha256): JsonResponse
    {
        $device = $this->uploader($request);
        $complete = $this->files->exists($device->household_id, $sha256);

        return response()->json([
            'complete' => $complete,
            'chunks' => $complete ? [] : $this->files->chunks($device->household_id, $sha256),
        ]);
    }

    public function chunk(Request $request, string $sha256, int $index): JsonResponse
    {
        $device = $this->uploader($request);
        $chunkBytes = (int) config('homesync.file_chunk_bytes');
        $maxChunks = $this->maxChunks();
        $bytes = $request->getContent();

        if ($index >= $maxChunks || $bytes === '' || strlen($bytes) > $chunkBytes) {
            return response()->json([
                'error' => 'validation',
                'details' => ['chunk' => "1 to $chunkBytes bytes, index below $maxChunks"],
            ], 422);
        }
        if (! $this->files->exists($device->household_id, $sha256)) {
            $this->files->putChunk($device->household_id, $sha256, $index, $bytes);
        }

        return response()->json(['received' => $index]);
    }

    public function complete(Request $request, string $sha256): JsonResponse
    {
        $device = $this->uploader($request);
        $data = $request->validate(['chunks' => ['required', 'integer', 'min:1', 'max:'.$this->maxChunks()]]);

        $size = $this->files->complete($device->household_id, $sha256, (int) $data['chunks'], (int) config('homesync.file_max_bytes'));
        if ($size === null) {
            return response()->json([
                'error' => 'validation',
                'details' => ['file' => 'missing chunks, too big, or the hash does not match'],
            ], 422);
        }

        return response()->json(['sha256' => $sha256, 'size' => $size]);
    }

    /** Records that point at a file: entity => column holding the SHA-256. */
    private const SOURCES = [
        'vault_files' => 'sha256',
        'inventory_items' => 'photo_sha256',
    ];

    /** Streams a file that a record this member can read uses. */
    public function show(Request $request, string $sha256): BinaryFileResponse|JsonResponse
    {
        /** @var Device $device */
        $device = $request->user();
        $role = $device->member->role;
        $readable = false;
        $usedElsewhere = false;
        foreach (self::SOURCES as $entity => $column) {
            $used = DB::table($entity)
                ->where('household_id', $device->household_id)
                ->where($column, $sha256)
                ->whereNull('deleted_at')
                ->exists();
            if ($this->registry->canRead($entity, $role)) {
                $readable = $readable || $used;
            } else {
                $usedElsewhere = $usedElsewhere || $used;
            }
        }
        if (! $readable && ($usedElsewhere || ! $this->canReadAny($role))) {
            return response()->json(['error' => 'forbidden'], 403);
        }
        if (! $readable || ! $this->files->exists($device->household_id, $sha256)) {
            return response()->json(['error' => 'not_found'], 404);
        }

        return response()->file($this->files->absolutePath($device->household_id, $sha256), [
            'Content-Type' => 'application/octet-stream',
            'Cache-Control' => 'private, max-age=31536000, immutable',
        ]);
    }

    private function maxChunks(): int
    {
        return (int) ceil(config('homesync.file_max_bytes') / config('homesync.file_chunk_bytes'));
    }

    private function canReadAny(string $role): bool
    {
        foreach (array_keys(self::SOURCES) as $entity) {
            if ($this->registry->canRead($entity, $role)) {
                return true;
            }
        }

        return false;
    }

    /** Uploads: a member who can write any record that holds a file. */
    private function uploader(Request $request): Device
    {
        /** @var Device $device */
        $device = $request->user();
        $role = $device->member->role;
        $allowed = false;
        foreach (array_keys(self::SOURCES) as $entity) {
            $allowed = $allowed || $this->registry->canWrite($entity, $role);
        }
        abort_unless($allowed, 403, 'forbidden');

        return $device;
    }
}
