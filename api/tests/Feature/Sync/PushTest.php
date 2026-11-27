<?php

namespace Tests\Feature\Sync;

use App\Models\Household;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class PushTest extends SyncTestCase
{
    public function test_insert_is_applied_and_pulled_as_a_full_row(): void
    {
        $device = $this->device();
        $id = (string) Str::uuid7();

        $res = $this->push($device, [$this->op('grocery_items', $id, 'insert', ['name' => 'Rice', 'quantity_text' => '5 kg'], $this->hlc(1))]);

        $this->assertSame(['applied'], $this->statuses($res));
        $row = $this->latest($device, $id);
        $this->assertSame('Rice', $row['name']);
        $this->assertFalse($row['is_bought']);
        $this->assertSame($this->household->id, $row['household_id']);
        $this->assertSame($res->json('results.0.server_version'), $row['server_version']);
    }

    public function test_resending_the_same_op_is_a_duplicate_and_applies_once(): void
    {
        $device = $this->device();
        $id = (string) Str::uuid7();
        $op = $this->op('grocery_items', $id, 'insert', ['name' => 'Eggs'], $this->hlc(1));

        $first = $this->push($device, [$op]);
        $second = $this->push($device, [$op]);

        $this->assertSame(['duplicate'], $this->statuses($second));
        $this->assertSame($first->json('results.0.server_version'), $second->json('results.0.server_version'));
        $this->assertSame(1, DB::table('change_log')->count());
    }

    public function test_edits_to_different_fields_both_survive(): void
    {
        $ana = $this->device('adult');
        $ben = $this->device('adult');
        $id = (string) Str::uuid7();
        $this->push($ana, [$this->op('grocery_items', $id, 'insert', ['name' => 'Oil'], $this->hlc(1))]);

        $this->push($ana, [$this->op('grocery_items', $id, 'update', ['name' => 'Cooking oil'], $this->hlc(3))]);
        $res = $this->push($ben, [$this->op('grocery_items', $id, 'update', ['store' => 'Supermarket'], $this->hlc(2, 0, 'bbbbbbbb'))]);

        $this->assertSame(['applied'], $this->statuses($res));
        $row = $this->latest($ana, $id);
        $this->assertSame('Cooking oil', $row['name']);
        $this->assertSame('Supermarket', $row['store']);
    }

    public function test_an_older_edit_to_the_same_field_loses(): void
    {
        $ana = $this->device('adult');
        $ben = $this->device('adult');
        $id = (string) Str::uuid7();
        $this->push($ana, [$this->op('grocery_items', $id, 'insert', ['name' => 'Milk'], $this->hlc(1))]);
        $this->push($ana, [$this->op('grocery_items', $id, 'update', ['name' => 'Fresh milk'], $this->hlc(5))]);

        $res = $this->push($ben, [$this->op('grocery_items', $id, 'update', ['name' => 'Soy milk'], $this->hlc(4, 0, 'bbbbbbbb'))]);

        $this->assertSame(['merged'], $this->statuses($res));
        $this->assertSame('Fresh milk', $this->latest($ben, $id)['name']);
    }

    public function test_bought_wins_over_an_unbuy_from_someone_else(): void
    {
        $ana = $this->device('adult');
        $ben = $this->device('adult');
        $id = (string) Str::uuid7();
        $this->push($ana, [$this->op('grocery_items', $id, 'insert', ['name' => 'Tomatoes'], $this->hlc(1))]);
        $this->push($ana, [$this->op('grocery_items', $id, 'update', ['is_bought' => true], $this->hlc(2))]);

        $res = $this->push($ben, [$this->op('grocery_items', $id, 'update', ['is_bought' => false], $this->hlc(3, 0, 'bbbbbbbb'))]);

        $this->assertSame(['merged'], $this->statuses($res));
        $this->assertTrue($this->latest($ana, $id)['is_bought']);
    }

    public function test_clearing_a_bought_item_keeps_it_with_cleared_at_for_history(): void
    {
        $ana = $this->device('adult');
        $id = (string) Str::uuid7();
        $this->push($ana, [$this->op('grocery_items', $id, 'insert', ['name' => 'Eggs'], $this->hlc(1))]);
        $this->push($ana, [$this->op('grocery_items', $id, 'update', ['is_bought' => true, 'bought_at' => '2026-11-26T01:00:00.000Z'], $this->hlc(2))]);

        $res = $this->push($ana, [$this->op('grocery_items', $id, 'update', [
            'bought_at' => '2026-11-24T01:00:00.000Z',
            'cleared_at' => '2026-11-26T10:00:00.000Z',
        ], $this->hlc(3))]);

        $this->assertSame(['applied'], $this->statuses($res));
        $row = $this->latest($ana, $id);
        $this->assertTrue($row['is_bought']);
        $this->assertNull($row['deleted_at']);
        $this->assertStringStartsWith('2026-11-24T01:00:00', $row['bought_at']);
        $this->assertStringStartsWith('2026-11-26T10:00:00', $row['cleared_at']);
    }

    public function test_a_grocery_item_can_carry_a_planned_shopping_day(): void
    {
        $ana = $this->device('adult');
        $id = (string) Str::uuid7();
        $this->push($ana, [$this->op('grocery_items', $id, 'insert', ['name' => 'Rice', 'planned_on' => '2026-11-29'], $this->hlc(1))]);
        $this->assertSame('2026-11-29', substr($this->latest($ana, $id)['planned_on'], 0, 10));

        $res = $this->push($ana, [$this->op('grocery_items', $id, 'update', ['planned_on' => null], $this->hlc(2))]);

        $this->assertSame(['applied'], $this->statuses($res));
        $this->assertNull($this->latest($ana, $id)['planned_on']);
    }

    public function test_the_person_who_marked_bought_can_undo_it(): void
    {
        $ana = $this->device('adult');
        $id = (string) Str::uuid7();
        $this->push($ana, [$this->op('grocery_items', $id, 'insert', ['name' => 'Bread'], $this->hlc(1))]);
        $this->push($ana, [$this->op('grocery_items', $id, 'update', ['is_bought' => true], $this->hlc(2))]);

        $res = $this->push($ana, [$this->op('grocery_items', $id, 'update', ['is_bought' => false], $this->hlc(3))]);

        $this->assertSame(['applied'], $this->statuses($res));
        $this->assertFalse($this->latest($ana, $id)['is_bought']);
    }

    public function test_bought_wins_even_when_it_arrives_late(): void
    {
        $ana = $this->device('adult');
        $ben = $this->device('adult');
        $id = (string) Str::uuid7();
        $this->push($ana, [$this->op('grocery_items', $id, 'insert', ['name' => 'Sugar'], $this->hlc(1))]);
        // Ben edits something newer first, then Ana's older "bought" arrives.
        $this->push($ben, [$this->op('grocery_items', $id, 'update', ['note' => 'brown', 'is_bought' => false], $this->hlc(5, 0, 'bbbbbbbb'))]);

        $res = $this->push($ana, [$this->op('grocery_items', $id, 'update', ['is_bought' => true], $this->hlc(3))]);

        $this->assertSame(['applied'], $this->statuses($res));
        $this->assertTrue($this->latest($ana, $id)['is_bought']);
    }

    public function test_offline_increments_from_two_phones_both_count(): void
    {
        $ana = $this->device('adult');
        $ben = $this->device('helper');
        $id = (string) Str::uuid7();
        $this->push($ana, [$this->op('pantry_items', $id, 'insert', ['name' => 'Rice', 'unit' => 'kg', 'quantity' => 5], $this->hlc(1))]);

        $this->push($ana, [$this->op('pantry_items', $id, 'increment', ['quantity' => -1], $this->hlc(2))]);
        $this->push($ben, [$this->op('pantry_items', $id, 'increment', ['quantity' => -2.5], $this->hlc(2, 0, 'bbbbbbbb'))]);

        $this->assertEquals(1.5, $this->latest($ana, $id)['quantity']);
    }

    public function test_setting_a_counter_directly_is_rejected(): void
    {
        $ana = $this->device('adult');
        $id = (string) Str::uuid7();
        $this->push($ana, [$this->op('pantry_items', $id, 'insert', ['name' => 'Eggs', 'quantity' => 12], $this->hlc(1))]);

        $res = $this->push($ana, [$this->op('pantry_items', $id, 'update', ['quantity' => 6], $this->hlc(2))]);

        $this->assertSame(['rejected'], $this->statuses($res));
        $this->assertSame('not_counter', $res->json('results.0.error'));
    }

    public function test_concurrent_bill_amount_change_is_kept_for_review(): void
    {
        $john = $this->device('owner');
        $ana = $this->device('adult');
        $id = (string) Str::uuid7();
        $insert = $this->push($john, [$this->op('bills', $id, 'insert', ['name' => 'Water', 'amount_minor' => 120000], $this->hlc(1))]);
        $seen = $insert->json('results.0.server_version');

        // Both edit the amount from the same starting point, offline.
        $this->push($john, [$this->op('bills', $id, 'update', ['amount_minor' => 142000], $this->hlc(3), $seen)]);
        $res = $this->push($ana, [$this->op('bills', $id, 'update', ['amount_minor' => 124000], $this->hlc(2, 0, 'bbbbbbbb'), $seen)]);

        $this->assertSame(['merged'], $this->statuses($res));
        $this->assertNotNull($res->json('results.0.conflict_id'));
        $this->assertSame(142000, $this->latest($john, $id)['amount_minor']);
        $conflict = DB::table('conflicts')->first();
        $this->assertSame(124000, json_decode($conflict->lost_value));
        $this->assertSame($ana->member_id, $conflict->lost_by);
    }

    public function test_two_devices_setting_the_same_category_budget_share_one_row(): void
    {
        $john = $this->device('owner');
        $ana = $this->device('adult');
        // Both devices derive the same id for (household, "food") and insert offline.
        $id = '5a1e3c9d-8f2b-5c47-9a10-3b6d2e8f4c71';
        $this->push($john, [$this->op('budgets', $id, 'insert', ['category' => 'food', 'limit_minor' => 800000], $this->hlc(3))]);
        $res = $this->push($ana, [$this->op('budgets', $id, 'insert', ['category' => 'food', 'limit_minor' => 650000], $this->hlc(2, 0, 'bbbbbbbb'))]);

        $this->assertSame(['merged'], $this->statuses($res));
        $this->assertSame(1, DB::table('budgets')->count());
        $this->assertSame(800000, $this->latest($john, $id)['limit_minor']);
        $conflict = DB::table('conflicts')->where('entity', 'budgets')->first();
        $this->assertNotNull($conflict, 'the losing limit is kept for review');
        $this->assertSame(650000, json_decode($conflict->lost_value));
    }

    public function test_same_category_budget_keeps_the_overwritten_limit_when_the_newer_arrives_second(): void
    {
        $john = $this->device('owner');
        $ana = $this->device('adult');
        $id = '5a1e3c9d-8f2b-5c47-9a10-3b6d2e8f4c71';
        $this->push($ana, [$this->op('budgets', $id, 'insert', ['category' => 'food', 'limit_minor' => 650000], $this->hlc(2, 0, 'bbbbbbbb'))]);
        $res = $this->push($john, [$this->op('budgets', $id, 'insert', ['category' => 'food', 'limit_minor' => 800000], $this->hlc(3))]);

        $this->assertSame(['applied'], $this->statuses($res));
        $this->assertNotNull($res->json('results.0.conflict_id'));
        $this->assertSame(800000, $this->latest($john, $id)['limit_minor']);
        $conflict = DB::table('conflicts')->where('entity', 'budgets')->first();
        $this->assertSame(650000, json_decode($conflict->lost_value));
        $this->assertSame($ana->member_id, $conflict->lost_by);
    }

    public function test_budgets_are_for_adults_only(): void
    {
        $helper = $this->device('helper');
        $res = $this->push($helper, [$this->op('budgets', (string) Str::uuid7(), 'insert', ['category' => 'food', 'limit_minor' => 1], $this->hlc(1))]);
        $this->assertSame(['rejected'], $this->statuses($res));
        $this->assertSame('forbidden', $res->json('results.0.error'));
    }

    public function test_the_same_payment_from_two_devices_is_recorded_once(): void
    {
        $john = $this->device('owner');
        $ana = $this->device('adult');
        $txId = '7b2d4f6a-1c3e-5a8b-9d0f-2e4a6c8b0d1f';
        $billId = (string) Str::uuid7();
        $payment = fn (int $amount) => ['amount_minor' => -$amount, 'category' => 'utilities', 'occurred_at' => '2026-11-26T01:00:00Z', 'source_type' => 'bill', 'source_id' => $billId];

        $this->push($ana, [$this->op('transactions', $txId, 'insert', $payment(324000), $this->hlc(2))]);
        $res = $this->push($john, [$this->op('transactions', $txId, 'insert', $payment(330000), $this->hlc(3))]);

        $this->assertSame(['merged'], $this->statuses($res), 'not rejected: the device just pulls the first one');
        $this->assertSame(1, DB::table('transactions')->count());
        $this->assertSame(-324000, $this->latest($john, $txId)['amount_minor']);
    }

    public function test_bills_take_repeat_fields_and_subscriptions_are_for_adults(): void
    {
        $john = $this->device('owner');
        $helper = $this->device('helper');
        $billId = (string) Str::uuid7();

        $res = $this->push($john, [
            $this->op('bills', $billId, 'insert', ['name' => 'Meralco', 'amount_minor' => 324000, 'due_on' => '2026-12-05', 'category' => 'utilities', 'repeat' => 'monthly', 'series_id' => $billId], $this->hlc(1)),
            $this->op('subscriptions', (string) Str::uuid7(), 'insert', ['name' => 'Netflix', 'price_minor' => 54900, 'cycle' => 'monthly', 'next_due_on' => '2026-12-01'], $this->hlc(2)),
        ]);
        $this->assertSame(['applied', 'applied'], $this->statuses($res));
        $this->assertSame('monthly', $this->latest($john, $billId)['repeat']);

        $res = $this->push($helper, [$this->op('subscriptions', (string) Str::uuid7(), 'insert', ['name' => 'Spotify'], $this->hlc(3))]);
        $this->assertSame('forbidden', $res->json('results.0.error'));
    }

    public function test_adults_manage_chores_and_everyone_but_viewers_marks_them_done(): void
    {
        $owner = $this->device('owner');
        $child = $this->device('child');
        $viewer = $this->device('viewer');
        $choreId = (string) Str::uuid7();

        $res = $this->push($child, [$this->op('chores', (string) Str::uuid7(), 'insert', ['name' => 'Sweep'], $this->hlc(1))]);
        $this->assertSame('forbidden', $res->json('results.0.error'));

        $this->push($owner, [$this->op('chores', $choreId, 'insert', ['name' => 'Wash dishes', 'repeat' => 'daily', 'assigned_to' => $child->member_id], $this->hlc(2))]);
        $done = fn ($d, int $t) => $this->op('chore_completions', (string) Str::uuid7(), 'insert', ['chore_id' => $choreId, 'member_id' => $d->member_id, 'done_on' => '2026-11-26'], $this->hlc($t));

        $this->assertSame(['applied'], $this->statuses($this->push($child, [$done($child, 3)])));
        $this->assertSame('forbidden', $this->push($viewer, [$done($viewer, 4)])->json('results.0.error'));
        $this->assertSame(1, DB::table('chore_completions')->count());
    }

    public function test_everyone_but_viewers_adds_events_and_everyone_reads_them(): void
    {
        $child = $this->device('child');
        $viewer = $this->device('viewer');
        $id = (string) Str::uuid7();
        $fields = ['title' => 'School play', 'starts_on' => '2026-12-04', 'ends_on' => '2026-12-05', 'color' => 'dagat', 'start_time' => '15:00', 'repeat' => 'none', 'member_id' => $child->member_id, 'created_by' => $child->member_id];

        $this->assertSame(['applied'], $this->statuses($this->push($child, [$this->op('events', $id, 'insert', $fields, $this->hlc(1))])));
        $this->assertSame('forbidden', $this->push($viewer, [$this->op('events', (string) Str::uuid7(), 'insert', $fields, $this->hlc(2))])->json('results.0.error'));

        $pulled = collect($this->pull($viewer)->assertOk()->json('changes'))->firstWhere('entity', 'events');
        $this->assertSame($id, $pulled['entity_id']);
        $this->assertSame('15:00', $pulled['row']['start_time']);
        $this->assertSame('2026-12-04', $pulled['row']['starts_on']);
        $this->assertSame('2026-12-05', $pulled['row']['ends_on']);
        $this->assertSame('dagat', $pulled['row']['color']);
    }

    public function test_debts_are_for_adults_and_payments_from_two_devices_both_count(): void
    {
        $john = $this->device('owner');
        $ana = $this->device('adult');
        $teen = $this->device('teen');
        $debtId = (string) Str::uuid7();
        $debt = ['kind' => 'loan', 'name' => 'Pag-IBIG salary loan', 'counterparty' => 'Pag-IBIG', 'principal_minor' => 6000000, 'installment_minor' => 280000, 'next_due_on' => '2026-12-10', 'repeat' => 'monthly', 'started_on' => '2026-06-10'];

        $this->assertSame('forbidden', $this->push($teen, [$this->op('debts', (string) Str::uuid7(), 'insert', $debt, $this->hlc(1))])->json('results.0.error'));
        $this->assertSame(['applied'], $this->statuses($this->push($john, [$this->op('debts', $debtId, 'insert', $debt, $this->hlc(2))])));

        $payment = fn ($d, int $t) => $this->op('debt_payments', (string) Str::uuid7(), 'insert', ['debt_id' => $debtId, 'kind' => 'payment', 'amount_minor' => 280000, 'paid_on' => '2026-12-09', 'member_id' => $d->member_id], $this->hlc($t));
        $this->assertSame(['applied'], $this->statuses($this->push($john, [$payment($john, 3)])));
        $this->assertSame(['applied'], $this->statuses($this->push($ana, [$payment($ana, 4)])));
        $this->assertSame(2, DB::table('debt_payments')->where('debt_id', $debtId)->count());

        $pulled = collect($this->pull($ana)->assertOk()->json('changes'))->firstWhere('entity', 'debts');
        $this->assertSame('loan', $pulled['row']['kind']);
        $this->assertSame(6000000, $pulled['row']['principal_minor']);
        $this->assertEmpty(collect($this->pull($teen)->json('changes'))->whereIn('entity', ['debts', 'debt_payments'])->all());
    }

    public function test_a_paid_off_debt_stays_closed_unless_the_closer_reopens_it(): void
    {
        $john = $this->device('owner');
        $ana = $this->device('adult');
        $id = (string) Str::uuid7();
        $seen = $this->push($john, [$this->op('debts', $id, 'insert', ['kind' => 'pawn', 'name' => 'Gold ring', 'principal_minor' => 500000], $this->hlc(1))])
            ->json('results.0.server_version');

        $this->push($john, [$this->op('debts', $id, 'update', ['is_closed' => true, 'closed_by' => $john->member_id], $this->hlc(3), $seen)]);
        $this->push($ana, [$this->op('debts', $id, 'update', ['is_closed' => false], $this->hlc(4), $seen)]);
        $this->assertTrue((bool) $this->latest($john, $id)['is_closed'], 'someone else cannot reopen it');
        $this->push($john, [$this->op('debts', $id, 'update', ['is_closed' => false, 'closed_by' => null], $this->hlc(6), $seen)]);
        $this->assertFalse((bool) $this->latest($john, $id)['is_closed'], 'the closer can');

        $this->assertSame('validation', $this->push($john, [$this->op('debt_payments', (string) Str::uuid7(), 'insert', ['debt_id' => $id, 'kind' => 'payment', 'amount_minor' => 'lots', 'paid_on' => '2026-11-26'], $this->hlc(5))])->json('results.0.error'));
    }

    public function test_vehicles_are_for_adults_and_logs_from_two_devices_both_count(): void
    {
        $john = $this->device('owner');
        $ana = $this->device('adult');
        $teen = $this->device('teen');
        $carId = (string) Str::uuid7();
        $car = ['kind' => 'car', 'name' => 'Innova', 'plate' => 'ABC 1234', 'color' => 'silver', 'registration_due_on' => '2027-07-20', 'pms_due_on' => '2026-12-06', 'pms_due_km' => 45000, 'pms_every_months' => 6, 'pms_every_km' => 5000];

        $this->assertSame('forbidden', $this->push($teen, [$this->op('vehicles', (string) Str::uuid7(), 'insert', $car, $this->hlc(1))])->json('results.0.error'));
        $this->assertSame(['applied'], $this->statuses($this->push($john, [$this->op('vehicles', $carId, 'insert', $car, $this->hlc(2))])));

        $fuel = fn ($d, int $t) => $this->op('vehicle_logs', (string) Str::uuid7(), 'insert', ['vehicle_id' => $carId, 'kind' => 'fuel', 'amount_minor' => 200000, 'logged_on' => '2026-11-26', 'odometer_km' => 44210, 'litres' => 31.5, 'member_id' => $d->member_id], $this->hlc($t));
        $this->assertSame(['applied'], $this->statuses($this->push($john, [$fuel($john, 3)])));
        $this->assertSame(['applied'], $this->statuses($this->push($ana, [$fuel($ana, 4)])));
        $this->assertSame(2, DB::table('vehicle_logs')->where('vehicle_id', $carId)->count());
        $reading = $this->op('vehicle_logs', (string) Str::uuid7(), 'insert', ['vehicle_id' => $carId, 'kind' => 'odometer', 'logged_on' => '2026-11-27', 'odometer_km' => 44300], $this->hlc(5));
        $this->assertSame(['applied'], $this->statuses($this->push($ana, [$reading])));

        $changes = collect($this->pull($ana)->assertOk()->json('changes'));
        $pulled = $changes->firstWhere('entity', 'vehicles');
        $this->assertSame('ABC 1234', $pulled['row']['plate']);
        $this->assertSame(45000, $pulled['row']['pms_due_km']);
        $this->assertEqualsWithDelta(31.5, (float) $changes->firstWhere('entity', 'vehicle_logs')['row']['litres'], 0.001);
        $this->assertEmpty(collect($this->pull($teen)->json('changes'))->whereIn('entity', ['vehicles', 'vehicle_logs'])->all());

        $logId = $changes->firstWhere('entity', 'vehicle_logs')['entity_id'];
        $this->assertSame('rejected', $this->push($john, [$this->op('vehicle_logs', $logId, 'update', ['amount_minor' => 1], $this->hlc(6), 1)])->json('results.0.status'), 'logs are append-only');
    }

    public function test_conflicts_sync_to_adults_and_can_be_resolved(): void
    {
        $john = $this->device('owner');
        $ana = $this->device('adult');
        $teen = $this->device('teen');
        $id = (string) Str::uuid7();
        $seen = $this->push($john, [$this->op('bills', $id, 'insert', ['name' => 'Water', 'amount_minor' => 120000], $this->hlc(1))])
            ->json('results.0.server_version');
        $this->push($john, [$this->op('bills', $id, 'update', ['amount_minor' => 142000], $this->hlc(3), $seen)]);
        $conflictId = $this->push($ana, [$this->op('bills', $id, 'update', ['amount_minor' => 124000], $this->hlc(2, 0, 'bbbbbbbb'), $seen)])
            ->json('results.0.conflict_id');

        $pulled = collect($this->pull($john)->assertOk()->json('changes'))->firstWhere('entity', 'conflicts');
        $this->assertSame($conflictId, $pulled['entity_id']);
        $this->assertSame('bills', $pulled['row']['entity']);
        $this->assertSame('amount_minor', $pulled['row']['field']);
        $this->assertSame(142000, $pulled['row']['kept_value']);
        $this->assertSame(124000, $pulled['row']['lost_value']);
        $this->assertSame($ana->member_id, $pulled['row']['lost_by']);
        $this->assertNull($pulled['row']['resolved_at']);
        $this->assertNotNull($pulled['row']['server_version']);

        $this->assertNull(collect($this->pull($teen)->json('changes'))->firstWhere('entity', 'conflicts'));

        $res = $this->push($john, [$this->op('conflicts', $conflictId, 'update', [
            'resolved_at' => '2026-11-25T08:00:00Z', 'resolved_by' => $john->member_id,
        ], $this->hlc(4))]);
        $this->assertSame(['applied'], $this->statuses($res));
        $this->assertNotNull(DB::table('conflicts')->where('id', $conflictId)->value('resolved_at'));
    }

    public function test_devices_cannot_create_or_rewrite_conflicts(): void
    {
        $john = $this->device('owner');
        $id = (string) Str::uuid7();
        $res = $this->push($john, [$this->op('conflicts', $id, 'insert', ['entity' => 'bills', 'field' => 'x'], $this->hlc(1))]);
        $this->assertSame('forbidden', $res->json('results.0.error'));
    }

    public function test_delete_wins_over_an_older_edit(): void
    {
        $ana = $this->device('adult');
        $ben = $this->device('adult');
        $id = (string) Str::uuid7();
        $this->push($ana, [$this->op('grocery_items', $id, 'insert', ['name' => 'Soap'], $this->hlc(1))]);
        $this->push($ana, [$this->op('grocery_items', $id, 'delete', [], $this->hlc(3))]);

        $res = $this->push($ben, [$this->op('grocery_items', $id, 'update', ['name' => 'Dish soap'], $this->hlc(2, 0, 'bbbbbbbb'))]);

        $this->assertSame(['merged'], $this->statuses($res));
        $this->assertNotNull($this->latest($ana, $id)['deleted_at']);
    }

    public function test_a_newer_edit_brings_a_deleted_record_back(): void
    {
        $ana = $this->device('adult');
        $ben = $this->device('adult');
        $id = (string) Str::uuid7();
        $this->push($ana, [$this->op('grocery_items', $id, 'insert', ['name' => 'Soap'], $this->hlc(1))]);
        $this->push($ana, [$this->op('grocery_items', $id, 'delete', [], $this->hlc(3))]);

        $res = $this->push($ben, [$this->op('grocery_items', $id, 'update', ['name' => 'Dish soap'], $this->hlc(4, 0, 'bbbbbbbb'))]);

        $this->assertSame(['applied'], $this->statuses($res));
        $row = $this->latest($ana, $id);
        $this->assertNull($row['deleted_at']);
        $this->assertSame('Dish soap', $row['name']);
    }

    public function test_a_delete_older_than_an_edit_loses(): void
    {
        $ana = $this->device('adult');
        $ben = $this->device('adult');
        $id = (string) Str::uuid7();
        $this->push($ana, [$this->op('grocery_items', $id, 'insert', ['name' => 'Salt'], $this->hlc(1))]);
        $this->push($ana, [$this->op('grocery_items', $id, 'update', ['name' => 'Sea salt'], $this->hlc(4))]);

        $res = $this->push($ben, [$this->op('grocery_items', $id, 'delete', [], $this->hlc(3, 0, 'bbbbbbbb'))]);

        $this->assertSame(['merged'], $this->statuses($res));
        $this->assertNull($this->latest($ana, $id)['deleted_at']);
    }

    public function test_ledger_entries_are_append_only_except_the_note(): void
    {
        $ana = $this->device('adult');
        $id = (string) Str::uuid7();
        $this->push($ana, [$this->op('transactions', $id, 'insert', [
            'category' => 'Food', 'amount_minor' => -186000, 'occurred_at' => '2026-11-25T03:10:00Z',
        ], $this->hlc(1))]);

        $amount = $this->push($ana, [$this->op('transactions', $id, 'update', ['amount_minor' => -1], $this->hlc(2))]);
        $note = $this->push($ana, [$this->op('transactions', $id, 'update', ['note' => 'Public market'], $this->hlc(3))]);

        $this->assertSame(['rejected'], $this->statuses($amount));
        $this->assertSame(['applied'], $this->statuses($note));
        $row = $this->latest($ana, $id);
        $this->assertSame(-186000, $row['amount_minor']);
        $this->assertSame('Public market', $row['note']);
        $this->assertSame('2026-11-25T03:10:00Z', $row['occurred_at']);
    }

    public function test_a_rejected_op_does_not_block_the_rest_of_the_batch(): void
    {
        $helper = $this->device('helper');
        $a = (string) Str::uuid7();
        $b = (string) Str::uuid7();

        $res = $this->push($helper, [
            $this->op('grocery_items', $a, 'insert', ['name' => 'Garlic'], $this->hlc(1)),
            $this->op('bills', $b, 'insert', ['name' => 'Internet', 'amount_minor' => 169900], $this->hlc(2)),
            $this->op('grocery_items', $a, 'update', ['bogus' => 1], $this->hlc(3)),
        ]);

        $this->assertSame(['applied', 'rejected', 'rejected'], $this->statuses($res));
        $this->assertSame('forbidden', $res->json('results.1.error'));
        $this->assertSame('validation', $res->json('results.2.error'));
        $this->assertDatabaseHas('grocery_items', ['id' => $a, 'name' => 'Garlic']);
        $this->assertDatabaseMissing('bills', ['id' => $b]);
    }

    public function test_another_households_record_cannot_be_touched(): void
    {
        $mine = $this->device('owner');
        $other = Household::create(['id' => (string) Str::uuid7(), 'name' => 'Other']);
        $theirs = $this->device('owner', $other);
        $id = (string) Str::uuid7();
        $this->push($theirs, [$this->op('grocery_items', $id, 'insert', ['name' => 'Theirs'], $this->hlc(1))]);

        $res = $this->push($mine, [$this->op('grocery_items', $id, 'update', ['name' => 'Mine now'], $this->hlc(2))]);

        $this->assertSame('household_mismatch', $res->json('results.0.error'));
        $this->assertDatabaseHas('grocery_items', ['id' => $id, 'name' => 'Theirs']);
    }

    public function test_malformed_ops_are_rejected_with_details(): void
    {
        $device = $this->device();

        $res = $this->push($device, [['op_id' => 'nope', 'entity' => 'grocery_items', 'entity_id' => 'x', 'op' => 'upsert', 'hlc' => '123']]);

        $this->assertSame('validation', $res->json('results.0.error'));
        $this->assertSame(['op_id', 'entity_id', 'op', 'hlc'], array_keys($res->json('results.0.details')));
    }
}
