import 'package:drift/drift.dart';

/// Columns every synced table carries (docs/sync-protocol.md §2).
///
/// Drift turns the getter names into snake_case column names, so they match
/// the server's field names exactly; the sync engine relies on that.
mixin SyncColumns on Table {
  TextColumn get id => text()();
  TextColumn get householdId => text()();
  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();
  DateTimeColumn get updatedAt => dateTime().clientDefault(DateTime.now)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get hlc => text().nullable()();
  IntColumn get serverVersion => integer().nullable()();
  TextColumn get updatedBy => text().nullable()();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ------------------------------------------------------------ synced tables
// Same reference tables as the API (api/config/homesync.php). Modules extend
// them in Phase 1.

class Members extends Table with SyncColumns {
  TextColumn get name => text()();
  TextColumn get role => text()();
  TextColumn get color => text().nullable()();
  TextColumn get pinHash => text().nullable()();
  IntColumn get userId => integer().nullable()();
}

class GroceryItems extends Table with SyncColumns {
  TextColumn get name => text()();
  TextColumn get quantityText => text().nullable()();
  TextColumn get store => text().nullable()();
  BoolColumn get isBought => boolean().withDefault(const Constant(false))();
  DateTimeColumn get boughtAt => dateTime().nullable()();

  /// Set by "clear bought": hidden from the list, kept for history.
  DateTimeColumn get clearedAt => dateTime().nullable()();

  /// Planned shopping day (`YYYY-MM-DD`) while still to buy; null = no date.
  TextColumn get plannedOn => text().nullable()();
  TextColumn get requestedBy => text().nullable()();
  TextColumn get note => text().nullable()();
}

class PantryItems extends Table with SyncColumns {
  TextColumn get name => text()();
  TextColumn get unit => text().nullable()();
  RealColumn get quantity => real().withDefault(const Constant(0))();
  RealColumn get minQuantity => real().nullable()();
  TextColumn get location => text().nullable()();

  /// Calendar date `YYYY-MM-DD`, kept as text so time zones never shift it.
  TextColumn get expiresOn => text().nullable()();
}

/// Monthly limit per spending category. Id derived from household and
/// category (sync-protocol §2.1), so there is one row per category.
class Budgets extends Table with SyncColumns {
  TextColumn get category => text()();
  IntColumn get limitMinor => integer().withDefault(const Constant(0))();
  TextColumn get currency => text().withDefault(const Constant('PHP'))();
}

/// One bill per due date. A monthly bill's occurrences share [seriesId];
/// the next one's id is derived from the series and due date (§2.1).
class Bills extends Table with SyncColumns {
  TextColumn get name => text()();
  TextColumn get provider => text().nullable()();
  IntColumn get amountMinor => integer().withDefault(const Constant(0))();
  TextColumn get currency => text().withDefault(const Constant('PHP'))();

  /// Calendar date `YYYY-MM-DD`.
  TextColumn get dueOn => text().nullable()();
  BoolColumn get isPaid => boolean().withDefault(const Constant(false))();
  DateTimeColumn get paidAt => dateTime().nullable()();

  /// Budget category the payment is recorded under.
  TextColumn get category => text().nullable()();

  /// `monthly` or null (one-off).
  TextColumn get repeat => text().nullable()();
  TextColumn get seriesId => text().nullable()();
}

class Subscriptions extends Table with SyncColumns {
  TextColumn get name => text()();
  IntColumn get priceMinor => integer().withDefault(const Constant(0))();
  TextColumn get currency => text().withDefault(const Constant('PHP'))();

  /// `monthly` or `yearly`.
  TextColumn get cycle => text().withDefault(const Constant('monthly'))();

  /// Calendar date `YYYY-MM-DD`.
  TextColumn get nextDueOn => text().nullable()();
  TextColumn get category => text().nullable()();
}

/// A household chore: `daily`, `weekly` on [weekday] (1 = Monday), or
/// `once` on [dueOn]. Done for a day = a [ChoreCompletions] row that day.
class Chores extends Table with SyncColumns {
  TextColumn get name => text()();

  /// Member id, or null for anyone.
  TextColumn get assignedTo => text().nullable()();
  TextColumn get repeat => text().withDefault(const Constant('daily'))();
  IntColumn get weekday => integer().nullable()();

  /// Calendar date `YYYY-MM-DD` (once).
  TextColumn get dueOn => text().nullable()();
}

/// Who did a chore on which day. Append-only; undo is a delete.
class ChoreCompletions extends Table with SyncColumns {
  TextColumn get choreId => text()();
  TextColumn get memberId => text().nullable()();

  /// Calendar date `YYYY-MM-DD`.
  TextColumn get doneOn => text()();
}

/// A calendar event on a local date, all day or at a local time, repeating
/// `weekly`, `monthly` or `yearly` from [startsOn] (`none` = once).
@DataClassName('CalendarEvent')
class Events extends Table with SyncColumns {
  TextColumn get title => text()();

  /// Calendar date `YYYY-MM-DD` (the first occurrence).
  TextColumn get startsOn => text()();

  /// Last day `YYYY-MM-DD` of a multi-day event's first occurrence; null = one
  /// day. A repeat copies the whole span.
  TextColumn get endsOn => text().nullable()();

  /// Local `HH:MM`; null = all day. On a multi-day event the start time is on
  /// the first day and the end time on the last.
  TextColumn get startTime => text().nullable()();
  TextColumn get endTime => text().nullable()();
  TextColumn get repeat => text().withDefault(const Constant('none'))();

  /// Palette name (`ube`, `dagat`, `dahon`, `narra`, `rosas`, `tubig`); null =
  /// the default look.
  TextColumn get color => text().nullable()();

  /// Who it is for; null = the whole family.
  TextColumn get memberId => text().nullable()();
  TextColumn get location => text().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get createdBy => text().nullable()();
}

/// A loan, credit card, pawn ticket or money lent ([kind] `loan`, `card`,
/// `pawn`, `lent`). Balance = [principalMinor] + charges - payments in
/// [DebtPayments]; it is never stored.
class Debts extends Table with SyncColumns {
  TextColumn get kind => text()();
  TextColumn get name => text()();

  /// Bank, pawnshop or person.
  TextColumn get counterparty => text().nullable()();

  /// Pawn ticket number, last digits of a card, loan account.
  TextColumn get reference => text().nullable()();
  IntColumn get principalMinor => integer().withDefault(const Constant(0))();
  TextColumn get currency => text().withDefault(const Constant('PHP'))();

  /// Monthly amortization or minimum due.
  IntColumn get installmentMinor => integer().nullable()();

  /// Calendar date `YYYY-MM-DD` (a pawn ticket's maturity).
  TextColumn get nextDueOn => text().nullable()();

  /// `monthly` or null.
  TextColumn get repeat => text().nullable()();
  TextColumn get startedOn => text().nullable()();
  BoolColumn get isClosed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get closedAt => dateTime().nullable()();
  TextColumn get closedBy => text().nullable()();
  TextColumn get note => text().nullable()();
}

/// A payment, interest-only payment or charge on a debt ([kind] `payment`,
/// `interest`, `charge`; [amountMinor] positive). Append-only.
class DebtPayments extends Table with SyncColumns {
  TextColumn get debtId => text()();
  TextColumn get kind => text()();
  IntColumn get amountMinor => integer()();
  TextColumn get currency => text().withDefault(const Constant('PHP'))();

  /// Calendar date `YYYY-MM-DD`.
  TextColumn get paidOn => text()();
  TextColumn get memberId => text().nullable()();
  TextColumn get note => text().nullable()();
}

/// A car or motorcycle ([kind] `car`, `motorcycle`) with its due dates. The
/// odometer is the highest reading in [VehicleLogs]; it is never stored here.
class Vehicles extends Table with SyncColumns {
  TextColumn get kind => text()();
  TextColumn get name => text()();
  TextColumn get plate => text().nullable()();
  TextColumn get color => text().nullable()();

  /// Calendar dates `YYYY-MM-DD`; registration and insurance are yearly.
  TextColumn get registrationDueOn => text().nullable()();
  TextColumn get insuranceDueOn => text().nullable()();

  /// PMS / change oil: due at this date or this odometer reading, whichever
  /// comes first.
  TextColumn get pmsDueOn => text().nullable()();
  IntColumn get pmsDueKm => integer().nullable()();

  /// How often PMS is done; logging one sets the next date and reading.
  IntColumn get pmsEveryMonths => integer().nullable()();
  IntColumn get pmsEveryKm => integer().nullable()();
  TextColumn get note => text().nullable()();
}

/// A cost ([kind] `fuel`, `repair`, `pms`, `registration`, `insurance`;
/// [amountMinor] positive) or an odometer reading ([kind] `odometer`, no
/// amount) for a vehicle. Append-only.
class VehicleLogs extends Table with SyncColumns {
  TextColumn get vehicleId => text()();
  TextColumn get kind => text()();
  IntColumn get amountMinor => integer().nullable()();
  TextColumn get currency => text().withDefault(const Constant('PHP'))();

  /// Calendar date `YYYY-MM-DD`.
  TextColumn get loggedOn => text()();
  IntColumn get odometerKm => integer().nullable()();
  RealColumn get litres => real().nullable()();
  TextColumn get memberId => text().nullable()();
  TextColumn get note => text().nullable()();
}

/// A room, house or stall the household rents out; kept while vacant.
class RentalUnits extends Table with SyncColumns {
  TextColumn get name => text()();
  TextColumn get note => text().nullable()();
}

/// One tenant in a [RentalUnits] row. Rent is due every month on [dueDay]
/// (the last day of a shorter month) from the month of [startsOn] up to the
/// month of [endsOn]. [rentMinor] applies from the month of [rentSince]
/// (from the start when null); earlier months use [prevRentMinor].
class Leases extends Table with SyncColumns {
  TextColumn get unitId => text()();
  TextColumn get tenantName => text()();
  TextColumn get phone => text().nullable()();
  IntColumn get rentMinor => integer()();
  IntColumn get prevRentMinor => integer().nullable()();
  TextColumn get rentSince => text().nullable()();
  TextColumn get currency => text().withDefault(const Constant('PHP'))();
  IntColumn get dueDay => integer()();

  /// Calendar dates `YYYY-MM-DD`.
  TextColumn get startsOn => text()();
  TextColumn get endsOn => text().nullable()();
  IntColumn get depositMinor => integer().nullable()();
  IntColumn get depositReturnedMinor => integer().nullable()();
  TextColumn get depositReturnedOn => text().nullable()();
  TextColumn get note => text().nullable()();
}

/// Money received for a lease ([kind] `payment`) or rent forgiven
/// (`waived`). Covers the oldest month first. Append-only.
class RentPayments extends Table with SyncColumns {
  TextColumn get leaseId => text()();
  TextColumn get kind => text()();
  IntColumn get amountMinor => integer()();
  TextColumn get currency => text().withDefault(const Constant('PHP'))();

  /// Calendar date `YYYY-MM-DD`.
  TextColumn get paidOn => text()();

  /// `cash`, `gcash` or `bank` (optional).
  TextColumn get method => text().nullable()();
  TextColumn get memberId => text().nullable()();
  TextColumn get note => text().nullable()();
}

/// A durable thing the household owns (appliance, electronics, furniture,
/// tools). Everyone reads; adults write. The photo is a plain file named by
/// [photoSha256], kept in [VaultBlobs] and uploaded like vault files.
class InventoryItems extends Table with SyncColumns {
  TextColumn get name => text()();

  /// `appliance`, `electronics`, `furniture`, `tools` or `other`.
  TextColumn get category => text()();
  TextColumn get room => text().nullable()();
  TextColumn get brand => text().nullable()();
  TextColumn get model => text().nullable()();
  TextColumn get serialNo => text().nullable()();

  /// Calendar date `YYYY-MM-DD`.
  TextColumn get boughtOn => text().nullable()();
  IntColumn get priceMinor => integer().nullable()();
  TextColumn get currency => text().withDefault(const Constant('PHP'))();

  /// Calendar date `YYYY-MM-DD`: the last day under warranty.
  TextColumn get warrantyUntil => text().nullable()();
  TextColumn get photoSha256 => text().nullable()();
  IntColumn get photoSize => integer().nullable()();

  /// Who borrowed it and since when; both null when it is home.
  TextColumn get lentTo => text().nullable()();
  TextColumn get lentOn => text().nullable()();
  TextColumn get note => text().nullable()();
}

/// A number to call in an emergency. The national hotlines are built in.
class EmergencyContacts extends Table with SyncColumns {
  TextColumn get name => text()();

  /// `family`, `barangay`, `hospital`, `doctor` or `other`.
  TextColumn get kind => text()();
  TextColumn get phone => text()();
  TextColumn get note => text().nullable()();
  IntColumn get position => integer().withDefault(const Constant(0))();
}

/// Where the household meets and evacuates. One row per household.
class EmergencyPlans extends Table with SyncColumns {
  TextColumn get meetingPoint => text().nullable()();
  TextColumn get meetingPointFar => text().nullable()();
  TextColumn get evacuationCenter => text().nullable()();
  TextColumn get note => text().nullable()();
}

/// One thing in a go-bag; [memberId] null = the household's shared bag.
class GoBagItems extends Table with SyncColumns {
  TextColumn get memberId => text().nullable()();
  TextColumn get name => text()();
  BoolColumn get packed => boolean().withDefault(const Constant(false))();

  /// Calendar date `YYYY-MM-DD` (food, water, medicine, batteries).
  TextColumn get expiresOn => text().nullable()();
  IntColumn get position => integer().withDefault(const Constant(0))();
}

/// A tick on a built-in hazard checklist item. Id derived from hazard + item.
class EmergencyChecks extends Table with SyncColumns {
  /// `typhoon`, `flood` or `earthquake`.
  TextColumn get hazard => text()();
  TextColumn get item => text()();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
  TextColumn get doneBy => text().nullable()();
  DateTimeColumn get doneAt => dateTime().nullable()();
}

/// "I'm safe" ([status] `safe`) or "Need help" (`help`). Append-only.
class SafetyCheckins extends Table with SyncColumns {
  TextColumn get memberId => text()();
  TextColumn get status => text()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get checkedAt => dateTime()();
}

/// A member's health profile; [sealed] is blood type, allergies, conditions,
/// maintenance medicines, PhilHealth/HMO numbers and doctor, encrypted with
/// the vault key. One row per member (derived id).
class HealthProfiles extends Table with SyncColumns {
  TextColumn get memberId => text()();
  TextColumn get sealed => text()();
}

/// A medicine for a member (null = anyone), taken at local `HH:MM` [times]
/// (comma-separated; null = as needed). [stock] is a counter.
class Medicines extends Table with SyncColumns {
  TextColumn get name => text()();
  TextColumn get strength => text().nullable()();
  TextColumn get memberId => text().nullable()();
  TextColumn get times => text().nullable()();
  RealColumn get doseQty => real().withDefault(const Constant(1))();

  /// Last day of a course `YYYY-MM-DD`; null = ongoing.
  TextColumn get endsOn => text().nullable()();
  RealColumn get stock => real().withDefault(const Constant(0))();
  RealColumn get minStock => real().nullable()();
  TextColumn get unit => text().nullable()();
  TextColumn get expiresOn => text().nullable()();
  TextColumn get note => text().nullable()();
}

/// A dose given. Append-only; a scheduled dose has a derived id.
class MedDoses extends Table with SyncColumns {
  TextColumn get medicineId => text()();
  TextColumn get memberId => text().nullable()();
  TextColumn get givenBy => text().nullable()();

  /// Calendar date `YYYY-MM-DD` and the scheduled `HH:MM` (null = as needed).
  TextColumn get takenOn => text()();
  TextColumn get slot => text().nullable()();
  DateTimeColumn get takenAt => dateTime().nullable()();
  TextColumn get note => text().nullable()();
}

/// A checkup or vaccine ([kind] `checkup`, `vaccine`), done when [doneAt] is set.
class Checkups extends Table with SyncColumns {
  TextColumn get memberId => text().nullable()();
  TextColumn get kind => text()();
  TextColumn get title => text()();
  TextColumn get dueOn => text().nullable()();
  TextColumn get dueTime => text().nullable()();
  TextColumn get place => text().nullable()();
  DateTimeColumn get doneAt => dateTime().nullable()();
  TextColumn get doneBy => text().nullable()();
  TextColumn get note => text().nullable()();
}

/// The money ledger. Append-only: only `note` and deletion change later.
@DataClassName('LedgerEntry')
class Transactions extends Table with SyncColumns {
  TextColumn get accountId => text().nullable()();
  TextColumn get category => text().nullable()();
  IntColumn get amountMinor => integer()();
  TextColumn get currency => text().withDefault(const Constant('PHP'))();
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get memberId => text().nullable()();
  TextColumn get sourceType => text().nullable()();
  TextColumn get sourceId => text().nullable()();
  TextColumn get note => text().nullable()();
}

// ------------------------------------------------------------- vault
// Document Vault (docs/vault.md). Secrets are encrypted on the device with
// the household vault key before they reach this database; the hub only
// ever sees ciphertext. All three are never auto-merged (sync-protocol §6).

/// The household vault key, wrapped by the vault passphrase and by the
/// owner's recovery code. One row per household (derived id).
class VaultKeys extends Table with SyncColumns {
  /// base64 of version byte, nonce, ciphertext and tag (see VaultCrypto).
  TextColumn get passphraseWrap => text()();
  TextColumn get kdfSalt => text()();
  IntColumn get kdfIterations => integer()();
  TextColumn get recoveryWrap => text()();
  TextColumn get recoverySalt => text()();
  TextColumn get createdBy => text().nullable()();
}

/// A document. [sealed] is the encrypted title, number, issuer and note.
class VaultItems extends Table with SyncColumns {
  TextColumn get kind => text()();
  TextColumn get memberId => text().nullable()();

  /// Calendar date `YYYY-MM-DD`; plain so reminders work while locked.
  TextColumn get expiresOn => text().nullable()();
  TextColumn get sealed => text()();
  TextColumn get createdBy => text().nullable()();
}

/// A photo or PDF of a document: its own key ([keyWrap], wrapped by the
/// vault key), the SHA-256 and size of its ciphertext, and its encrypted
/// name and type ([sealed]).
class VaultFiles extends Table with SyncColumns {
  TextColumn get itemId => text()();
  TextColumn get sha256 => text()();
  IntColumn get size => integer()();
  TextColumn get keyWrap => text()();
  TextColumn get sealed => text()();
  IntColumn get position => integer().withDefault(const Constant(0))();
}

/// Local only: encrypted file bytes kept on this device, by SHA-256 of the
/// ciphertext. [needsUpload] until the hub has them.
class VaultBlobs extends Table {
  TextColumn get sha256 => text()();
  BlobColumn get data => blob()();
  BoolColumn get needsUpload => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();

  @override
  Set<Column> get primaryKey => {sha256};
}

/// Values kept for review (sync-protocol §6.1). Created by the hub only.
@DataClassName('ConflictRecord')
class Conflicts extends Table with SyncColumns {
  TextColumn get entity => text()();
  TextColumn get entityId => text()();
  TextColumn get field => text()();

  /// JSON-encoded values, as received.
  TextColumn get keptValue => text().nullable()();
  TextColumn get keptBy => text().nullable()();
  TextColumn get lostValue => text().nullable()();
  TextColumn get lostBy => text().nullable()();
  DateTimeColumn get resolvedAt => dateTime().nullable()();
  TextColumn get resolvedBy => text().nullable()();
}

// ------------------------------------------------------------- sync tables

/// Local changes waiting to be pushed (sync-protocol §3).
@DataClassName('OutboxOp')
class Outbox extends Table {
  IntColumn get seq => integer().autoIncrement()();
  TextColumn get opId => text().unique()();
  TextColumn get entity => text()();
  TextColumn get entityId => text()();

  /// insert, update, delete or increment.
  TextColumn get op => text()();

  /// JSON object in wire format.
  TextColumn get fields => text()();
  TextColumn get hlc => text()();
  IntColumn get baseVersion => integer().nullable()();

  /// Set when a push containing this op starts. A sending op is never merged
  /// with later edits: the server may already have applied it.
  BoolColumn get sending => boolean().withDefault(const Constant(false))();

  /// Profile that made the change. On the shared tablet each PIN profile is
  /// its own device with its own token, and the op must be pushed with it:
  /// the server takes `updated_by` from the token.
  TextColumn get memberId => text()();
  TextColumn get deviceId => text()();
  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();
}

/// Per-field clock of the last change this device knows about.
class FieldClocks extends Table {
  TextColumn get entity => text()();
  TextColumn get entityId => text()();
  TextColumn get field => text()();
  TextColumn get hlc => text()();

  @override
  Set<Column> get primaryKey => {entity, entityId, field};
}

/// Small key/value store: pull cursor, last synced time, clock state.
@DataClassName('SyncStateEntry')
class SyncState extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

/// Ops the server rejected, kept so the user can see what didn't sync.
class SyncErrors extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get opId => text()();
  TextColumn get entity => text()();
  TextColumn get entityId => text()();
  TextColumn get op => text()();
  TextColumn get fields => text()();
  TextColumn get error => text()();
  TextColumn get details => text().nullable()();
  BoolColumn get dismissed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();
}
