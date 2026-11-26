<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Household extends Model
{
    use HasUuids;

    protected $fillable = ['id', 'name'];

    public function members(): HasMany
    {
        return $this->hasMany(Member::class);
    }

    public function devices(): HasMany
    {
        return $this->hasMany(Device::class);
    }
}
