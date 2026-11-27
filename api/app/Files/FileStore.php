<?php

namespace App\Files;

use Illuminate\Contracts\Filesystem\Filesystem;
use Illuminate\Support\Facades\Storage;
use RuntimeException;

/**
 * Encrypted vault files on the hub's private local disk
 * (storage/app/private), named by the SHA-256 of their ciphertext.
 *
 * Works on plain shared hosting: no symlinks (storage:link), no exec(), no
 * object storage. Files arrive in numbered chunks (sync-protocol §7) and are
 * joined and checked against their hash on completion; downloads are
 * streamed through PHP after an auth check.
 */
class FileStore
{
    private function disk(): Filesystem
    {
        return Storage::disk('local');
    }

    public function path(string $householdId, string $sha256): string
    {
        return "vault/$householdId/".substr($sha256, 0, 2)."/$sha256";
    }

    private function chunkDir(string $householdId, string $sha256): string
    {
        return "vault-uploads/$householdId/$sha256";
    }

    public function exists(string $householdId, string $sha256): bool
    {
        return $this->disk()->exists($this->path($householdId, $sha256));
    }

    /** @return list<int> chunk indexes already received, in order */
    public function chunks(string $householdId, string $sha256): array
    {
        $indexes = [];
        foreach ($this->disk()->files($this->chunkDir($householdId, $sha256)) as $file) {
            $name = basename($file);
            if (ctype_digit($name)) {
                $indexes[] = (int) $name;
            }
        }
        sort($indexes);

        return $indexes;
    }

    public function putChunk(string $householdId, string $sha256, int $index, string $bytes): void
    {
        $this->disk()->put($this->chunkDir($householdId, $sha256)."/$index", $bytes);
    }

    /**
     * Joins chunks 0..$count-1 and keeps the result if its hash matches.
     *
     * @return int|null the file size, or null when chunks are missing, the
     *                  file is too big or the hash does not match (the
     *                  chunks are then discarded)
     */
    public function complete(string $householdId, string $sha256, int $count, int $maxBytes): ?int
    {
        if ($this->exists($householdId, $sha256)) {
            return (int) $this->disk()->size($this->path($householdId, $sha256));
        }
        $dir = $this->chunkDir($householdId, $sha256);
        $have = $this->chunks($householdId, $sha256);
        if ($have !== range(0, $count - 1)) {
            return null;
        }

        $final = $this->path($householdId, $sha256);
        $tmp = "$final.part";
        $this->disk()->makeDirectory(dirname($final));
        $out = fopen($this->disk()->path($tmp), 'wb');
        if ($out === false) {
            throw new RuntimeException('cannot write vault file');
        }
        $hash = hash_init('sha256');
        $size = 0;
        try {
            foreach ($have as $index) {
                $bytes = (string) $this->disk()->get("$dir/$index");
                $size += strlen($bytes);
                if ($size > $maxBytes) {
                    break;
                }
                hash_update($hash, $bytes);
                fwrite($out, $bytes);
            }
        } finally {
            fclose($out);
        }

        $this->disk()->deleteDirectory($dir);
        if ($size > $maxBytes || ! hash_equals($sha256, hash_final($hash))) {
            $this->disk()->delete($tmp);

            return null;
        }
        $this->disk()->move($tmp, $final);

        return $size;
    }

    public function absolutePath(string $householdId, string $sha256): string
    {
        return $this->disk()->path($this->path($householdId, $sha256));
    }
}
