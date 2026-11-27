<?php

namespace Tests\Feature\Sync;

use App\Models\Device;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Laravel\Sanctum\Sanctum;

class VaultTest extends SyncTestCase
{
    private const H = ['X-HomeSync-Protocol' => '1'];

    private function item(array $overrides = []): array
    {
        return $overrides + ['kind' => 'id', 'expires_on' => '2027-03-01', 'sealed' => 'AQ-ciphertext-1'];
    }

    public function test_the_vault_is_for_owner_and_adults_only(): void
    {
        $owner = $this->device('owner');
        $id = (string) Str::uuid7();
        $this->assertSame(['applied'], $this->statuses($this->push($owner, [$this->op('vault_items', $id, 'insert', $this->item(), $this->hlc(1))])));

        $this->assertSame(['applied'], $this->statuses($this->push($this->device('adult'), [
            $this->op('vault_items', (string) Str::uuid7(), 'insert', $this->item(), $this->hlc(2)),
        ])));
        foreach (['teen', 'child', 'helper', 'viewer'] as $role) {
            $device = $this->device($role);
            $res = $this->push($device, [$this->op('vault_items', (string) Str::uuid7(), 'insert', $this->item(), $this->hlc(3))]);
            $this->assertSame('forbidden', $res->json('results.0.error'), $role);
            $this->assertNull($this->latest($device, $id), "$role must not receive vault rows");
        }
        $this->assertNotNull($this->latest($this->device('adult'), $id));
    }

    public function test_only_the_owner_sets_up_the_vault_key(): void
    {
        $key = [
            'passphrase_wrap' => 'AQ-wrap', 'kdf_salt' => 'c2FsdA', 'kdf_iterations' => 600000,
            'recovery_wrap' => 'AQ-rwrap', 'recovery_salt' => 'cnNhbHQ',
        ];
        $res = $this->push($this->device('adult'), [$this->op('vault_keys', (string) Str::uuid7(), 'insert', $key, $this->hlc(1))]);
        $this->assertSame('forbidden', $res->json('results.0.error'));

        $id = (string) Str::uuid7();
        $owner = $this->device('owner');
        $this->assertSame(['applied'], $this->statuses($this->push($owner, [$this->op('vault_keys', $id, 'insert', $key, $this->hlc(2))])));
        $this->assertSame(600000, $this->latest($this->device('adult'), $id)['kdf_iterations']);
    }

    public function test_concurrent_edits_of_a_document_keep_both_versions(): void
    {
        $owner = $this->device('owner');
        $adult = $this->device('adult');
        $id = (string) Str::uuid7();
        $this->push($owner, [$this->op('vault_items', $id, 'insert', $this->item(), $this->hlc(1))]);
        $base = $this->latest($owner, $id)['server_version'];

        // Both edit offline from the same version; the owner's edit is newer
        // but reaches the hub second.
        $this->push($adult, [$this->op('vault_items', $id, 'update', ['sealed' => 'AQ-adult'], $this->hlc(2, 0, 'bbbbbbbb'), $base)]);
        $res = $this->push($owner, [$this->op('vault_items', $id, 'update', ['sealed' => 'AQ-owner'], $this->hlc(3), $base)]);

        $this->assertSame('merged', $res->json('results.0.status'));
        $this->assertNotNull($res->json('results.0.conflict_id'));
        $this->assertSame('AQ-owner', $this->latest($owner, $id)['sealed']);
        $conflict = DB::table('conflicts')->where('entity_id', $id)->sole();
        $this->assertSame('sealed', $conflict->field);
        $this->assertSame('AQ-owner', json_decode($conflict->kept_value));
        $this->assertSame('AQ-adult', json_decode($conflict->lost_value));
        $this->assertSame($adult->member_id, $conflict->lost_by);
    }

