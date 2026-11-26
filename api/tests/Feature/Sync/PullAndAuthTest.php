<?php

namespace Tests\Feature\Sync;

use App\Models\Device;
use App\Models\Member;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Laravel\Sanctum\Sanctum;

class PullAndAuthTest extends SyncTestCase
{
    public function test_pull_pages_through_changes_with_a_cursor(): void
    {
        $device = $this->device();
        $ops = [];
        foreach (range(1, 5) as $i) {
            $ops[] = $this->op('grocery_items', (string) Str::uuid7(), 'insert', ['name' => "Item $i"], $this->hlc($i));
        }
        $this->push($device, $ops);

        $first = $this->pull($device, 0, 2)->assertOk();
        $this->assertCount(2, $first->json('changes'));
        $this->assertTrue($first->json('has_more'));

        $rest = $this->pull($device, $first->json('cursor'), 10)->assertOk();
        $this->assertCount(3, $rest->json('changes'));
        $this->assertFalse($rest->json('has_more'));
        $this->assertSame('Item 5', $rest->json('changes.2.row.name'));
    }

    public function test_pull_hides_entities_the_role_cannot_read_but_still_advances(): void
    {
        $owner = $this->device('owner');
        $helper = $this->device('helper');
        $this->push($owner, [
            $this->op('bills', (string) Str::uuid7(), 'insert', ['name' => 'Electric', 'amount_minor' => 348000], $this->hlc(1)),
            $this->op('grocery_items', (string) Str::uuid7(), 'insert', ['name' => 'Rice'], $this->hlc(2)),
        ]);

        $res = $this->pull($helper)->assertOk();

        $this->assertSame(['grocery_items'], array_column($res->json('changes'), 'entity'));
        $this->assertSame(2, $res->json('cursor'));
    }

    public function test_bootstrap_returns_readable_tables_and_a_cursor(): void
    {
        $owner = $this->device('owner');
        $helper = $this->device('helper');
        $this->push($owner, [$this->op('bills', (string) Str::uuid7(), 'insert', ['name' => 'Water', 'amount_minor' => 1], $this->hlc(1))]);
        Sanctum::actingAs($helper);

        $res = $this->getJson('/api/sync/bootstrap', ['X-HomeSync-Protocol' => '1'])->assertOk();

        $this->assertArrayNotHasKey('bills', $res->json('entities'));
        $this->assertCount(2, $res->json('entities.members'));
        $this->assertSame(1, $res->json('cursor'));
    }

    public function test_requests_without_a_supported_protocol_get_426(): void
    {
        Sanctum::actingAs($this->device());

        $this->getJson('/api/sync/pull')->assertStatus(426)->assertJson(['min_protocol' => 1]);
        $this->getJson('/api/sync/pull', ['X-HomeSync-Protocol' => '0'])->assertStatus(426);
    }

    public function test_email_login_creates_a_device_token(): void
    {
        $user = User::factory()->create(['email' => 'john@example.com', 'password' => Hash::make('secret123')]);
        Member::create(['id' => (string) Str::uuid7(), 'household_id' => $this->household->id, 'name' => 'John', 'role' => 'owner', 'user_id' => $user->id]);
        $deviceId = (string) Str::uuid7();

        $res = $this->postJson('/api/auth/login', [
            'email' => 'john@example.com', 'password' => 'secret123',
            'device_id' => $deviceId, 'device_name' => 'Pixel', 'platform' => 'android',
        ], ['X-HomeSync-Protocol' => '1'])->assertOk();

        $this->assertNotEmpty($res->json('token'));
        $this->assertSame('owner', $res->json('member.role'));
        $this->getJson('/api/auth/me', ['X-HomeSync-Protocol' => '1', 'Authorization' => 'Bearer '.$res->json('token')])
            ->assertOk()->assertJsonPath('device.id', $deviceId);
    }

    public function test_wrong_password_is_refused(): void
    {
        User::factory()->create(['email' => 'john@example.com', 'password' => Hash::make('secret123')]);

        $this->postJson('/api/auth/login', [
            'email' => 'john@example.com', 'password' => 'nope', 'device_id' => (string) Str::uuid7(),
            'device_name' => 'Pixel', 'platform' => 'android',
        ], ['X-HomeSync-Protocol' => '1'])->assertStatus(422)->assertJsonValidationErrors('email');
    }

    public function test_pin_sign_in_on_the_shared_tablet(): void
    {
        $tablet = $this->device('owner');
        $tablet->forceFill(['is_shared' => true, 'name' => 'Kitchen tablet'])->save();
        $miguel = Member::create(['id' => (string) Str::uuid7(), 'household_id' => $this->household->id, 'name' => 'Miguel', 'role' => 'teen', 'pin_hash' => Hash::make('4821')]);
        Sanctum::actingAs($tablet);

        $wrong = $this->postJson('/api/auth/pin', ['member_id' => $miguel->id, 'pin' => '0000', 'device_id' => (string) Str::uuid7()], ['X-HomeSync-Protocol' => '1']);
        $right = $this->postJson('/api/auth/pin', ['member_id' => $miguel->id, 'pin' => '4821', 'device_id' => (string) Str::uuid7()], ['X-HomeSync-Protocol' => '1']);

        $wrong->assertStatus(422);
        $right->assertOk()->assertJsonPath('member.role', 'teen')->assertJsonPath('device.name', 'Kitchen tablet (Miguel)');
    }

    public function test_pin_sign_in_is_refused_on_a_personal_phone(): void
    {
        $phone = $this->device('owner');
        $kid = Member::create(['id' => (string) Str::uuid7(), 'household_id' => $this->household->id, 'name' => 'Bea', 'role' => 'child', 'pin_hash' => Hash::make('1111')]);
        Sanctum::actingAs($phone);

        $this->postJson('/api/auth/pin', ['member_id' => $kid->id, 'pin' => '1111', 'device_id' => (string) Str::uuid7()], ['X-HomeSync-Protocol' => '1'])
            ->assertStatus(403);
    }

    public function test_setup_command_creates_the_household_and_owner_once(): void
    {
        Device::query()->delete();
        Member::query()->delete();
        $this->household->delete();

        $this->artisan('homesync:setup', ['--household' => 'Our home', '--name' => 'John', '--email' => 'john@example.com', '--password' => 'secret123'])
            ->assertSuccessful();
        $this->artisan('homesync:setup', ['--household' => 'Again', '--name' => 'X', '--email' => 'x@example.com', '--password' => 'secret123'])
            ->assertFailed();

        $this->assertDatabaseHas('members', ['name' => 'John', 'role' => 'owner']);
    }
}
