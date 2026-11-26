<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * A household member. Also a synced entity (see config/homesync.php), so its
 * sync columns are written by SyncService; this model is for auth and setup.
 */
class Member extends Model
{
    use HasUuids;

    public const ROLES = ['owner', 'adult', 'teen', 'child', 'helper', 'viewer'];

    protected $fillable = ['id', 'household_id', 'name', 'role', 'color', 'pin_hash', 'user_id'];

    protected $hidden = ['pin_hash'];

    public function household(): BelongsTo
    {
        return $this->belongsTo(Household::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function isAdult(): bool
    {
        return in_array($this->role, ['owner', 'adult'], true);
    }
}