    public function test_an_older_concurrent_edit_arriving_late_is_kept_for_review_not_applied(): void
    {
        $owner = $this->device('owner');
        $adult = $this->device('adult');
        $id = (string) Str::uuid7();
        $this->push($owner, [$this->op('vault_items', $id, 'insert', $this->item(), $this->hlc(1))]);
        $base = $this->latest($owner, $id)['server_version'];

        $this->push($owner, [$this->op('vault_items', $id, 'update', ['sealed' => 'AQ-newer'], $this->hlc(5), $base)]);
        $res = $this->push($adult, [$this->op('vault_items', $id, 'update', ['sealed' => 'AQ-older'], $this->hlc(3, 0, 'bbbbbbbb'), $base)]);

        $this->assertSame('merged', $res->json('results.0.status'));
        $this->assertSame('AQ-newer', $this->latest($owner, $id)['sealed']);
        $conflict = DB::table('conflicts')->where('entity_id', $id)->sole();
        $this->assertSame('AQ-older', json_decode($conflict->lost_value));
    }

    public function test_edits_made_after_seeing_the_latest_version_do_not_conflict(): void
    {
        $owner = $this->device('owner');
        $adult = $this->device('adult');
        $id = (string) Str::uuid7();
        $this->push($owner, [$this->op('vault_items', $id, 'insert', $this->item(), $this->hlc(1))]);
        $this->push($owner, [$this->op('vault_items', $id, 'update', ['sealed' => 'AQ-2'], $this->hlc(2), $this->latest($owner, $id)['server_version'])]);

        // The adult pulled the latest version, then edited it.
        $res = $this->push($adult, [$this->op('vault_items', $id, 'update', ['sealed' => 'AQ-3'], $this->hlc(3, 0, 'bbbbbbbb'), $this->latest($adult, $id)['server_version'])]);

        $this->assertSame('applied', $res->json('results.0.status'));
        $this->assertSame('AQ-3', $this->latest($owner, $id)['sealed']);
        $this->assertSame(0, DB::table('conflicts')->count());
    }

    public function test_concurrent_edits_of_different_fields_do_not_conflict(): void
    {
        $owner = $this->device('owner');
        $adult = $this->device('adult');
        $id = (string) Str::uuid7();
        $this->push($owner, [$this->op('vault_items', $id, 'insert', $this->item(), $this->hlc(1))]);
        $base = $this->latest($owner, $id)['server_version'];

        $this->push($owner, [$this->op('vault_items', $id, 'update', ['expires_on' => '2030-01-01'], $this->hlc(2), $base)]);
        $res = $this->push($adult, [$this->op('vault_items', $id, 'update', ['sealed' => 'AQ-new'], $this->hlc(3, 0, 'bbbbbbbb'), $base)]);

        $this->assertSame('applied', $res->json('results.0.status'));
        $row = $this->latest($owner, $id);
        $this->assertSame('2030-01-01', $row['expires_on']);
        $this->assertSame('AQ-new', $row['sealed']);
        $this->assertSame(0, DB::table('conflicts')->count());
    }

    public function test_setting_up_the_vault_on_two_devices_keeps_the_other_key_for_review(): void
    {
        $phone = $this->device('owner');
        $laptop = Device::create([
            'id' => (string) Str::uuid7(), 'household_id' => $this->household->id,
            'member_id' => $phone->member_id, 'name' => 'Laptop', 'platform' => 'web',
        ]);
        $id = (string) Str::uuid7(); // derived from the household on both devices
        $key = fn (string $tag) => [
            'passphrase_wrap' => "AQ-wrap-$tag", 'kdf_salt' => "salt-$tag", 'kdf_iterations' => 600000,
            'recovery_wrap' => "AQ-rwrap-$tag", 'recovery_salt' => "rsalt-$tag",
        ];
        $this->push($phone, [$this->op('vault_keys', $id, 'insert', $key('phone'), $this->hlc(1))]);
        $res = $this->push($laptop, [$this->op('vault_keys', $id, 'insert', $key('laptop'), $this->hlc(2, 0, 'cccccccc'))]);

        $this->assertSame('merged', $res->json('results.0.status'));
        $this->assertSame('AQ-wrap-laptop', $this->latest($phone, $id)['passphrase_wrap']);
        $lost = DB::table('conflicts')->where('entity_id', $id)->pluck('lost_value', 'field')->map(fn ($v) => json_decode($v));
        $this->assertSame('AQ-wrap-phone', $lost['passphrase_wrap']);
        $this->assertSame('AQ-rwrap-phone', $lost['recovery_wrap']);
    }

