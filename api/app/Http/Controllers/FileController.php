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
 * Encrypted vault files (sync-protocol §7). The hub never sees plaintext:
 * devices encrypt before hashing and uploading, and decrypt after download.
 */
class FileController extends Controller
{
    public function __construct(private readonly FileStore $files, private readonly EntityRegistry $registry) {}

    /** Which chunks the hub already has, so an interrupted upload resumes. */
    public function status(Request $request, string $sha256): JsonResponse
    {
        $device = $this->device($request, write: true);
        $complete = $this->files->exists($device->household_id, $sha256);

        return response()->json([
            'complete' => $complete,
            'chunks' => $complete ? [] : $this->files->chunks($device->household_id, $sha256),
        ]);
    }

    public function chunk(Request $request, string $sha256, int $index): JsonResponse
    {
        $device = $this->device($request, write: true);
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
        $device = $this->device($request, write: true);
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

    /** Streams the ciphertext of a file that a vault record in this household uses. */
    public function show(Request $request, string $sha256): BinaryFileResponse|JsonResponse
    {
        $device = $this->device($request, write: false);
        $known = DB::table('vault_files')
            ->where('household_id', $device->household_id)
            ->where('sha256', $sha256)
            ->whereNull('deleted_at')
            ->exists();
        if (! $known || ! $this->files->exists($device->household_id, $sha256)) {
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

    private function device(Request $request, bool $write): Device
    {
        /** @var Device $device */
        $device = $request->user();
        $role = $device->member->role;
        $allowed = $write
            ? $this->registry->canWrite('vault_files', $role)
            : $this->registry->canRead('vault_files', $role);
        abort_unless($allowed, 403, 'forbidden');

        return $device;
    }
}
