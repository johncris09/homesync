<?php

namespace App\Models;

use Illuminate\Auth\Authenticatable;
use Illuminate\Contracts\Auth\Authenticatable as AuthenticatableContract;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Laravel\Sanctum\HasApiTokens;

/**
 * One app install acting as one member. Sanctum tokens belong to devices, so
 * `$request->user()` on API routes is the Device, and `->member` is who acts.
 * A shared tablet gets one Device row per PIN profile.
 */
class Device extends Model implements AuthenticatableContract
{
    use Authenticatable, HasApiTokens, HasUuids;

    protected $fillable = [
        'id', 'household_id', 'member_id', 'name', 'platform', 'is_shared',
        'last_pull_cursor', 'last_seen_at', 'revoked_at',
    ];

    protected function casts(): array
    {
        return [
            'is_shared' => 'boolean',
            'last_pull_cursor' => 'integer',
            'last_seen_at' => 'datetime',
            'revoked_at' => 'datetime',
        ];
    }

    /** Devices sign in with tokens only; there is no password or remember-me. */
    public function getRememberTokenName()
    {
        return '';
    }

    public function household(): BelongsTo
    {
        return $this->belongsTo(Household::class);
    }

    public function member(): BelongsTo
    {
        return $this->belongsTo(Member::class);
    }
}