    // ------------------------------------------------------------------ files

    private function upload(Device $device, string $bytes, int $chunkSize = 4): string
    {
        $sha = hash('sha256', $bytes);
        Sanctum::actingAs($device);
        foreach (str_split($bytes, $chunkSize) as $i => $chunk) {
            $this->call('PUT', "/api/files/$sha/chunks/$i", [], [], [], $this->transformHeadersToServerVars(self::H + ['Content-Type' => 'application/octet-stream']), $chunk)
                ->assertOk();
        }
        $this->postJson("/api/files/$sha/complete", ['chunks' => count(str_split($bytes, $chunkSize))], self::H)
            ->assertOk()->assertJson(['size' => strlen($bytes)]);

        return $sha;
    }

    public function test_an_encrypted_file_is_uploaded_in_chunks_and_downloaded_by_adults(): void
    {
        Storage::fake('local');
        $owner = $this->device('owner');
        $bytes = random_bytes(37);
        $sha = $this->upload($owner, $bytes);

        // Not served until a vault record uses it.
        Sanctum::actingAs($owner);
        $this->get("/api/files/$sha", self::H)->assertNotFound();

        $this->push($owner, [$this->op('vault_files', (string) Str::uuid7(), 'insert', [
            'item_id' => (string) Str::uuid7(), 'sha256' => $sha, 'size' => strlen($bytes),
            'key_wrap' => 'AQ-k', 'sealed' => 'AQ-s', 'position' => 0,
        ], $this->hlc(1))]);

        Sanctum::actingAs($this->device('adult'));
        $res = $this->get("/api/files/$sha", self::H)->assertOk();
        $this->assertSame($bytes, $res->streamedContent());

        Sanctum::actingAs($this->device('helper'));
        $this->get("/api/files/$sha", self::H)->assertForbidden();
        $this->getJson("/api/files/$sha/chunks", self::H)->assertForbidden();
    }

    public function test_an_interrupted_upload_resumes_and_a_wrong_hash_is_refused(): void
    {
        Storage::fake('local');
        $owner = $this->device('owner');
        $bytes = 'abcdefghij';
        $sha = hash('sha256', $bytes);
        Sanctum::actingAs($owner);
        $server = $this->transformHeadersToServerVars(self::H + ['Content-Type' => 'application/octet-stream']);

        $this->call('PUT', "/api/files/$sha/chunks/0", [], [], [], $server, 'abcde')->assertOk();
        $this->getJson("/api/files/$sha/chunks", self::H)->assertExactJson(['complete' => false, 'chunks' => [0]]);
        $this->postJson("/api/files/$sha/complete", ['chunks' => 2], self::H)->assertStatus(422);

        $this->call('PUT', "/api/files/$sha/chunks/1", [], [], [], $server, 'fghij')->assertOk();
        $this->postJson("/api/files/$sha/complete", ['chunks' => 2], self::H)->assertOk();
        $this->getJson("/api/files/$sha/chunks", self::H)->assertExactJson(['complete' => true, 'chunks' => []]);

        $wrong = str_repeat('0', 64);
        $this->call('PUT', "/api/files/$wrong/chunks/0", [], [], [], $server, 'tampered')->assertOk();
        $this->postJson("/api/files/$wrong/complete", ['chunks' => 1], self::H)->assertStatus(422);
        $this->getJson("/api/files/$wrong/chunks", self::H)->assertExactJson(['complete' => false, 'chunks' => []]);
    }

    public function test_oversized_chunks_are_refused(): void
    {
        Storage::fake('local');
        config(['homesync.file_chunk_bytes' => 4]);
        Sanctum::actingAs($this->device('owner'));
        $sha = hash('sha256', 'x');
        $this->call('PUT', "/api/files/$sha/chunks/0", [], [], [], $this->transformHeadersToServerVars(self::H), 'too long')
            ->assertStatus(422);
    }
}
