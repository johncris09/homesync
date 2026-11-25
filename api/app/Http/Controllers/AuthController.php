<?php

namespace App\Http\Controllers;

use App\Models\Device;
use App\Models\Member;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    /** Email sign-in. Creates a Device for this install and returns its token. */
    public function login(Request $request): JsonResponse
    {
        $data = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
            'device_id' => ['required', 'uuid'],
            'device_name' => ['required', 'string', 'max:100'],
            'platform' => ['required', 'in:android,web'],
            'is_shared' => ['sometimes', 'boolean'],
        ]);

        $user = User::where('email', $data['email'])->first();
        if (! $user || ! Hash::check($data['password'], $user->password)) {
            throw ValidationException::withMessages(['email' => 'Email or password is incorrect.']);
        }

        $member = Member::where('user_id', $user->id)->first();
        if (! $member) {
            throw ValidationException::withMessages(['email' => 'This account is not a member of a household yet.']);
        }

        $device = Device::updateOrCreate(['id' => strtolower($data['device_id'])], [
            'household_id' => $member->household_id,
            'member_id' => $member->id,
            'name' => $data['device_name'],
            'platform' => $data['platform'],
            'is_shared' => (bool) ($data['is_shared'] ?? false),
            'revoked_at' => null,
        ]);

        return $this->issued($device, $member);
    }

    /**
     * PIN sign-in on the shared household tablet. The tablet is already signed
     * in by an adult; this issues a token for the chosen member's profile.
     */
    public function pin(Request $request): JsonResponse
    {
        /** @var Device $tablet */
        $tablet = $request->user();
        $data = $request->validate([
            'member_id' => ['required', 'uuid'],
            'pin' => ['required', 'digits:4'],
            'device_id' => ['required', 'uuid'],
        ]);

        if (! $tablet->is_shared) {
            abort(403, 'PIN profiles work only on a device set up as the shared household tablet.');
        }

        $member = Member::where('id', strtolower($data['member_id']))
            ->where('household_id', $tablet->household_id)->first();
        if (! $member || ! $member->pin_hash || ! Hash::check($data['pin'], $member->pin_hash)) {
            throw ValidationException::withMessages(['pin' => 'That PIN is not right.']);
        }

        $device = Device::updateOrCreate(['id' => strtolower($data['device_id'])], [
            'household_id' => $tablet->household_id,
            'member_id' => $member->id,
            'name' => $tablet->name.' ('.$member->name.')',
            'platform' => $tablet->platform,
            'is_shared' => true,
            'revoked_at' => null,
        ]);

        return $this->issued($device, $member);
    }

    public function me(Request $request): JsonResponse
    {
        /** @var Device $device */
        $device = $request->user();

        return response()->json([
            'device' => $device->only(['id', 'name', 'platform', 'is_shared']),
            'member' => $device->member->only(['id', 'name', 'role', 'color']),
            'household' => $device->household->only(['id', 'name']),
        ]);
    }

    /** Signs this device out and revokes its token. */
    public function logout(Request $request): JsonResponse
    {
        /** @var Device $device */
        $device = $request->user();
        $device->currentAccessToken()->delete();
        $device->forceFill(['revoked_at' => now()])->save();

        return response()->json(['signed_out' => true]);
    }

    private function issued(Device $device, Member $member): JsonResponse
    {
        $device->tokens()->delete();
        $token = $device->createToken('device')->plainTextToken;

        return response()->json([
            'token' => $token,
            'device' => $device->only(['id', 'name', 'platform', 'is_shared']),
            'member' => $member->only(['id', 'name', 'role', 'color']),
            'household' => $member->household->only(['id', 'name']),
        ]);
    }
}
