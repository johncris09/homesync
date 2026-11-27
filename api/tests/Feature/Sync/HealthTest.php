<?php

namespace Tests\Feature\Sync;

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class HealthTest extends SyncTestCase
{
    public function test_profiles_are_for_adults_and_concurrent_edits_go_to_conflicts(): void
    {
        $owner = $this->device('owner');
        $adult = $this->device('adult');
        $helper = $this->device('helper');
        $id = (string) Str::uuid7();
        $profile = ['member_id' => $owner->member_id, 'sealed' => 'AQ-first'];

        $this->assertSame('forbidden', $this->push($helper, [$this->op('health_profiles', (string) Str::uuid7(), 'insert', $profile, $this->hlc(1))])->json('results.0.error'));
        $this->assertSame(['applied'], $this->statuses($this->push($owner, [$this->op('health_profiles', $id, 'insert', $profile, $this->hlc(2))])));
        $base = $this->latest($owner, $id)['server_version'];

        $this->push($adult, [$this->op('health_profiles', $id, 'update', ['sealed' => 'AQ-adult'], $this->hlc(3, 0, 'bbbbbbbb'), $base)]);
        $res = $this->push($owner, [$this->op('health_profiles', $id, 'update', ['sealed' => 'AQ-owner'], $this->hlc(4), $base)]);
        $this->assertSame('merged', $res->json('results.0.status'), 'never auto-merged');
        $this->assertSame(1, DB::table('conflicts')->where('entity', 'health_profiles')->where('entity_id', $id)->count());
        $this->assertEmpty(collect($this->pull($helper)->json('changes'))->where('entity', 'health_profiles')->all());
    }

    public function test_doses_lower_the_stock_and_the_same_dose_twice_is_recorded_once(): void
    {
        $owner = $this->device('owner');
        $helper = $this->device('helper');
        $viewer = $this->device('viewer');
        $medId = (string) Str::uuid7();
        $med = ['name' => 'Losartan', 'strength' => '50mg', 'member_id' => $owner->member_id, 'times' => '08:00,20:00', 'dose_qty' => 1, 'stock' => 30, 'min_stock' => 7, 'unit' => 'tablet'];
        $this->assertSame(['applied'], $this->statuses($this->push($owner, [$this->op('medicines', $medId, 'insert', $med, $this->hlc(1))])));

        $doseId = (string) Str::uuid7(); // derived on the device from medicine/day/slot
        $dose = fn ($d, int $t) => [
            $this->op('med_doses', $doseId, 'insert', ['medicine_id' => $medId, 'member_id' => $owner->member_id, 'given_by' => $d->member_id, 'taken_on' => '2026-11-28', 'slot' => '08:00', 'taken_at' => '2026-11-28T00:05:00Z'], $this->hlc($t)),
            $this->op('medicines', $medId, 'increment', ['stock' => -1], $this->hlc($t)),
        ];
        $this->assertSame(['applied', 'applied'], $this->statuses($this->push($helper, $dose($helper, 2))));
        $this->assertSame(['merged', 'applied'], $this->statuses($this->push($owner, $dose($owner, 3))));
        $this->assertSame(1, DB::table('med_doses')->where('medicine_id', $medId)->count());
        $this->assertSame((string) $helper->member_id, DB::table('med_doses')->value('given_by'), 'the first one stays');

        $this->assertSame('not_counter', $this->push($helper, [$this->op('medicines', $medId, 'update', ['stock' => 99], $this->hlc(4), 1)])->json('results.0.error'));
        $this->assertSame('forbidden', $this->push($viewer, [$this->op('med_doses', (string) Str::uuid7(), 'insert', ['medicine_id' => $medId, 'taken_on' => '2026-11-28'], $this->hlc(5))])->json('results.0.error'));
        $this->assertEquals(28, (float) $this->latest($viewer, $medId)['stock'], 'viewers read medicines');
    }

    public function test_adults_manage_checkups_and_everyone_reads_them(): void
    {
        $owner = $this->device('owner');
        $teen = $this->device('teen');
        $checkup = ['member_id' => $owner->member_id, 'kind' => 'vaccine', 'title' => 'Flu vaccine', 'due_on' => '2026-12-03', 'due_time' => '09:30', 'place' => 'Health center'];

        $this->assertSame('forbidden', $this->push($teen, [$this->op('checkups', (string) Str::uuid7(), 'insert', $checkup, $this->hlc(1))])->json('results.0.error'));
        $id = (string) Str::uuid7();
        $this->assertSame(['applied'], $this->statuses($this->push($owner, [$this->op('checkups', $id, 'insert', $checkup, $this->hlc(2))])));
        $this->assertSame('Flu vaccine', $this->latest($teen, $id)['title']);
    }
}
