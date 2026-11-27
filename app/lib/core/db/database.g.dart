// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $MembersTable extends Members with TableInfo<$MembersTable, Member> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _householdIdMeta = const VerificationMeta(
    'householdId',
  );
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
    'household_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverVersionMeta = const VerificationMeta(
    'serverVersion',
  );
  @override
  late final GeneratedColumn<int> serverVersion = GeneratedColumn<int>(
    'server_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pinHashMeta = const VerificationMeta(
    'pinHash',
  );
  @override
  late final GeneratedColumn<String> pinHash = GeneratedColumn<String>(
    'pin_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    householdId,
    createdAt,
    updatedAt,
    deletedAt,
    hlc,
    serverVersion,
    updatedBy,
    deviceId,
    name,
    role,
    color,
    pinHash,
    userId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'members';
  @override
  VerificationContext validateIntegrity(
    Insertable<Member> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
        _householdIdMeta,
        householdId.isAcceptableOrUnknown(
          data['household_id']!,
          _householdIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    }
    if (data.containsKey('server_version')) {
      context.handle(
        _serverVersionMeta,
        serverVersion.isAcceptableOrUnknown(
          data['server_version']!,
          _serverVersionMeta,
        ),
      );
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('pin_hash')) {
      context.handle(
        _pinHashMeta,
        pinHash.isAcceptableOrUnknown(data['pin_hash']!, _pinHashMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Member map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Member(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      householdId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}household_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      ),
      serverVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_version'],
      ),
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
      pinHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pin_hash'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      ),
    );
  }

  @override
  $MembersTable createAlias(String alias) {
    return $MembersTable(attachedDatabase, alias);
  }
}

class Member extends DataClass implements Insertable<Member> {
  final String id;
  final String householdId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? hlc;
  final int? serverVersion;
  final String? updatedBy;
  final String? deviceId;
  final String name;
  final String role;
  final String? color;
  final String? pinHash;
  final int? userId;
  const Member({
    required this.id,
    required this.householdId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.hlc,
    this.serverVersion,
    this.updatedBy,
    this.deviceId,
    required this.name,
    required this.role,
    this.color,
    this.pinHash,
    this.userId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['household_id'] = Variable<String>(householdId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || hlc != null) {
      map['hlc'] = Variable<String>(hlc);
    }
    if (!nullToAbsent || serverVersion != null) {
      map['server_version'] = Variable<int>(serverVersion);
    }
    if (!nullToAbsent || updatedBy != null) {
      map['updated_by'] = Variable<String>(updatedBy);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['name'] = Variable<String>(name);
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    if (!nullToAbsent || pinHash != null) {
      map['pin_hash'] = Variable<String>(pinHash);
    }
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<int>(userId);
    }
    return map;
  }

  MembersCompanion toCompanion(bool nullToAbsent) {
    return MembersCompanion(
      id: Value(id),
      householdId: Value(householdId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      hlc: hlc == null && nullToAbsent ? const Value.absent() : Value(hlc),
      serverVersion: serverVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(serverVersion),
      updatedBy: updatedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedBy),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      name: Value(name),
      role: Value(role),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      pinHash: pinHash == null && nullToAbsent
          ? const Value.absent()
          : Value(pinHash),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
    );
  }

  factory Member.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Member(
      id: serializer.fromJson<String>(json['id']),
      householdId: serializer.fromJson<String>(json['householdId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      hlc: serializer.fromJson<String?>(json['hlc']),
      serverVersion: serializer.fromJson<int?>(json['serverVersion']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      name: serializer.fromJson<String>(json['name']),
      role: serializer.fromJson<String>(json['role']),
      color: serializer.fromJson<String?>(json['color']),
      pinHash: serializer.fromJson<String?>(json['pinHash']),
      userId: serializer.fromJson<int?>(json['userId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'householdId': serializer.toJson<String>(householdId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'hlc': serializer.toJson<String?>(hlc),
      'serverVersion': serializer.toJson<int?>(serverVersion),
      'updatedBy': serializer.toJson<String?>(updatedBy),
      'deviceId': serializer.toJson<String?>(deviceId),
      'name': serializer.toJson<String>(name),
      'role': serializer.toJson<String>(role),
      'color': serializer.toJson<String?>(color),
      'pinHash': serializer.toJson<String?>(pinHash),
      'userId': serializer.toJson<int?>(userId),
    };
  }

  Member copyWith({
    String? id,
    String? householdId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> hlc = const Value.absent(),
    Value<int?> serverVersion = const Value.absent(),
    Value<String?> updatedBy = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
    String? name,
    String? role,
    Value<String?> color = const Value.absent(),
    Value<String?> pinHash = const Value.absent(),
    Value<int?> userId = const Value.absent(),
  }) => Member(
    id: id ?? this.id,
    householdId: householdId ?? this.householdId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    hlc: hlc.present ? hlc.value : this.hlc,
    serverVersion: serverVersion.present
        ? serverVersion.value
        : this.serverVersion,
    updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    name: name ?? this.name,
    role: role ?? this.role,
    color: color.present ? color.value : this.color,
    pinHash: pinHash.present ? pinHash.value : this.pinHash,
    userId: userId.present ? userId.value : this.userId,
  );
  Member copyWithCompanion(MembersCompanion data) {
    return Member(
      id: data.id.present ? data.id.value : this.id,
      householdId: data.householdId.present
          ? data.householdId.value
          : this.householdId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      serverVersion: data.serverVersion.present
          ? data.serverVersion.value
          : this.serverVersion,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      name: data.name.present ? data.name.value : this.name,
      role: data.role.present ? data.role.value : this.role,
      color: data.color.present ? data.color.value : this.color,
      pinHash: data.pinHash.present ? data.pinHash.value : this.pinHash,
      userId: data.userId.present ? data.userId.value : this.userId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Member(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('hlc: $hlc, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deviceId: $deviceId, ')
          ..write('name: $name, ')
          ..write('role: $role, ')
          ..write('color: $color, ')
          ..write('pinHash: $pinHash, ')
          ..write('userId: $userId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    householdId,
    createdAt,
    updatedAt,
    deletedAt,
    hlc,
    serverVersion,
    updatedBy,
    deviceId,
    name,
    role,
    color,
    pinHash,
    userId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Member &&
          other.id == this.id &&
          other.householdId == this.householdId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.hlc == this.hlc &&
          other.serverVersion == this.serverVersion &&
          other.updatedBy == this.updatedBy &&
          other.deviceId == this.deviceId &&
          other.name == this.name &&
          other.role == this.role &&
          other.color == this.color &&
          other.pinHash == this.pinHash &&
          other.userId == this.userId);
}

class MembersCompanion extends UpdateCompanion<Member> {
  final Value<String> id;
  final Value<String> householdId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> hlc;
  final Value<int?> serverVersion;
  final Value<String?> updatedBy;
  final Value<String?> deviceId;
  final Value<String> name;
  final Value<String> role;
  final Value<String?> color;
  final Value<String?> pinHash;
  final Value<int?> userId;
  final Value<int> rowid;
  const MembersCompanion({
    this.id = const Value.absent(),
    this.householdId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.hlc = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.name = const Value.absent(),
    this.role = const Value.absent(),
    this.color = const Value.absent(),
    this.pinHash = const Value.absent(),
    this.userId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MembersCompanion.insert({
    required String id,
    required String householdId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.hlc = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.deviceId = const Value.absent(),
    required String name,
    required String role,
    this.color = const Value.absent(),
    this.pinHash = const Value.absent(),
    this.userId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       householdId = Value(householdId),
       name = Value(name),
       role = Value(role);
  static Insertable<Member> custom({
    Expression<String>? id,
    Expression<String>? householdId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? hlc,
    Expression<int>? serverVersion,
    Expression<String>? updatedBy,
    Expression<String>? deviceId,
    Expression<String>? name,
    Expression<String>? role,
    Expression<String>? color,
    Expression<String>? pinHash,
    Expression<int>? userId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (householdId != null) 'household_id': householdId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (hlc != null) 'hlc': hlc,
      if (serverVersion != null) 'server_version': serverVersion,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (deviceId != null) 'device_id': deviceId,
      if (name != null) 'name': name,
      if (role != null) 'role': role,
      if (color != null) 'color': color,
      if (pinHash != null) 'pin_hash': pinHash,
      if (userId != null) 'user_id': userId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MembersCompanion copyWith({
    Value<String>? id,
    Value<String>? householdId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? hlc,
    Value<int?>? serverVersion,
    Value<String?>? updatedBy,
    Value<String?>? deviceId,
    Value<String>? name,
    Value<String>? role,
    Value<String?>? color,
    Value<String?>? pinHash,
    Value<int?>? userId,
    Value<int>? rowid,
  }) {
    return MembersCompanion(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      hlc: hlc ?? this.hlc,
      serverVersion: serverVersion ?? this.serverVersion,
      updatedBy: updatedBy ?? this.updatedBy,
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      role: role ?? this.role,
      color: color ?? this.color,
      pinHash: pinHash ?? this.pinHash,
      userId: userId ?? this.userId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (serverVersion.present) {
      map['server_version'] = Variable<int>(serverVersion.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (pinHash.present) {
      map['pin_hash'] = Variable<String>(pinHash.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MembersCompanion(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('hlc: $hlc, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deviceId: $deviceId, ')
          ..write('name: $name, ')
          ..write('role: $role, ')
          ..write('color: $color, ')
          ..write('pinHash: $pinHash, ')
          ..write('userId: $userId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GroceryItemsTable extends GroceryItems
    with TableInfo<$GroceryItemsTable, GroceryItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroceryItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _householdIdMeta = const VerificationMeta(
    'householdId',
  );
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
    'household_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverVersionMeta = const VerificationMeta(
    'serverVersion',
  );
  @override
  late final GeneratedColumn<int> serverVersion = GeneratedColumn<int>(
    'server_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityTextMeta = const VerificationMeta(
    'quantityText',
  );
  @override
  late final GeneratedColumn<String> quantityText = GeneratedColumn<String>(
    'quantity_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _storeMeta = const VerificationMeta('store');
  @override
  late final GeneratedColumn<String> store = GeneratedColumn<String>(
    'store',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isBoughtMeta = const VerificationMeta(
    'isBought',
  );
  @override
  late final GeneratedColumn<bool> isBought = GeneratedColumn<bool>(
    'is_bought',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_bought" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _boughtAtMeta = const VerificationMeta(
    'boughtAt',
  );
  @override
  late final GeneratedColumn<DateTime> boughtAt = GeneratedColumn<DateTime>(
    'bought_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clearedAtMeta = const VerificationMeta(
    'clearedAt',
  );
  @override
  late final GeneratedColumn<DateTime> clearedAt = GeneratedColumn<DateTime>(
    'cleared_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plannedOnMeta = const VerificationMeta(
    'plannedOn',
  );
  @override
  late final GeneratedColumn<String> plannedOn = GeneratedColumn<String>(
    'planned_on',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _requestedByMeta = const VerificationMeta(
    'requestedBy',
  );
  @override
  late final GeneratedColumn<String> requestedBy = GeneratedColumn<String>(
    'requested_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    householdId,
    createdAt,
    updatedAt,
    deletedAt,
    hlc,
    serverVersion,
    updatedBy,
    deviceId,
    name,
    quantityText,
    store,
    isBought,
    boughtAt,
    clearedAt,
    plannedOn,
    requestedBy,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'grocery_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<GroceryItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
        _householdIdMeta,
        householdId.isAcceptableOrUnknown(
          data['household_id']!,
          _householdIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    }
    if (data.containsKey('server_version')) {
      context.handle(
        _serverVersionMeta,
        serverVersion.isAcceptableOrUnknown(
          data['server_version']!,
          _serverVersionMeta,
        ),
      );
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('quantity_text')) {
      context.handle(
        _quantityTextMeta,
        quantityText.isAcceptableOrUnknown(
          data['quantity_text']!,
          _quantityTextMeta,
        ),
      );
    }
    if (data.containsKey('store')) {
      context.handle(
        _storeMeta,
        store.isAcceptableOrUnknown(data['store']!, _storeMeta),
      );
    }
    if (data.containsKey('is_bought')) {
      context.handle(
        _isBoughtMeta,
        isBought.isAcceptableOrUnknown(data['is_bought']!, _isBoughtMeta),
      );
    }
    if (data.containsKey('bought_at')) {
      context.handle(
        _boughtAtMeta,
        boughtAt.isAcceptableOrUnknown(data['bought_at']!, _boughtAtMeta),
      );
    }
    if (data.containsKey('cleared_at')) {
      context.handle(
        _clearedAtMeta,
        clearedAt.isAcceptableOrUnknown(data['cleared_at']!, _clearedAtMeta),
      );
    }
    if (data.containsKey('planned_on')) {
      context.handle(
        _plannedOnMeta,
        plannedOn.isAcceptableOrUnknown(data['planned_on']!, _plannedOnMeta),
      );
    }
    if (data.containsKey('requested_by')) {
      context.handle(
        _requestedByMeta,
        requestedBy.isAcceptableOrUnknown(
          data['requested_by']!,
          _requestedByMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GroceryItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GroceryItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      householdId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}household_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      ),
      serverVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_version'],
      ),
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      quantityText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quantity_text'],
      ),
      store: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store'],
      ),
      isBought: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_bought'],
      )!,
      boughtAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}bought_at'],
      ),
      clearedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cleared_at'],
      ),
      plannedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}planned_on'],
      ),
      requestedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}requested_by'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $GroceryItemsTable createAlias(String alias) {
    return $GroceryItemsTable(attachedDatabase, alias);
  }
}

class GroceryItem extends DataClass implements Insertable<GroceryItem> {
  final String id;
  final String householdId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? hlc;
  final int? serverVersion;
  final String? updatedBy;
  final String? deviceId;
  final String name;
  final String? quantityText;
  final String? store;
  final bool isBought;
  final DateTime? boughtAt;

  /// Set by "clear bought": hidden from the list, kept for history.
  final DateTime? clearedAt;

  /// Planned shopping day (`YYYY-MM-DD`) while still to buy; null = no date.
  final String? plannedOn;
  final String? requestedBy;
  final String? note;
  const GroceryItem({
    required this.id,
    required this.householdId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.hlc,
    this.serverVersion,
    this.updatedBy,
    this.deviceId,
    required this.name,
    this.quantityText,
    this.store,
    required this.isBought,
    this.boughtAt,
    this.clearedAt,
    this.plannedOn,
    this.requestedBy,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['household_id'] = Variable<String>(householdId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || hlc != null) {
      map['hlc'] = Variable<String>(hlc);
    }
    if (!nullToAbsent || serverVersion != null) {
      map['server_version'] = Variable<int>(serverVersion);
    }
    if (!nullToAbsent || updatedBy != null) {
      map['updated_by'] = Variable<String>(updatedBy);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || quantityText != null) {
      map['quantity_text'] = Variable<String>(quantityText);
    }
    if (!nullToAbsent || store != null) {
      map['store'] = Variable<String>(store);
    }
    map['is_bought'] = Variable<bool>(isBought);
    if (!nullToAbsent || boughtAt != null) {
      map['bought_at'] = Variable<DateTime>(boughtAt);
    }
    if (!nullToAbsent || clearedAt != null) {
      map['cleared_at'] = Variable<DateTime>(clearedAt);
    }
    if (!nullToAbsent || plannedOn != null) {
      map['planned_on'] = Variable<String>(plannedOn);
    }
    if (!nullToAbsent || requestedBy != null) {
      map['requested_by'] = Variable<String>(requestedBy);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  GroceryItemsCompanion toCompanion(bool nullToAbsent) {
    return GroceryItemsCompanion(
      id: Value(id),
      householdId: Value(householdId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      hlc: hlc == null && nullToAbsent ? const Value.absent() : Value(hlc),
      serverVersion: serverVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(serverVersion),
      updatedBy: updatedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedBy),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      name: Value(name),
      quantityText: quantityText == null && nullToAbsent
          ? const Value.absent()
          : Value(quantityText),
      store: store == null && nullToAbsent
          ? const Value.absent()
          : Value(store),
      isBought: Value(isBought),
      boughtAt: boughtAt == null && nullToAbsent
          ? const Value.absent()
          : Value(boughtAt),
      clearedAt: clearedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(clearedAt),
      plannedOn: plannedOn == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedOn),
      requestedBy: requestedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(requestedBy),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory GroceryItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GroceryItem(
      id: serializer.fromJson<String>(json['id']),
      householdId: serializer.fromJson<String>(json['householdId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      hlc: serializer.fromJson<String?>(json['hlc']),
      serverVersion: serializer.fromJson<int?>(json['serverVersion']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      name: serializer.fromJson<String>(json['name']),
      quantityText: serializer.fromJson<String?>(json['quantityText']),
      store: serializer.fromJson<String?>(json['store']),
      isBought: serializer.fromJson<bool>(json['isBought']),
      boughtAt: serializer.fromJson<DateTime?>(json['boughtAt']),
      clearedAt: serializer.fromJson<DateTime?>(json['clearedAt']),
      plannedOn: serializer.fromJson<String?>(json['plannedOn']),
      requestedBy: serializer.fromJson<String?>(json['requestedBy']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'householdId': serializer.toJson<String>(householdId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'hlc': serializer.toJson<String?>(hlc),
      'serverVersion': serializer.toJson<int?>(serverVersion),
      'updatedBy': serializer.toJson<String?>(updatedBy),
      'deviceId': serializer.toJson<String?>(deviceId),
      'name': serializer.toJson<String>(name),
      'quantityText': serializer.toJson<String?>(quantityText),
      'store': serializer.toJson<String?>(store),
      'isBought': serializer.toJson<bool>(isBought),
      'boughtAt': serializer.toJson<DateTime?>(boughtAt),
      'clearedAt': serializer.toJson<DateTime?>(clearedAt),
      'plannedOn': serializer.toJson<String?>(plannedOn),
      'requestedBy': serializer.toJson<String?>(requestedBy),
      'note': serializer.toJson<String?>(note),
    };
  }

  GroceryItem copyWith({
    String? id,
    String? householdId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> hlc = const Value.absent(),
    Value<int?> serverVersion = const Value.absent(),
    Value<String?> updatedBy = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
    String? name,
    Value<String?> quantityText = const Value.absent(),
    Value<String?> store = const Value.absent(),
    bool? isBought,
    Value<DateTime?> boughtAt = const Value.absent(),
    Value<DateTime?> clearedAt = const Value.absent(),
    Value<String?> plannedOn = const Value.absent(),
    Value<String?> requestedBy = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) => GroceryItem(
    id: id ?? this.id,
    householdId: householdId ?? this.householdId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    hlc: hlc.present ? hlc.value : this.hlc,
    serverVersion: serverVersion.present
        ? serverVersion.value
        : this.serverVersion,
    updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    name: name ?? this.name,
    quantityText: quantityText.present ? quantityText.value : this.quantityText,
    store: store.present ? store.value : this.store,
    isBought: isBought ?? this.isBought,
    boughtAt: boughtAt.present ? boughtAt.value : this.boughtAt,
    clearedAt: clearedAt.present ? clearedAt.value : this.clearedAt,
    plannedOn: plannedOn.present ? plannedOn.value : this.plannedOn,
    requestedBy: requestedBy.present ? requestedBy.value : this.requestedBy,
    note: note.present ? note.value : this.note,
  );
  GroceryItem copyWithCompanion(GroceryItemsCompanion data) {
    return GroceryItem(
      id: data.id.present ? data.id.value : this.id,
      householdId: data.householdId.present
          ? data.householdId.value
          : this.householdId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      serverVersion: data.serverVersion.present
          ? data.serverVersion.value
          : this.serverVersion,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      name: data.name.present ? data.name.value : this.name,
      quantityText: data.quantityText.present
          ? data.quantityText.value
          : this.quantityText,
      store: data.store.present ? data.store.value : this.store,
      isBought: data.isBought.present ? data.isBought.value : this.isBought,
      boughtAt: data.boughtAt.present ? data.boughtAt.value : this.boughtAt,
      clearedAt: data.clearedAt.present ? data.clearedAt.value : this.clearedAt,
      plannedOn: data.plannedOn.present ? data.plannedOn.value : this.plannedOn,
      requestedBy: data.requestedBy.present
          ? data.requestedBy.value
          : this.requestedBy,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GroceryItem(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('hlc: $hlc, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deviceId: $deviceId, ')
          ..write('name: $name, ')
          ..write('quantityText: $quantityText, ')
          ..write('store: $store, ')
          ..write('isBought: $isBought, ')
          ..write('boughtAt: $boughtAt, ')
          ..write('clearedAt: $clearedAt, ')
          ..write('plannedOn: $plannedOn, ')
          ..write('requestedBy: $requestedBy, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    householdId,
    createdAt,
    updatedAt,
    deletedAt,
    hlc,
    serverVersion,
    updatedBy,
    deviceId,
    name,
    quantityText,
    store,
    isBought,
    boughtAt,
    clearedAt,
    plannedOn,
    requestedBy,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroceryItem &&
          other.id == this.id &&
          other.householdId == this.householdId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.hlc == this.hlc &&
          other.serverVersion == this.serverVersion &&
          other.updatedBy == this.updatedBy &&
          other.deviceId == this.deviceId &&
          other.name == this.name &&
          other.quantityText == this.quantityText &&
          other.store == this.store &&
          other.isBought == this.isBought &&
          other.boughtAt == this.boughtAt &&
          other.clearedAt == this.clearedAt &&
          other.plannedOn == this.plannedOn &&
          other.requestedBy == this.requestedBy &&
          other.note == this.note);
}

class GroceryItemsCompanion extends UpdateCompanion<GroceryItem> {
  final Value<String> id;
  final Value<String> householdId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> hlc;
  final Value<int?> serverVersion;
  final Value<String?> updatedBy;
  final Value<String?> deviceId;
  final Value<String> name;
  final Value<String?> quantityText;
  final Value<String?> store;
  final Value<bool> isBought;
  final Value<DateTime?> boughtAt;
  final Value<DateTime?> clearedAt;
  final Value<String?> plannedOn;
  final Value<String?> requestedBy;
  final Value<String?> note;
  final Value<int> rowid;
  const GroceryItemsCompanion({
    this.id = const Value.absent(),
    this.householdId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.hlc = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.name = const Value.absent(),
    this.quantityText = const Value.absent(),
    this.store = const Value.absent(),
    this.isBought = const Value.absent(),
    this.boughtAt = const Value.absent(),
    this.clearedAt = const Value.absent(),
    this.plannedOn = const Value.absent(),
    this.requestedBy = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GroceryItemsCompanion.insert({
    required String id,
    required String householdId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.hlc = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.deviceId = const Value.absent(),
    required String name,
    this.quantityText = const Value.absent(),
    this.store = const Value.absent(),
    this.isBought = const Value.absent(),
    this.boughtAt = const Value.absent(),
    this.clearedAt = const Value.absent(),
    this.plannedOn = const Value.absent(),
    this.requestedBy = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       householdId = Value(householdId),
       name = Value(name);
  static Insertable<GroceryItem> custom({
    Expression<String>? id,
    Expression<String>? householdId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? hlc,
    Expression<int>? serverVersion,
    Expression<String>? updatedBy,
    Expression<String>? deviceId,
    Expression<String>? name,
    Expression<String>? quantityText,
    Expression<String>? store,
    Expression<bool>? isBought,
    Expression<DateTime>? boughtAt,
    Expression<DateTime>? clearedAt,
    Expression<String>? plannedOn,
    Expression<String>? requestedBy,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (householdId != null) 'household_id': householdId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (hlc != null) 'hlc': hlc,
      if (serverVersion != null) 'server_version': serverVersion,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (deviceId != null) 'device_id': deviceId,
      if (name != null) 'name': name,
      if (quantityText != null) 'quantity_text': quantityText,
      if (store != null) 'store': store,
      if (isBought != null) 'is_bought': isBought,
      if (boughtAt != null) 'bought_at': boughtAt,
      if (clearedAt != null) 'cleared_at': clearedAt,
      if (plannedOn != null) 'planned_on': plannedOn,
      if (requestedBy != null) 'requested_by': requestedBy,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GroceryItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? householdId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? hlc,
    Value<int?>? serverVersion,
    Value<String?>? updatedBy,
    Value<String?>? deviceId,
    Value<String>? name,
    Value<String?>? quantityText,
    Value<String?>? store,
    Value<bool>? isBought,
    Value<DateTime?>? boughtAt,
    Value<DateTime?>? clearedAt,
    Value<String?>? plannedOn,
    Value<String?>? requestedBy,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return GroceryItemsCompanion(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      hlc: hlc ?? this.hlc,
      serverVersion: serverVersion ?? this.serverVersion,
      updatedBy: updatedBy ?? this.updatedBy,
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      quantityText: quantityText ?? this.quantityText,
      store: store ?? this.store,
      isBought: isBought ?? this.isBought,
      boughtAt: boughtAt ?? this.boughtAt,
      clearedAt: clearedAt ?? this.clearedAt,
      plannedOn: plannedOn ?? this.plannedOn,
      requestedBy: requestedBy ?? this.requestedBy,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (serverVersion.present) {
      map['server_version'] = Variable<int>(serverVersion.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (quantityText.present) {
      map['quantity_text'] = Variable<String>(quantityText.value);
    }
    if (store.present) {
      map['store'] = Variable<String>(store.value);
    }
    if (isBought.present) {
      map['is_bought'] = Variable<bool>(isBought.value);
    }
    if (boughtAt.present) {
      map['bought_at'] = Variable<DateTime>(boughtAt.value);
    }
    if (clearedAt.present) {
      map['cleared_at'] = Variable<DateTime>(clearedAt.value);
    }
    if (plannedOn.present) {
      map['planned_on'] = Variable<String>(plannedOn.value);
    }
    if (requestedBy.present) {
      map['requested_by'] = Variable<String>(requestedBy.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroceryItemsCompanion(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('hlc: $hlc, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deviceId: $deviceId, ')
          ..write('name: $name, ')
          ..write('quantityText: $quantityText, ')
          ..write('store: $store, ')
          ..write('isBought: $isBought, ')
          ..write('boughtAt: $boughtAt, ')
          ..write('clearedAt: $clearedAt, ')
          ..write('plannedOn: $plannedOn, ')
          ..write('requestedBy: $requestedBy, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PantryItemsTable extends PantryItems
    with TableInfo<$PantryItemsTable, PantryItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PantryItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _householdIdMeta = const VerificationMeta(
    'householdId',
  );
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
    'household_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverVersionMeta = const VerificationMeta(
    'serverVersion',
  );
  @override
  late final GeneratedColumn<int> serverVersion = GeneratedColumn<int>(
    'server_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _minQuantityMeta = const VerificationMeta(
    'minQuantity',
  );
  @override
  late final GeneratedColumn<double> minQuantity = GeneratedColumn<double>(
    'min_quantity',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expiresOnMeta = const VerificationMeta(
    'expiresOn',
  );
  @override
  late final GeneratedColumn<String> expiresOn = GeneratedColumn<String>(
    'expires_on',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    householdId,
    createdAt,
    updatedAt,
    deletedAt,
    hlc,
    serverVersion,
    updatedBy,
    deviceId,
    name,
    unit,
    quantity,
    minQuantity,
    location,
    expiresOn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pantry_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<PantryItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
        _householdIdMeta,
        householdId.isAcceptableOrUnknown(
          data['household_id']!,
          _householdIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    }
    if (data.containsKey('server_version')) {
      context.handle(
        _serverVersionMeta,
        serverVersion.isAcceptableOrUnknown(
          data['server_version']!,
          _serverVersionMeta,
        ),
      );
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('min_quantity')) {
      context.handle(
        _minQuantityMeta,
        minQuantity.isAcceptableOrUnknown(
          data['min_quantity']!,
          _minQuantityMeta,
        ),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('expires_on')) {
      context.handle(
        _expiresOnMeta,
        expiresOn.isAcceptableOrUnknown(data['expires_on']!, _expiresOnMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PantryItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PantryItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      householdId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}household_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      ),
      serverVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_version'],
      ),
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      ),
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      minQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}min_quantity'],
      ),
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      expiresOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expires_on'],
      ),
    );
  }

  @override
  $PantryItemsTable createAlias(String alias) {
    return $PantryItemsTable(attachedDatabase, alias);
  }
}

class PantryItem extends DataClass implements Insertable<PantryItem> {
  final String id;
  final String householdId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? hlc;
  final int? serverVersion;
  final String? updatedBy;
  final String? deviceId;
  final String name;
  final String? unit;
  final double quantity;
  final double? minQuantity;
  final String? location;

  /// Calendar date `YYYY-MM-DD`, kept as text so time zones never shift it.
  final String? expiresOn;
  const PantryItem({
    required this.id,
    required this.householdId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.hlc,
    this.serverVersion,
    this.updatedBy,
    this.deviceId,
    required this.name,
    this.unit,
    required this.quantity,
    this.minQuantity,
    this.location,
    this.expiresOn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['household_id'] = Variable<String>(householdId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || hlc != null) {
      map['hlc'] = Variable<String>(hlc);
    }
    if (!nullToAbsent || serverVersion != null) {
      map['server_version'] = Variable<int>(serverVersion);
    }
    if (!nullToAbsent || updatedBy != null) {
      map['updated_by'] = Variable<String>(updatedBy);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(unit);
    }
    map['quantity'] = Variable<double>(quantity);
    if (!nullToAbsent || minQuantity != null) {
      map['min_quantity'] = Variable<double>(minQuantity);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || expiresOn != null) {
      map['expires_on'] = Variable<String>(expiresOn);
    }
    return map;
  }

  PantryItemsCompanion toCompanion(bool nullToAbsent) {
    return PantryItemsCompanion(
      id: Value(id),
      householdId: Value(householdId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      hlc: hlc == null && nullToAbsent ? const Value.absent() : Value(hlc),
      serverVersion: serverVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(serverVersion),
      updatedBy: updatedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedBy),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      name: Value(name),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
      quantity: Value(quantity),
      minQuantity: minQuantity == null && nullToAbsent
          ? const Value.absent()
          : Value(minQuantity),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      expiresOn: expiresOn == null && nullToAbsent
          ? const Value.absent()
          : Value(expiresOn),
    );
  }

  factory PantryItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PantryItem(
      id: serializer.fromJson<String>(json['id']),
      householdId: serializer.fromJson<String>(json['householdId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      hlc: serializer.fromJson<String?>(json['hlc']),
      serverVersion: serializer.fromJson<int?>(json['serverVersion']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      name: serializer.fromJson<String>(json['name']),
      unit: serializer.fromJson<String?>(json['unit']),
      quantity: serializer.fromJson<double>(json['quantity']),
      minQuantity: serializer.fromJson<double?>(json['minQuantity']),
      location: serializer.fromJson<String?>(json['location']),
      expiresOn: serializer.fromJson<String?>(json['expiresOn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'householdId': serializer.toJson<String>(householdId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'hlc': serializer.toJson<String?>(hlc),
      'serverVersion': serializer.toJson<int?>(serverVersion),
      'updatedBy': serializer.toJson<String?>(updatedBy),
      'deviceId': serializer.toJson<String?>(deviceId),
      'name': serializer.toJson<String>(name),
      'unit': serializer.toJson<String?>(unit),
      'quantity': serializer.toJson<double>(quantity),
      'minQuantity': serializer.toJson<double?>(minQuantity),
      'location': serializer.toJson<String?>(location),
      'expiresOn': serializer.toJson<String?>(expiresOn),
    };
  }

  PantryItem copyWith({
    String? id,
    String? householdId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> hlc = const Value.absent(),
    Value<int?> serverVersion = const Value.absent(),
    Value<String?> updatedBy = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
    String? name,
    Value<String?> unit = const Value.absent(),
    double? quantity,
    Value<double?> minQuantity = const Value.absent(),
    Value<String?> location = const Value.absent(),
    Value<String?> expiresOn = const Value.absent(),
  }) => PantryItem(
    id: id ?? this.id,
    householdId: householdId ?? this.householdId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    hlc: hlc.present ? hlc.value : this.hlc,
    serverVersion: serverVersion.present
        ? serverVersion.value
        : this.serverVersion,
    updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    name: name ?? this.name,
    unit: unit.present ? unit.value : this.unit,
    quantity: quantity ?? this.quantity,
    minQuantity: minQuantity.present ? minQuantity.value : this.minQuantity,
    location: location.present ? location.value : this.location,
    expiresOn: expiresOn.present ? expiresOn.value : this.expiresOn,
  );
  PantryItem copyWithCompanion(PantryItemsCompanion data) {
    return PantryItem(
      id: data.id.present ? data.id.value : this.id,
      householdId: data.householdId.present
          ? data.householdId.value
          : this.householdId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      serverVersion: data.serverVersion.present
          ? data.serverVersion.value
          : this.serverVersion,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      name: data.name.present ? data.name.value : this.name,
      unit: data.unit.present ? data.unit.value : this.unit,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      minQuantity: data.minQuantity.present
          ? data.minQuantity.value
          : this.minQuantity,
      location: data.location.present ? data.location.value : this.location,
      expiresOn: data.expiresOn.present ? data.expiresOn.value : this.expiresOn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PantryItem(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('hlc: $hlc, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deviceId: $deviceId, ')
          ..write('name: $name, ')
          ..write('unit: $unit, ')
          ..write('quantity: $quantity, ')
          ..write('minQuantity: $minQuantity, ')
          ..write('location: $location, ')
          ..write('expiresOn: $expiresOn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    householdId,
    createdAt,
    updatedAt,
    deletedAt,
    hlc,
    serverVersion,
    updatedBy,
    deviceId,
    name,
    unit,
    quantity,
    minQuantity,
    location,
    expiresOn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PantryItem &&
          other.id == this.id &&
          other.householdId == this.householdId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.hlc == this.hlc &&
          other.serverVersion == this.serverVersion &&
          other.updatedBy == this.updatedBy &&
          other.deviceId == this.deviceId &&
          other.name == this.name &&
          other.unit == this.unit &&
          other.quantity == this.quantity &&
          other.minQuantity == this.minQuantity &&
          other.location == this.location &&
          other.expiresOn == this.expiresOn);
}

class PantryItemsCompanion extends UpdateCompanion<PantryItem> {
  final Value<String> id;
  final Value<String> householdId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> hlc;
  final Value<int?> serverVersion;
  final Value<String?> updatedBy;
  final Value<String?> deviceId;
  final Value<String> name;
  final Value<String?> unit;
  final Value<double> quantity;
  final Value<double?> minQuantity;
  final Value<String?> location;
  final Value<String?> expiresOn;
  final Value<int> rowid;
  const PantryItemsCompanion({
    this.id = const Value.absent(),
    this.householdId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.hlc = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.name = const Value.absent(),
    this.unit = const Value.absent(),
    this.quantity = const Value.absent(),
    this.minQuantity = const Value.absent(),
    this.location = const Value.absent(),
    this.expiresOn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PantryItemsCompanion.insert({
    required String id,
    required String householdId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.hlc = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.deviceId = const Value.absent(),
    required String name,
    this.unit = const Value.absent(),
    this.quantity = const Value.absent(),
    this.minQuantity = const Value.absent(),
    this.location = const Value.absent(),
    this.expiresOn = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       householdId = Value(householdId),
       name = Value(name);
  static Insertable<PantryItem> custom({
    Expression<String>? id,
    Expression<String>? householdId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? hlc,
    Expression<int>? serverVersion,
    Expression<String>? updatedBy,
    Expression<String>? deviceId,
    Expression<String>? name,
    Expression<String>? unit,
    Expression<double>? quantity,
    Expression<double>? minQuantity,
    Expression<String>? location,
    Expression<String>? expiresOn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (householdId != null) 'household_id': householdId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (hlc != null) 'hlc': hlc,
      if (serverVersion != null) 'server_version': serverVersion,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (deviceId != null) 'device_id': deviceId,
      if (name != null) 'name': name,
      if (unit != null) 'unit': unit,
      if (quantity != null) 'quantity': quantity,
      if (minQuantity != null) 'min_quantity': minQuantity,
      if (location != null) 'location': location,
      if (expiresOn != null) 'expires_on': expiresOn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PantryItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? householdId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? hlc,
    Value<int?>? serverVersion,
    Value<String?>? updatedBy,
    Value<String?>? deviceId,
    Value<String>? name,
    Value<String?>? unit,
    Value<double>? quantity,
    Value<double?>? minQuantity,
    Value<String?>? location,
    Value<String?>? expiresOn,
    Value<int>? rowid,
  }) {
    return PantryItemsCompanion(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      hlc: hlc ?? this.hlc,
      serverVersion: serverVersion ?? this.serverVersion,
      updatedBy: updatedBy ?? this.updatedBy,
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      minQuantity: minQuantity ?? this.minQuantity,
      location: location ?? this.location,
      expiresOn: expiresOn ?? this.expiresOn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (serverVersion.present) {
      map['server_version'] = Variable<int>(serverVersion.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (minQuantity.present) {
      map['min_quantity'] = Variable<double>(minQuantity.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (expiresOn.present) {
      map['expires_on'] = Variable<String>(expiresOn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PantryItemsCompanion(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('hlc: $hlc, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deviceId: $deviceId, ')
          ..write('name: $name, ')
          ..write('unit: $unit, ')
          ..write('quantity: $quantity, ')
          ..write('minQuantity: $minQuantity, ')
          ..write('location: $location, ')
          ..write('expiresOn: $expiresOn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BillsTable extends Bills with TableInfo<$BillsTable, Bill> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BillsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _householdIdMeta = const VerificationMeta(
    'householdId',
  );
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
    'household_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverVersionMeta = const VerificationMeta(
    'serverVersion',
  );
  @override
  late final GeneratedColumn<int> serverVersion = GeneratedColumn<int>(
    'server_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PHP'),
  );
  static const VerificationMeta _dueOnMeta = const VerificationMeta('dueOn');
  @override
  late final GeneratedColumn<String> dueOn = GeneratedColumn<String>(
    'due_on',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPaidMeta = const VerificationMeta('isPaid');
  @override
  late final GeneratedColumn<bool> isPaid = GeneratedColumn<bool>(
    'is_paid',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_paid" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _paidAtMeta = const VerificationMeta('paidAt');
  @override
  late final GeneratedColumn<DateTime> paidAt = GeneratedColumn<DateTime>(
    'paid_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repeatMeta = const VerificationMeta('repeat');
  @override
  late final GeneratedColumn<String> repeat = GeneratedColumn<String>(
    'repeat',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seriesIdMeta = const VerificationMeta(
    'seriesId',
  );
  @override
  late final GeneratedColumn<String> seriesId = GeneratedColumn<String>(
    'series_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    householdId,
    createdAt,
    updatedAt,
    deletedAt,
    hlc,
    serverVersion,
    updatedBy,
    deviceId,
    name,
    provider,
    amountMinor,
    currency,
    dueOn,
    isPaid,
    paidAt,
    category,
    repeat,
    seriesId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bills';
  @override
  VerificationContext validateIntegrity(
    Insertable<Bill> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
        _householdIdMeta,
        householdId.isAcceptableOrUnknown(
          data['household_id']!,
          _householdIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    }
    if (data.containsKey('server_version')) {
      context.handle(
        _serverVersionMeta,
        serverVersion.isAcceptableOrUnknown(
          data['server_version']!,
          _serverVersionMeta,
        ),
      );
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('due_on')) {
      context.handle(
        _dueOnMeta,
        dueOn.isAcceptableOrUnknown(data['due_on']!, _dueOnMeta),
      );
    }
    if (data.containsKey('is_paid')) {
      context.handle(
        _isPaidMeta,
        isPaid.isAcceptableOrUnknown(data['is_paid']!, _isPaidMeta),
      );
    }
    if (data.containsKey('paid_at')) {
      context.handle(
        _paidAtMeta,
        paidAt.isAcceptableOrUnknown(data['paid_at']!, _paidAtMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('repeat')) {
      context.handle(
        _repeatMeta,
        repeat.isAcceptableOrUnknown(data['repeat']!, _repeatMeta),
      );
    }
    if (data.containsKey('series_id')) {
      context.handle(
        _seriesIdMeta,
        seriesId.isAcceptableOrUnknown(data['series_id']!, _seriesIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Bill map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Bill(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      householdId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}household_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      ),
      serverVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_version'],
      ),
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      ),
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      dueOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}due_on'],
      ),
      isPaid: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_paid'],
      )!,
      paidAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}paid_at'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      repeat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repeat'],
      ),
      seriesId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}series_id'],
      ),
    );
  }

  @override
  $BillsTable createAlias(String alias) {
    return $BillsTable(attachedDatabase, alias);
  }
}

class Bill extends DataClass implements Insertable<Bill> {
  final String id;
  final String householdId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? hlc;
  final int? serverVersion;
  final String? updatedBy;
  final String? deviceId;
  final String name;
  final String? provider;
  final int amountMinor;
  final String currency;

  /// Calendar date `YYYY-MM-DD`.
  final String? dueOn;
  final bool isPaid;
  final DateTime? paidAt;

  /// Budget category the payment is recorded under.
  final String? category;

  /// `monthly` or null (one-off).
  final String? repeat;
  final String? seriesId;
  const Bill({
    required this.id,
    required this.householdId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.hlc,
    this.serverVersion,
    this.updatedBy,
    this.deviceId,
    required this.name,
    this.provider,
    required this.amountMinor,
    required this.currency,
    this.dueOn,
    required this.isPaid,
    this.paidAt,
    this.category,
    this.repeat,
    this.seriesId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['household_id'] = Variable<String>(householdId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || hlc != null) {
      map['hlc'] = Variable<String>(hlc);
    }
    if (!nullToAbsent || serverVersion != null) {
      map['server_version'] = Variable<int>(serverVersion);
    }
    if (!nullToAbsent || updatedBy != null) {
      map['updated_by'] = Variable<String>(updatedBy);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || provider != null) {
      map['provider'] = Variable<String>(provider);
    }
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || dueOn != null) {
      map['due_on'] = Variable<String>(dueOn);
    }
    map['is_paid'] = Variable<bool>(isPaid);
    if (!nullToAbsent || paidAt != null) {
      map['paid_at'] = Variable<DateTime>(paidAt);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || repeat != null) {
      map['repeat'] = Variable<String>(repeat);
    }
    if (!nullToAbsent || seriesId != null) {
      map['series_id'] = Variable<String>(seriesId);
    }
    return map;
  }

  BillsCompanion toCompanion(bool nullToAbsent) {
    return BillsCompanion(
      id: Value(id),
      householdId: Value(householdId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      hlc: hlc == null && nullToAbsent ? const Value.absent() : Value(hlc),
      serverVersion: serverVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(serverVersion),
      updatedBy: updatedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedBy),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      name: Value(name),
      provider: provider == null && nullToAbsent
          ? const Value.absent()
          : Value(provider),
      amountMinor: Value(amountMinor),
      currency: Value(currency),
      dueOn: dueOn == null && nullToAbsent
          ? const Value.absent()
          : Value(dueOn),
      isPaid: Value(isPaid),
      paidAt: paidAt == null && nullToAbsent
          ? const Value.absent()
          : Value(paidAt),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      repeat: repeat == null && nullToAbsent
          ? const Value.absent()
          : Value(repeat),
      seriesId: seriesId == null && nullToAbsent
          ? const Value.absent()
          : Value(seriesId),
    );
  }

  factory Bill.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Bill(
      id: serializer.fromJson<String>(json['id']),
      householdId: serializer.fromJson<String>(json['householdId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      hlc: serializer.fromJson<String?>(json['hlc']),
      serverVersion: serializer.fromJson<int?>(json['serverVersion']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      name: serializer.fromJson<String>(json['name']),
      provider: serializer.fromJson<String?>(json['provider']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      dueOn: serializer.fromJson<String?>(json['dueOn']),
      isPaid: serializer.fromJson<bool>(json['isPaid']),
      paidAt: serializer.fromJson<DateTime?>(json['paidAt']),
      category: serializer.fromJson<String?>(json['category']),
      repeat: serializer.fromJson<String?>(json['repeat']),
      seriesId: serializer.fromJson<String?>(json['seriesId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'householdId': serializer.toJson<String>(householdId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'hlc': serializer.toJson<String?>(hlc),
      'serverVersion': serializer.toJson<int?>(serverVersion),
      'updatedBy': serializer.toJson<String?>(updatedBy),
      'deviceId': serializer.toJson<String?>(deviceId),
      'name': serializer.toJson<String>(name),
      'provider': serializer.toJson<String?>(provider),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currency': serializer.toJson<String>(currency),
      'dueOn': serializer.toJson<String?>(dueOn),
      'isPaid': serializer.toJson<bool>(isPaid),
      'paidAt': serializer.toJson<DateTime?>(paidAt),
      'category': serializer.toJson<String?>(category),
      'repeat': serializer.toJson<String?>(repeat),
      'seriesId': serializer.toJson<String?>(seriesId),
    };
  }

  Bill copyWith({
    String? id,
    String? householdId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> hlc = const Value.absent(),
    Value<int?> serverVersion = const Value.absent(),
    Value<String?> updatedBy = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
    String? name,
    Value<String?> provider = const Value.absent(),
    int? amountMinor,
    String? currency,
    Value<String?> dueOn = const Value.absent(),
    bool? isPaid,
    Value<DateTime?> paidAt = const Value.absent(),
    Value<String?> category = const Value.absent(),
    Value<String?> repeat = const Value.absent(),
    Value<String?> seriesId = const Value.absent(),
  }) => Bill(
    id: id ?? this.id,
    householdId: householdId ?? this.householdId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    hlc: hlc.present ? hlc.value : this.hlc,
    serverVersion: serverVersion.present
        ? serverVersion.value
        : this.serverVersion,
    updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    name: name ?? this.name,
    provider: provider.present ? provider.value : this.provider,
    amountMinor: amountMinor ?? this.amountMinor,
    currency: currency ?? this.currency,
    dueOn: dueOn.present ? dueOn.value : this.dueOn,
    isPaid: isPaid ?? this.isPaid,
    paidAt: paidAt.present ? paidAt.value : this.paidAt,
    category: category.present ? category.value : this.category,
    repeat: repeat.present ? repeat.value : this.repeat,
    seriesId: seriesId.present ? seriesId.value : this.seriesId,
  );
  Bill copyWithCompanion(BillsCompanion data) {
    return Bill(
      id: data.id.present ? data.id.value : this.id,
      householdId: data.householdId.present
          ? data.householdId.value
          : this.householdId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      serverVersion: data.serverVersion.present
          ? data.serverVersion.value
          : this.serverVersion,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      name: data.name.present ? data.name.value : this.name,
      provider: data.provider.present ? data.provider.value : this.provider,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      dueOn: data.dueOn.present ? data.dueOn.value : this.dueOn,
      isPaid: data.isPaid.present ? data.isPaid.value : this.isPaid,
      paidAt: data.paidAt.present ? data.paidAt.value : this.paidAt,
      category: data.category.present ? data.category.value : this.category,
      repeat: data.repeat.present ? data.repeat.value : this.repeat,
      seriesId: data.seriesId.present ? data.seriesId.value : this.seriesId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Bill(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('hlc: $hlc, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deviceId: $deviceId, ')
          ..write('name: $name, ')
          ..write('provider: $provider, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('dueOn: $dueOn, ')
          ..write('isPaid: $isPaid, ')
          ..write('paidAt: $paidAt, ')
          ..write('category: $category, ')
          ..write('repeat: $repeat, ')
          ..write('seriesId: $seriesId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    householdId,
    createdAt,
    updatedAt,
    deletedAt,
    hlc,
    serverVersion,
    updatedBy,
    deviceId,
    name,
    provider,
    amountMinor,
    currency,
    dueOn,
    isPaid,
    paidAt,
    category,
    repeat,
    seriesId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Bill &&
          other.id == this.id &&
          other.householdId == this.householdId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.hlc == this.hlc &&
          other.serverVersion == this.serverVersion &&
          other.updatedBy == this.updatedBy &&
          other.deviceId == this.deviceId &&
          other.name == this.name &&
          other.provider == this.provider &&
          other.amountMinor == this.amountMinor &&
          other.currency == this.currency &&
          other.dueOn == this.dueOn &&
          other.isPaid == this.isPaid &&
          other.paidAt == this.paidAt &&
          other.category == this.category &&
          other.repeat == this.repeat &&
          other.seriesId == this.seriesId);
}

class BillsCompanion extends UpdateCompanion<Bill> {
  final Value<String> id;
  final Value<String> householdId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> hlc;
  final Value<int?> serverVersion;
  final Value<String?> updatedBy;
  final Value<String?> deviceId;
  final Value<String> name;
  final Value<String?> provider;
  final Value<int> amountMinor;
  final Value<String> currency;
  final Value<String?> dueOn;
  final Value<bool> isPaid;
  final Value<DateTime?> paidAt;
  final Value<String?> category;
  final Value<String?> repeat;
  final Value<String?> seriesId;
  final Value<int> rowid;
  const BillsCompanion({
    this.id = const Value.absent(),
    this.householdId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.hlc = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.name = const Value.absent(),
    this.provider = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.dueOn = const Value.absent(),
    this.isPaid = const Value.absent(),
    this.paidAt = const Value.absent(),
    this.category = const Value.absent(),
    this.repeat = const Value.absent(),
    this.seriesId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BillsCompanion.insert({
    required String id,
    required String householdId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.hlc = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.deviceId = const Value.absent(),
    required String name,
    this.provider = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.dueOn = const Value.absent(),
    this.isPaid = const Value.absent(),
    this.paidAt = const Value.absent(),
    this.category = const Value.absent(),
    this.repeat = const Value.absent(),
    this.seriesId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       householdId = Value(householdId),
       name = Value(name);
  static Insertable<Bill> custom({
    Expression<String>? id,
    Expression<String>? householdId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? hlc,
    Expression<int>? serverVersion,
    Expression<String>? updatedBy,
    Expression<String>? deviceId,
    Expression<String>? name,
    Expression<String>? provider,
    Expression<int>? amountMinor,
    Expression<String>? currency,
    Expression<String>? dueOn,
    Expression<bool>? isPaid,
    Expression<DateTime>? paidAt,
    Expression<String>? category,
    Expression<String>? repeat,
    Expression<String>? seriesId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (householdId != null) 'household_id': householdId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (hlc != null) 'hlc': hlc,
      if (serverVersion != null) 'server_version': serverVersion,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (deviceId != null) 'device_id': deviceId,
      if (name != null) 'name': name,
      if (provider != null) 'provider': provider,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currency != null) 'currency': currency,
      if (dueOn != null) 'due_on': dueOn,
      if (isPaid != null) 'is_paid': isPaid,
      if (paidAt != null) 'paid_at': paidAt,
      if (category != null) 'category': category,
      if (repeat != null) 'repeat': repeat,
      if (seriesId != null) 'series_id': seriesId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BillsCompanion copyWith({
    Value<String>? id,
    Value<String>? householdId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? hlc,
    Value<int?>? serverVersion,
    Value<String?>? updatedBy,
    Value<String?>? deviceId,
    Value<String>? name,
    Value<String?>? provider,
    Value<int>? amountMinor,
    Value<String>? currency,
    Value<String?>? dueOn,
    Value<bool>? isPaid,
    Value<DateTime?>? paidAt,
    Value<String?>? category,
    Value<String?>? repeat,
    Value<String?>? seriesId,
    Value<int>? rowid,
  }) {
    return BillsCompanion(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      hlc: hlc ?? this.hlc,
      serverVersion: serverVersion ?? this.serverVersion,
      updatedBy: updatedBy ?? this.updatedBy,
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      provider: provider ?? this.provider,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      dueOn: dueOn ?? this.dueOn,
      isPaid: isPaid ?? this.isPaid,
      paidAt: paidAt ?? this.paidAt,
      category: category ?? this.category,
      repeat: repeat ?? this.repeat,
      seriesId: seriesId ?? this.seriesId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (serverVersion.present) {
      map['server_version'] = Variable<int>(serverVersion.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (dueOn.present) {
      map['due_on'] = Variable<String>(dueOn.value);
    }
    if (isPaid.present) {
      map['is_paid'] = Variable<bool>(isPaid.value);
    }
    if (paidAt.present) {
      map['paid_at'] = Variable<DateTime>(paidAt.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (repeat.present) {
      map['repeat'] = Variable<String>(repeat.value);
    }
    if (seriesId.present) {
      map['series_id'] = Variable<String>(seriesId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BillsCompanion(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('hlc: $hlc, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deviceId: $deviceId, ')
          ..write('name: $name, ')
          ..write('provider: $provider, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('dueOn: $dueOn, ')
          ..write('isPaid: $isPaid, ')
          ..write('paidAt: $paidAt, ')
          ..write('category: $category, ')
          ..write('repeat: $repeat, ')
          ..write('seriesId: $seriesId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SubscriptionsTable extends Subscriptions
    with TableInfo<$SubscriptionsTable, Subscription> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubscriptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _householdIdMeta = const VerificationMeta(
    'householdId',
  );
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
    'household_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverVersionMeta = const VerificationMeta(
    'serverVersion',
  );
  @override
  late final GeneratedColumn<int> serverVersion = GeneratedColumn<int>(
    'server_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceMinorMeta = const VerificationMeta(
    'priceMinor',
  );
  @override
  late final GeneratedColumn<int> priceMinor = GeneratedColumn<int>(
    'price_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PHP'),
  );
  static const VerificationMeta _cycleMeta = const VerificationMeta('cycle');
  @override
  late final GeneratedColumn<String> cycle = GeneratedColumn<String>(
    'cycle',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('monthly'),
  );
  static const VerificationMeta _nextDueOnMeta = const VerificationMeta(
    'nextDueOn',
  );
  @override
  late final GeneratedColumn<String> nextDueOn = GeneratedColumn<String>(
    'next_due_on',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    householdId,
    createdAt,
    updatedAt,
    deletedAt,
    hlc,
    serverVersion,
    updatedBy,
    deviceId,
    name,
    priceMinor,
    currency,
    cycle,
    nextDueOn,
    category,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subscriptions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Subscription> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
        _householdIdMeta,
        householdId.isAcceptableOrUnknown(
          data['household_id']!,
          _householdIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    }
    if (data.containsKey('server_version')) {
      context.handle(
        _serverVersionMeta,
        serverVersion.isAcceptableOrUnknown(
          data['server_version']!,
          _serverVersionMeta,
        ),
      );
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('price_minor')) {
      context.handle(
        _priceMinorMeta,
        priceMinor.isAcceptableOrUnknown(data['price_minor']!, _priceMinorMeta),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('cycle')) {
      context.handle(
        _cycleMeta,
        cycle.isAcceptableOrUnknown(data['cycle']!, _cycleMeta),
      );
    }
    if (data.containsKey('next_due_on')) {
      context.handle(
        _nextDueOnMeta,
        nextDueOn.isAcceptableOrUnknown(data['next_due_on']!, _nextDueOnMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Subscription map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Subscription(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      householdId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}household_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      ),
      serverVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_version'],
      ),
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      priceMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price_minor'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      cycle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cycle'],
      )!,
      nextDueOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}next_due_on'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
    );
  }

  @override
  $SubscriptionsTable createAlias(String alias) {
    return $SubscriptionsTable(attachedDatabase, alias);
  }
}

class Subscription extends DataClass implements Insertable<Subscription> {
  final String id;
  final String householdId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? hlc;
  final int? serverVersion;
  final String? updatedBy;
  final String? deviceId;
  final String name;
  final int priceMinor;
  final String currency;

  /// `monthly` or `yearly`.
  final String cycle;

  /// Calendar date `YYYY-MM-DD`.
  final String? nextDueOn;
  final String? category;
  const Subscription({
    required this.id,
    required this.householdId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.hlc,
    this.serverVersion,
    this.updatedBy,
    this.deviceId,
    required this.name,
    required this.priceMinor,
    required this.currency,
    required this.cycle,
    this.nextDueOn,
    this.category,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['household_id'] = Variable<String>(householdId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || hlc != null) {
      map['hlc'] = Variable<String>(hlc);
    }
    if (!nullToAbsent || serverVersion != null) {
      map['server_version'] = Variable<int>(serverVersion);
    }
    if (!nullToAbsent || updatedBy != null) {
      map['updated_by'] = Variable<String>(updatedBy);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['name'] = Variable<String>(name);
    map['price_minor'] = Variable<int>(priceMinor);
    map['currency'] = Variable<String>(currency);
    map['cycle'] = Variable<String>(cycle);
    if (!nullToAbsent || nextDueOn != null) {
      map['next_due_on'] = Variable<String>(nextDueOn);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    return map;
  }

  SubscriptionsCompanion toCompanion(bool nullToAbsent) {
    return SubscriptionsCompanion(
      id: Value(id),
      householdId: Value(householdId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      hlc: hlc == null && nullToAbsent ? const Value.absent() : Value(hlc),
      serverVersion: serverVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(serverVersion),
      updatedBy: updatedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedBy),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      name: Value(name),
      priceMinor: Value(priceMinor),
      currency: Value(currency),
      cycle: Value(cycle),
      nextDueOn: nextDueOn == null && nullToAbsent
          ? const Value.absent()
          : Value(nextDueOn),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
    );
  }

  factory Subscription.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Subscription(
      id: serializer.fromJson<String>(json['id']),
      householdId: serializer.fromJson<String>(json['householdId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      hlc: serializer.fromJson<String?>(json['hlc']),
      serverVersion: serializer.fromJson<int?>(json['serverVersion']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      name: serializer.fromJson<String>(json['name']),
      priceMinor: serializer.fromJson<int>(json['priceMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      cycle: serializer.fromJson<String>(json['cycle']),
      nextDueOn: serializer.fromJson<String?>(json['nextDueOn']),
      category: serializer.fromJson<String?>(json['category']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'householdId': serializer.toJson<String>(householdId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'hlc': serializer.toJson<String?>(hlc),
      'serverVersion': serializer.toJson<int?>(serverVersion),
      'updatedBy': serializer.toJson<String?>(updatedBy),
      'deviceId': serializer.toJson<String?>(deviceId),
      'name': serializer.toJson<String>(name),
      'priceMinor': serializer.toJson<int>(priceMinor),
      'currency': serializer.toJson<String>(currency),
      'cycle': serializer.toJson<String>(cycle),
      'nextDueOn': serializer.toJson<String?>(nextDueOn),
      'category': serializer.toJson<String?>(category),
    };
  }

  Subscription copyWith({
    String? id,
    String? householdId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> hlc = const Value.absent(),
    Value<int?> serverVersion = const Value.absent(),
    Value<String?> updatedBy = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
    String? name,
    int? priceMinor,
    String? currency,
    String? cycle,
    Value<String?> nextDueOn = const Value.absent(),
    Value<String?> category = const Value.absent(),
  }) => Subscription(
    id: id ?? this.id,
    householdId: householdId ?? this.householdId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    hlc: hlc.present ? hlc.value : this.hlc,
    serverVersion: serverVersion.present
        ? serverVersion.value
        : this.serverVersion,
    updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    name: name ?? this.name,
    priceMinor: priceMinor ?? this.priceMinor,
    currency: currency ?? this.currency,
    cycle: cycle ?? this.cycle,
    nextDueOn: nextDueOn.present ? nextDueOn.value : this.nextDueOn,
    category: category.present ? category.value : this.category,
  );
  Subscription copyWithCompanion(SubscriptionsCompanion data) {
    return Subscription(
      id: data.id.present ? data.id.value : this.id,
      householdId: data.householdId.present
          ? data.householdId.value
          : this.householdId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      serverVersion: data.serverVersion.present
          ? data.serverVersion.value
          : this.serverVersion,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      name: data.name.present ? data.name.value : this.name,
      priceMinor: data.priceMinor.present
          ? data.priceMinor.value
          : this.priceMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      cycle: data.cycle.present ? data.cycle.value : this.cycle,
      nextDueOn: data.nextDueOn.present ? data.nextDueOn.value : this.nextDueOn,
      category: data.category.present ? data.category.value : this.category,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Subscription(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('hlc: $hlc, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deviceId: $deviceId, ')
          ..write('name: $name, ')
          ..write('priceMinor: $priceMinor, ')
          ..write('currency: $currency, ')
          ..write('cycle: $cycle, ')
          ..write('nextDueOn: $nextDueOn, ')
          ..write('category: $category')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    householdId,
    createdAt,
    updatedAt,
    deletedAt,
    hlc,
    serverVersion,
    updatedBy,
    deviceId,
    name,
    priceMinor,
    currency,
    cycle,
    nextDueOn,
    category,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Subscription &&
          other.id == this.id &&
          other.householdId == this.householdId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.hlc == this.hlc &&
          other.serverVersion == this.serverVersion &&
          other.updatedBy == this.updatedBy &&
          other.deviceId == this.deviceId &&
          other.name == this.name &&
          other.priceMinor == this.priceMinor &&
          other.currency == this.currency &&
          other.cycle == this.cycle &&
          other.nextDueOn == this.nextDueOn &&
          other.category == this.category);
}

class SubscriptionsCompanion extends UpdateCompanion<Subscription> {
  final Value<String> id;
  final Value<String> householdId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> hlc;
  final Value<int?> serverVersion;
  final Value<String?> updatedBy;
  final Value<String?> deviceId;
  final Value<String> name;
  final Value<int> priceMinor;
  final Value<String> currency;
  final Value<String> cycle;
  final Value<String?> nextDueOn;
  final Value<String?> category;
  final Value<int> rowid;
  const SubscriptionsCompanion({
    this.id = const Value.absent(),
    this.householdId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.hlc = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.name = const Value.absent(),
    this.priceMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.cycle = const Value.absent(),
    this.nextDueOn = const Value.absent(),
    this.category = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubscriptionsCompanion.insert({
    required String id,
    required String householdId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.hlc = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.deviceId = const Value.absent(),
    required String name,
    this.priceMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.cycle = const Value.absent(),
    this.nextDueOn = const Value.absent(),
    this.category = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       householdId = Value(householdId),
       name = Value(name);
  static Insertable<Subscription> custom({
    Expression<String>? id,
    Expression<String>? householdId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? hlc,
    Expression<int>? serverVersion,
    Expression<String>? updatedBy,
    Expression<String>? deviceId,
    Expression<String>? name,
    Expression<int>? priceMinor,
    Expression<String>? currency,
    Expression<String>? cycle,
    Expression<String>? nextDueOn,
    Expression<String>? category,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (householdId != null) 'household_id': householdId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (hlc != null) 'hlc': hlc,
      if (serverVersion != null) 'server_version': serverVersion,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (deviceId != null) 'device_id': deviceId,
      if (name != null) 'name': name,
      if (priceMinor != null) 'price_minor': priceMinor,
      if (currency != null) 'currency': currency,
      if (cycle != null) 'cycle': cycle,
      if (nextDueOn != null) 'next_due_on': nextDueOn,
      if (category != null) 'category': category,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubscriptionsCompanion copyWith({
    Value<String>? id,
    Value<String>? householdId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? hlc,
    Value<int?>? serverVersion,
    Value<String?>? updatedBy,
    Value<String?>? deviceId,
    Value<String>? name,
    Value<int>? priceMinor,
    Value<String>? currency,
    Value<String>? cycle,
    Value<String?>? nextDueOn,
    Value<String?>? category,
    Value<int>? rowid,
  }) {
    return SubscriptionsCompanion(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      hlc: hlc ?? this.hlc,
      serverVersion: serverVersion ?? this.serverVersion,
      updatedBy: updatedBy ?? this.updatedBy,
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      priceMinor: priceMinor ?? this.priceMinor,
      currency: currency ?? this.currency,
      cycle: cycle ?? this.cycle,
      nextDueOn: nextDueOn ?? this.nextDueOn,
      category: category ?? this.category,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (serverVersion.present) {
      map['server_version'] = Variable<int>(serverVersion.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (priceMinor.present) {
      map['price_minor'] = Variable<int>(priceMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (cycle.present) {
      map['cycle'] = Variable<String>(cycle.value);
    }
    if (nextDueOn.present) {
      map['next_due_on'] = Variable<String>(nextDueOn.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubscriptionsCompanion(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('hlc: $hlc, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deviceId: $deviceId, ')
          ..write('name: $name, ')
          ..write('priceMinor: $priceMinor, ')
          ..write('currency: $currency, ')
          ..write('cycle: $cycle, ')
          ..write('nextDueOn: $nextDueOn, ')
          ..write('category: $category, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChoresTable extends Chores with TableInfo<$ChoresTable, Chore> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChoresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _householdIdMeta = const VerificationMeta(
    'householdId',
  );
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
    'household_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverVersionMeta = const VerificationMeta(
    'serverVersion',
  );
  @override
  late final GeneratedColumn<int> serverVersion = GeneratedColumn<int>(
    'server_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assignedToMeta = const VerificationMeta(
    'assignedTo',
  );
  @override
  late final GeneratedColumn<String> assignedTo = GeneratedColumn<String>(
    'assigned_to',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repeatMeta = const VerificationMeta('repeat');
  @override
  late final GeneratedColumn<String> repeat = GeneratedColumn<String>(
    'repeat',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('daily'),
  );
  static const VerificationMeta _weekdayMeta = const VerificationMeta(
    'weekday',
  );
  @override
  late final GeneratedColumn<int> weekday = GeneratedColumn<int>(
    'weekday',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dueOnMeta = const VerificationMeta('dueOn');
  @override
  late final GeneratedColumn<String> dueOn = GeneratedColumn<String>(
    'due_on',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    householdId,
    createdAt,
    updatedAt,
    deletedAt,
    hlc,
    serverVersion,
    updatedBy,
    deviceId,
    name,
    assignedTo,
    repeat,
    weekday,
    dueOn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chores';
  @override
  VerificationContext validateIntegrity(
    Insertable<Chore> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
        _householdIdMeta,
        householdId.isAcceptableOrUnknown(
          data['household_id']!,
          _householdIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    }
    if (data.containsKey('server_version')) {
      context.handle(
        _serverVersionMeta,
        serverVersion.isAcceptableOrUnknown(
          data['server_version']!,
          _serverVersionMeta,
        ),
      );
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('assigned_to')) {
      context.handle(
        _assignedToMeta,
        assignedTo.isAcceptableOrUnknown(data['assigned_to']!, _assignedToMeta),
      );
    }
    if (data.containsKey('repeat')) {
      context.handle(
        _repeatMeta,
        repeat.isAcceptableOrUnknown(data['repeat']!, _repeatMeta),
      );
    }
    if (data.containsKey('weekday')) {
      context.handle(
        _weekdayMeta,
        weekday.isAcceptableOrUnknown(data['weekday']!, _weekdayMeta),
      );
    }
    if (data.containsKey('due_on')) {
      context.handle(
        _dueOnMeta,
        dueOn.isAcceptableOrUnknown(data['due_on']!, _dueOnMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Chore map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Chore(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      householdId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}household_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      ),
      serverVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_version'],
      ),
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      assignedTo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assigned_to'],
      ),
      repeat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repeat'],
      )!,
      weekday: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekday'],
      ),
      dueOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}due_on'],
      ),
    );
  }

  @override
  $ChoresTable createAlias(String alias) {
    return $ChoresTable(attachedDatabase, alias);
  }
}

class Chore extends DataClass implements Insertable<Chore> {
  final String id;
  final String householdId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? hlc;
  final int? serverVersion;
  final String? updatedBy;
  final String? deviceId;
  final String name;

  /// Member id, or null for anyone.
  final String? assignedTo;
  final String repeat;
  final int? weekday;

  /// Calendar date `YYYY-MM-DD` (once).
  final String? dueOn;
  const Chore({
    required this.id,
    required this.householdId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.hlc,
    this.serverVersion,
    this.updatedBy,
    this.deviceId,
    required this.name,
    this.assignedTo,
    required this.repeat,
    this.weekday,
    this.dueOn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['household_id'] = Variable<String>(householdId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || hlc != null) {
      map['hlc'] = Variable<String>(hlc);
    }
    if (!nullToAbsent || serverVersion != null) {
      map['server_version'] = Variable<int>(serverVersion);
    }
    if (!nullToAbsent || updatedBy != null) {
      map['updated_by'] = Variable<String>(updatedBy);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || assignedTo != null) {
      map['assigned_to'] = Variable<String>(assignedTo);
    }
    map['repeat'] = Variable<String>(repeat);
    if (!nullToAbsent || weekday != null) {
      map['weekday'] = Variable<int>(weekday);
    }
    if (!nullToAbsent || dueOn != null) {
      map['due_on'] = Variable<String>(dueOn);
    }
    return map;
  }

  ChoresCompanion toCompanion(bool nullToAbsent) {
    return ChoresCompanion(
      id: Value(id),
      householdId: Value(householdId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      hlc: hlc == null && nullToAbsent ? const Value.absent() : Value(hlc),
      serverVersion: serverVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(serverVersion),
      updatedBy: updatedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedBy),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      name: Value(name),
      assignedTo: assignedTo == null && nullToAbsent
          ? const Value.absent()
          : Value(assignedTo),
      repeat: Value(repeat),
      weekday: weekday == null && nullToAbsent
          ? const Value.absent()
          : Value(weekday),
      dueOn: dueOn == null && nullToAbsent
          ? const Value.absent()
          : Value(dueOn),
    );
  }

  factory Chore.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Chore(
      id: serializer.fromJson<String>(json['id']),
      householdId: serializer.fromJson<String>(json['householdId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      hlc: serializer.fromJson<String?>(json['hlc']),
      serverVersion: serializer.fromJson<int?>(json['serverVersion']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      name: serializer.fromJson<String>(json['name']),
      assignedTo: serializer.fromJson<String?>(json['assignedTo']),
      repeat: serializer.fromJson<String>(json['repeat']),
      weekday: serializer.fromJson<int?>(json['weekday']),
      dueOn: serializer.fromJson<String?>(json['dueOn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'householdId': serializer.toJson<String>(householdId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'hlc': serializer.toJson<String?>(hlc),
      'serverVersion': serializer.toJson<int?>(serverVersion),
      'updatedBy': serializer.toJson<String?>(updatedBy),
      'deviceId': serializer.toJson<String?>(deviceId),
      'name': serializer.toJson<String>(name),
      'assignedTo': serializer.toJson<String?>(assignedTo),
      'repeat': serializer.toJson<String>(repeat),
      'weekday': serializer.toJson<int?>(weekday),
      'dueOn': serializer.toJson<String?>(dueOn),
    };
  }

  Chore copyWith({
    String? id,
    String? householdId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> hlc = const Value.absent(),
    Value<int?> serverVersion = const Value.absent(),
    Value<String?> updatedBy = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
    String? name,
    Value<String?> assignedTo = const Value.absent(),
    String? repeat,
    Value<int?> weekday = const Value.absent(),
    Value<String?> dueOn = const Value.absent(),
  }) => Chore(
    id: id ?? this.id,
    householdId: householdId ?? this.householdId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    hlc: hlc.present ? hlc.value : this.hlc,
    serverVersion: serverVersion.present
        ? serverVersion.value
        : this.serverVersion,
    updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    name: name ?? this.name,
    assignedTo: assignedTo.present ? assignedTo.value : this.assignedTo,
    repeat: repeat ?? this.repeat,
    weekday: weekday.present ? weekday.value : this.weekday,
    dueOn: dueOn.present ? dueOn.value : this.dueOn,
  );
  Chore copyWithCompanion(ChoresCompanion data) {
    return Chore(
      id: data.id.present ? data.id.value : this.id,
      householdId: data.householdId.present
          ? data.householdId.value
          : this.householdId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      serverVersion: data.serverVersion.present
          ? data.serverVersion.value
          : this.serverVersion,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      name: data.name.present ? data.name.value : this.name,
      assignedTo: data.assignedTo.present
          ? data.assignedTo.value
          : this.assignedTo,
      repeat: data.repeat.present ? data.repeat.value : this.repeat,
      weekday: data.weekday.present ? data.weekday.value : this.weekday,
      dueOn: data.dueOn.present ? data.dueOn.value : this.dueOn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Chore(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('hlc: $hlc, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deviceId: $deviceId, ')
          ..write('name: $name, ')
          ..write('assignedTo: $assignedTo, ')
          ..write('repeat: $repeat, ')
          ..write('weekday: $weekday, ')
          ..write('dueOn: $dueOn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    householdId,
    createdAt,
    updatedAt,
    deletedAt,
    hlc,
    serverVersion,
    updatedBy,
    deviceId,
    name,
    assignedTo,
    repeat,
    weekday,
    dueOn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Chore &&
          other.id == this.id &&
          other.householdId == this.householdId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.hlc == this.hlc &&
          other.serverVersion == this.serverVersion &&
          other.updatedBy == this.updatedBy &&
          other.deviceId == this.deviceId &&
          other.name == this.name &&
          other.assignedTo == this.assignedTo &&
          other.repeat == this.repeat &&
          other.weekday == this.weekday &&
          other.dueOn == this.dueOn);
}

class ChoresCompanion extends UpdateCompanion<Chore> {
  final Value<String> id;
  final Value<String> householdId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> hlc;
  final Value<int?> serverVersion;
  final Value<String?> updatedBy;
  final Value<String?> deviceId;
  final Value<String> name;
  final Value<String?> assignedTo;
  final Value<String> repeat;
  final Value<int?> weekday;
  final Value<String?> dueOn;
  final Value<int> rowid;
  const ChoresCompanion({
    this.id = const Value.absent(),
    this.householdId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.hlc = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.name = const Value.absent(),
    this.assignedTo = const Value.absent(),
    this.repeat = const Value.absent(),
    this.weekday = const Value.absent(),
    this.dueOn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChoresCompanion.insert({
    required String id,
    required String householdId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.hlc = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.deviceId = const Value.absent(),
    required String name,
    this.assignedTo = const Value.absent(),
    this.repeat = const Value.absent(),
    this.weekday = const Value.absent(),
    this.dueOn = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       householdId = Value(householdId),
       name = Value(name);
  static Insertable<Chore> custom({
    Expression<String>? id,
    Expression<String>? householdId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? hlc,
    Expression<int>? serverVersion,
    Expression<String>? updatedBy,
    Expression<String>? deviceId,
    Expression<String>? name,
    Expression<String>? assignedTo,
    Expression<String>? repeat,
    Expression<int>? weekday,
    Expression<String>? dueOn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (householdId != null) 'household_id': householdId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (hlc != null) 'hlc': hlc,
      if (serverVersion != null) 'server_version': serverVersion,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (deviceId != null) 'device_id': deviceId,
      if (name != null) 'name': name,
      if (assignedTo != null) 'assigned_to': assignedTo,
      if (repeat != null) 'repeat': repeat,
      if (weekday != null) 'weekday': weekday,
      if (dueOn != null) 'due_on': dueOn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChoresCompanion copyWith({
    Value<String>? id,
    Value<String>? householdId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? hlc,
    Value<int?>? serverVersion,
    Value<String?>? updatedBy,
    Value<String?>? deviceId,
    Value<String>? name,
    Value<String?>? assignedTo,
    Value<String>? repeat,
    Value<int?>? weekday,
    Value<String?>? dueOn,
    Value<int>? rowid,
  }) {
    return ChoresCompanion(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      hlc: hlc ?? this.hlc,
      serverVersion: serverVersion ?? this.serverVersion,
      updatedBy: updatedBy ?? this.updatedBy,
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      assignedTo: assignedTo ?? this.assignedTo,
      repeat: repeat ?? this.repeat,
      weekday: weekday ?? this.weekday,
      dueOn: dueOn ?? this.dueOn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (serverVersion.present) {
      map['server_version'] = Variable<int>(serverVersion.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (assignedTo.present) {
      map['assigned_to'] = Variable<String>(assignedTo.value);
    }
    if (repeat.present) {
      map['repeat'] = Variable<String>(repeat.value);
    }
    if (weekday.present) {
      map['weekday'] = Variable<int>(weekday.value);
    }
    if (dueOn.present) {
      map['due_on'] = Variable<String>(dueOn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChoresCompanion(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('hlc: $hlc, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deviceId: $deviceId, ')
          ..write('name: $name, ')
          ..write('assignedTo: $assignedTo, ')
          ..write('repeat: $repeat, ')
          ..write('weekday: $weekday, ')
          ..write('dueOn: $dueOn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChoreCompletionsTable extends ChoreCompletions
    with TableInfo<$ChoreCompletionsTable, ChoreCompletion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChoreCompletionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _householdIdMeta = const VerificationMeta(
    'householdId',
  );
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
    'household_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverVersionMeta = const VerificationMeta(
    'serverVersion',
  );
  @override
  late final GeneratedColumn<int> serverVersion = GeneratedColumn<int>(
    'server_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _choreIdMeta = const VerificationMeta(
    'choreId',
  );
  @override
  late final GeneratedColumn<String> choreId = GeneratedColumn<String>(
    'chore_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _memberIdMeta = const VerificationMeta(
    'memberId',
  );
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
    'member_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _doneOnMeta = const VerificationMeta('doneOn');
  @override
  late final GeneratedColumn<String> doneOn = GeneratedColumn<String>(
    'done_on',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    householdId,
    createdAt,
    updatedAt,
    deletedAt,
    hlc,
    serverVersion,
    updatedBy,
    deviceId,
    choreId,
    memberId,
    doneOn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chore_completions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChoreCompletion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
        _householdIdMeta,
        householdId.isAcceptableOrUnknown(
          data['household_id']!,
          _householdIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    }
    if (data.containsKey('server_version')) {
      context.handle(
        _serverVersionMeta,
        serverVersion.isAcceptableOrUnknown(
          data['server_version']!,
          _serverVersionMeta,
        ),
      );
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('chore_id')) {
      context.handle(
        _choreIdMeta,
        choreId.isAcceptableOrUnknown(data['chore_id']!, _choreIdMeta),
      );
    } else if (isInserting) {
      context.missing(_choreIdMeta);
    }
    if (data.containsKey('member_id')) {
      context.handle(
        _memberIdMeta,
        memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta),
      );
    }
    if (data.containsKey('done_on')) {
      context.handle(
        _doneOnMeta,
        doneOn.isAcceptableOrUnknown(data['done_on']!, _doneOnMeta),
      );
    } else if (isInserting) {
      context.missing(_doneOnMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChoreCompletion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChoreCompletion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      householdId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}household_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      ),
      serverVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_version'],
      ),
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      choreId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chore_id'],
      )!,
      memberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_id'],
      ),
      doneOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}done_on'],
      )!,
    );
  }

  @override
  $ChoreCompletionsTable createAlias(String alias) {
    return $ChoreCompletionsTable(attachedDatabase, alias);
  }
}

class ChoreCompletion extends DataClass implements Insertable<ChoreCompletion> {
  final String id;
  final String householdId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? hlc;
  final int? serverVersion;
  final String? updatedBy;
  final String? deviceId;
  final String choreId;
  final String? memberId;

  /// Calendar date `YYYY-MM-DD`.
  final String doneOn;
  const ChoreCompletion({
    required this.id,
    required this.householdId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.hlc,
    this.serverVersion,
    this.updatedBy,
    this.deviceId,
    required this.choreId,
    this.memberId,
    required this.doneOn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['household_id'] = Variable<String>(householdId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || hlc != null) {
      map['hlc'] = Variable<String>(hlc);
    }
    if (!nullToAbsent || serverVersion != null) {
      map['server_version'] = Variable<int>(serverVersion);
    }
    if (!nullToAbsent || updatedBy != null) {
      map['updated_by'] = Variable<String>(updatedBy);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['chore_id'] = Variable<String>(choreId);
    if (!nullToAbsent || memberId != null) {
      map['member_id'] = Variable<String>(memberId);
    }
    map['done_on'] = Variable<String>(doneOn);
    return map;
  }

  ChoreCompletionsCompanion toCompanion(bool nullToAbsent) {
    return ChoreCompletionsCompanion(
      id: Value(id),
      householdId: Value(householdId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      hlc: hlc == null && nullToAbsent ? const Value.absent() : Value(hlc),
      serverVersion: serverVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(serverVersion),
      updatedBy: updatedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedBy),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      choreId: Value(choreId),
      memberId: memberId == null && nullToAbsent
          ? const Value.absent()
          : Value(memberId),
      doneOn: Value(doneOn),
    );
  }

  factory ChoreCompletion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChoreCompletion(
      id: serializer.fromJson<String>(json['id']),
      householdId: serializer.fromJson<String>(json['householdId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      hlc: serializer.fromJson<String?>(json['hlc']),
      serverVersion: serializer.fromJson<int?>(json['serverVersion']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      choreId: serializer.fromJson<String>(json['choreId']),
      memberId: serializer.fromJson<String?>(json['memberId']),
      doneOn: serializer.fromJson<String>(json['doneOn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'householdId': serializer.toJson<String>(householdId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'hlc': serializer.toJson<String?>(hlc),
      'serverVersion': serializer.toJson<int?>(serverVersion),
      'updatedBy': serializer.toJson<String?>(updatedBy),
      'deviceId': serializer.toJson<String?>(deviceId),
      'choreId': serializer.toJson<String>(choreId),
      'memberId': serializer.toJson<String?>(memberId),
      'doneOn': serializer.toJson<String>(doneOn),
    };
  }

  ChoreCompletion copyWith({
    String? id,
    String? householdId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> hlc = const Value.absent(),
    Value<int?> serverVersion = const Value.absent(),
    Value<String?> updatedBy = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
    String? choreId,
    Value<String?> memberId = const Value.absent(),
    String? doneOn,
  }) => ChoreCompletion(
    id: id ?? this.id,
    householdId: householdId ?? this.householdId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    hlc: hlc.present ? hlc.value : this.hlc,
    serverVersion: serverVersion.present
        ? serverVersion.value
        : this.serverVersion,
    updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    choreId: choreId ?? this.choreId,
    memberId: memberId.present ? memberId.value : this.memberId,
    doneOn: doneOn ?? this.doneOn,
  );
  ChoreCompletion copyWithCompanion(ChoreCompletionsCompanion data) {
    return ChoreCompletion(
      id: data.id.present ? data.id.value : this.id,
      householdId: data.householdId.present
          ? data.householdId.value
          : this.householdId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      serverVersion: data.serverVersion.present
          ? data.serverVersion.value
          : this.serverVersion,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      choreId: data.choreId.present ? data.choreId.value : this.choreId,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      doneOn: data.doneOn.present ? data.doneOn.value : this.doneOn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChoreCompletion(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('hlc: $hlc, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deviceId: $deviceId, ')
          ..write('choreId: $choreId, ')
          ..write('memberId: $memberId, ')
          ..write('doneOn: $doneOn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    householdId,
    createdAt,
    updatedAt,
    deletedAt,
    hlc,
    serverVersion,
    updatedBy,
    deviceId,
    choreId,
    memberId,
    doneOn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChoreCompletion &&
          other.id == this.id &&
          other.householdId == this.householdId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.hlc == this.hlc &&
          other.serverVersion == this.serverVersion &&
          other.updatedBy == this.updatedBy &&
          other.deviceId == this.deviceId &&
          other.choreId == this.choreId &&
          other.memberId == this.memberId &&
          other.doneOn == this.doneOn);
}

class ChoreCompletionsCompanion extends UpdateCompanion<ChoreCompletion> {
  final Value<String> id;
  final Value<String> householdId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> hlc;
  final Value<int?> serverVersion;
  final Value<String?> updatedBy;
  final Value<String?> deviceId;
  final Value<String> choreId;
  final Value<String?> memberId;
  final Value<String> doneOn;
  final Value<int> rowid;
  const ChoreCompletionsCompanion({
    this.id = const Value.absent(),
    this.householdId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.hlc = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.choreId = const Value.absent(),
    this.memberId = const Value.absent(),
    this.doneOn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChoreCompletionsCompanion.insert({
    required String id,
    required String householdId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.hlc = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.deviceId = const Value.absent(),
    required String choreId,
    this.memberId = const Value.absent(),
    required String doneOn,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       householdId = Value(householdId),
       choreId = Value(choreId),
       doneOn = Value(doneOn);
  static Insertable<ChoreCompletion> custom({
    Expression<String>? id,
    Expression<String>? householdId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? hlc,
    Expression<int>? serverVersion,
    Expression<String>? updatedBy,
    Expression<String>? deviceId,
    Expression<String>? choreId,
    Expression<String>? memberId,
    Expression<String>? doneOn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (householdId != null) 'household_id': householdId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (hlc != null) 'hlc': hlc,
      if (serverVersion != null) 'server_version': serverVersion,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (deviceId != null) 'device_id': deviceId,
      if (choreId != null) 'chore_id': choreId,
      if (memberId != null) 'member_id': memberId,
      if (doneOn != null) 'done_on': doneOn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChoreCompletionsCompanion copyWith({
    Value<String>? id,
    Value<String>? householdId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? hlc,
    Value<int?>? serverVersion,
    Value<String?>? updatedBy,
    Value<String?>? deviceId,
    Value<String>? choreId,
    Value<String?>? memberId,
    Value<String>? doneOn,
    Value<int>? rowid,
  }) {
    return ChoreCompletionsCompanion(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      hlc: hlc ?? this.hlc,
      serverVersion: serverVersion ?? this.serverVersion,
      updatedBy: updatedBy ?? this.updatedBy,
      deviceId: deviceId ?? this.deviceId,
      choreId: choreId ?? this.choreId,
      memberId: memberId ?? this.memberId,
      doneOn: doneOn ?? this.doneOn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (serverVersion.present) {
      map['server_version'] = Variable<int>(serverVersion.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (choreId.present) {
      map['chore_id'] = Variable<String>(choreId.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (doneOn.present) {
      map['done_on'] = Variable<String>(doneOn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChoreCompletionsCompanion(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('hlc: $hlc, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deviceId: $deviceId, ')
          ..write('choreId: $choreId, ')
          ..write('memberId: $memberId, ')
          ..write('doneOn: $doneOn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EventsTable extends Events with TableInfo<$EventsTable, CalendarEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _householdIdMeta = const VerificationMeta(
    'householdId',
  );
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
    'household_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverVersionMeta = const VerificationMeta(
    'serverVersion',
  );
  @override
  late final GeneratedColumn<int> serverVersion = GeneratedColumn<int>(
    'server_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startsOnMeta = const VerificationMeta(
    'startsOn',
  );
  @override
  late final GeneratedColumn<String> startsOn = GeneratedColumn<String>(
    'starts_on',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endsOnMeta = const VerificationMeta('endsOn');
  @override
  late final GeneratedColumn<String> endsOn = GeneratedColumn<String>(
    'ends_on',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<String> startTime = GeneratedColumn<String>(
    'start_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<String> endTime = GeneratedColumn<String>(
    'end_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repeatMeta = const VerificationMeta('repeat');
  @override
  late final GeneratedColumn<String> repeat = GeneratedColumn<String>(
    'repeat',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _memberIdMeta = const VerificationMeta(
    'memberId',
  );
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
    'member_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    householdId,
    createdAt,
    updatedAt,
    deletedAt,
    hlc,
    serverVersion,
    updatedBy,
    deviceId,
    title,
    startsOn,
    endsOn,
    startTime,
    endTime,
    repeat,
    color,
    memberId,
    location,
    note,
    createdBy,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'events';
  @override
  VerificationContext validateIntegrity(
    Insertable<CalendarEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
        _householdIdMeta,
        householdId.isAcceptableOrUnknown(
          data['household_id']!,
          _householdIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    }
    if (data.containsKey('server_version')) {
      context.handle(
        _serverVersionMeta,
        serverVersion.isAcceptableOrUnknown(
          data['server_version']!,
          _serverVersionMeta,
        ),
      );
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('starts_on')) {
      context.handle(
        _startsOnMeta,
        startsOn.isAcceptableOrUnknown(data['starts_on']!, _startsOnMeta),
      );
    } else if (isInserting) {
      context.missing(_startsOnMeta);
    }
    if (data.containsKey('ends_on')) {
      context.handle(
        _endsOnMeta,
        endsOn.isAcceptableOrUnknown(data['ends_on']!, _endsOnMeta),
      );
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    }
    if (data.containsKey('repeat')) {
      context.handle(
        _repeatMeta,
        repeat.isAcceptableOrUnknown(data['repeat']!, _repeatMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('member_id')) {
      context.handle(
        _memberIdMeta,
        memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CalendarEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CalendarEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      householdId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}household_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      ),
      serverVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_version'],
      ),
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      startsOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}starts_on'],
      )!,
      endsOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ends_on'],
      ),
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_time'],
      ),
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_time'],
      ),
      repeat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repeat'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
      memberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_id'],
      ),
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
    );
  }

  @override
  $EventsTable createAlias(String alias) {
    return $EventsTable(attachedDatabase, alias);
  }
}

class CalendarEvent extends DataClass implements Insertable<CalendarEvent> {
  final String id;
  final String householdId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? hlc;
  final int? serverVersion;
  final String? updatedBy;
  final String? deviceId;
  final String title;

  /// Calendar date `YYYY-MM-DD` (the first occurrence).
  final String startsOn;

  /// Last day `YYYY-MM-DD` of a multi-day event's first occurrence; null = one
  /// day. A repeat copies the whole span.
  final String? endsOn;

  /// Local `HH:MM`; null = all day. On a multi-day event the start time is on
  /// the first day and the end time on the last.
  final String? startTime;
  final String? endTime;
  final String repeat;

  /// Palette name (`ube`, `dagat`, `dahon`, `narra`, `rosas`, `tubig`); null =
  /// the default look.
  final String? color;

  /// Who it is for; null = the whole family.
  final String? memberId;
  final String? location;
  final String? note;
  final String? createdBy;
  const CalendarEvent({
    required this.id,
    required this.householdId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.hlc,
    this.serverVersion,
    this.updatedBy,
    this.deviceId,
    required this.title,
    required this.startsOn,
    this.endsOn,
    this.startTime,
    this.endTime,
    required this.repeat,
    this.color,
    this.memberId,
    this.location,
    this.note,
    this.createdBy,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['household_id'] = Variable<String>(householdId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || hlc != null) {
      map['hlc'] = Variable<String>(hlc);
    }
    if (!nullToAbsent || serverVersion != null) {
      map['server_version'] = Variable<int>(serverVersion);
    }
    if (!nullToAbsent || updatedBy != null) {
      map['updated_by'] = Variable<String>(updatedBy);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['title'] = Variable<String>(title);
    map['starts_on'] = Variable<String>(startsOn);
    if (!nullToAbsent || endsOn != null) {
      map['ends_on'] = Variable<String>(endsOn);
    }
    if (!nullToAbsent || startTime != null) {
      map['start_time'] = Variable<String>(startTime);
    }
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<String>(endTime);
    }
    map['repeat'] = Variable<String>(repeat);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    if (!nullToAbsent || memberId != null) {
      map['member_id'] = Variable<String>(memberId);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    return map;
  }

  EventsCompanion toCompanion(bool nullToAbsent) {
    return EventsCompanion(
      id: Value(id),
      householdId: Value(householdId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      hlc: hlc == null && nullToAbsent ? const Value.absent() : Value(hlc),
      serverVersion: serverVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(serverVersion),
      updatedBy: updatedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedBy),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      title: Value(title),
      startsOn: Value(startsOn),
      endsOn: endsOn == null && nullToAbsent
          ? const Value.absent()
          : Value(endsOn),
      startTime: startTime == null && nullToAbsent
          ? const Value.absent()
          : Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      repeat: Value(repeat),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      memberId: memberId == null && nullToAbsent
          ? const Value.absent()
          : Value(memberId),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
    );
  }

  factory CalendarEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CalendarEvent(
      id: serializer.fromJson<String>(json['id']),
      householdId: serializer.fromJson<String>(json['householdId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      hlc: serializer.fromJson<String?>(json['hlc']),
      serverVersion: serializer.fromJson<int?>(json['serverVersion']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      title: serializer.fromJson<String>(json['title']),
      startsOn: serializer.fromJson<String>(json['startsOn']),
      endsOn: serializer.fromJson<String?>(json['endsOn']),
      startTime: serializer.fromJson<String?>(json['startTime']),
      endTime: serializer.fromJson<String?>(json['endTime']),
      repeat: serializer.fromJson<String>(json['repeat']),
      color: serializer.fromJson<String?>(json['color']),
      memberId: serializer.fromJson<String?>(json['memberId']),
      location: serializer.fromJson<String?>(json['location']),
      note: serializer.fromJson<String?>(json['note']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'householdId': serializer.toJson<String>(householdId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'hlc': serializer.toJson<String?>(hlc),
      'serverVersion': serializer.toJson<int?>(serverVersion),
      'updatedBy': serializer.toJson<String?>(updatedBy),
      'deviceId': serializer.toJson<String?>(deviceId),
      'title': serializer.toJson<String>(title),
      'startsOn': serializer.toJson<String>(startsOn),
      'endsOn': serializer.toJson<String?>(endsOn),
      'startTime': serializer.toJson<String?>(startTime),
      'endTime': serializer.toJson<String?>(endTime),
      'repeat': serializer.toJson<String>(repeat),
      'color': serializer.toJson<String?>(color),
      'memberId': serializer.toJson<String?>(memberId),
      'location': serializer.toJson<String?>(location),
      'note': serializer.toJson<String?>(note),
      'createdBy': serializer.toJson<String?>(createdBy),
    };
  }

  CalendarEvent copyWith({
    String? id,
    String? householdId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> hlc = const Value.absent(),
    Value<int?> serverVersion = const Value.absent(),
    Value<String?> updatedBy = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
    String? title,
    String? startsOn,
    Value<String?> endsOn = const Value.absent(),
    Value<String?> startTime = const Value.absent(),
    Value<String?> endTime = const Value.absent(),
    String? repeat,
    Value<String?> color = const Value.absent(),
    Value<String?> memberId = const Value.absent(),
    Value<String?> location = const Value.absent(),
    Value<String?> note = const Value.absent(),
    Value<String?> createdBy = const Value.absent(),
  }) => CalendarEvent(
    id: id ?? this.id,
    householdId: householdId ?? this.householdId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    hlc: hlc.present ? hlc.value : this.hlc,
    serverVersion: serverVersion.present
        ? serverVersion.value
        : this.serverVersion,
    updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    title: title ?? this.title,
    startsOn: startsOn ?? this.startsOn,
    endsOn: endsOn.present ? endsOn.value : this.endsOn,
    startTime: startTime.present ? startTime.value : this.startTime,
    endTime: endTime.present ? endTime.value : this.endTime,
    repeat: repeat ?? this.repeat,
    color: color.present ? color.value : this.color,
    memberId: memberId.present ? memberId.value : this.memberId,
    location: location.present ? location.value : this.location,
    note: note.present ? note.value : this.note,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
  );
  CalendarEvent copyWithCompanion(EventsCompanion data) {
    return CalendarEvent(
      id: data.id.present ? data.id.value : this.id,
      householdId: data.householdId.present
          ? data.householdId.value
          : this.householdId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      serverVersion: data.serverVersion.present
          ? data.serverVersion.value
          : this.serverVersion,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      title: data.title.present ? data.title.value : this.title,
      startsOn: data.startsOn.present ? data.startsOn.value : this.startsOn,
      endsOn: data.endsOn.present ? data.endsOn.value : this.endsOn,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      repeat: data.repeat.present ? data.repeat.value : this.repeat,
      color: data.color.present ? data.color.value : this.color,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      location: data.location.present ? data.location.value : this.location,
      note: data.note.present ? data.note.value : this.note,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CalendarEvent(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('hlc: $hlc, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deviceId: $deviceId, ')
          ..write('title: $title, ')
          ..write('startsOn: $startsOn, ')
          ..write('endsOn: $endsOn, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('repeat: $repeat, ')
          ..write('color: $color, ')
          ..write('memberId: $memberId, ')
          ..write('location: $location, ')
          ..write('note: $note, ')
          ..write('createdBy: $createdBy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    householdId,
    createdAt,
    updatedAt,
    deletedAt,
    hlc,
    serverVersion,
    updatedBy,
    deviceId,
    title,
    startsOn,
    endsOn,
    startTime,
    endTime,
    repeat,
    color,
    memberId,
    location,
    note,
    createdBy,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CalendarEvent &&
          other.id == this.id &&
          other.householdId == this.householdId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.hlc == this.hlc &&
          other.serverVersion == this.serverVersion &&
          other.updatedBy == this.updatedBy &&
          other.deviceId == this.deviceId &&
          other.title == this.title &&
          other.startsOn == this.startsOn &&
          other.endsOn == this.endsOn &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.repeat == this.repeat &&
          other.color == this.color &&
          other.memberId == this.memberId &&
          other.location == this.location &&
          other.note == this.note &&
          other.createdBy == this.createdBy);
}

class EventsCompanion extends UpdateCompanion<CalendarEvent> {
  final Value<String> id;
  final Value<String> householdId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> hlc;
  final Value<int?> serverVersion;
  final Value<String?> updatedBy;
  final Value<String?> deviceId;
  final Value<String> title;
  final Value<String> startsOn;
  final Value<String?> endsOn;
  final Value<String?> startTime;
  final Value<String?> endTime;
  final Value<String> repeat;
  final Value<String?> color;
  final Value<String?> memberId;
  final Value<String?> location;
  final Value<String?> note;
  final Value<String?> createdBy;
  final Value<int> rowid;
  const EventsCompanion({
    this.id = const Value.absent(),
    this.householdId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.hlc = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.title = const Value.absent(),
    this.startsOn = const Value.absent(),
    this.endsOn = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.repeat = const Value.absent(),
    this.color = const Value.absent(),
    this.memberId = const Value.absent(),
    this.location = const Value.absent(),
    this.note = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EventsCompanion.insert({
    required String id,
    required String householdId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.hlc = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.deviceId = const Value.absent(),
    required String title,
    required String startsOn,
    this.endsOn = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.repeat = const Value.absent(),
    this.color = const Value.absent(),
    this.memberId = const Value.absent(),
    this.location = const Value.absent(),
    this.note = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       householdId = Value(householdId),
       title = Value(title),
       startsOn = Value(startsOn);
  static Insertable<CalendarEvent> custom({
    Expression<String>? id,
    Expression<String>? householdId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? hlc,
    Expression<int>? serverVersion,
    Expression<String>? updatedBy,
    Expression<String>? deviceId,
    Expression<String>? title,
    Expression<String>? startsOn,
    Expression<String>? endsOn,
    Expression<String>? startTime,
    Expression<String>? endTime,
    Expression<String>? repeat,
    Expression<String>? color,
    Expression<String>? memberId,
    Expression<String>? location,
    Expression<String>? note,
    Expression<String>? createdBy,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (householdId != null) 'household_id': householdId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (hlc != null) 'hlc': hlc,
      if (serverVersion != null) 'server_version': serverVersion,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (deviceId != null) 'device_id': deviceId,
      if (title != null) 'title': title,
      if (startsOn != null) 'starts_on': startsOn,
      if (endsOn != null) 'ends_on': endsOn,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (repeat != null) 'repeat': repeat,
      if (color != null) 'color': color,
      if (memberId != null) 'member_id': memberId,
      if (location != null) 'location': location,
      if (note != null) 'note': note,
      if (createdBy != null) 'created_by': createdBy,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EventsCompanion copyWith({
    Value<String>? id,
    Value<String>? householdId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? hlc,
    Value<int?>? serverVersion,
    Value<String?>? updatedBy,
    Value<String?>? deviceId,
    Value<String>? title,
    Value<String>? startsOn,
    Value<String?>? endsOn,
    Value<String?>? startTime,
    Value<String?>? endTime,
    Value<String>? repeat,
    Value<String?>? color,
    Value<String?>? memberId,
    Value<String?>? location,
    Value<String?>? note,
    Value<String?>? createdBy,
    Value<int>? rowid,
  }) {
    return EventsCompanion(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      hlc: hlc ?? this.hlc,
      serverVersion: serverVersion ?? this.serverVersion,
      updatedBy: updatedBy ?? this.updatedBy,
      deviceId: deviceId ?? this.deviceId,
      title: title ?? this.title,
      startsOn: startsOn ?? this.startsOn,
      endsOn: endsOn ?? this.endsOn,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      repeat: repeat ?? this.repeat,
      color: color ?? this.color,
      memberId: memberId ?? this.memberId,
      location: location ?? this.location,
      note: note ?? this.note,
      createdBy: createdBy ?? this.createdBy,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (serverVersion.present) {
      map['server_version'] = Variable<int>(serverVersion.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (startsOn.present) {
      map['starts_on'] = Variable<String>(startsOn.value);
    }
    if (endsOn.present) {
      map['ends_on'] = Variable<String>(endsOn.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<String>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<String>(endTime.value);
    }
    if (repeat.present) {
      map['repeat'] = Variable<String>(repeat.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventsCompanion(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('hlc: $hlc, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deviceId: $deviceId, ')
          ..write('title: $title, ')
          ..write('startsOn: $startsOn, ')
          ..write('endsOn: $endsOn, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('repeat: $repeat, ')
          ..write('color: $color, ')
          ..write('memberId: $memberId, ')
          ..write('location: $location, ')
          ..write('note: $note, ')
          ..write('createdBy: $createdBy, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DebtsTable extends Debts with TableInfo<$DebtsTable, Debt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DebtsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _householdIdMeta = const VerificationMeta(
    'householdId',
  );
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
    'household_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverVersionMeta = const VerificationMeta(
    'serverVersion',
  );
  @override
  late final GeneratedColumn<int> serverVersion = GeneratedColumn<int>(
    'server_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _counterpartyMeta = const VerificationMeta(
    'counterparty',
  );
  @override
  late final GeneratedColumn<String> counterparty = GeneratedColumn<String>(
    'counterparty',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referenceMeta = const VerificationMeta(
    'reference',
  );
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
    'reference',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _principalMinorMeta = const VerificationMeta(
    'principalMinor',
  );
  @override
  late final GeneratedColumn<int> principalMinor = GeneratedColumn<int>(
    'principal_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PHP'),
  );
  static const VerificationMeta _installmentMinorMeta = const VerificationMeta(
    'installmentMinor',
  );
  @override
  late final GeneratedColumn<int> installmentMinor = GeneratedColumn<int>(
    'installment_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextDueOnMeta = const VerificationMeta(
    'nextDueOn',
  );
  @override
  late final GeneratedColumn<String> nextDueOn = GeneratedColumn<String>(
    'next_due_on',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repeatMeta = const VerificationMeta('repeat');
  @override
  late final GeneratedColumn<String> repeat = GeneratedColumn<String>(
    'repeat',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startedOnMeta = const VerificationMeta(
    'startedOn',
  );
  @override
  late final GeneratedColumn<String> startedOn = GeneratedColumn<String>(
    'started_on',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isClosedMeta = const VerificationMeta(
    'isClosed',
  );
  @override
  late final GeneratedColumn<bool> isClosed = GeneratedColumn<bool>(
    'is_closed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_closed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _closedAtMeta = const VerificationMeta(
    'closedAt',
  );
  @override
  late final GeneratedColumn<DateTime> closedAt = GeneratedColumn<DateTime>(
    'closed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _closedByMeta = const VerificationMeta(
    'closedBy',
  );
  @override
  late final GeneratedColumn<String> closedBy = GeneratedColumn<String>(
    'closed_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    householdId,
    createdAt,
    updatedAt,
    deletedAt,
    hlc,
    serverVersion,
    updatedBy,
    deviceId,
    kind,
    name,
    counterparty,
    reference,
    principalMinor,
    currency,
    installmentMinor,
    nextDueOn,
    repeat,
    startedOn,
    isClosed,
    closedAt,
    closedBy,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'debts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Debt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
        _householdIdMeta,
        householdId.isAcceptableOrUnknown(
          data['household_id']!,
          _householdIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    }
    if (data.containsKey('server_version')) {
      context.handle(
        _serverVersionMeta,
        serverVersion.isAcceptableOrUnknown(
          data['server_version']!,
          _serverVersionMeta,
        ),
      );
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('counterparty')) {
      context.handle(
        _counterpartyMeta,
        counterparty.isAcceptableOrUnknown(
          data['counterparty']!,
          _counterpartyMeta,
        ),
      );
    }
    if (data.containsKey('reference')) {
      context.handle(
        _referenceMeta,
        reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta),
      );
    }
    if (data.containsKey('principal_minor')) {
      context.handle(
        _principalMinorMeta,
        principalMinor.isAcceptableOrUnknown(
          data['principal_minor']!,
          _principalMinorMeta,
        ),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('installment_minor')) {
      context.handle(
        _installmentMinorMeta,
        installmentMinor.isAcceptableOrUnknown(
          data['installment_minor']!,
          _installmentMinorMeta,
        ),
      );
    }
    if (data.containsKey('next_due_on')) {
      context.handle(
        _nextDueOnMeta,
        nextDueOn.isAcceptableOrUnknown(data['next_due_on']!, _nextDueOnMeta),
      );
    }
    if (data.containsKey('repeat')) {
      context.handle(
        _repeatMeta,
        repeat.isAcceptableOrUnknown(data['repeat']!, _repeatMeta),
      );
    }
    if (data.containsKey('started_on')) {
      context.handle(
        _startedOnMeta,
        startedOn.isAcceptableOrUnknown(data['started_on']!, _startedOnMeta),
      );
    }
    if (data.containsKey('is_closed')) {
      context.handle(
        _isClosedMeta,
        isClosed.isAcceptableOrUnknown(data['is_closed']!, _isClosedMeta),
      );
    }
    if (data.containsKey('closed_at')) {
      context.handle(
        _closedAtMeta,
        closedAt.isAcceptableOrUnknown(data['closed_at']!, _closedAtMeta),
      );
    }
    if (data.containsKey('closed_by')) {
      context.handle(
        _closedByMeta,
        closedBy.isAcceptableOrUnknown(data['closed_by']!, _closedByMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Debt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Debt(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      householdId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}household_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      ),
      serverVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_version'],
      ),
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      counterparty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}counterparty'],
      ),
      reference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference'],
      ),
      principalMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}principal_minor'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      installmentMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}installment_minor'],
      ),
      nextDueOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}next_due_on'],
      ),
      repeat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repeat'],
      ),
      startedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}started_on'],
      ),
      isClosed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_closed'],
      )!,
      closedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}closed_at'],
      ),
      closedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}closed_by'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $DebtsTable createAlias(String alias) {
    return $DebtsTable(attachedDatabase, alias);
  }
}

class Debt extends DataClass implements Insertable<Debt> {
  final String id;
  final String householdId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? hlc;
  final int? serverVersion;
  final String? updatedBy;
  final String? deviceId;
  final String kind;
  final String name;

  /// Bank, pawnshop or person.
  final String? counterparty;

  /// Pawn ticket number, last digits of a card, loan account.
  final String? reference;
  final int principalMinor;
  final String currency;

  /// Monthly amortization or minimum due.
  final int? installmentMinor;

  /// Calendar date `YYYY-MM-DD` (a pawn ticket's maturity).
  final String? nextDueOn;

  /// `monthly` or null.
  final String? repeat;
  final String? startedOn;
  final bool isClosed;
  final DateTime? closedAt;
  final String? closedBy;
  final String? note;
  const Debt({
    required this.id,
    required this.householdId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.hlc,
    this.serverVersion,
    this.updatedBy,
    this.deviceId,
    required this.kind,
    required this.name,
    this.counterparty,
    this.reference,
    required this.principalMinor,
    required this.currency,
    this.installmentMinor,
    this.nextDueOn,
    this.repeat,
    this.startedOn,
    required this.isClosed,
    this.closedAt,
    this.closedBy,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['household_id'] = Variable<String>(householdId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || hlc != null) {
      map['hlc'] = Variable<String>(hlc);
    }
    if (!nullToAbsent || serverVersion != null) {
      map['server_version'] = Variable<int>(serverVersion);
    }
    if (!nullToAbsent || updatedBy != null) {
      map['updated_by'] = Variable<String>(updatedBy);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['kind'] = Variable<String>(kind);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || counterparty != null) {
      map['counterparty'] = Variable<String>(counterparty);
    }
    if (!nullToAbsent || reference != null) {
      map['reference'] = Variable<String>(reference);
    }
    map['principal_minor'] = Variable<int>(principalMinor);
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || installmentMinor != null) {
      map['installment_minor'] = Variable<int>(installmentMinor);
    }
    if (!nullToAbsent || nextDueOn != null) {
      map['next_due_on'] = Variable<String>(nextDueOn);
    }
    if (!nullToAbsent || repeat != null) {
      map['repeat'] = Variable<String>(repeat);
    }
    if (!nullToAbsent || startedOn != null) {
      map['started_on'] = Variable<String>(startedOn);
    }
    map['is_closed'] = Variable<bool>(isClosed);
    if (!nullToAbsent || closedAt != null) {
      map['closed_at'] = Variable<DateTime>(closedAt);
    }
    if (!nullToAbsent || closedBy != null) {
      map['closed_by'] = Variable<String>(closedBy);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  DebtsCompanion toCompanion(bool nullToAbsent) {
    return DebtsCompanion(
      id: Value(id),
      householdId: Value(householdId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      hlc: hlc == null && nullToAbsent ? const Value.absent() : Value(hlc),
      serverVersion: serverVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(serverVersion),
      updatedBy: updatedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedBy),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      kind: Value(kind),
      name: Value(name),
      counterparty: counterparty == null && nullToAbsent
          ? const Value.absent()
          : Value(counterparty),
      reference: reference == null && nullToAbsent
          ? const Value.absent()
          : Value(reference),
      principalMinor: Value(principalMinor),
      currency: Value(currency),
      installmentMinor: installmentMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(installmentMinor),
      nextDueOn: nextDueOn == null && nullToAbsent
          ? const Value.absent()
          : Value(nextDueOn),
      repeat: repeat == null && nullToAbsent
          ? const Value.absent()
          : Value(repeat),
      startedOn: startedOn == null && nullToAbsent
          ? const Value.absent()
          : Value(startedOn),
      isClosed: Value(isClosed),
      closedAt: closedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(closedAt),
      closedBy: closedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(closedBy),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory Debt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Debt(
      id: serializer.fromJson<String>(json['id']),
      householdId: serializer.fromJson<String>(json['householdId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      hlc: serializer.fromJson<String?>(json['hlc']),
      serverVersion: serializer.fromJson<int?>(json['serverVersion']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      kind: serializer.fromJson<String>(json['kind']),
      name: serializer.fromJson<String>(json['name']),
      counterparty: serializer.fromJson<String?>(json['counterparty']),
      reference: serializer.fromJson<String?>(json['reference']),
      principalMinor: serializer.fromJson<int>(json['principalMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      installmentMinor: serializer.fromJson<int?>(json['installmentMinor']),
      nextDueOn: serializer.fromJson<String?>(json['nextDueOn']),
      repeat: serializer.fromJson<String?>(json['repeat']),
      startedOn: serializer.fromJson<String?>(json['startedOn']),
      isClosed: serializer.fromJson<bool>(json['isClosed']),
      closedAt: serializer.fromJson<DateTime?>(json['closedAt']),
      closedBy: serializer.fromJson<String?>(json['closedBy']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'householdId': serializer.toJson<String>(householdId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'hlc': serializer.toJson<String?>(hlc),
      'serverVersion': serializer.toJson<int?>(serverVersion),
      'updatedBy': serializer.toJson<String?>(updatedBy),
      'deviceId': serializer.toJson<String?>(deviceId),
      'kind': serializer.toJson<String>(kind),
      'name': serializer.toJson<String>(name),
      'counterparty': serializer.toJson<String?>(counterparty),
      'reference': serializer.toJson<String?>(reference),
      'principalMinor': serializer.toJson<int>(principalMinor),
      'currency': serializer.toJson<String>(currency),
      'installmentMinor': serializer.toJson<int?>(installmentMinor),
      'nextDueOn': serializer.toJson<String?>(nextDueOn),
      'repeat': serializer.toJson<String?>(repeat),
      'startedOn': serializer.toJson<String?>(startedOn),
      'isClosed': serializer.toJson<bool>(isClosed),
      'closedAt': serializer.toJson<DateTime?>(closedAt),
      'closedBy': serializer.toJson<String?>(closedBy),
      'note': serializer.toJson<String?>(note),
    };
  }

  Debt copyWith({
    String? id,
    String? householdId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> hlc = const Value.absent(),
    Value<int?> serverVersion = const Value.absent(),
    Value<String?> updatedBy = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
    String? kind,
    String? name,
    Value<String?> counterparty = const Value.absent(),
    Value<String?> reference = const Value.absent(),
    int? principalMinor,
    String? currency,
    Value<int?> installmentMinor = const Value.absent(),
    Value<String?> nextDueOn = const Value.absent(),
    Value<String?> repeat = const Value.absent(),
    Value<String?> startedOn = const Value.absent(),
    bool? isClosed,
    Value<DateTime?> closedAt = const Value.absent(),
    Value<String?> closedBy = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) => Debt(
    id: id ?? this.id,
    householdId: householdId ?? this.householdId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    hlc: hlc.present ? hlc.value : this.hlc,
    serverVersion: serverVersion.present
        ? serverVersion.value
        : this.serverVersion,
    updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    kind: kind ?? this.kind,
    name: name ?? this.name,
    counterparty: counterparty.present ? counterparty.value : this.counterparty,
    reference: reference.present ? reference.value : this.reference,
    principalMinor: principalMinor ?? this.principalMinor,
    currency: currency ?? this.currency,
    installmentMinor: installmentMinor.present
        ? installmentMinor.value
        : this.installmentMinor,
    nextDueOn: nextDueOn.present ? nextDueOn.value : this.nextDueOn,
    repeat: repeat.present ? repeat.value : this.repeat,
    startedOn: startedOn.present ? startedOn.value : this.startedOn,
    isClosed: isClosed ?? this.isClosed,
    closedAt: closedAt.present ? closedAt.value : this.closedAt,
    closedBy: closedBy.present ? closedBy.value : this.closedBy,
    note: note.present ? note.value : this.note,
  );
  Debt copyWithCompanion(DebtsCompanion data) {
    return Debt(
      id: data.id.present ? data.id.value : this.id,
      householdId: data.householdId.present
          ? data.householdId.value
          : this.householdId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      serverVersion: data.serverVersion.present
          ? data.serverVersion.value
          : this.serverVersion,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      kind: data.kind.present ? data.kind.value : this.kind,
      name: data.name.present ? data.name.value : this.name,
      counterparty: data.counterparty.present
          ? data.counterparty.value
          : this.counterparty,
      reference: data.reference.present ? data.reference.value : this.reference,
      principalMinor: data.principalMinor.present
          ? data.principalMinor.value
          : this.principalMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      installmentMinor: data.installmentMinor.present
          ? data.installmentMinor.value
          : this.installmentMinor,
      nextDueOn: data.nextDueOn.present ? data.nextDueOn.value : this.nextDueOn,
      repeat: data.repeat.present ? data.repeat.value : this.repeat,
      startedOn: data.startedOn.present ? data.startedOn.value : this.startedOn,
      isClosed: data.isClosed.present ? data.isClosed.value : this.isClosed,
      closedAt: data.closedAt.present ? data.closedAt.value : this.closedAt,
      closedBy: data.closedBy.present ? data.closedBy.value : this.closedBy,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Debt(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('hlc: $hlc, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deviceId: $deviceId, ')
          ..write('kind: $kind, ')
          ..write('name: $name, ')
          ..write('counterparty: $counterparty, ')
          ..write('reference: $reference, ')
          ..write('principalMinor: $principalMinor, ')
          ..write('currency: $currency, ')
          ..write('installmentMinor: $installmentMinor, ')
          ..write('nextDueOn: $nextDueOn, ')
          ..write('repeat: $repeat, ')
          ..write('startedOn: $startedOn, ')
          ..write('isClosed: $isClosed, ')
          ..write('closedAt: $closedAt, ')
          ..write('closedBy: $closedBy, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    householdId,
    createdAt,
    updatedAt,
    deletedAt,
    hlc,
    serverVersion,
    updatedBy,
    deviceId,
    kind,
    name,
    counterparty,
    reference,
    principalMinor,
    currency,
    installmentMinor,
    nextDueOn,
    repeat,
    startedOn,
    isClosed,
    closedAt,
    closedBy,
    note,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Debt &&
          other.id == this.id &&
          other.householdId == this.householdId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.hlc == this.hlc &&
          other.serverVersion == this.serverVersion &&
          other.updatedBy == this.updatedBy &&
          other.deviceId == this.deviceId &&
          other.kind == this.kind &&
          other.name == this.name &&
          other.counterparty == this.counterparty &&
          other.reference == this.reference &&
          other.principalMinor == this.principalMinor &&
          other.currency == this.currency &&
          other.installmentMinor == this.installmentMinor &&
          other.nextDueOn == this.nextDueOn &&
          other.repeat == this.repeat &&
          other.startedOn == this.startedOn &&
          other.isClosed == this.isClosed &&
          other.closedAt == this.closedAt &&
          other.closedBy == this.closedBy &&
          other.note == this.note);
}

class DebtsCompanion extends UpdateCompanion<Debt> {
  final Value<String> id;
  final Value<String> householdId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> hlc;
  final Value<int?> serverVersion;
  final Value<String?> updatedBy;
  final Value<String?> deviceId;
  final Value<String> kind;
  final Value<String> name;
  final Value<String?> counterparty;
  final Value<String?> reference;
  final Value<int> principalMinor;
  final Value<String> currency;
  final Value<int?> installmentMinor;
  final Value<String?> nextDueOn;
  final Value<String?> repeat;
  final Value<String?> startedOn;
  final Value<bool> isClosed;
  final Value<DateTime?> closedAt;
  final Value<String?> closedBy;
  final Value<String?> note;
  final Value<int> rowid;
  const DebtsCompanion({
    this.id = const Value.absent(),
    this.householdId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.hlc = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.kind = const Value.absent(),
    this.name = const Value.absent(),
    this.counterparty = const Value.absent(),
    this.reference = const Value.absent(),
    this.principalMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.installmentMinor = const Value.absent(),
    this.nextDueOn = const Value.absent(),
    this.repeat = const Value.absent(),
    this.startedOn = const Value.absent(),
    this.isClosed = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.closedBy = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DebtsCompanion.insert({
    required String id,
    required String householdId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.hlc = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.deviceId = const Value.absent(),
    required String kind,
    required String name,
    this.counterparty = const Value.absent(),
    this.reference = const Value.absent(),
    this.principalMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.installmentMinor = const Value.absent(),
    this.nextDueOn = const Value.absent(),
    this.repeat = const Value.absent(),
    this.startedOn = const Value.absent(),
    this.isClosed = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.closedBy = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       householdId = Value(householdId),
       kind = Value(kind),
       name = Value(name);
  static Insertable<Debt> custom({
    Expression<String>? id,
    Expression<String>? householdId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? hlc,
    Expression<int>? serverVersion,
    Expression<String>? updatedBy,
    Expression<String>? deviceId,
    Expression<String>? kind,
    Expression<String>? name,
    Expression<String>? counterparty,
    Expression<String>? reference,
    Expression<int>? principalMinor,
    Expression<String>? currency,
    Expression<int>? installmentMinor,
    Expression<String>? nextDueOn,
    Expression<String>? repeat,
    Expression<String>? startedOn,
    Expression<bool>? isClosed,
    Expression<DateTime>? closedAt,
    Expression<String>? closedBy,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (householdId != null) 'household_id': householdId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (hlc != null) 'hlc': hlc,
      if (serverVersion != null) 'server_version': serverVersion,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (deviceId != null) 'device_id': deviceId,
      if (kind != null) 'kind': kind,
      if (name != null) 'name': name,
      if (counterparty != null) 'counterparty': counterparty,
      if (reference != null) 'reference': reference,
      if (principalMinor != null) 'principal_minor': principalMinor,
      if (currency != null) 'currency': currency,
      if (installmentMinor != null) 'installment_minor': installmentMinor,
      if (nextDueOn != null) 'next_due_on': nextDueOn,
      if (repeat != null) 'repeat': repeat,
      if (startedOn != null) 'started_on': startedOn,
      if (isClosed != null) 'is_closed': isClosed,
      if (closedAt != null) 'closed_at': closedAt,
      if (closedBy != null) 'closed_by': closedBy,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DebtsCompanion copyWith({
    Value<String>? id,
    Value<String>? householdId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? hlc,
    Value<int?>? serverVersion,
    Value<String?>? updatedBy,
    Value<String?>? deviceId,
    Value<String>? kind,
    Value<String>? name,
    Value<String?>? counterparty,
    Value<String?>? reference,
    Value<int>? principalMinor,
    Value<String>? currency,
    Value<int?>? installmentMinor,
    Value<String?>? nextDueOn,
    Value<String?>? repeat,
    Value<String?>? startedOn,
    Value<bool>? isClosed,
    Value<DateTime?>? closedAt,
    Value<String?>? closedBy,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return DebtsCompanion(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      hlc: hlc ?? this.hlc,
      serverVersion: serverVersion ?? this.serverVersion,
      updatedBy: updatedBy ?? this.updatedBy,
      deviceId: deviceId ?? this.deviceId,
      kind: kind ?? this.kind,
      name: name ?? this.name,
      counterparty: counterparty ?? this.counterparty,
      reference: reference ?? this.reference,
      principalMinor: principalMinor ?? this.principalMinor,
      currency: currency ?? this.currency,
      installmentMinor: installmentMinor ?? this.installmentMinor,
      nextDueOn: nextDueOn ?? this.nextDueOn,
      repeat: repeat ?? this.repeat,
      startedOn: startedOn ?? this.startedOn,
      isClosed: isClosed ?? this.isClosed,
      closedAt: closedAt ?? this.closedAt,
      closedBy: closedBy ?? this.closedBy,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (serverVersion.present) {
      map['server_version'] = Variable<int>(serverVersion.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (counterparty.present) {
      map['counterparty'] = Variable<String>(counterparty.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (principalMinor.present) {
      map['principal_minor'] = Variable<int>(principalMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (installmentMinor.present) {
      map['installment_minor'] = Variable<int>(installmentMinor.value);
    }
    if (nextDueOn.present) {
      map['next_due_on'] = Variable<String>(nextDueOn.value);
    }
    if (repeat.present) {
      map['repeat'] = Variable<String>(repeat.value);
    }
    if (startedOn.present) {
      map['started_on'] = Variable<String>(startedOn.value);
    }
    if (isClosed.present) {
      map['is_closed'] = Variable<bool>(isClosed.value);
    }
    if (closedAt.present) {
      map['closed_at'] = Variable<DateTime>(closedAt.value);
    }
    if (closedBy.present) {
      map['closed_by'] = Variable<String>(closedBy.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DebtsCompanion(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('hlc: $hlc, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deviceId: $deviceId, ')
          ..write('kind: $kind, ')
          ..write('name: $name, ')
          ..write('counterparty: $counterparty, ')
          ..write('reference: $reference, ')
          ..write('principalMinor: $principalMinor, ')
          ..write('currency: $currency, ')
          ..write('installmentMinor: $installmentMinor, ')
          ..write('nextDueOn: $nextDueOn, ')
          ..write('repeat: $repeat, ')
          ..write('startedOn: $startedOn, ')
          ..write('isClosed: $isClosed, ')
          ..write('closedAt: $closedAt, ')
          ..write('closedBy: $closedBy, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DebtPaymentsTable extends DebtPayments
    with TableInfo<$DebtPaymentsTable, DebtPayment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DebtPaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _householdIdMeta = const VerificationMeta(
    'householdId',
  );
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
    'household_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverVersionMeta = const VerificationMeta(
    'serverVersion',
  );
  @override
  late final GeneratedColumn<int> serverVersion = GeneratedColumn<int>(
    'server_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _debtIdMeta = const VerificationMeta('debtId');
  @override
  late final GeneratedColumn<String> debtId = GeneratedColumn<String>(
    'debt_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PHP'),
  );
  static const VerificationMeta _paidOnMeta = const VerificationMeta('paidOn');
  @override
  late final GeneratedColumn<String> paidOn = GeneratedColumn<String>(
    'paid_on',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _memberIdMeta = const VerificationMeta(
    'memberId',
  );
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
    'member_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    householdId,
    createdAt,
    updatedAt,
    deletedAt,
    hlc,
    serverVersion,
    updatedBy,
    deviceId,
    debtId,
    kind,
    amountMinor,
    currency,
    paidOn,
    memberId,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'debt_payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<DebtPayment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
        _householdIdMeta,
        householdId.isAcceptableOrUnknown(
          data['household_id']!,
          _householdIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    }
    if (data.containsKey('server_version')) {
      context.handle(
        _serverVersionMeta,
        serverVersion.isAcceptableOrUnknown(
          data['server_version']!,
          _serverVersionMeta,
        ),
      );
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('debt_id')) {
      context.handle(
        _debtIdMeta,
        debtId.isAcceptableOrUnknown(data['debt_id']!, _debtIdMeta),
      );
    } else if (isInserting) {
      context.missing(_debtIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('paid_on')) {
      context.handle(
        _paidOnMeta,
        paidOn.isAcceptableOrUnknown(data['paid_on']!, _paidOnMeta),
      );
    } else if (isInserting) {
      context.missing(_paidOnMeta);
    }
    if (data.containsKey('member_id')) {
      context.handle(
        _memberIdMeta,
        memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DebtPayment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DebtPayment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      householdId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}household_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      ),
      serverVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_version'],
      ),
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      debtId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}debt_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      paidOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}paid_on'],
      )!,
      memberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_id'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $DebtPaymentsTable createAlias(String alias) {
    return $DebtPaymentsTable(attachedDatabase, alias);
  }
}

class DebtPayment extends DataClass implements Insertable<DebtPayment> {
  final String id;
  final String householdId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? hlc;
  final int? serverVersion;
  final String? updatedBy;
  final String? deviceId;
  final String debtId;
  final String kind;
  final int amountMinor;
  final String currency;

  /// Calendar date `YYYY-MM-DD`.
  final String paidOn;
  final String? memberId;
  final String? note;
  const DebtPayment({
    required this.id,
    required this.householdId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.hlc,
    this.serverVersion,
    this.updatedBy,
    this.deviceId,
    required this.debtId,
    required this.kind,
    required this.amountMinor,
    required this.currency,
    required this.paidOn,
    this.memberId,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['household_id'] = Variable<String>(householdId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || hlc != null) {
      map['hlc'] = Variable<String>(hlc);
    }
    if (!nullToAbsent || serverVersion != null) {
      map['server_version'] = Variable<int>(serverVersion);
    }
    if (!nullToAbsent || updatedBy != null) {
      map['updated_by'] = Variable<String>(updatedBy);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['debt_id'] = Variable<String>(debtId);
    map['kind'] = Variable<String>(kind);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency'] = Variable<String>(currency);
    map['paid_on'] = Variable<String>(paidOn);
    if (!nullToAbsent || memberId != null) {
      map['member_id'] = Variable<String>(memberId);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  DebtPaymentsCompanion toCompanion(bool nullToAbsent) {
    return DebtPaymentsCompanion(
      id: Value(id),
      householdId: Value(householdId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      hlc: hlc == null && nullToAbsent ? const Value.absent() : Value(hlc),
      serverVersion: serverVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(serverVersion),
      updatedBy: updatedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedBy),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      debtId: Value(debtId),
      kind: Value(kind),
      amountMinor: Value(amountMinor),
      currency: Value(currency),
      paidOn: Value(paidOn),
      memberId: memberId == null && nullToAbsent
          ? const Value.absent()
          : Value(memberId),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory DebtPayment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DebtPayment(
      id: serializer.fromJson<String>(json['id']),
      householdId: serializer.fromJson<String>(json['householdId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      hlc: serializer.fromJson<String?>(json['hlc']),
      serverVersion: serializer.fromJson<int?>(json['serverVersion']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      debtId: serializer.fromJson<String>(json['debtId']),
      kind: serializer.fromJson<String>(json['kind']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      paidOn: serializer.fromJson<String>(json['paidOn']),
      memberId: serializer.fromJson<String?>(json['memberId']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'householdId': serializer.toJson<String>(householdId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'hlc': serializer.toJson<String?>(hlc),
      'serverVersion': serializer.toJson<int?>(serverVersion),
      'updatedBy': serializer.toJson<String?>(updatedBy),
      'deviceId': serializer.toJson<String?>(deviceId),
      'debtId': serializer.toJson<String>(debtId),
      'kind': serializer.toJson<String>(kind),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currency': serializer.toJson<String>(currency),
      'paidOn': serializer.toJson<String>(paidOn),
      'memberId': serializer.toJson<String?>(memberId),
      'note': serializer.toJson<String?>(note),
    };
  }

  DebtPayment copyWith({
    String? id,
    String? householdId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> hlc = const Value.absent(),
    Value<int?> serverVersion = const Value.absent(),
    Value<String?> updatedBy = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
    String? debtId,
    String? kind,
    int? amountMinor,
    String? currency,
    String? paidOn,
    Value<String?> memberId = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) => DebtPayment(
    id: id ?? this.id,
    householdId: householdId ?? this.householdId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    hlc: hlc.present ? hlc.value : this.hlc,
    serverVersion: serverVersion.present
        ? serverVersion.value
        : this.serverVersion,
    updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    debtId: debtId ?? this.debtId,
    kind: kind ?? this.kind,
    amountMinor: amountMinor ?? this.amountMinor,
    currency: currency ?? this.currency,
    paidOn: paidOn ?? this.paidOn,
    memberId: memberId.present ? memberId.value : this.memberId,
    note: note.present ? note.value : this.note,
  );
  DebtPayment copyWithCompanion(DebtPaymentsCompanion data) {
    return DebtPayment(
      id: data.id.present ? data.id.value : this.id,
      householdId: data.householdId.present
          ? data.householdId.value
          : this.householdId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      serverVersion: data.serverVersion.present
          ? data.serverVersion.value
          : this.serverVersion,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      debtId: data.debtId.present ? data.debtId.value : this.debtId,
      kind: data.kind.present ? data.kind.value : this.kind,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      paidOn: data.paidOn.present ? data.paidOn.value : this.paidOn,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DebtPayment(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('hlc: $hlc, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deviceId: $deviceId, ')
          ..write('debtId: $debtId, ')
          ..write('kind: $kind, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('paidOn: $paidOn, ')
          ..write('memberId: $memberId, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    householdId,
    createdAt,
    updatedAt,
    deletedAt,
    hlc,
    serverVersion,
    updatedBy,
    deviceId,
    debtId,
    kind,
    amountMinor,
    currency,
    paidOn,
    memberId,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DebtPayment &&
          other.id == this.id &&
          other.householdId == this.householdId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.hlc == this.hlc &&
          other.serverVersion == this.serverVersion &&
          other.updatedBy == this.updatedBy &&
          other.deviceId == this.deviceId &&
          other.debtId == this.debtId &&
          other.kind == this.kind &&
          other.amountMinor == this.amountMinor &&
          other.currency == this.currency &&
          other.paidOn == this.paidOn &&
          other.memberId == this.memberId &&
          other.note == this.note);
}

class DebtPaymentsCompanion extends UpdateCompanion<DebtPayment> {
  final Value<String> id;
  final Value<String> householdId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> hlc;
  final Value<int?> serverVersion;
  final Value<String?> updatedBy;
  final Value<String?> deviceId;
  final Value<String> debtId;
  final Value<String> kind;
  final Value<int> amountMinor;
  final Value<String> currency;
  final Value<String> paidOn;
  final Value<String?> memberId;
  final Value<String?> note;
  final Value<int> rowid;
  const DebtPaymentsCompanion({
    this.id = const Value.absent(),
    this.householdId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.hlc = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.debtId = const Value.absent(),
    this.kind = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.paidOn = const Value.absent(),
    this.memberId = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DebtPaymentsCompanion.insert({
    required String id,
    required String householdId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.hlc = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.deviceId = const Value.absent(),
    required String debtId,
    required String kind,
    required int amountMinor,
    this.currency = const Value.absent(),
    required String paidOn,
    this.memberId = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       householdId = Value(householdId),
       debtId = Value(debtId),
       kind = Value(kind),
       amountMinor = Value(amountMinor),
       paidOn = Value(paidOn);
  static Insertable<DebtPayment> custom({
    Expression<String>? id,
    Expression<String>? householdId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? hlc,
    Expression<int>? serverVersion,
    Expression<String>? updatedBy,
    Expression<String>? deviceId,
    Expression<String>? debtId,
    Expression<String>? kind,
    Expression<int>? amountMinor,
    Expression<String>? currency,
    Expression<String>? paidOn,
    Expression<String>? memberId,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (householdId != null) 'household_id': householdId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (hlc != null) 'hlc': hlc,
      if (serverVersion != null) 'server_version': serverVersion,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (deviceId != null) 'device_id': deviceId,
      if (debtId != null) 'debt_id': debtId,
      if (kind != null) 'kind': kind,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currency != null) 'currency': currency,
      if (paidOn != null) 'paid_on': paidOn,
      if (memberId != null) 'member_id': memberId,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DebtPaymentsCompanion copyWith({
    Value<String>? id,
    Value<String>? householdId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? hlc,
    Value<int?>? serverVersion,
    Value<String?>? updatedBy,
    Value<String?>? deviceId,
    Value<String>? debtId,
    Value<String>? kind,
    Value<int>? amountMinor,
    Value<String>? currency,
    Value<String>? paidOn,
    Value<String?>? memberId,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return DebtPaymentsCompanion(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      hlc: hlc ?? this.hlc,
      serverVersion: serverVersion ?? this.serverVersion,
      updatedBy: updatedBy ?? this.updatedBy,
      deviceId: deviceId ?? this.deviceId,
      debtId: debtId ?? this.debtId,
      kind: kind ?? this.kind,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      paidOn: paidOn ?? this.paidOn,
      memberId: memberId ?? this.memberId,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (serverVersion.present) {
      map['server_version'] = Variable<int>(serverVersion.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (debtId.present) {
      map['debt_id'] = Variable<String>(debtId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (paidOn.present) {
      map['paid_on'] = Variable<String>(paidOn.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DebtPaymentsCompanion(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('hlc: $hlc, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deviceId: $deviceId, ')
          ..write('debtId: $debtId, ')
          ..write('kind: $kind, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('paidOn: $paidOn, ')
          ..write('memberId: $memberId, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VehiclesTable extends Vehicles with TableInfo<$VehiclesTable, Vehicle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VehiclesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _householdIdMeta = const VerificationMeta(
    'householdId',
  );
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
    'household_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverVersionMeta = const VerificationMeta(
    'serverVersion',
  );
  @override
  late final GeneratedColumn<int> serverVersion = GeneratedColumn<int>(
    'server_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plateMeta = const VerificationMeta('plate');
  @override
  late final GeneratedColumn<String> plate = GeneratedColumn<String>(
    'plate',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _registrationDueOnMeta = const VerificationMeta(
    'registrationDueOn',
  );
  @override
  late final GeneratedColumn<String> registrationDueOn =
      GeneratedColumn<String>(
        'registration_due_on',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _insuranceDueOnMeta = const VerificationMeta(
    'insuranceDueOn',
  );
  @override
  late final GeneratedColumn<String> insuranceDueOn = GeneratedColumn<String>(
    'insurance_due_on',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pmsDueOnMeta = const VerificationMeta(
    'pmsDueOn',
  );
  @override
  late final GeneratedColumn<String> pmsDueOn = GeneratedColumn<String>(
    'pms_due_on',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pmsDueKmMeta = const VerificationMeta(
    'pmsDueKm',
  );
  @override
  late final GeneratedColumn<int> pmsDueKm = GeneratedColumn<int>(
    'pms_due_km',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pmsEveryMonthsMeta = const VerificationMeta(
    'pmsEveryMonths',
  );
  @override
  late final GeneratedColumn<int> pmsEveryMonths = GeneratedColumn<int>(
    'pms_every_months',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pmsEveryKmMeta = const VerificationMeta(
    'pmsEveryKm',
  );
  @override
  late final GeneratedColumn<int> pmsEveryKm = GeneratedColumn<int>(
    'pms_every_km',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    householdId,
    createdAt,
    updatedAt,
    deletedAt,
    hlc,
    serverVersion,
    updatedBy,
    deviceId,
    kind,
    name,
    plate,
    color,
    registrationDueOn,
    insuranceDueOn,
    pmsDueOn,
    pmsDueKm,
    pmsEveryMonths,
    pmsEveryKm,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vehicles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Vehicle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
        _householdIdMeta,
        householdId.isAcceptableOrUnknown(
          data['household_id']!,
          _householdIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    }
    if (data.containsKey('server_version')) {
      context.handle(
        _serverVersionMeta,
        serverVersion.isAcceptableOrUnknown(
          data['server_version']!,
          _serverVersionMeta,
        ),
      );
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('plate')) {
      context.handle(
        _plateMeta,
        plate.isAcceptableOrUnknown(data['plate']!, _plateMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('registration_due_on')) {
      context.handle(
        _registrationDueOnMeta,
        registrationDueOn.isAcceptableOrUnknown(
          data['registration_due_on']!,
          _registrationDueOnMeta,
        ),
      );
    }
    if (data.containsKey('insurance_due_on')) {
      context.handle(
        _insuranceDueOnMeta,
        insuranceDueOn.isAcceptableOrUnknown(
          data['insurance_due_on']!,
          _insuranceDueOnMeta,
        ),
      );
    }
    if (data.containsKey('pms_due_on')) {
      context.handle(
        _pmsDueOnMeta,
        pmsDueOn.isAcceptableOrUnknown(data['pms_due_on']!, _pmsDueOnMeta),
      );
    }
    if (data.containsKey('pms_due_km')) {
      context.handle(
        _pmsDueKmMeta,
        pmsDueKm.isAcceptableOrUnknown(data['pms_due_km']!, _pmsDueKmMeta),
      );
    }
    if (data.containsKey('pms_every_months')) {
      context.handle(
        _pmsEveryMonthsMeta,
        pmsEveryMonths.isAcceptableOrUnknown(
          data['pms_every_months']!,
          _pmsEveryMonthsMeta,
        ),
      );
    }
    if (data.containsKey('pms_every_km')) {
      context.handle(
        _pmsEveryKmMeta,
        pmsEveryKm.isAcceptableOrUnknown(
          data['pms_every_km']!,
          _pmsEveryKmMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Vehicle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Vehicle(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      householdId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}household_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      ),
      serverVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_version'],
      ),
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      plate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plate'],
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
      registrationDueOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}registration_due_on'],
      ),
      insuranceDueOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}insurance_due_on'],
      ),
      pmsDueOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pms_due_on'],
      ),
      pmsDueKm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pms_due_km'],
      ),
      pmsEveryMonths: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pms_every_months'],
      ),
      pmsEveryKm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pms_every_km'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $VehiclesTable createAlias(String alias) {
    return $VehiclesTable(attachedDatabase, alias);
  }
}

class Vehicle extends DataClass implements Insertable<Vehicle> {
  final String id;
  final String householdId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? hlc;
  final int? serverVersion;
  final String? updatedBy;
  final String? deviceId;
  final String kind;
  final String name;
  final String? plate;
  final String? color;

  /// Calendar dates `YYYY-MM-DD`; registration and insurance are yearly.
  final String? registrationDueOn;
  final String? insuranceDueOn;

  /// PMS / change oil: due at this date or this odometer reading, whichever
  /// comes first.
  final String? pmsDueOn;
  final int? pmsDueKm;

  /// How often PMS is done; logging one sets the next date and reading.
  final int? pmsEveryMonths;
  final int? pmsEveryKm;
  final String? note;
  const Vehicle({
    required this.id,
    required this.householdId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.hlc,
    this.serverVersion,
    this.updatedBy,
    this.deviceId,
    required this.kind,
    required this.name,
    this.plate,
    this.color,
    this.registrationDueOn,
    this.insuranceDueOn,
    this.pmsDueOn,
    this.pmsDueKm,
    this.pmsEveryMonths,
    this.pmsEveryKm,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['household_id'] = Variable<String>(householdId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || hlc != null) {
      map['hlc'] = Variable<String>(hlc);
    }
    if (!nullToAbsent || serverVersion != null) {
      map['server_version'] = Variable<int>(serverVersion);
    }
    if (!nullToAbsent || updatedBy != null) {
      map['updated_by'] = Variable<String>(updatedBy);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['kind'] = Variable<String>(kind);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || plate != null) {
      map['plate'] = Variable<String>(plate);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    if (!nullToAbsent || registrationDueOn != null) {
      map['registration_due_on'] = Variable<String>(registrationDueOn);
    }
    if (!nullToAbsent || insuranceDueOn != null) {
      map['insurance_due_on'] = Variable<String>(insuranceDueOn);
    }
    if (!nullToAbsent || pmsDueOn != null) {
      map['pms_due_on'] = Variable<String>(pmsDueOn);
    }
    if (!nullToAbsent || pmsDueKm != null) {
      map['pms_due_km'] = Variable<int>(pmsDueKm);
    }
    if (!nullToAbsent || pmsEveryMonths != null) {
      map['pms_every_months'] = Variable<int>(pmsEveryMonths);
    }
    if (!nullToAbsent || pmsEveryKm != null) {
      map['pms_every_km'] = Variable<int>(pmsEveryKm);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  VehiclesCompanion toCompanion(bool nullToAbsent) {
    return VehiclesCompanion(
      id: Value(id),
      householdId: Value(householdId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      hlc: hlc == null && nullToAbsent ? const Value.absent() : Value(hlc),
      serverVersion: serverVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(serverVersion),
      updatedBy: updatedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedBy),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      kind: Value(kind),
      name: Value(name),
      plate: plate == null && nullToAbsent
          ? const Value.absent()
          : Value(plate),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      registrationDueOn: registrationDueOn == null && nullToAbsent
          ? const Value.absent()
          : Value(registrationDueOn),
      insuranceDueOn: insuranceDueOn == null && nullToAbsent
          ? const Value.absent()
          : Value(insuranceDueOn),
      pmsDueOn: pmsDueOn == null && nullToAbsent
          ? const Value.absent()
          : Value(pmsDueOn),
      pmsDueKm: pmsDueKm == null && nullToAbsent
          ? const Value.absent()
          : Value(pmsDueKm),
      pmsEveryMonths: pmsEveryMonths == null && nullToAbsent
          ? const Value.absent()
          : Value(pmsEveryMonths),
      pmsEveryKm: pmsEveryKm == null && nullToAbsent
          ? const Value.absent()
          : Value(pmsEveryKm),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory Vehicle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Vehicle(
      id: serializer.fromJson<String>(json['id']),
      householdId: serializer.fromJson<String>(json['householdId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      hlc: serializer.fromJson<String?>(json['hlc']),
      serverVersion: serializer.fromJson<int?>(json['serverVersion']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      kind: serializer.fromJson<String>(json['kind']),
      name: serializer.fromJson<String>(json['name']),
      plate: serializer.fromJson<String?>(json['plate']),
      color: serializer.fromJson<String?>(json['color']),
      registrationDueOn: serializer.fromJson<String?>(
        json['registrationDueOn'],
      ),
      insuranceDueOn: serializer.fromJson<String?>(json['insuranceDueOn']),
      pmsDueOn: serializer.fromJson<String?>(json['pmsDueOn']),
      pmsDueKm: serializer.fromJson<int?>(json['pmsDueKm']),
      pmsEveryMonths: serializer.fromJson<int?>(json['pmsEveryMonths']),
      pmsEveryKm: serializer.fromJson<int?>(json['pmsEveryKm']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'householdId': serializer.toJson<String>(householdId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'hlc': serializer.toJson<String?>(hlc),
      'serverVersion': serializer.toJson<int?>(serverVersion),
      'updatedBy': serializer.toJson<String?>(updatedBy),
      'deviceId': serializer.toJson<String?>(deviceId),
      'kind': serializer.toJson<String>(kind),
      'name': serializer.toJson<String>(name),
      'plate': serializer.toJson<String?>(plate),
      'color': serializer.toJson<String?>(color),
      'registrationDueOn': serializer.toJson<String?>(registrationDueOn),
      'insuranceDueOn': serializer.toJson<String?>(insuranceDueOn),
      'pmsDueOn': serializer.toJson<String?>(pmsDueOn),
      'pmsDueKm': serializer.toJson<int?>(pmsDueKm),
      'pmsEveryMonths': serializer.toJson<int?>(pmsEveryMonths),
      'pmsEveryKm': serializer.toJson<int?>(pmsEveryKm),
      'note': serializer.toJson<String?>(note),
    };
  }

  Vehicle copyWith({
    String? id,
    String? householdId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> hlc = const Value.absent(),
    Value<int?> serverVersion = const Value.absent(),
    Value<String?> updatedBy = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
    String? kind,
    String? name,
    Value<String?> plate = const Value.absent(),
    Value<String?> color = const Value.absent(),
    Value<String?> registrationDueOn = const Value.absent(),
    Value<String?> insuranceDueOn = const Value.absent(),
    Value<String?> pmsDueOn = const Value.absent(),
    Value<int?> pmsDueKm = const Value.absent(),
    Value<int?> pmsEveryMonths = const Value.absent(),
    Value<int?> pmsEveryKm = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) => Vehicle(
    id: id ?? this.id,
    householdId: householdId ?? this.householdId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    hlc: hlc.present ? hlc.value : this.hlc,
    serverVersion: serverVersion.present
        ? serverVersion.value
        : this.serverVersion,
    updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    kind: kind ?? this.kind,
    name: name ?? this.name,
    plate: plate.present ? plate.value : this.plate,
    color: color.present ? color.value : this.color,
    registrationDueOn: registrationDueOn.present
        ? registrationDueOn.value
        : this.registrationDueOn,
    insuranceDueOn: insuranceDueOn.present
        ? insuranceDueOn.value
        : this.insuranceDueOn,
    pmsDueOn: pmsDueOn.present ? pmsDueOn.value : this.pmsDueOn,
    pmsDueKm: pmsDueKm.present ? pmsDueKm.value : this.pmsDueKm,
    pmsEveryMonths: pmsEveryMonths.present
        ? pmsEveryMonths.value
        : this.pmsEveryMonths,
    pmsEveryKm: pmsEveryKm.present ? pmsEveryKm.value : this.pmsEveryKm,
    note: note.present ? note.value : this.note,
  );
  Vehicle copyWithCompanion(VehiclesCompanion data) {
    return Vehicle(
      id: data.id.present ? data.id.value : this.id,
      householdId: data.householdId.present
          ? data.householdId.value
          : this.householdId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      serverVersion: data.serverVersion.present
          ? data.serverVersion.value
          : this.serverVersion,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      kind: data.kind.present ? data.kind.value : this.kind,
      name: data.name.present ? data.name.value : this.name,
      plate: data.plate.present ? data.plate.value : this.plate,
      color: data.color.present ? data.color.value : this.color,
      registrationDueOn: data.registrationDueOn.present
          ? data.registrationDueOn.value
          : this.registrationDueOn,
      insuranceDueOn: data.insuranceDueOn.present
          ? data.insuranceDueOn.value
          : this.insuranceDueOn,
      pmsDueOn: data.pmsDueOn.present ? data.pmsDueOn.value : this.pmsDueOn,
      pmsDueKm: data.pmsDueKm.present ? data.pmsDueKm.value : this.pmsDueKm,
      pmsEveryMonths: data.pmsEveryMonths.present
          ? data.pmsEveryMonths.value
          : this.pmsEveryMonths,
      pmsEveryKm: data.pmsEveryKm.present
          ? data.pmsEveryKm.value
          : this.pmsEveryKm,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Vehicle(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('hlc: $hlc, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deviceId: $deviceId, ')
          ..write('kind: $kind, ')
          ..write('name: $name, ')
          ..write('plate: $plate, ')
          ..write('color: $color, ')
          ..write('registrationDueOn: $registrationDueOn, ')
          ..write('insuranceDueOn: $insuranceDueOn, ')
          ..write('pmsDueOn: $pmsDueOn, ')
          ..write('pmsDueKm: $pmsDueKm, ')
          ..write('pmsEveryMonths: $pmsEveryMonths, ')
          ..write('pmsEveryKm: $pmsEveryKm, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    householdId,
    createdAt,
    updatedAt,
    deletedAt,
    hlc,
    serverVersion,
    updatedBy,
    deviceId,
    kind,
    name,
    plate,
    color,
    registrationDueOn,
    insuranceDueOn,
    pmsDueOn,
    pmsDueKm,
    pmsEveryMonths,
    pmsEveryKm,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Vehicle &&
          other.id == this.id &&
          other.householdId == this.householdId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.hlc == this.hlc &&
          other.serverVersion == this.serverVersion &&
          other.updatedBy == this.updatedBy &&
          other.deviceId == this.deviceId &&
          other.kind == this.kind &&
          other.name == this.name &&
          other.plate == this.plate &&
          other.color == this.color &&
          other.registrationDueOn == this.registrationDueOn &&
          other.insuranceDueOn == this.insuranceDueOn &&
          other.pmsDueOn == this.pmsDueOn &&
          other.pmsDueKm == this.pmsDueKm &&
          other.pmsEveryMonths == this.pmsEveryMonths &&
          other.pmsEveryKm == this.pmsEveryKm &&
          other.note == this.note);
}

class VehiclesCompanion extends UpdateCompanion<Vehicle> {
  final Value<String> id;
  final Value<String> householdId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> hlc;
  final Value<int?> serverVersion;
  final Value<String?> updatedBy;
  final Value<String?> deviceId;
  final Value<String> kind;
  final Value<String> name;
  final Value<String?> plate;
  final Value<String?> color;
  final Value<String?> registrationDueOn;
  final Value<String?> insuranceDueOn;
  final Value<String?> pmsDueOn;
  final Value<int?> pmsDueKm;
  final Value<int?> pmsEveryMonths;
  final Value<int?> pmsEveryKm;
  final Value<String?> note;
  final Value<int> rowid;
  const VehiclesCompanion({
    this.id = const Value.absent(),
    this.householdId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.hlc = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.kind = const Value.absent(),
    this.name = const Value.absent(),
    this.plate = const Value.absent(),
    this.color = const Value.absent(),
    this.registrationDueOn = const Value.absent(),
    this.insuranceDueOn = const Value.absent(),
    this.pmsDueOn = const Value.absent(),
    this.pmsDueKm = const Value.absent(),
    this.pmsEveryMonths = const Value.absent(),
    this.pmsEveryKm = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VehiclesCompanion.insert({
    required String id,
    required String householdId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.hlc = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.deviceId = const Value.absent(),
    required String kind,
    required String name,
    this.plate = const Value.absent(),
    this.color = const Value.absent(),
    this.registrationDueOn = const Value.absent(),
    this.insuranceDueOn = const Value.absent(),
    this.pmsDueOn = const Value.absent(),
    this.pmsDueKm = const Value.absent(),
    this.pmsEveryMonths = const Value.absent(),
    this.pmsEveryKm = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       householdId = Value(householdId),
       kind = Value(kind),
       name = Value(name);
  static Insertable<Vehicle> custom({
    Expression<String>? id,
    Expression<String>? householdId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? hlc,
    Expression<int>? serverVersion,
    Expression<String>? updatedBy,
    Expression<String>? deviceId,
    Expression<String>? kind,
    Expression<String>? name,
    Expression<String>? plate,
    Expression<String>? color,
    Expression<String>? registrationDueOn,
    Expression<String>? insuranceDueOn,
    Expression<String>? pmsDueOn,
    Expression<int>? pmsDueKm,
    Expression<int>? pmsEveryMonths,
    Expression<int>? pmsEveryKm,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (householdId != null) 'household_id': householdId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (hlc != null) 'hlc': hlc,
      if (serverVersion != null) 'server_version': serverVersion,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (deviceId != null) 'device_id': deviceId,
      if (kind != null) 'kind': kind,
      if (name != null) 'name': name,
      if (plate != null) 'plate': plate,
      if (color != null) 'color': color,
      if (registrationDueOn != null) 'registration_due_on': registrationDueOn,
      if (insuranceDueOn != null) 'insurance_due_on': insuranceDueOn,
      if (pmsDueOn != null) 'pms_due_on': pmsDueOn,
      if (pmsDueKm != null) 'pms_due_km': pmsDueKm,
      if (pmsEveryMonths != null) 'pms_every_months': pmsEveryMonths,
      if (pmsEveryKm != null) 'pms_every_km': pmsEveryKm,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VehiclesCompanion copyWith({
    Value<String>? id,
    Value<String>? householdId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? hlc,
    Value<int?>? serverVersion,
    Value<String?>? updatedBy,
    Value<String?>? deviceId,
    Value<String>? kind,
    Value<String>? name,
    Value<String?>? plate,
    Value<String?>? color,
    Value<String?>? registrationDueOn,
    Value<String?>? insuranceDueOn,
    Value<String?>? pmsDueOn,
    Value<int?>? pmsDueKm,
    Value<int?>? pmsEveryMonths,
    Value<int?>? pmsEveryKm,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return VehiclesCompanion(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      hlc: hlc ?? this.hlc,
      serverVersion: serverVersion ?? this.serverVersion,
      updatedBy: updatedBy ?? this.updatedBy,
      deviceId: deviceId ?? this.deviceId,
      kind: kind ?? this.kind,
      name: name ?? this.name,
      plate: plate ?? this.plate,
      color: color ?? this.color,
      registrationDueOn: registrationDueOn ?? this.registrationDueOn,
      insuranceDueOn: insuranceDueOn ?? this.insuranceDueOn,
      pmsDueOn: pmsDueOn ?? this.pmsDueOn,
      pmsDueKm: pmsDueKm ?? this.pmsDueKm,
      pmsEveryMonths: pmsEveryMonths ?? this.pmsEveryMonths,
      pmsEveryKm: pmsEveryKm ?? this.pmsEveryKm,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (serverVersion.present) {
      map['server_version'] = Variable<int>(serverVersion.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (plate.present) {
      map['plate'] = Variable<String>(plate.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (registrationDueOn.present) {
      map['registration_due_on'] = Variable<String>(registrationDueOn.value);
    }
    if (insuranceDueOn.present) {
      map['insurance_due_on'] = Variable<String>(insuranceDueOn.value);
    }
    if (pmsDueOn.present) {
      map['pms_due_on'] = Variable<String>(pmsDueOn.value);
    }
    if (pmsDueKm.present) {
      map['pms_due_km'] = Variable<int>(pmsDueKm.value);
    }
    if (pmsEveryMonths.present) {
      map['pms_every_months'] = Variable<int>(pmsEveryMonths.value);
    }
    if (pmsEveryKm.present) {
      map['pms_every_km'] = Variable<int>(pmsEveryKm.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VehiclesCompanion(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('hlc: $hlc, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deviceId: $deviceId, ')
          ..write('kind: $kind, ')
          ..write('name: $name, ')
          ..write('plate: $plate, ')
          ..write('color: $color, ')
          ..write('registrationDueOn: $registrationDueOn, ')
          ..write('insuranceDueOn: $insuranceDueOn, ')
          ..write('pmsDueOn: $pmsDueOn, ')
          ..write('pmsDueKm: $pmsDueKm, ')
          ..write('pmsEveryMonths: $pmsEveryMonths, ')
          ..write('pmsEveryKm: $pmsEveryKm, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VehicleLogsTable extends VehicleLogs
    with TableInfo<$VehicleLogsTable, VehicleLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VehicleLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _householdIdMeta = const VerificationMeta(
    'householdId',
  );
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
    'household_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverVersionMeta = const VerificationMeta(
    'serverVersion',
  );
  @override
  late final GeneratedColumn<int> serverVersion = GeneratedColumn<int>(
    'server_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<String> vehicleId = GeneratedColumn<String>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PHP'),
  );
  static const VerificationMeta _loggedOnMeta = const VerificationMeta(
    'loggedOn',
  );
  @override
  late final GeneratedColumn<String> loggedOn = GeneratedColumn<String>(
    'logged_on',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _odometerKmMeta = const VerificationMeta(
    'odometerKm',
  );
  @override
  late final GeneratedColumn<int> odometerKm = GeneratedColumn<int>(
    'odometer_km',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _litresMeta = const VerificationMeta('litres');
  @override
  late final GeneratedColumn<double> litres = GeneratedColumn<double>(
    'litres',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _memberIdMeta = const VerificationMeta(
    'memberId',
  );
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
    'member_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    householdId,
    createdAt,
    updatedAt,
    deletedAt,
    hlc,
    serverVersion,
    updatedBy,
    deviceId,
    vehicleId,
    kind,
    amountMinor,
    currency,
    loggedOn,
    odometerKm,
    litres,
    memberId,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vehicle_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<VehicleLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
        _householdIdMeta,
        householdId.isAcceptableOrUnknown(
          data['household_id']!,
          _householdIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    }
    if (data.containsKey('server_version')) {
      context.handle(
        _serverVersionMeta,
        serverVersion.isAcceptableOrUnknown(
          data['server_version']!,
          _serverVersionMeta,
        ),
      );
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('logged_on')) {
      context.handle(
        _loggedOnMeta,
        loggedOn.isAcceptableOrUnknown(data['logged_on']!, _loggedOnMeta),
      );
    } else if (isInserting) {
      context.missing(_loggedOnMeta);
    }
    if (data.containsKey('odometer_km')) {
      context.handle(
        _odometerKmMeta,
        odometerKm.isAcceptableOrUnknown(data['odometer_km']!, _odometerKmMeta),
      );
    }
    if (data.containsKey('litres')) {
      context.handle(
        _litresMeta,
        litres.isAcceptableOrUnknown(data['litres']!, _litresMeta),
      );
    }
    if (data.containsKey('member_id')) {
      context.handle(
        _memberIdMeta,
        memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VehicleLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VehicleLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      householdId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}household_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      ),
      serverVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_version'],
      ),
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vehicle_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      loggedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logged_on'],
      )!,
      odometerKm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}odometer_km'],
      ),
      litres: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}litres'],
      ),
      memberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_id'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $VehicleLogsTable createAlias(String alias) {
    return $VehicleLogsTable(attachedDatabase, alias);
  }
}

class VehicleLog extends DataClass implements Insertable<VehicleLog> {
  final String id;
  final String householdId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? hlc;
  final int? serverVersion;
  final String? updatedBy;
  final String? deviceId;
  final String vehicleId;
  final String kind;
  final int? amountMinor;
  final String currency;

  /// Calendar date `YYYY-MM-DD`.
  final String loggedOn;
  final int? odometerKm;
  final double? litres;
  final String? memberId;
  final String? note;
  const VehicleLog({
    required this.id,
    required this.householdId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.hlc,
    this.serverVersion,
    this.updatedBy,
    this.deviceId,
    required this.vehicleId,
    required this.kind,
    this.amountMinor,
    required this.currency,
    required this.loggedOn,
    this.odometerKm,
    this.litres,
    this.memberId,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['household_id'] = Variable<String>(householdId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || hlc != null) {
      map['hlc'] = Variable<String>(hlc);
    }
    if (!nullToAbsent || serverVersion != null) {
      map['server_version'] = Variable<int>(serverVersion);
    }
    if (!nullToAbsent || updatedBy != null) {
      map['updated_by'] = Variable<String>(updatedBy);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['vehicle_id'] = Variable<String>(vehicleId);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || amountMinor != null) {
      map['amount_minor'] = Variable<int>(amountMinor);
    }
    map['currency'] = Variable<String>(currency);
    map['logged_on'] = Variable<String>(loggedOn);
    if (!nullToAbsent || odometerKm != null) {
      map['odometer_km'] = Variable<int>(odometerKm);
    }
    if (!nullToAbsent || litres != null) {
      map['litres'] = Variable<double>(litres);
    }
    if (!nullToAbsent || memberId != null) {
      map['member_id'] = Variable<String>(memberId);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  VehicleLogsCompanion toCompanion(bool nullToAbsent) {
    return VehicleLogsCompanion(
      id: Value(id),
      householdId: Value(householdId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      hlc: hlc == null && nullToAbsent ? const Value.absent() : Value(hlc),
      serverVersion: serverVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(serverVersion),
      updatedBy: updatedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedBy),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      vehicleId: Value(vehicleId),
      kind: Value(kind),
      amountMinor: amountMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(amountMinor),
      currency: Value(currency),
      loggedOn: Value(loggedOn),
      odometerKm: odometerKm == null && nullToAbsent
          ? const Value.absent()
          : Value(odometerKm),
      litres: litres == null && nullToAbsent
          ? const Value.absent()
          : Value(litres),
      memberId: memberId == null && nullToAbsent
          ? const Value.absent()
          : Value(memberId),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory VehicleLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VehicleLog(
      id: serializer.fromJson<String>(json['id']),
      householdId: serializer.fromJson<String>(json['householdId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      hlc: serializer.fromJson<String?>(json['hlc']),
      serverVersion: serializer.fromJson<int?>(json['serverVersion']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      vehicleId: serializer.fromJson<String>(json['vehicleId']),
      kind: serializer.fromJson<String>(json['kind']),
      amountMinor: serializer.fromJson<int?>(json['amountMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      loggedOn: serializer.fromJson<String>(json['loggedOn']),
      odometerKm: serializer.fromJson<int?>(json['odometerKm']),
      litres: serializer.fromJson<double?>(json['litres']),
      memberId: serializer.fromJson<String?>(json['memberId']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'householdId': serializer.toJson<String>(householdId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'hlc': serializer.toJson<String?>(hlc),
      'serverVersion': serializer.toJson<int?>(serverVersion),
      'updatedBy': serializer.toJson<String?>(updatedBy),
      'deviceId': serializer.toJson<String?>(deviceId),
      'vehicleId': serializer.toJson<String>(vehicleId),
      'kind': serializer.toJson<String>(kind),
      'amountMinor': serializer.toJson<int?>(amountMinor),
      'currency': serializer.toJson<String>(currency),
      'loggedOn': serializer.toJson<String>(loggedOn),
      'odometerKm': serializer.toJson<int?>(odometerKm),
      'litres': serializer.toJson<double?>(litres),
      'memberId': serializer.toJson<String?>(memberId),
      'note': serializer.toJson<String?>(note),
    };
  }

  VehicleLog copyWith({
    String? id,
    String? householdId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> hlc = const Value.absent(),
    Value<int?> serverVersion = const Value.absent(),
    Value<String?> updatedBy = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
    String? vehicleId,
    String? kind,
    Value<int?> amountMinor = const Value.absent(),
    String? currency,
    String? loggedOn,
    Value<int?> odometerKm = const Value.absent(),
    Value<double?> litres = const Value.absent(),
    Value<String?> memberId = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) => VehicleLog(
    id: id ?? this.id,
    householdId: householdId ?? this.householdId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    hlc: hlc.present ? hlc.value : this.hlc,
    serverVersion: serverVersion.present
        ? serverVersion.value
        : this.serverVersion,
    updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    vehicleId: vehicleId ?? this.vehicleId,
    kind: kind ?? this.kind,
    amountMinor: amountMinor.present ? amountMinor.value : this.amountMinor,
    currency: currency ?? this.currency,
    loggedOn: loggedOn ?? this.loggedOn,
    odometerKm: odometerKm.present ? odometerKm.value : this.odometerKm,
    litres: litres.present ? litres.value : this.litres,
    memberId: memberId.present ? memberId.value : this.memberId,
    note: note.present ? note.value : this.note,
  );
  VehicleLog copyWithCompanion(VehicleLogsCompanion data) {
    return VehicleLog(
      id: data.id.present ? data.id.value : this.id,
      householdId: data.householdId.present
          ? data.householdId.value
          : this.householdId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      serverVersion: data.serverVersion.present
          ? data.serverVersion.value
          : this.serverVersion,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      kind: data.kind.present ? data.kind.value : this.kind,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      loggedOn: data.loggedOn.present ? data.loggedOn.value : this.loggedOn,
      odometerKm: data.odometerKm.present
          ? data.odometerKm.value
          : this.odometerKm,
      litres: data.litres.present ? data.litres.value : this.litres,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VehicleLog(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('hlc: $hlc, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deviceId: $deviceId, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('kind: $kind, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('loggedOn: $loggedOn, ')
          ..write('odometerKm: $odometerKm, ')
          ..write('litres: $litres, ')
          ..write('memberId: $memberId, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    householdId,
    createdAt,
    updatedAt,
    deletedAt,
    hlc,
    serverVersion,
    updatedBy,
    deviceId,
    vehicleId,
    kind,
    amountMinor,
    currency,
    loggedOn,
    odometerKm,
    litres,
    memberId,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VehicleLog &&
          other.id == this.id &&
          other.householdId == this.householdId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.hlc == this.hlc &&
          other.serverVersion == this.serverVersion &&
          other.updatedBy == this.updatedBy &&
          other.deviceId == this.deviceId &&
          other.vehicleId == this.vehicleId &&
          other.kind == this.kind &&
          other.amountMinor == this.amountMinor &&
          other.currency == this.currency &&
          other.loggedOn == this.loggedOn &&
          other.odometerKm == this.odometerKm &&
          other.litres == this.litres &&
          other.memberId == this.memberId &&
          other.note == this.note);
}

class VehicleLogsCompanion extends UpdateCompanion<VehicleLog> {
  final Value<String> id;
  final Value<String> householdId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> hlc;
  final Value<int?> serverVersion;
  final Value<String?> updatedBy;
  final Value<String?> deviceId;
  final Value<String> vehicleId;
  final Value<String> kind;
  final Value<int?> amountMinor;
  final Value<String> currency;
  final Value<String> loggedOn;
  final Value<int?> odometerKm;
  final Value<double?> litres;
  final Value<String?> memberId;
  final Value<String?> note;
  final Value<int> rowid;
  const VehicleLogsCompanion({
    this.id = const Value.absent(),
    this.householdId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.hlc = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.kind = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.loggedOn = const Value.absent(),
    this.odometerKm = const Value.absent(),
    this.litres = const Value.absent(),
    this.memberId = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VehicleLogsCompanion.insert({
    required String id,
    required String householdId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.hlc = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.deviceId = const Value.absent(),
    required String vehicleId,
    required String kind,
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    required String loggedOn,
    this.odometerKm = const Value.absent(),
    this.litres = const Value.absent(),
    this.memberId = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       householdId = Value(householdId),
       vehicleId = Value(vehicleId),
       kind = Value(kind),
       loggedOn = Value(loggedOn);
  static Insertable<VehicleLog> custom({
    Expression<String>? id,
    Expression<String>? householdId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? hlc,
    Expression<int>? serverVersion,
    Expression<String>? updatedBy,
    Expression<String>? deviceId,
    Expression<String>? vehicleId,
    Expression<String>? kind,
    Expression<int>? amountMinor,
    Expression<String>? currency,
    Expression<String>? loggedOn,
    Expression<int>? odometerKm,
    Expression<double>? litres,
    Expression<String>? memberId,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (householdId != null) 'household_id': householdId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (hlc != null) 'hlc': hlc,
      if (serverVersion != null) 'server_version': serverVersion,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (deviceId != null) 'device_id': deviceId,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (kind != null) 'kind': kind,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currency != null) 'currency': currency,
      if (loggedOn != null) 'logged_on': loggedOn,
      if (odometerKm != null) 'odometer_km': odometerKm,
      if (litres != null) 'litres': litres,
      if (memberId != null) 'member_id': memberId,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VehicleLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? householdId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? hlc,
    Value<int?>? serverVersion,
    Value<String?>? updatedBy,
    Value<String?>? deviceId,
    Value<String>? vehicleId,
    Value<String>? kind,
    Value<int?>? amountMinor,
    Value<String>? currency,
    Value<String>? loggedOn,
    Value<int?>? odometerKm,
    Value<double?>? litres,
    Value<String?>? memberId,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return VehicleLogsCompanion(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      hlc: hlc ?? this.hlc,
      serverVersion: serverVersion ?? this.serverVersion,
      updatedBy: updatedBy ?? this.updatedBy,
      deviceId: deviceId ?? this.deviceId,
      vehicleId: vehicleId ?? this.vehicleId,
      kind: kind ?? this.kind,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      loggedOn: loggedOn ?? this.loggedOn,
      odometerKm: odometerKm ?? this.odometerKm,
      litres: litres ?? this.litres,
      memberId: memberId ?? this.memberId,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (serverVersion.present) {
      map['server_version'] = Variable<int>(serverVersion.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<String>(vehicleId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (loggedOn.present) {
      map['logged_on'] = Variable<String>(loggedOn.value);
    }
    if (odometerKm.present) {
      map['odometer_km'] = Variable<int>(odometerKm.value);
    }
    if (litres.present) {
      map['litres'] = Variable<double>(litres.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VehicleLogsCompanion(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('hlc: $hlc, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deviceId: $deviceId, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('kind: $kind, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('loggedOn: $loggedOn, ')
          ..write('odometerKm: $odometerKm, ')
          ..write('litres: $litres, ')
          ..write('memberId: $memberId, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BudgetsTable extends Budgets with TableInfo<$BudgetsTable, Budget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _householdIdMeta = const VerificationMeta(
    'householdId',
  );
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
    'household_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverVersionMeta = const VerificationMeta(
    'serverVersion',
  );
  @override
  late final GeneratedColumn<int> serverVersion = GeneratedColumn<int>(
    'server_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _limitMinorMeta = const VerificationMeta(
    'limitMinor',
  );
  @override
  late final GeneratedColumn<int> limitMinor = GeneratedColumn<int>(
    'limit_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PHP'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    householdId,
    createdAt,
    updatedAt,
    deletedAt,
    hlc,
    serverVersion,
    updatedBy,
    deviceId,
    category,
    limitMinor,
    currency,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budgets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Budget> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
        _householdIdMeta,
        householdId.isAcceptableOrUnknown(
          data['household_id']!,
          _householdIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    }
    if (data.containsKey('server_version')) {
      context.handle(
        _serverVersionMeta,
        serverVersion.isAcceptableOrUnknown(
          data['server_version']!,
          _serverVersionMeta,
        ),
      );
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('limit_minor')) {
      context.handle(
        _limitMinorMeta,
        limitMinor.isAcceptableOrUnknown(data['limit_minor']!, _limitMinorMeta),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Budget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Budget(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      householdId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}household_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      ),
      serverVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_version'],
      ),
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      limitMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}limit_minor'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
    );
  }

  @override
  $BudgetsTable createAlias(String alias) {
    return $BudgetsTable(attachedDatabase, alias);
  }
}

class Budget extends DataClass implements Insertable<Budget> {
  final String id;
  final String householdId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? hlc;
  final int? serverVersion;
  final String? updatedBy;
  final String? deviceId;
  final String category;
  final int limitMinor;
  final String currency;
  const Budget({
    required this.id,
    required this.householdId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.hlc,
    this.serverVersion,
    this.updatedBy,
    this.deviceId,
    required this.category,
    required this.limitMinor,
    required this.currency,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['household_id'] = Variable<String>(householdId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || hlc != null) {
      map['hlc'] = Variable<String>(hlc);
    }
    if (!nullToAbsent || serverVersion != null) {
      map['server_version'] = Variable<int>(serverVersion);
    }
    if (!nullToAbsent || updatedBy != null) {
      map['updated_by'] = Variable<String>(updatedBy);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['category'] = Variable<String>(category);
    map['limit_minor'] = Variable<int>(limitMinor);
    map['currency'] = Variable<String>(currency);
    return map;
  }

  BudgetsCompanion toCompanion(bool nullToAbsent) {
    return BudgetsCompanion(
      id: Value(id),
      householdId: Value(householdId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      hlc: hlc == null && nullToAbsent ? const Value.absent() : Value(hlc),
      serverVersion: serverVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(serverVersion),
      updatedBy: updatedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedBy),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      category: Value(category),
      limitMinor: Value(limitMinor),
      currency: Value(currency),
    );
  }

  factory Budget.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Budget(
      id: serializer.fromJson<String>(json['id']),
      householdId: serializer.fromJson<String>(json['householdId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      hlc: serializer.fromJson<String?>(json['hlc']),
      serverVersion: serializer.fromJson<int?>(json['serverVersion']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      category: serializer.fromJson<String>(json['category']),
      limitMinor: serializer.fromJson<int>(json['limitMinor']),
      currency: serializer.fromJson<String>(json['currency']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'householdId': serializer.toJson<String>(householdId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'hlc': serializer.toJson<String?>(hlc),
      'serverVersion': serializer.toJson<int?>(serverVersion),
      'updatedBy': serializer.toJson<String?>(updatedBy),
      'deviceId': serializer.toJson<String?>(deviceId),
      'category': serializer.toJson<String>(category),
      'limitMinor': serializer.toJson<int>(limitMinor),
      'currency': serializer.toJson<String>(currency),
    };
  }

  Budget copyWith({
    String? id,
    String? householdId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> hlc = const Value.absent(),
    Value<int?> serverVersion = const Value.absent(),
    Value<String?> updatedBy = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
    String? category,
    int? limitMinor,
    String? currency,
  }) => Budget(
    id: id ?? this.id,
    householdId: householdId ?? this.householdId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    hlc: hlc.present ? hlc.value : this.hlc,
    serverVersion: serverVersion.present
        ? serverVersion.value
        : this.serverVersion,
    updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    category: category ?? this.category,
    limitMinor: limitMinor ?? this.limitMinor,
    currency: currency ?? this.currency,
  );
  Budget copyWithCompanion(BudgetsCompanion data) {
    return Budget(
      id: data.id.present ? data.id.value : this.id,
      householdId: data.householdId.present
          ? data.householdId.value
          : this.householdId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      serverVersion: data.serverVersion.present
          ? data.serverVersion.value
          : this.serverVersion,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      category: data.category.present ? data.category.value : this.category,
      limitMinor: data.limitMinor.present
          ? data.limitMinor.value
          : this.limitMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Budget(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('hlc: $hlc, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deviceId: $deviceId, ')
          ..write('category: $category, ')
          ..write('limitMinor: $limitMinor, ')
          ..write('currency: $currency')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    householdId,
    createdAt,
    updatedAt,
    deletedAt,
    hlc,
    serverVersion,
    updatedBy,
    deviceId,
    category,
    limitMinor,
    currency,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Budget &&
          other.id == this.id &&
          other.householdId == this.householdId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.hlc == this.hlc &&
          other.serverVersion == this.serverVersion &&
          other.updatedBy == this.updatedBy &&
          other.deviceId == this.deviceId &&
          other.category == this.category &&
          other.limitMinor == this.limitMinor &&
          other.currency == this.currency);
}

class BudgetsCompanion extends UpdateCompanion<Budget> {
  final Value<String> id;
  final Value<String> householdId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> hlc;
  final Value<int?> serverVersion;
  final Value<String?> updatedBy;
  final Value<String?> deviceId;
  final Value<String> category;
  final Value<int> limitMinor;
  final Value<String> currency;
  final Value<int> rowid;
  const BudgetsCompanion({
    this.id = const Value.absent(),
    this.householdId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.hlc = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.category = const Value.absent(),
    this.limitMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetsCompanion.insert({
    required String id,
    required String householdId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.hlc = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.deviceId = const Value.absent(),
    required String category,
    this.limitMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       householdId = Value(householdId),
       category = Value(category);
  static Insertable<Budget> custom({
    Expression<String>? id,
    Expression<String>? householdId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? hlc,
    Expression<int>? serverVersion,
    Expression<String>? updatedBy,
    Expression<String>? deviceId,
    Expression<String>? category,
    Expression<int>? limitMinor,
    Expression<String>? currency,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (householdId != null) 'household_id': householdId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (hlc != null) 'hlc': hlc,
      if (serverVersion != null) 'server_version': serverVersion,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (deviceId != null) 'device_id': deviceId,
      if (category != null) 'category': category,
      if (limitMinor != null) 'limit_minor': limitMinor,
      if (currency != null) 'currency': currency,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetsCompanion copyWith({
    Value<String>? id,
    Value<String>? householdId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? hlc,
    Value<int?>? serverVersion,
    Value<String?>? updatedBy,
    Value<String?>? deviceId,
    Value<String>? category,
    Value<int>? limitMinor,
    Value<String>? currency,
    Value<int>? rowid,
  }) {
    return BudgetsCompanion(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      hlc: hlc ?? this.hlc,
      serverVersion: serverVersion ?? this.serverVersion,
      updatedBy: updatedBy ?? this.updatedBy,
      deviceId: deviceId ?? this.deviceId,
      category: category ?? this.category,
      limitMinor: limitMinor ?? this.limitMinor,
      currency: currency ?? this.currency,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (serverVersion.present) {
      map['server_version'] = Variable<int>(serverVersion.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (limitMinor.present) {
      map['limit_minor'] = Variable<int>(limitMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetsCompanion(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('hlc: $hlc, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deviceId: $deviceId, ')
          ..write('category: $category, ')
          ..write('limitMinor: $limitMinor, ')
          ..write('currency: $currency, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, LedgerEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _householdIdMeta = const VerificationMeta(
    'householdId',
  );
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
    'household_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverVersionMeta = const VerificationMeta(
    'serverVersion',
  );
  @override
  late final GeneratedColumn<int> serverVersion = GeneratedColumn<int>(
    'server_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PHP'),
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _memberIdMeta = const VerificationMeta(
    'memberId',
  );
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
    'member_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceTypeMeta = const VerificationMeta(
    'sourceType',
  );
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
    'source_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    householdId,
    createdAt,
    updatedAt,
    deletedAt,
    hlc,
    serverVersion,
    updatedBy,
    deviceId,
    accountId,
    category,
    amountMinor,
    currency,
    occurredAt,
    memberId,
    sourceType,
    sourceId,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<LedgerEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
        _householdIdMeta,
        householdId.isAcceptableOrUnknown(
          data['household_id']!,
          _householdIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    }
    if (data.containsKey('server_version')) {
      context.handle(
        _serverVersionMeta,
        serverVersion.isAcceptableOrUnknown(
          data['server_version']!,
          _serverVersionMeta,
        ),
      );
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('member_id')) {
      context.handle(
        _memberIdMeta,
        memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta),
      );
    }
    if (data.containsKey('source_type')) {
      context.handle(
        _sourceTypeMeta,
        sourceType.isAcceptableOrUnknown(data['source_type']!, _sourceTypeMeta),
      );
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LedgerEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LedgerEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      householdId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}household_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      ),
      serverVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_version'],
      ),
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      memberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_id'],
      ),
      sourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_type'],
      ),
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class LedgerEntry extends DataClass implements Insertable<LedgerEntry> {
  final String id;
  final String householdId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? hlc;
  final int? serverVersion;
  final String? updatedBy;
  final String? deviceId;
  final String? accountId;
  final String? category;
  final int amountMinor;
  final String currency;
  final DateTime occurredAt;
  final String? memberId;
  final String? sourceType;
  final String? sourceId;
  final String? note;
  const LedgerEntry({
    required this.id,
    required this.householdId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.hlc,
    this.serverVersion,
    this.updatedBy,
    this.deviceId,
    this.accountId,
    this.category,
    required this.amountMinor,
    required this.currency,
    required this.occurredAt,
    this.memberId,
    this.sourceType,
    this.sourceId,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['household_id'] = Variable<String>(householdId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || hlc != null) {
      map['hlc'] = Variable<String>(hlc);
    }
    if (!nullToAbsent || serverVersion != null) {
      map['server_version'] = Variable<int>(serverVersion);
    }
    if (!nullToAbsent || updatedBy != null) {
      map['updated_by'] = Variable<String>(updatedBy);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<String>(accountId);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency'] = Variable<String>(currency);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    if (!nullToAbsent || memberId != null) {
      map['member_id'] = Variable<String>(memberId);
    }
    if (!nullToAbsent || sourceType != null) {
      map['source_type'] = Variable<String>(sourceType);
    }
    if (!nullToAbsent || sourceId != null) {
      map['source_id'] = Variable<String>(sourceId);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      householdId: Value(householdId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      hlc: hlc == null && nullToAbsent ? const Value.absent() : Value(hlc),
      serverVersion: serverVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(serverVersion),
      updatedBy: updatedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedBy),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      amountMinor: Value(amountMinor),
      currency: Value(currency),
      occurredAt: Value(occurredAt),
      memberId: memberId == null && nullToAbsent
          ? const Value.absent()
          : Value(memberId),
      sourceType: sourceType == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceType),
      sourceId: sourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceId),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory LedgerEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LedgerEntry(
      id: serializer.fromJson<String>(json['id']),
      householdId: serializer.fromJson<String>(json['householdId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      hlc: serializer.fromJson<String?>(json['hlc']),
      serverVersion: serializer.fromJson<int?>(json['serverVersion']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      accountId: serializer.fromJson<String?>(json['accountId']),
      category: serializer.fromJson<String?>(json['category']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      memberId: serializer.fromJson<String?>(json['memberId']),
      sourceType: serializer.fromJson<String?>(json['sourceType']),
      sourceId: serializer.fromJson<String?>(json['sourceId']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'householdId': serializer.toJson<String>(householdId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'hlc': serializer.toJson<String?>(hlc),
      'serverVersion': serializer.toJson<int?>(serverVersion),
      'updatedBy': serializer.toJson<String?>(updatedBy),
      'deviceId': serializer.toJson<String?>(deviceId),
      'accountId': serializer.toJson<String?>(accountId),
      'category': serializer.toJson<String?>(category),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currency': serializer.toJson<String>(currency),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'memberId': serializer.toJson<String?>(memberId),
      'sourceType': serializer.toJson<String?>(sourceType),
      'sourceId': serializer.toJson<String?>(sourceId),
      'note': serializer.toJson<String?>(note),
    };
  }

  LedgerEntry copyWith({
    String? id,
    String? householdId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> hlc = const Value.absent(),
    Value<int?> serverVersion = const Value.absent(),
    Value<String?> updatedBy = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
    Value<String?> accountId = const Value.absent(),
    Value<String?> category = const Value.absent(),
    int? amountMinor,
    String? currency,
    DateTime? occurredAt,
    Value<String?> memberId = const Value.absent(),
    Value<String?> sourceType = const Value.absent(),
    Value<String?> sourceId = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) => LedgerEntry(
    id: id ?? this.id,
    householdId: householdId ?? this.householdId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    hlc: hlc.present ? hlc.value : this.hlc,
    serverVersion: serverVersion.present
        ? serverVersion.value
        : this.serverVersion,
    updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    accountId: accountId.present ? accountId.value : this.accountId,
    category: category.present ? category.value : this.category,
    amountMinor: amountMinor ?? this.amountMinor,
    currency: currency ?? this.currency,
    occurredAt: occurredAt ?? this.occurredAt,
    memberId: memberId.present ? memberId.value : this.memberId,
    sourceType: sourceType.present ? sourceType.value : this.sourceType,
    sourceId: sourceId.present ? sourceId.value : this.sourceId,
    note: note.present ? note.value : this.note,
  );
  LedgerEntry copyWithCompanion(TransactionsCompanion data) {
    return LedgerEntry(
      id: data.id.present ? data.id.value : this.id,
      householdId: data.householdId.present
          ? data.householdId.value
          : this.householdId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      serverVersion: data.serverVersion.present
          ? data.serverVersion.value
          : this.serverVersion,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      category: data.category.present ? data.category.value : this.category,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      sourceType: data.sourceType.present
          ? data.sourceType.value
          : this.sourceType,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LedgerEntry(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('hlc: $hlc, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deviceId: $deviceId, ')
          ..write('accountId: $accountId, ')
          ..write('category: $category, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('memberId: $memberId, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceId: $sourceId, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    householdId,
    createdAt,
    updatedAt,
    deletedAt,
    hlc,
    serverVersion,
    updatedBy,
    deviceId,
    accountId,
    category,
    amountMinor,
    currency,
    occurredAt,
    memberId,
    sourceType,
    sourceId,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LedgerEntry &&
          other.id == this.id &&
          other.householdId == this.householdId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.hlc == this.hlc &&
          other.serverVersion == this.serverVersion &&
          other.updatedBy == this.updatedBy &&
          other.deviceId == this.deviceId &&
          other.accountId == this.accountId &&
          other.category == this.category &&
          other.amountMinor == this.amountMinor &&
          other.currency == this.currency &&
          other.occurredAt == this.occurredAt &&
          other.memberId == this.memberId &&
          other.sourceType == this.sourceType &&
          other.sourceId == this.sourceId &&
          other.note == this.note);
}

class TransactionsCompanion extends UpdateCompanion<LedgerEntry> {
  final Value<String> id;
  final Value<String> householdId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> hlc;
  final Value<int?> serverVersion;
  final Value<String?> updatedBy;
  final Value<String?> deviceId;
  final Value<String?> accountId;
  final Value<String?> category;
  final Value<int> amountMinor;
  final Value<String> currency;
  final Value<DateTime> occurredAt;
  final Value<String?> memberId;
  final Value<String?> sourceType;
  final Value<String?> sourceId;
  final Value<String?> note;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.householdId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.hlc = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.category = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.memberId = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String id,
    required String householdId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.hlc = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.category = const Value.absent(),
    required int amountMinor,
    this.currency = const Value.absent(),
    required DateTime occurredAt,
    this.memberId = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       householdId = Value(householdId),
       amountMinor = Value(amountMinor),
       occurredAt = Value(occurredAt);
  static Insertable<LedgerEntry> custom({
    Expression<String>? id,
    Expression<String>? householdId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? hlc,
    Expression<int>? serverVersion,
    Expression<String>? updatedBy,
    Expression<String>? deviceId,
    Expression<String>? accountId,
    Expression<String>? category,
    Expression<int>? amountMinor,
    Expression<String>? currency,
    Expression<DateTime>? occurredAt,
    Expression<String>? memberId,
    Expression<String>? sourceType,
    Expression<String>? sourceId,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (householdId != null) 'household_id': householdId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (hlc != null) 'hlc': hlc,
      if (serverVersion != null) 'server_version': serverVersion,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (deviceId != null) 'device_id': deviceId,
      if (accountId != null) 'account_id': accountId,
      if (category != null) 'category': category,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currency != null) 'currency': currency,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (memberId != null) 'member_id': memberId,
      if (sourceType != null) 'source_type': sourceType,
      if (sourceId != null) 'source_id': sourceId,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith({
    Value<String>? id,
    Value<String>? householdId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? hlc,
    Value<int?>? serverVersion,
    Value<String?>? updatedBy,
    Value<String?>? deviceId,
    Value<String?>? accountId,
    Value<String?>? category,
    Value<int>? amountMinor,
    Value<String>? currency,
    Value<DateTime>? occurredAt,
    Value<String?>? memberId,
    Value<String?>? sourceType,
    Value<String?>? sourceId,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      hlc: hlc ?? this.hlc,
      serverVersion: serverVersion ?? this.serverVersion,
      updatedBy: updatedBy ?? this.updatedBy,
      deviceId: deviceId ?? this.deviceId,
      accountId: accountId ?? this.accountId,
      category: category ?? this.category,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      occurredAt: occurredAt ?? this.occurredAt,
      memberId: memberId ?? this.memberId,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (serverVersion.present) {
      map['server_version'] = Variable<int>(serverVersion.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('hlc: $hlc, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deviceId: $deviceId, ')
          ..write('accountId: $accountId, ')
          ..write('category: $category, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('memberId: $memberId, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceId: $sourceId, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConflictsTable extends Conflicts
    with TableInfo<$ConflictsTable, ConflictRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConflictsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _householdIdMeta = const VerificationMeta(
    'householdId',
  );
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
    'household_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverVersionMeta = const VerificationMeta(
    'serverVersion',
  );
  @override
  late final GeneratedColumn<int> serverVersion = GeneratedColumn<int>(
    'server_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fieldMeta = const VerificationMeta('field');
  @override
  late final GeneratedColumn<String> field = GeneratedColumn<String>(
    'field',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keptValueMeta = const VerificationMeta(
    'keptValue',
  );
  @override
  late final GeneratedColumn<String> keptValue = GeneratedColumn<String>(
    'kept_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _keptByMeta = const VerificationMeta('keptBy');
  @override
  late final GeneratedColumn<String> keptBy = GeneratedColumn<String>(
    'kept_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lostValueMeta = const VerificationMeta(
    'lostValue',
  );
  @override
  late final GeneratedColumn<String> lostValue = GeneratedColumn<String>(
    'lost_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lostByMeta = const VerificationMeta('lostBy');
  @override
  late final GeneratedColumn<String> lostBy = GeneratedColumn<String>(
    'lost_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resolvedAtMeta = const VerificationMeta(
    'resolvedAt',
  );
  @override
  late final GeneratedColumn<DateTime> resolvedAt = GeneratedColumn<DateTime>(
    'resolved_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resolvedByMeta = const VerificationMeta(
    'resolvedBy',
  );
  @override
  late final GeneratedColumn<String> resolvedBy = GeneratedColumn<String>(
    'resolved_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    householdId,
    createdAt,
    updatedAt,
    deletedAt,
    hlc,
    serverVersion,
    updatedBy,
    deviceId,
    entity,
    entityId,
    field,
    keptValue,
    keptBy,
    lostValue,
    lostBy,
    resolvedAt,
    resolvedBy,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conflicts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConflictRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
        _householdIdMeta,
        householdId.isAcceptableOrUnknown(
          data['household_id']!,
          _householdIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    }
    if (data.containsKey('server_version')) {
      context.handle(
        _serverVersionMeta,
        serverVersion.isAcceptableOrUnknown(
          data['server_version']!,
          _serverVersionMeta,
        ),
      );
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('field')) {
      context.handle(
        _fieldMeta,
        field.isAcceptableOrUnknown(data['field']!, _fieldMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldMeta);
    }
    if (data.containsKey('kept_value')) {
      context.handle(
        _keptValueMeta,
        keptValue.isAcceptableOrUnknown(data['kept_value']!, _keptValueMeta),
      );
    }
    if (data.containsKey('kept_by')) {
      context.handle(
        _keptByMeta,
        keptBy.isAcceptableOrUnknown(data['kept_by']!, _keptByMeta),
      );
    }
    if (data.containsKey('lost_value')) {
      context.handle(
        _lostValueMeta,
        lostValue.isAcceptableOrUnknown(data['lost_value']!, _lostValueMeta),
      );
    }
    if (data.containsKey('lost_by')) {
      context.handle(
        _lostByMeta,
        lostBy.isAcceptableOrUnknown(data['lost_by']!, _lostByMeta),
      );
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
        _resolvedAtMeta,
        resolvedAt.isAcceptableOrUnknown(data['resolved_at']!, _resolvedAtMeta),
      );
    }
    if (data.containsKey('resolved_by')) {
      context.handle(
        _resolvedByMeta,
        resolvedBy.isAcceptableOrUnknown(data['resolved_by']!, _resolvedByMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConflictRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConflictRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      householdId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}household_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      ),
      serverVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_version'],
      ),
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      field: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field'],
      )!,
      keptValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kept_value'],
      ),
      keptBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kept_by'],
      ),
      lostValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lost_value'],
      ),
      lostBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lost_by'],
      ),
      resolvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}resolved_at'],
      ),
      resolvedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resolved_by'],
      ),
    );
  }

  @override
  $ConflictsTable createAlias(String alias) {
    return $ConflictsTable(attachedDatabase, alias);
  }
}

class ConflictRecord extends DataClass implements Insertable<ConflictRecord> {
  final String id;
  final String householdId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? hlc;
  final int? serverVersion;
  final String? updatedBy;
  final String? deviceId;
  final String entity;
  final String entityId;
  final String field;

  /// JSON-encoded values, as received.
  final String? keptValue;
  final String? keptBy;
  final String? lostValue;
  final String? lostBy;
  final DateTime? resolvedAt;
  final String? resolvedBy;
  const ConflictRecord({
    required this.id,
    required this.householdId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.hlc,
    this.serverVersion,
    this.updatedBy,
    this.deviceId,
    required this.entity,
    required this.entityId,
    required this.field,
    this.keptValue,
    this.keptBy,
    this.lostValue,
    this.lostBy,
    this.resolvedAt,
    this.resolvedBy,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['household_id'] = Variable<String>(householdId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || hlc != null) {
      map['hlc'] = Variable<String>(hlc);
    }
    if (!nullToAbsent || serverVersion != null) {
      map['server_version'] = Variable<int>(serverVersion);
    }
    if (!nullToAbsent || updatedBy != null) {
      map['updated_by'] = Variable<String>(updatedBy);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['entity'] = Variable<String>(entity);
    map['entity_id'] = Variable<String>(entityId);
    map['field'] = Variable<String>(field);
    if (!nullToAbsent || keptValue != null) {
      map['kept_value'] = Variable<String>(keptValue);
    }
    if (!nullToAbsent || keptBy != null) {
      map['kept_by'] = Variable<String>(keptBy);
    }
    if (!nullToAbsent || lostValue != null) {
      map['lost_value'] = Variable<String>(lostValue);
    }
    if (!nullToAbsent || lostBy != null) {
      map['lost_by'] = Variable<String>(lostBy);
    }
    if (!nullToAbsent || resolvedAt != null) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt);
    }
    if (!nullToAbsent || resolvedBy != null) {
      map['resolved_by'] = Variable<String>(resolvedBy);
    }
    return map;
  }

  ConflictsCompanion toCompanion(bool nullToAbsent) {
    return ConflictsCompanion(
      id: Value(id),
      householdId: Value(householdId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      hlc: hlc == null && nullToAbsent ? const Value.absent() : Value(hlc),
      serverVersion: serverVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(serverVersion),
      updatedBy: updatedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedBy),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      entity: Value(entity),
      entityId: Value(entityId),
      field: Value(field),
      keptValue: keptValue == null && nullToAbsent
          ? const Value.absent()
          : Value(keptValue),
      keptBy: keptBy == null && nullToAbsent
          ? const Value.absent()
          : Value(keptBy),
      lostValue: lostValue == null && nullToAbsent
          ? const Value.absent()
          : Value(lostValue),
      lostBy: lostBy == null && nullToAbsent
          ? const Value.absent()
          : Value(lostBy),
      resolvedAt: resolvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedAt),
      resolvedBy: resolvedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedBy),
    );
  }

  factory ConflictRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConflictRecord(
      id: serializer.fromJson<String>(json['id']),
      householdId: serializer.fromJson<String>(json['householdId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      hlc: serializer.fromJson<String?>(json['hlc']),
      serverVersion: serializer.fromJson<int?>(json['serverVersion']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      entity: serializer.fromJson<String>(json['entity']),
      entityId: serializer.fromJson<String>(json['entityId']),
      field: serializer.fromJson<String>(json['field']),
      keptValue: serializer.fromJson<String?>(json['keptValue']),
      keptBy: serializer.fromJson<String?>(json['keptBy']),
      lostValue: serializer.fromJson<String?>(json['lostValue']),
      lostBy: serializer.fromJson<String?>(json['lostBy']),
      resolvedAt: serializer.fromJson<DateTime?>(json['resolvedAt']),
      resolvedBy: serializer.fromJson<String?>(json['resolvedBy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'householdId': serializer.toJson<String>(householdId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'hlc': serializer.toJson<String?>(hlc),
      'serverVersion': serializer.toJson<int?>(serverVersion),
      'updatedBy': serializer.toJson<String?>(updatedBy),
      'deviceId': serializer.toJson<String?>(deviceId),
      'entity': serializer.toJson<String>(entity),
      'entityId': serializer.toJson<String>(entityId),
      'field': serializer.toJson<String>(field),
      'keptValue': serializer.toJson<String?>(keptValue),
      'keptBy': serializer.toJson<String?>(keptBy),
      'lostValue': serializer.toJson<String?>(lostValue),
      'lostBy': serializer.toJson<String?>(lostBy),
      'resolvedAt': serializer.toJson<DateTime?>(resolvedAt),
      'resolvedBy': serializer.toJson<String?>(resolvedBy),
    };
  }

  ConflictRecord copyWith({
    String? id,
    String? householdId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> hlc = const Value.absent(),
    Value<int?> serverVersion = const Value.absent(),
    Value<String?> updatedBy = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
    String? entity,
    String? entityId,
    String? field,
    Value<String?> keptValue = const Value.absent(),
    Value<String?> keptBy = const Value.absent(),
    Value<String?> lostValue = const Value.absent(),
    Value<String?> lostBy = const Value.absent(),
    Value<DateTime?> resolvedAt = const Value.absent(),
    Value<String?> resolvedBy = const Value.absent(),
  }) => ConflictRecord(
    id: id ?? this.id,
    householdId: householdId ?? this.householdId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    hlc: hlc.present ? hlc.value : this.hlc,
    serverVersion: serverVersion.present
        ? serverVersion.value
        : this.serverVersion,
    updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    entity: entity ?? this.entity,
    entityId: entityId ?? this.entityId,
    field: field ?? this.field,
    keptValue: keptValue.present ? keptValue.value : this.keptValue,
    keptBy: keptBy.present ? keptBy.value : this.keptBy,
    lostValue: lostValue.present ? lostValue.value : this.lostValue,
    lostBy: lostBy.present ? lostBy.value : this.lostBy,
    resolvedAt: resolvedAt.present ? resolvedAt.value : this.resolvedAt,
    resolvedBy: resolvedBy.present ? resolvedBy.value : this.resolvedBy,
  );
  ConflictRecord copyWithCompanion(ConflictsCompanion data) {
    return ConflictRecord(
      id: data.id.present ? data.id.value : this.id,
      householdId: data.householdId.present
          ? data.householdId.value
          : this.householdId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      serverVersion: data.serverVersion.present
          ? data.serverVersion.value
          : this.serverVersion,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      entity: data.entity.present ? data.entity.value : this.entity,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      field: data.field.present ? data.field.value : this.field,
      keptValue: data.keptValue.present ? data.keptValue.value : this.keptValue,
      keptBy: data.keptBy.present ? data.keptBy.value : this.keptBy,
      lostValue: data.lostValue.present ? data.lostValue.value : this.lostValue,
      lostBy: data.lostBy.present ? data.lostBy.value : this.lostBy,
      resolvedAt: data.resolvedAt.present
          ? data.resolvedAt.value
          : this.resolvedAt,
      resolvedBy: data.resolvedBy.present
          ? data.resolvedBy.value
          : this.resolvedBy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConflictRecord(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('hlc: $hlc, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deviceId: $deviceId, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('field: $field, ')
          ..write('keptValue: $keptValue, ')
          ..write('keptBy: $keptBy, ')
          ..write('lostValue: $lostValue, ')
          ..write('lostBy: $lostBy, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('resolvedBy: $resolvedBy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    householdId,
    createdAt,
    updatedAt,
    deletedAt,
    hlc,
    serverVersion,
    updatedBy,
    deviceId,
    entity,
    entityId,
    field,
    keptValue,
    keptBy,
    lostValue,
    lostBy,
    resolvedAt,
    resolvedBy,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConflictRecord &&
          other.id == this.id &&
          other.householdId == this.householdId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.hlc == this.hlc &&
          other.serverVersion == this.serverVersion &&
          other.updatedBy == this.updatedBy &&
          other.deviceId == this.deviceId &&
          other.entity == this.entity &&
          other.entityId == this.entityId &&
          other.field == this.field &&
          other.keptValue == this.keptValue &&
          other.keptBy == this.keptBy &&
          other.lostValue == this.lostValue &&
          other.lostBy == this.lostBy &&
          other.resolvedAt == this.resolvedAt &&
          other.resolvedBy == this.resolvedBy);
}

class ConflictsCompanion extends UpdateCompanion<ConflictRecord> {
  final Value<String> id;
  final Value<String> householdId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> hlc;
  final Value<int?> serverVersion;
  final Value<String?> updatedBy;
  final Value<String?> deviceId;
  final Value<String> entity;
  final Value<String> entityId;
  final Value<String> field;
  final Value<String?> keptValue;
  final Value<String?> keptBy;
  final Value<String?> lostValue;
  final Value<String?> lostBy;
  final Value<DateTime?> resolvedAt;
  final Value<String?> resolvedBy;
  final Value<int> rowid;
  const ConflictsCompanion({
    this.id = const Value.absent(),
    this.householdId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.hlc = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.entity = const Value.absent(),
    this.entityId = const Value.absent(),
    this.field = const Value.absent(),
    this.keptValue = const Value.absent(),
    this.keptBy = const Value.absent(),
    this.lostValue = const Value.absent(),
    this.lostBy = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.resolvedBy = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConflictsCompanion.insert({
    required String id,
    required String householdId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.hlc = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.deviceId = const Value.absent(),
    required String entity,
    required String entityId,
    required String field,
    this.keptValue = const Value.absent(),
    this.keptBy = const Value.absent(),
    this.lostValue = const Value.absent(),
    this.lostBy = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.resolvedBy = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       householdId = Value(householdId),
       entity = Value(entity),
       entityId = Value(entityId),
       field = Value(field);
  static Insertable<ConflictRecord> custom({
    Expression<String>? id,
    Expression<String>? householdId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? hlc,
    Expression<int>? serverVersion,
    Expression<String>? updatedBy,
    Expression<String>? deviceId,
    Expression<String>? entity,
    Expression<String>? entityId,
    Expression<String>? field,
    Expression<String>? keptValue,
    Expression<String>? keptBy,
    Expression<String>? lostValue,
    Expression<String>? lostBy,
    Expression<DateTime>? resolvedAt,
    Expression<String>? resolvedBy,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (householdId != null) 'household_id': householdId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (hlc != null) 'hlc': hlc,
      if (serverVersion != null) 'server_version': serverVersion,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (deviceId != null) 'device_id': deviceId,
      if (entity != null) 'entity': entity,
      if (entityId != null) 'entity_id': entityId,
      if (field != null) 'field': field,
      if (keptValue != null) 'kept_value': keptValue,
      if (keptBy != null) 'kept_by': keptBy,
      if (lostValue != null) 'lost_value': lostValue,
      if (lostBy != null) 'lost_by': lostBy,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
      if (resolvedBy != null) 'resolved_by': resolvedBy,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConflictsCompanion copyWith({
    Value<String>? id,
    Value<String>? householdId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? hlc,
    Value<int?>? serverVersion,
    Value<String?>? updatedBy,
    Value<String?>? deviceId,
    Value<String>? entity,
    Value<String>? entityId,
    Value<String>? field,
    Value<String?>? keptValue,
    Value<String?>? keptBy,
    Value<String?>? lostValue,
    Value<String?>? lostBy,
    Value<DateTime?>? resolvedAt,
    Value<String?>? resolvedBy,
    Value<int>? rowid,
  }) {
    return ConflictsCompanion(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      hlc: hlc ?? this.hlc,
      serverVersion: serverVersion ?? this.serverVersion,
      updatedBy: updatedBy ?? this.updatedBy,
      deviceId: deviceId ?? this.deviceId,
      entity: entity ?? this.entity,
      entityId: entityId ?? this.entityId,
      field: field ?? this.field,
      keptValue: keptValue ?? this.keptValue,
      keptBy: keptBy ?? this.keptBy,
      lostValue: lostValue ?? this.lostValue,
      lostBy: lostBy ?? this.lostBy,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (serverVersion.present) {
      map['server_version'] = Variable<int>(serverVersion.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (field.present) {
      map['field'] = Variable<String>(field.value);
    }
    if (keptValue.present) {
      map['kept_value'] = Variable<String>(keptValue.value);
    }
    if (keptBy.present) {
      map['kept_by'] = Variable<String>(keptBy.value);
    }
    if (lostValue.present) {
      map['lost_value'] = Variable<String>(lostValue.value);
    }
    if (lostBy.present) {
      map['lost_by'] = Variable<String>(lostBy.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt.value);
    }
    if (resolvedBy.present) {
      map['resolved_by'] = Variable<String>(resolvedBy.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConflictsCompanion(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('hlc: $hlc, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deviceId: $deviceId, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('field: $field, ')
          ..write('keptValue: $keptValue, ')
          ..write('keptBy: $keptBy, ')
          ..write('lostValue: $lostValue, ')
          ..write('lostBy: $lostBy, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('resolvedBy: $resolvedBy, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxTable extends Outbox with TableInfo<$OutboxTable, OutboxOp> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _opIdMeta = const VerificationMeta('opId');
  @override
  late final GeneratedColumn<String> opId = GeneratedColumn<String>(
    'op_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _opMeta = const VerificationMeta('op');
  @override
  late final GeneratedColumn<String> op = GeneratedColumn<String>(
    'op',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fieldsMeta = const VerificationMeta('fields');
  @override
  late final GeneratedColumn<String> fields = GeneratedColumn<String>(
    'fields',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseVersionMeta = const VerificationMeta(
    'baseVersion',
  );
  @override
  late final GeneratedColumn<int> baseVersion = GeneratedColumn<int>(
    'base_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sendingMeta = const VerificationMeta(
    'sending',
  );
  @override
  late final GeneratedColumn<bool> sending = GeneratedColumn<bool>(
    'sending',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sending" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _memberIdMeta = const VerificationMeta(
    'memberId',
  );
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
    'member_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  @override
  List<GeneratedColumn> get $columns => [
    seq,
    opId,
    entity,
    entityId,
    op,
    fields,
    hlc,
    baseVersion,
    sending,
    memberId,
    deviceId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxOp> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    }
    if (data.containsKey('op_id')) {
      context.handle(
        _opIdMeta,
        opId.isAcceptableOrUnknown(data['op_id']!, _opIdMeta),
      );
    } else if (isInserting) {
      context.missing(_opIdMeta);
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('op')) {
      context.handle(_opMeta, op.isAcceptableOrUnknown(data['op']!, _opMeta));
    } else if (isInserting) {
      context.missing(_opMeta);
    }
    if (data.containsKey('fields')) {
      context.handle(
        _fieldsMeta,
        fields.isAcceptableOrUnknown(data['fields']!, _fieldsMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldsMeta);
    }
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcMeta);
    }
    if (data.containsKey('base_version')) {
      context.handle(
        _baseVersionMeta,
        baseVersion.isAcceptableOrUnknown(
          data['base_version']!,
          _baseVersionMeta,
        ),
      );
    }
    if (data.containsKey('sending')) {
      context.handle(
        _sendingMeta,
        sending.isAcceptableOrUnknown(data['sending']!, _sendingMeta),
      );
    }
    if (data.containsKey('member_id')) {
      context.handle(
        _memberIdMeta,
        memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta),
      );
    } else if (isInserting) {
      context.missing(_memberIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {seq};
  @override
  OutboxOp map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxOp(
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      opId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_id'],
      )!,
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      op: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op'],
      )!,
      fields: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fields'],
      )!,
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      )!,
      baseVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_version'],
      ),
      sending: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sending'],
      )!,
      memberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $OutboxTable createAlias(String alias) {
    return $OutboxTable(attachedDatabase, alias);
  }
}

class OutboxOp extends DataClass implements Insertable<OutboxOp> {
  final int seq;
  final String opId;
  final String entity;
  final String entityId;

  /// insert, update, delete or increment.
  final String op;

  /// JSON object in wire format.
  final String fields;
  final String hlc;
  final int? baseVersion;

  /// Set when a push containing this op starts. A sending op is never merged
  /// with later edits: the server may already have applied it.
  final bool sending;

  /// Profile that made the change. On the shared tablet each PIN profile is
  /// its own device with its own token, and the op must be pushed with it:
  /// the server takes `updated_by` from the token.
  final String memberId;
  final String deviceId;
  final DateTime createdAt;
  const OutboxOp({
    required this.seq,
    required this.opId,
    required this.entity,
    required this.entityId,
    required this.op,
    required this.fields,
    required this.hlc,
    this.baseVersion,
    required this.sending,
    required this.memberId,
    required this.deviceId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['seq'] = Variable<int>(seq);
    map['op_id'] = Variable<String>(opId);
    map['entity'] = Variable<String>(entity);
    map['entity_id'] = Variable<String>(entityId);
    map['op'] = Variable<String>(op);
    map['fields'] = Variable<String>(fields);
    map['hlc'] = Variable<String>(hlc);
    if (!nullToAbsent || baseVersion != null) {
      map['base_version'] = Variable<int>(baseVersion);
    }
    map['sending'] = Variable<bool>(sending);
    map['member_id'] = Variable<String>(memberId);
    map['device_id'] = Variable<String>(deviceId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  OutboxCompanion toCompanion(bool nullToAbsent) {
    return OutboxCompanion(
      seq: Value(seq),
      opId: Value(opId),
      entity: Value(entity),
      entityId: Value(entityId),
      op: Value(op),
      fields: Value(fields),
      hlc: Value(hlc),
      baseVersion: baseVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(baseVersion),
      sending: Value(sending),
      memberId: Value(memberId),
      deviceId: Value(deviceId),
      createdAt: Value(createdAt),
    );
  }

  factory OutboxOp.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxOp(
      seq: serializer.fromJson<int>(json['seq']),
      opId: serializer.fromJson<String>(json['opId']),
      entity: serializer.fromJson<String>(json['entity']),
      entityId: serializer.fromJson<String>(json['entityId']),
      op: serializer.fromJson<String>(json['op']),
      fields: serializer.fromJson<String>(json['fields']),
      hlc: serializer.fromJson<String>(json['hlc']),
      baseVersion: serializer.fromJson<int?>(json['baseVersion']),
      sending: serializer.fromJson<bool>(json['sending']),
      memberId: serializer.fromJson<String>(json['memberId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'seq': serializer.toJson<int>(seq),
      'opId': serializer.toJson<String>(opId),
      'entity': serializer.toJson<String>(entity),
      'entityId': serializer.toJson<String>(entityId),
      'op': serializer.toJson<String>(op),
      'fields': serializer.toJson<String>(fields),
      'hlc': serializer.toJson<String>(hlc),
      'baseVersion': serializer.toJson<int?>(baseVersion),
      'sending': serializer.toJson<bool>(sending),
      'memberId': serializer.toJson<String>(memberId),
      'deviceId': serializer.toJson<String>(deviceId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  OutboxOp copyWith({
    int? seq,
    String? opId,
    String? entity,
    String? entityId,
    String? op,
    String? fields,
    String? hlc,
    Value<int?> baseVersion = const Value.absent(),
    bool? sending,
    String? memberId,
    String? deviceId,
    DateTime? createdAt,
  }) => OutboxOp(
    seq: seq ?? this.seq,
    opId: opId ?? this.opId,
    entity: entity ?? this.entity,
    entityId: entityId ?? this.entityId,
    op: op ?? this.op,
    fields: fields ?? this.fields,
    hlc: hlc ?? this.hlc,
    baseVersion: baseVersion.present ? baseVersion.value : this.baseVersion,
    sending: sending ?? this.sending,
    memberId: memberId ?? this.memberId,
    deviceId: deviceId ?? this.deviceId,
    createdAt: createdAt ?? this.createdAt,
  );
  OutboxOp copyWithCompanion(OutboxCompanion data) {
    return OutboxOp(
      seq: data.seq.present ? data.seq.value : this.seq,
      opId: data.opId.present ? data.opId.value : this.opId,
      entity: data.entity.present ? data.entity.value : this.entity,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      op: data.op.present ? data.op.value : this.op,
      fields: data.fields.present ? data.fields.value : this.fields,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      baseVersion: data.baseVersion.present
          ? data.baseVersion.value
          : this.baseVersion,
      sending: data.sending.present ? data.sending.value : this.sending,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxOp(')
          ..write('seq: $seq, ')
          ..write('opId: $opId, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('op: $op, ')
          ..write('fields: $fields, ')
          ..write('hlc: $hlc, ')
          ..write('baseVersion: $baseVersion, ')
          ..write('sending: $sending, ')
          ..write('memberId: $memberId, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    seq,
    opId,
    entity,
    entityId,
    op,
    fields,
    hlc,
    baseVersion,
    sending,
    memberId,
    deviceId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxOp &&
          other.seq == this.seq &&
          other.opId == this.opId &&
          other.entity == this.entity &&
          other.entityId == this.entityId &&
          other.op == this.op &&
          other.fields == this.fields &&
          other.hlc == this.hlc &&
          other.baseVersion == this.baseVersion &&
          other.sending == this.sending &&
          other.memberId == this.memberId &&
          other.deviceId == this.deviceId &&
          other.createdAt == this.createdAt);
}

class OutboxCompanion extends UpdateCompanion<OutboxOp> {
  final Value<int> seq;
  final Value<String> opId;
  final Value<String> entity;
  final Value<String> entityId;
  final Value<String> op;
  final Value<String> fields;
  final Value<String> hlc;
  final Value<int?> baseVersion;
  final Value<bool> sending;
  final Value<String> memberId;
  final Value<String> deviceId;
  final Value<DateTime> createdAt;
  const OutboxCompanion({
    this.seq = const Value.absent(),
    this.opId = const Value.absent(),
    this.entity = const Value.absent(),
    this.entityId = const Value.absent(),
    this.op = const Value.absent(),
    this.fields = const Value.absent(),
    this.hlc = const Value.absent(),
    this.baseVersion = const Value.absent(),
    this.sending = const Value.absent(),
    this.memberId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  OutboxCompanion.insert({
    this.seq = const Value.absent(),
    required String opId,
    required String entity,
    required String entityId,
    required String op,
    required String fields,
    required String hlc,
    this.baseVersion = const Value.absent(),
    this.sending = const Value.absent(),
    required String memberId,
    required String deviceId,
    this.createdAt = const Value.absent(),
  }) : opId = Value(opId),
       entity = Value(entity),
       entityId = Value(entityId),
       op = Value(op),
       fields = Value(fields),
       hlc = Value(hlc),
       memberId = Value(memberId),
       deviceId = Value(deviceId);
  static Insertable<OutboxOp> custom({
    Expression<int>? seq,
    Expression<String>? opId,
    Expression<String>? entity,
    Expression<String>? entityId,
    Expression<String>? op,
    Expression<String>? fields,
    Expression<String>? hlc,
    Expression<int>? baseVersion,
    Expression<bool>? sending,
    Expression<String>? memberId,
    Expression<String>? deviceId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (seq != null) 'seq': seq,
      if (opId != null) 'op_id': opId,
      if (entity != null) 'entity': entity,
      if (entityId != null) 'entity_id': entityId,
      if (op != null) 'op': op,
      if (fields != null) 'fields': fields,
      if (hlc != null) 'hlc': hlc,
      if (baseVersion != null) 'base_version': baseVersion,
      if (sending != null) 'sending': sending,
      if (memberId != null) 'member_id': memberId,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  OutboxCompanion copyWith({
    Value<int>? seq,
    Value<String>? opId,
    Value<String>? entity,
    Value<String>? entityId,
    Value<String>? op,
    Value<String>? fields,
    Value<String>? hlc,
    Value<int?>? baseVersion,
    Value<bool>? sending,
    Value<String>? memberId,
    Value<String>? deviceId,
    Value<DateTime>? createdAt,
  }) {
    return OutboxCompanion(
      seq: seq ?? this.seq,
      opId: opId ?? this.opId,
      entity: entity ?? this.entity,
      entityId: entityId ?? this.entityId,
      op: op ?? this.op,
      fields: fields ?? this.fields,
      hlc: hlc ?? this.hlc,
      baseVersion: baseVersion ?? this.baseVersion,
      sending: sending ?? this.sending,
      memberId: memberId ?? this.memberId,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (opId.present) {
      map['op_id'] = Variable<String>(opId.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (op.present) {
      map['op'] = Variable<String>(op.value);
    }
    if (fields.present) {
      map['fields'] = Variable<String>(fields.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (baseVersion.present) {
      map['base_version'] = Variable<int>(baseVersion.value);
    }
    if (sending.present) {
      map['sending'] = Variable<bool>(sending.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxCompanion(')
          ..write('seq: $seq, ')
          ..write('opId: $opId, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('op: $op, ')
          ..write('fields: $fields, ')
          ..write('hlc: $hlc, ')
          ..write('baseVersion: $baseVersion, ')
          ..write('sending: $sending, ')
          ..write('memberId: $memberId, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $FieldClocksTable extends FieldClocks
    with TableInfo<$FieldClocksTable, FieldClock> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FieldClocksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fieldMeta = const VerificationMeta('field');
  @override
  late final GeneratedColumn<String> field = GeneratedColumn<String>(
    'field',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [entity, entityId, field, hlc];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'field_clocks';
  @override
  VerificationContext validateIntegrity(
    Insertable<FieldClock> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('field')) {
      context.handle(
        _fieldMeta,
        field.isAcceptableOrUnknown(data['field']!, _fieldMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldMeta);
    }
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entity, entityId, field};
  @override
  FieldClock map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FieldClock(
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      field: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field'],
      )!,
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      )!,
    );
  }

  @override
  $FieldClocksTable createAlias(String alias) {
    return $FieldClocksTable(attachedDatabase, alias);
  }
}

class FieldClock extends DataClass implements Insertable<FieldClock> {
  final String entity;
  final String entityId;
  final String field;
  final String hlc;
  const FieldClock({
    required this.entity,
    required this.entityId,
    required this.field,
    required this.hlc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity'] = Variable<String>(entity);
    map['entity_id'] = Variable<String>(entityId);
    map['field'] = Variable<String>(field);
    map['hlc'] = Variable<String>(hlc);
    return map;
  }

  FieldClocksCompanion toCompanion(bool nullToAbsent) {
    return FieldClocksCompanion(
      entity: Value(entity),
      entityId: Value(entityId),
      field: Value(field),
      hlc: Value(hlc),
    );
  }

  factory FieldClock.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FieldClock(
      entity: serializer.fromJson<String>(json['entity']),
      entityId: serializer.fromJson<String>(json['entityId']),
      field: serializer.fromJson<String>(json['field']),
      hlc: serializer.fromJson<String>(json['hlc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entity': serializer.toJson<String>(entity),
      'entityId': serializer.toJson<String>(entityId),
      'field': serializer.toJson<String>(field),
      'hlc': serializer.toJson<String>(hlc),
    };
  }

  FieldClock copyWith({
    String? entity,
    String? entityId,
    String? field,
    String? hlc,
  }) => FieldClock(
    entity: entity ?? this.entity,
    entityId: entityId ?? this.entityId,
    field: field ?? this.field,
    hlc: hlc ?? this.hlc,
  );
  FieldClock copyWithCompanion(FieldClocksCompanion data) {
    return FieldClock(
      entity: data.entity.present ? data.entity.value : this.entity,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      field: data.field.present ? data.field.value : this.field,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FieldClock(')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('field: $field, ')
          ..write('hlc: $hlc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entity, entityId, field, hlc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FieldClock &&
          other.entity == this.entity &&
          other.entityId == this.entityId &&
          other.field == this.field &&
          other.hlc == this.hlc);
}

class FieldClocksCompanion extends UpdateCompanion<FieldClock> {
  final Value<String> entity;
  final Value<String> entityId;
  final Value<String> field;
  final Value<String> hlc;
  final Value<int> rowid;
  const FieldClocksCompanion({
    this.entity = const Value.absent(),
    this.entityId = const Value.absent(),
    this.field = const Value.absent(),
    this.hlc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FieldClocksCompanion.insert({
    required String entity,
    required String entityId,
    required String field,
    required String hlc,
    this.rowid = const Value.absent(),
  }) : entity = Value(entity),
       entityId = Value(entityId),
       field = Value(field),
       hlc = Value(hlc);
  static Insertable<FieldClock> custom({
    Expression<String>? entity,
    Expression<String>? entityId,
    Expression<String>? field,
    Expression<String>? hlc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entity != null) 'entity': entity,
      if (entityId != null) 'entity_id': entityId,
      if (field != null) 'field': field,
      if (hlc != null) 'hlc': hlc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FieldClocksCompanion copyWith({
    Value<String>? entity,
    Value<String>? entityId,
    Value<String>? field,
    Value<String>? hlc,
    Value<int>? rowid,
  }) {
    return FieldClocksCompanion(
      entity: entity ?? this.entity,
      entityId: entityId ?? this.entityId,
      field: field ?? this.field,
      hlc: hlc ?? this.hlc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (field.present) {
      map['field'] = Variable<String>(field.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FieldClocksCompanion(')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('field: $field, ')
          ..write('hlc: $hlc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncStateTable extends SyncState
    with TableInfo<$SyncStateTable, SyncStateEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncStateEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SyncStateEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStateEntry(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SyncStateTable createAlias(String alias) {
    return $SyncStateTable(attachedDatabase, alias);
  }
}

class SyncStateEntry extends DataClass implements Insertable<SyncStateEntry> {
  final String key;
  final String value;
  const SyncStateEntry({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SyncStateCompanion toCompanion(bool nullToAbsent) {
    return SyncStateCompanion(key: Value(key), value: Value(value));
  }

  factory SyncStateEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStateEntry(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SyncStateEntry copyWith({String? key, String? value}) =>
      SyncStateEntry(key: key ?? this.key, value: value ?? this.value);
  SyncStateEntry copyWithCompanion(SyncStateCompanion data) {
    return SyncStateEntry(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateEntry(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStateEntry &&
          other.key == this.key &&
          other.value == this.value);
}

class SyncStateCompanion extends UpdateCompanion<SyncStateEntry> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SyncStateCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStateCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SyncStateEntry> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStateCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SyncStateCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncErrorsTable extends SyncErrors
    with TableInfo<$SyncErrorsTable, SyncError> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncErrorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _opIdMeta = const VerificationMeta('opId');
  @override
  late final GeneratedColumn<String> opId = GeneratedColumn<String>(
    'op_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _opMeta = const VerificationMeta('op');
  @override
  late final GeneratedColumn<String> op = GeneratedColumn<String>(
    'op',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fieldsMeta = const VerificationMeta('fields');
  @override
  late final GeneratedColumn<String> fields = GeneratedColumn<String>(
    'fields',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
    'error',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detailsMeta = const VerificationMeta(
    'details',
  );
  @override
  late final GeneratedColumn<String> details = GeneratedColumn<String>(
    'details',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dismissedMeta = const VerificationMeta(
    'dismissed',
  );
  @override
  late final GeneratedColumn<bool> dismissed = GeneratedColumn<bool>(
    'dismissed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dismissed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    opId,
    entity,
    entityId,
    op,
    fields,
    error,
    details,
    dismissed,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_errors';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncError> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('op_id')) {
      context.handle(
        _opIdMeta,
        opId.isAcceptableOrUnknown(data['op_id']!, _opIdMeta),
      );
    } else if (isInserting) {
      context.missing(_opIdMeta);
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('op')) {
      context.handle(_opMeta, op.isAcceptableOrUnknown(data['op']!, _opMeta));
    } else if (isInserting) {
      context.missing(_opMeta);
    }
    if (data.containsKey('fields')) {
      context.handle(
        _fieldsMeta,
        fields.isAcceptableOrUnknown(data['fields']!, _fieldsMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldsMeta);
    }
    if (data.containsKey('error')) {
      context.handle(
        _errorMeta,
        error.isAcceptableOrUnknown(data['error']!, _errorMeta),
      );
    } else if (isInserting) {
      context.missing(_errorMeta);
    }
    if (data.containsKey('details')) {
      context.handle(
        _detailsMeta,
        details.isAcceptableOrUnknown(data['details']!, _detailsMeta),
      );
    }
    if (data.containsKey('dismissed')) {
      context.handle(
        _dismissedMeta,
        dismissed.isAcceptableOrUnknown(data['dismissed']!, _dismissedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncError map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncError(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      opId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_id'],
      )!,
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      op: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op'],
      )!,
      fields: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fields'],
      )!,
      error: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error'],
      )!,
      details: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}details'],
      ),
      dismissed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dismissed'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SyncErrorsTable createAlias(String alias) {
    return $SyncErrorsTable(attachedDatabase, alias);
  }
}

class SyncError extends DataClass implements Insertable<SyncError> {
  final int id;
  final String opId;
  final String entity;
  final String entityId;
  final String op;
  final String fields;
  final String error;
  final String? details;
  final bool dismissed;
  final DateTime createdAt;
  const SyncError({
    required this.id,
    required this.opId,
    required this.entity,
    required this.entityId,
    required this.op,
    required this.fields,
    required this.error,
    this.details,
    required this.dismissed,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['op_id'] = Variable<String>(opId);
    map['entity'] = Variable<String>(entity);
    map['entity_id'] = Variable<String>(entityId);
    map['op'] = Variable<String>(op);
    map['fields'] = Variable<String>(fields);
    map['error'] = Variable<String>(error);
    if (!nullToAbsent || details != null) {
      map['details'] = Variable<String>(details);
    }
    map['dismissed'] = Variable<bool>(dismissed);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SyncErrorsCompanion toCompanion(bool nullToAbsent) {
    return SyncErrorsCompanion(
      id: Value(id),
      opId: Value(opId),
      entity: Value(entity),
      entityId: Value(entityId),
      op: Value(op),
      fields: Value(fields),
      error: Value(error),
      details: details == null && nullToAbsent
          ? const Value.absent()
          : Value(details),
      dismissed: Value(dismissed),
      createdAt: Value(createdAt),
    );
  }

  factory SyncError.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncError(
      id: serializer.fromJson<int>(json['id']),
      opId: serializer.fromJson<String>(json['opId']),
      entity: serializer.fromJson<String>(json['entity']),
      entityId: serializer.fromJson<String>(json['entityId']),
      op: serializer.fromJson<String>(json['op']),
      fields: serializer.fromJson<String>(json['fields']),
      error: serializer.fromJson<String>(json['error']),
      details: serializer.fromJson<String?>(json['details']),
      dismissed: serializer.fromJson<bool>(json['dismissed']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'opId': serializer.toJson<String>(opId),
      'entity': serializer.toJson<String>(entity),
      'entityId': serializer.toJson<String>(entityId),
      'op': serializer.toJson<String>(op),
      'fields': serializer.toJson<String>(fields),
      'error': serializer.toJson<String>(error),
      'details': serializer.toJson<String?>(details),
      'dismissed': serializer.toJson<bool>(dismissed),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SyncError copyWith({
    int? id,
    String? opId,
    String? entity,
    String? entityId,
    String? op,
    String? fields,
    String? error,
    Value<String?> details = const Value.absent(),
    bool? dismissed,
    DateTime? createdAt,
  }) => SyncError(
    id: id ?? this.id,
    opId: opId ?? this.opId,
    entity: entity ?? this.entity,
    entityId: entityId ?? this.entityId,
    op: op ?? this.op,
    fields: fields ?? this.fields,
    error: error ?? this.error,
    details: details.present ? details.value : this.details,
    dismissed: dismissed ?? this.dismissed,
    createdAt: createdAt ?? this.createdAt,
  );
  SyncError copyWithCompanion(SyncErrorsCompanion data) {
    return SyncError(
      id: data.id.present ? data.id.value : this.id,
      opId: data.opId.present ? data.opId.value : this.opId,
      entity: data.entity.present ? data.entity.value : this.entity,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      op: data.op.present ? data.op.value : this.op,
      fields: data.fields.present ? data.fields.value : this.fields,
      error: data.error.present ? data.error.value : this.error,
      details: data.details.present ? data.details.value : this.details,
      dismissed: data.dismissed.present ? data.dismissed.value : this.dismissed,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncError(')
          ..write('id: $id, ')
          ..write('opId: $opId, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('op: $op, ')
          ..write('fields: $fields, ')
          ..write('error: $error, ')
          ..write('details: $details, ')
          ..write('dismissed: $dismissed, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    opId,
    entity,
    entityId,
    op,
    fields,
    error,
    details,
    dismissed,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncError &&
          other.id == this.id &&
          other.opId == this.opId &&
          other.entity == this.entity &&
          other.entityId == this.entityId &&
          other.op == this.op &&
          other.fields == this.fields &&
          other.error == this.error &&
          other.details == this.details &&
          other.dismissed == this.dismissed &&
          other.createdAt == this.createdAt);
}

class SyncErrorsCompanion extends UpdateCompanion<SyncError> {
  final Value<int> id;
  final Value<String> opId;
  final Value<String> entity;
  final Value<String> entityId;
  final Value<String> op;
  final Value<String> fields;
  final Value<String> error;
  final Value<String?> details;
  final Value<bool> dismissed;
  final Value<DateTime> createdAt;
  const SyncErrorsCompanion({
    this.id = const Value.absent(),
    this.opId = const Value.absent(),
    this.entity = const Value.absent(),
    this.entityId = const Value.absent(),
    this.op = const Value.absent(),
    this.fields = const Value.absent(),
    this.error = const Value.absent(),
    this.details = const Value.absent(),
    this.dismissed = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SyncErrorsCompanion.insert({
    this.id = const Value.absent(),
    required String opId,
    required String entity,
    required String entityId,
    required String op,
    required String fields,
    required String error,
    this.details = const Value.absent(),
    this.dismissed = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : opId = Value(opId),
       entity = Value(entity),
       entityId = Value(entityId),
       op = Value(op),
       fields = Value(fields),
       error = Value(error);
  static Insertable<SyncError> custom({
    Expression<int>? id,
    Expression<String>? opId,
    Expression<String>? entity,
    Expression<String>? entityId,
    Expression<String>? op,
    Expression<String>? fields,
    Expression<String>? error,
    Expression<String>? details,
    Expression<bool>? dismissed,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (opId != null) 'op_id': opId,
      if (entity != null) 'entity': entity,
      if (entityId != null) 'entity_id': entityId,
      if (op != null) 'op': op,
      if (fields != null) 'fields': fields,
      if (error != null) 'error': error,
      if (details != null) 'details': details,
      if (dismissed != null) 'dismissed': dismissed,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SyncErrorsCompanion copyWith({
    Value<int>? id,
    Value<String>? opId,
    Value<String>? entity,
    Value<String>? entityId,
    Value<String>? op,
    Value<String>? fields,
    Value<String>? error,
    Value<String?>? details,
    Value<bool>? dismissed,
    Value<DateTime>? createdAt,
  }) {
    return SyncErrorsCompanion(
      id: id ?? this.id,
      opId: opId ?? this.opId,
      entity: entity ?? this.entity,
      entityId: entityId ?? this.entityId,
      op: op ?? this.op,
      fields: fields ?? this.fields,
      error: error ?? this.error,
      details: details ?? this.details,
      dismissed: dismissed ?? this.dismissed,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (opId.present) {
      map['op_id'] = Variable<String>(opId.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (op.present) {
      map['op'] = Variable<String>(op.value);
    }
    if (fields.present) {
      map['fields'] = Variable<String>(fields.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (details.present) {
      map['details'] = Variable<String>(details.value);
    }
    if (dismissed.present) {
      map['dismissed'] = Variable<bool>(dismissed.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncErrorsCompanion(')
          ..write('id: $id, ')
          ..write('opId: $opId, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('op: $op, ')
          ..write('fields: $fields, ')
          ..write('error: $error, ')
          ..write('details: $details, ')
          ..write('dismissed: $dismissed, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MembersTable members = $MembersTable(this);
  late final $GroceryItemsTable groceryItems = $GroceryItemsTable(this);
  late final $PantryItemsTable pantryItems = $PantryItemsTable(this);
  late final $BillsTable bills = $BillsTable(this);
  late final $SubscriptionsTable subscriptions = $SubscriptionsTable(this);
  late final $ChoresTable chores = $ChoresTable(this);
  late final $ChoreCompletionsTable choreCompletions = $ChoreCompletionsTable(
    this,
  );
  late final $EventsTable events = $EventsTable(this);
  late final $DebtsTable debts = $DebtsTable(this);
  late final $DebtPaymentsTable debtPayments = $DebtPaymentsTable(this);
  late final $VehiclesTable vehicles = $VehiclesTable(this);
  late final $VehicleLogsTable vehicleLogs = $VehicleLogsTable(this);
  late final $BudgetsTable budgets = $BudgetsTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $ConflictsTable conflicts = $ConflictsTable(this);
  late final $OutboxTable outbox = $OutboxTable(this);
  late final $FieldClocksTable fieldClocks = $FieldClocksTable(this);
  late final $SyncStateTable syncState = $SyncStateTable(this);
  late final $SyncErrorsTable syncErrors = $SyncErrorsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    members,
    groceryItems,
    pantryItems,
    bills,
    subscriptions,
    chores,
    choreCompletions,
    events,
    debts,
    debtPayments,
    vehicles,
    vehicleLogs,
    budgets,
    transactions,
    conflicts,
    outbox,
    fieldClocks,
    syncState,
    syncErrors,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$MembersTableCreateCompanionBuilder =
    MembersCompanion Function({
      required String id,
      required String householdId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> hlc,
      Value<int?> serverVersion,
      Value<String?> updatedBy,
      Value<String?> deviceId,
      required String name,
      required String role,
      Value<String?> color,
      Value<String?> pinHash,
      Value<int?> userId,
      Value<int> rowid,
    });
typedef $$MembersTableUpdateCompanionBuilder =
    MembersCompanion Function({
      Value<String> id,
      Value<String> householdId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> hlc,
      Value<int?> serverVersion,
      Value<String?> updatedBy,
      Value<String?> deviceId,
      Value<String> name,
      Value<String> role,
      Value<String?> color,
      Value<String?> pinHash,
      Value<int?> userId,
      Value<int> rowid,
    });

class $$MembersTableFilterComposer
    extends Composer<_$AppDatabase, $MembersTable> {
  $$MembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinHash => $composableBuilder(
    column: $table.pinHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MembersTableOrderingComposer
    extends Composer<_$AppDatabase, $MembersTable> {
  $$MembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinHash => $composableBuilder(
    column: $table.pinHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $MembersTable> {
  $$MembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get pinHash =>
      $composableBuilder(column: $table.pinHash, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);
}

class $$MembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MembersTable,
          Member,
          $$MembersTableFilterComposer,
          $$MembersTableOrderingComposer,
          $$MembersTableAnnotationComposer,
          $$MembersTableCreateCompanionBuilder,
          $$MembersTableUpdateCompanionBuilder,
          (Member, BaseReferences<_$AppDatabase, $MembersTable, Member>),
          Member,
          PrefetchHooks Function()
        > {
  $$MembersTableTableManager(_$AppDatabase db, $MembersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> householdId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> hlc = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<String?> pinHash = const Value.absent(),
                Value<int?> userId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MembersCompanion(
                id: id,
                householdId: householdId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                hlc: hlc,
                serverVersion: serverVersion,
                updatedBy: updatedBy,
                deviceId: deviceId,
                name: name,
                role: role,
                color: color,
                pinHash: pinHash,
                userId: userId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String householdId,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> hlc = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                required String name,
                required String role,
                Value<String?> color = const Value.absent(),
                Value<String?> pinHash = const Value.absent(),
                Value<int?> userId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MembersCompanion.insert(
                id: id,
                householdId: householdId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                hlc: hlc,
                serverVersion: serverVersion,
                updatedBy: updatedBy,
                deviceId: deviceId,
                name: name,
                role: role,
                color: color,
                pinHash: pinHash,
                userId: userId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MembersTable,
      Member,
      $$MembersTableFilterComposer,
      $$MembersTableOrderingComposer,
      $$MembersTableAnnotationComposer,
      $$MembersTableCreateCompanionBuilder,
      $$MembersTableUpdateCompanionBuilder,
      (Member, BaseReferences<_$AppDatabase, $MembersTable, Member>),
      Member,
      PrefetchHooks Function()
    >;
typedef $$GroceryItemsTableCreateCompanionBuilder =
    GroceryItemsCompanion Function({
      required String id,
      required String householdId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> hlc,
      Value<int?> serverVersion,
      Value<String?> updatedBy,
      Value<String?> deviceId,
      required String name,
      Value<String?> quantityText,
      Value<String?> store,
      Value<bool> isBought,
      Value<DateTime?> boughtAt,
      Value<DateTime?> clearedAt,
      Value<String?> plannedOn,
      Value<String?> requestedBy,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$GroceryItemsTableUpdateCompanionBuilder =
    GroceryItemsCompanion Function({
      Value<String> id,
      Value<String> householdId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> hlc,
      Value<int?> serverVersion,
      Value<String?> updatedBy,
      Value<String?> deviceId,
      Value<String> name,
      Value<String?> quantityText,
      Value<String?> store,
      Value<bool> isBought,
      Value<DateTime?> boughtAt,
      Value<DateTime?> clearedAt,
      Value<String?> plannedOn,
      Value<String?> requestedBy,
      Value<String?> note,
      Value<int> rowid,
    });

class $$GroceryItemsTableFilterComposer
    extends Composer<_$AppDatabase, $GroceryItemsTable> {
  $$GroceryItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quantityText => $composableBuilder(
    column: $table.quantityText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get store => $composableBuilder(
    column: $table.store,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBought => $composableBuilder(
    column: $table.isBought,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get boughtAt => $composableBuilder(
    column: $table.boughtAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get clearedAt => $composableBuilder(
    column: $table.clearedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plannedOn => $composableBuilder(
    column: $table.plannedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestedBy => $composableBuilder(
    column: $table.requestedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GroceryItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $GroceryItemsTable> {
  $$GroceryItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quantityText => $composableBuilder(
    column: $table.quantityText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get store => $composableBuilder(
    column: $table.store,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBought => $composableBuilder(
    column: $table.isBought,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get boughtAt => $composableBuilder(
    column: $table.boughtAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get clearedAt => $composableBuilder(
    column: $table.clearedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plannedOn => $composableBuilder(
    column: $table.plannedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestedBy => $composableBuilder(
    column: $table.requestedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GroceryItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroceryItemsTable> {
  $$GroceryItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get quantityText => $composableBuilder(
    column: $table.quantityText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get store =>
      $composableBuilder(column: $table.store, builder: (column) => column);

  GeneratedColumn<bool> get isBought =>
      $composableBuilder(column: $table.isBought, builder: (column) => column);

  GeneratedColumn<DateTime> get boughtAt =>
      $composableBuilder(column: $table.boughtAt, builder: (column) => column);

  GeneratedColumn<DateTime> get clearedAt =>
      $composableBuilder(column: $table.clearedAt, builder: (column) => column);

  GeneratedColumn<String> get plannedOn =>
      $composableBuilder(column: $table.plannedOn, builder: (column) => column);

  GeneratedColumn<String> get requestedBy => $composableBuilder(
    column: $table.requestedBy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$GroceryItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GroceryItemsTable,
          GroceryItem,
          $$GroceryItemsTableFilterComposer,
          $$GroceryItemsTableOrderingComposer,
          $$GroceryItemsTableAnnotationComposer,
          $$GroceryItemsTableCreateCompanionBuilder,
          $$GroceryItemsTableUpdateCompanionBuilder,
          (
            GroceryItem,
            BaseReferences<_$AppDatabase, $GroceryItemsTable, GroceryItem>,
          ),
          GroceryItem,
          PrefetchHooks Function()
        > {
  $$GroceryItemsTableTableManager(_$AppDatabase db, $GroceryItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroceryItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroceryItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroceryItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> householdId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> hlc = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> quantityText = const Value.absent(),
                Value<String?> store = const Value.absent(),
                Value<bool> isBought = const Value.absent(),
                Value<DateTime?> boughtAt = const Value.absent(),
                Value<DateTime?> clearedAt = const Value.absent(),
                Value<String?> plannedOn = const Value.absent(),
                Value<String?> requestedBy = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GroceryItemsCompanion(
                id: id,
                householdId: householdId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                hlc: hlc,
                serverVersion: serverVersion,
                updatedBy: updatedBy,
                deviceId: deviceId,
                name: name,
                quantityText: quantityText,
                store: store,
                isBought: isBought,
                boughtAt: boughtAt,
                clearedAt: clearedAt,
                plannedOn: plannedOn,
                requestedBy: requestedBy,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String householdId,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> hlc = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                required String name,
                Value<String?> quantityText = const Value.absent(),
                Value<String?> store = const Value.absent(),
                Value<bool> isBought = const Value.absent(),
                Value<DateTime?> boughtAt = const Value.absent(),
                Value<DateTime?> clearedAt = const Value.absent(),
                Value<String?> plannedOn = const Value.absent(),
                Value<String?> requestedBy = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GroceryItemsCompanion.insert(
                id: id,
                householdId: householdId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                hlc: hlc,
                serverVersion: serverVersion,
                updatedBy: updatedBy,
                deviceId: deviceId,
                name: name,
                quantityText: quantityText,
                store: store,
                isBought: isBought,
                boughtAt: boughtAt,
                clearedAt: clearedAt,
                plannedOn: plannedOn,
                requestedBy: requestedBy,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GroceryItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GroceryItemsTable,
      GroceryItem,
      $$GroceryItemsTableFilterComposer,
      $$GroceryItemsTableOrderingComposer,
      $$GroceryItemsTableAnnotationComposer,
      $$GroceryItemsTableCreateCompanionBuilder,
      $$GroceryItemsTableUpdateCompanionBuilder,
      (
        GroceryItem,
        BaseReferences<_$AppDatabase, $GroceryItemsTable, GroceryItem>,
      ),
      GroceryItem,
      PrefetchHooks Function()
    >;
typedef $$PantryItemsTableCreateCompanionBuilder =
    PantryItemsCompanion Function({
      required String id,
      required String householdId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> hlc,
      Value<int?> serverVersion,
      Value<String?> updatedBy,
      Value<String?> deviceId,
      required String name,
      Value<String?> unit,
      Value<double> quantity,
      Value<double?> minQuantity,
      Value<String?> location,
      Value<String?> expiresOn,
      Value<int> rowid,
    });
typedef $$PantryItemsTableUpdateCompanionBuilder =
    PantryItemsCompanion Function({
      Value<String> id,
      Value<String> householdId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> hlc,
      Value<int?> serverVersion,
      Value<String?> updatedBy,
      Value<String?> deviceId,
      Value<String> name,
      Value<String?> unit,
      Value<double> quantity,
      Value<double?> minQuantity,
      Value<String?> location,
      Value<String?> expiresOn,
      Value<int> rowid,
    });

class $$PantryItemsTableFilterComposer
    extends Composer<_$AppDatabase, $PantryItemsTable> {
  $$PantryItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minQuantity => $composableBuilder(
    column: $table.minQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get expiresOn => $composableBuilder(
    column: $table.expiresOn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PantryItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $PantryItemsTable> {
  $$PantryItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minQuantity => $composableBuilder(
    column: $table.minQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expiresOn => $composableBuilder(
    column: $table.expiresOn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PantryItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PantryItemsTable> {
  $$PantryItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get minQuantity => $composableBuilder(
    column: $table.minQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get expiresOn =>
      $composableBuilder(column: $table.expiresOn, builder: (column) => column);
}

class $$PantryItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PantryItemsTable,
          PantryItem,
          $$PantryItemsTableFilterComposer,
          $$PantryItemsTableOrderingComposer,
          $$PantryItemsTableAnnotationComposer,
          $$PantryItemsTableCreateCompanionBuilder,
          $$PantryItemsTableUpdateCompanionBuilder,
          (
            PantryItem,
            BaseReferences<_$AppDatabase, $PantryItemsTable, PantryItem>,
          ),
          PantryItem,
          PrefetchHooks Function()
        > {
  $$PantryItemsTableTableManager(_$AppDatabase db, $PantryItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PantryItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PantryItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PantryItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> householdId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> hlc = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<double?> minQuantity = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String?> expiresOn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PantryItemsCompanion(
                id: id,
                householdId: householdId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                hlc: hlc,
                serverVersion: serverVersion,
                updatedBy: updatedBy,
                deviceId: deviceId,
                name: name,
                unit: unit,
                quantity: quantity,
                minQuantity: minQuantity,
                location: location,
                expiresOn: expiresOn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String householdId,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> hlc = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                required String name,
                Value<String?> unit = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<double?> minQuantity = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String?> expiresOn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PantryItemsCompanion.insert(
                id: id,
                householdId: householdId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                hlc: hlc,
                serverVersion: serverVersion,
                updatedBy: updatedBy,
                deviceId: deviceId,
                name: name,
                unit: unit,
                quantity: quantity,
                minQuantity: minQuantity,
                location: location,
                expiresOn: expiresOn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PantryItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PantryItemsTable,
      PantryItem,
      $$PantryItemsTableFilterComposer,
      $$PantryItemsTableOrderingComposer,
      $$PantryItemsTableAnnotationComposer,
      $$PantryItemsTableCreateCompanionBuilder,
      $$PantryItemsTableUpdateCompanionBuilder,
      (
        PantryItem,
        BaseReferences<_$AppDatabase, $PantryItemsTable, PantryItem>,
      ),
      PantryItem,
      PrefetchHooks Function()
    >;
typedef $$BillsTableCreateCompanionBuilder =
    BillsCompanion Function({
      required String id,
      required String householdId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> hlc,
      Value<int?> serverVersion,
      Value<String?> updatedBy,
      Value<String?> deviceId,
      required String name,
      Value<String?> provider,
      Value<int> amountMinor,
      Value<String> currency,
      Value<String?> dueOn,
      Value<bool> isPaid,
      Value<DateTime?> paidAt,
      Value<String?> category,
      Value<String?> repeat,
      Value<String?> seriesId,
      Value<int> rowid,
    });
typedef $$BillsTableUpdateCompanionBuilder =
    BillsCompanion Function({
      Value<String> id,
      Value<String> householdId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> hlc,
      Value<int?> serverVersion,
      Value<String?> updatedBy,
      Value<String?> deviceId,
      Value<String> name,
      Value<String?> provider,
      Value<int> amountMinor,
      Value<String> currency,
      Value<String?> dueOn,
      Value<bool> isPaid,
      Value<DateTime?> paidAt,
      Value<String?> category,
      Value<String?> repeat,
      Value<String?> seriesId,
      Value<int> rowid,
    });

class $$BillsTableFilterComposer extends Composer<_$AppDatabase, $BillsTable> {
  $$BillsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dueOn => $composableBuilder(
    column: $table.dueOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPaid => $composableBuilder(
    column: $table.isPaid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paidAt => $composableBuilder(
    column: $table.paidAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repeat => $composableBuilder(
    column: $table.repeat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seriesId => $composableBuilder(
    column: $table.seriesId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BillsTableOrderingComposer
    extends Composer<_$AppDatabase, $BillsTable> {
  $$BillsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dueOn => $composableBuilder(
    column: $table.dueOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPaid => $composableBuilder(
    column: $table.isPaid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paidAt => $composableBuilder(
    column: $table.paidAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repeat => $composableBuilder(
    column: $table.repeat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seriesId => $composableBuilder(
    column: $table.seriesId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BillsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BillsTable> {
  $$BillsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get dueOn =>
      $composableBuilder(column: $table.dueOn, builder: (column) => column);

  GeneratedColumn<bool> get isPaid =>
      $composableBuilder(column: $table.isPaid, builder: (column) => column);

  GeneratedColumn<DateTime> get paidAt =>
      $composableBuilder(column: $table.paidAt, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get repeat =>
      $composableBuilder(column: $table.repeat, builder: (column) => column);

  GeneratedColumn<String> get seriesId =>
      $composableBuilder(column: $table.seriesId, builder: (column) => column);
}

class $$BillsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BillsTable,
          Bill,
          $$BillsTableFilterComposer,
          $$BillsTableOrderingComposer,
          $$BillsTableAnnotationComposer,
          $$BillsTableCreateCompanionBuilder,
          $$BillsTableUpdateCompanionBuilder,
          (Bill, BaseReferences<_$AppDatabase, $BillsTable, Bill>),
          Bill,
          PrefetchHooks Function()
        > {
  $$BillsTableTableManager(_$AppDatabase db, $BillsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BillsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BillsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BillsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> householdId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> hlc = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> provider = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String?> dueOn = const Value.absent(),
                Value<bool> isPaid = const Value.absent(),
                Value<DateTime?> paidAt = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> repeat = const Value.absent(),
                Value<String?> seriesId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BillsCompanion(
                id: id,
                householdId: householdId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                hlc: hlc,
                serverVersion: serverVersion,
                updatedBy: updatedBy,
                deviceId: deviceId,
                name: name,
                provider: provider,
                amountMinor: amountMinor,
                currency: currency,
                dueOn: dueOn,
                isPaid: isPaid,
                paidAt: paidAt,
                category: category,
                repeat: repeat,
                seriesId: seriesId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String householdId,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> hlc = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                required String name,
                Value<String?> provider = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String?> dueOn = const Value.absent(),
                Value<bool> isPaid = const Value.absent(),
                Value<DateTime?> paidAt = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> repeat = const Value.absent(),
                Value<String?> seriesId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BillsCompanion.insert(
                id: id,
                householdId: householdId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                hlc: hlc,
                serverVersion: serverVersion,
                updatedBy: updatedBy,
                deviceId: deviceId,
                name: name,
                provider: provider,
                amountMinor: amountMinor,
                currency: currency,
                dueOn: dueOn,
                isPaid: isPaid,
                paidAt: paidAt,
                category: category,
                repeat: repeat,
                seriesId: seriesId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BillsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BillsTable,
      Bill,
      $$BillsTableFilterComposer,
      $$BillsTableOrderingComposer,
      $$BillsTableAnnotationComposer,
      $$BillsTableCreateCompanionBuilder,
      $$BillsTableUpdateCompanionBuilder,
      (Bill, BaseReferences<_$AppDatabase, $BillsTable, Bill>),
      Bill,
      PrefetchHooks Function()
    >;
typedef $$SubscriptionsTableCreateCompanionBuilder =
    SubscriptionsCompanion Function({
      required String id,
      required String householdId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> hlc,
      Value<int?> serverVersion,
      Value<String?> updatedBy,
      Value<String?> deviceId,
      required String name,
      Value<int> priceMinor,
      Value<String> currency,
      Value<String> cycle,
      Value<String?> nextDueOn,
      Value<String?> category,
      Value<int> rowid,
    });
typedef $$SubscriptionsTableUpdateCompanionBuilder =
    SubscriptionsCompanion Function({
      Value<String> id,
      Value<String> householdId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> hlc,
      Value<int?> serverVersion,
      Value<String?> updatedBy,
      Value<String?> deviceId,
      Value<String> name,
      Value<int> priceMinor,
      Value<String> currency,
      Value<String> cycle,
      Value<String?> nextDueOn,
      Value<String?> category,
      Value<int> rowid,
    });

class $$SubscriptionsTableFilterComposer
    extends Composer<_$AppDatabase, $SubscriptionsTable> {
  $$SubscriptionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priceMinor => $composableBuilder(
    column: $table.priceMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cycle => $composableBuilder(
    column: $table.cycle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nextDueOn => $composableBuilder(
    column: $table.nextDueOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SubscriptionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SubscriptionsTable> {
  $$SubscriptionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priceMinor => $composableBuilder(
    column: $table.priceMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cycle => $composableBuilder(
    column: $table.cycle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nextDueOn => $composableBuilder(
    column: $table.nextDueOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SubscriptionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubscriptionsTable> {
  $$SubscriptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get priceMinor => $composableBuilder(
    column: $table.priceMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get cycle =>
      $composableBuilder(column: $table.cycle, builder: (column) => column);

  GeneratedColumn<String> get nextDueOn =>
      $composableBuilder(column: $table.nextDueOn, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);
}

class $$SubscriptionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubscriptionsTable,
          Subscription,
          $$SubscriptionsTableFilterComposer,
          $$SubscriptionsTableOrderingComposer,
          $$SubscriptionsTableAnnotationComposer,
          $$SubscriptionsTableCreateCompanionBuilder,
          $$SubscriptionsTableUpdateCompanionBuilder,
          (
            Subscription,
            BaseReferences<_$AppDatabase, $SubscriptionsTable, Subscription>,
          ),
          Subscription,
          PrefetchHooks Function()
        > {
  $$SubscriptionsTableTableManager(_$AppDatabase db, $SubscriptionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubscriptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubscriptionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubscriptionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> householdId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> hlc = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> priceMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> cycle = const Value.absent(),
                Value<String?> nextDueOn = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SubscriptionsCompanion(
                id: id,
                householdId: householdId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                hlc: hlc,
                serverVersion: serverVersion,
                updatedBy: updatedBy,
                deviceId: deviceId,
                name: name,
                priceMinor: priceMinor,
                currency: currency,
                cycle: cycle,
                nextDueOn: nextDueOn,
                category: category,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String householdId,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> hlc = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                required String name,
                Value<int> priceMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> cycle = const Value.absent(),
                Value<String?> nextDueOn = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SubscriptionsCompanion.insert(
                id: id,
                householdId: householdId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                hlc: hlc,
                serverVersion: serverVersion,
                updatedBy: updatedBy,
                deviceId: deviceId,
                name: name,
                priceMinor: priceMinor,
                currency: currency,
                cycle: cycle,
                nextDueOn: nextDueOn,
                category: category,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SubscriptionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubscriptionsTable,
      Subscription,
      $$SubscriptionsTableFilterComposer,
      $$SubscriptionsTableOrderingComposer,
      $$SubscriptionsTableAnnotationComposer,
      $$SubscriptionsTableCreateCompanionBuilder,
      $$SubscriptionsTableUpdateCompanionBuilder,
      (
        Subscription,
        BaseReferences<_$AppDatabase, $SubscriptionsTable, Subscription>,
      ),
      Subscription,
      PrefetchHooks Function()
    >;
typedef $$ChoresTableCreateCompanionBuilder =
    ChoresCompanion Function({
      required String id,
      required String householdId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> hlc,
      Value<int?> serverVersion,
      Value<String?> updatedBy,
      Value<String?> deviceId,
      required String name,
      Value<String?> assignedTo,
      Value<String> repeat,
      Value<int?> weekday,
      Value<String?> dueOn,
      Value<int> rowid,
    });
typedef $$ChoresTableUpdateCompanionBuilder =
    ChoresCompanion Function({
      Value<String> id,
      Value<String> householdId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> hlc,
      Value<int?> serverVersion,
      Value<String?> updatedBy,
      Value<String?> deviceId,
      Value<String> name,
      Value<String?> assignedTo,
      Value<String> repeat,
      Value<int?> weekday,
      Value<String?> dueOn,
      Value<int> rowid,
    });

class $$ChoresTableFilterComposer
    extends Composer<_$AppDatabase, $ChoresTable> {
  $$ChoresTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assignedTo => $composableBuilder(
    column: $table.assignedTo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repeat => $composableBuilder(
    column: $table.repeat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekday => $composableBuilder(
    column: $table.weekday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dueOn => $composableBuilder(
    column: $table.dueOn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChoresTableOrderingComposer
    extends Composer<_$AppDatabase, $ChoresTable> {
  $$ChoresTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assignedTo => $composableBuilder(
    column: $table.assignedTo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repeat => $composableBuilder(
    column: $table.repeat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekday => $composableBuilder(
    column: $table.weekday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dueOn => $composableBuilder(
    column: $table.dueOn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChoresTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChoresTable> {
  $$ChoresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get assignedTo => $composableBuilder(
    column: $table.assignedTo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get repeat =>
      $composableBuilder(column: $table.repeat, builder: (column) => column);

  GeneratedColumn<int> get weekday =>
      $composableBuilder(column: $table.weekday, builder: (column) => column);

  GeneratedColumn<String> get dueOn =>
      $composableBuilder(column: $table.dueOn, builder: (column) => column);
}

class $$ChoresTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChoresTable,
          Chore,
          $$ChoresTableFilterComposer,
          $$ChoresTableOrderingComposer,
          $$ChoresTableAnnotationComposer,
          $$ChoresTableCreateCompanionBuilder,
          $$ChoresTableUpdateCompanionBuilder,
          (Chore, BaseReferences<_$AppDatabase, $ChoresTable, Chore>),
          Chore,
          PrefetchHooks Function()
        > {
  $$ChoresTableTableManager(_$AppDatabase db, $ChoresTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChoresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChoresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChoresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> householdId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> hlc = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> assignedTo = const Value.absent(),
                Value<String> repeat = const Value.absent(),
                Value<int?> weekday = const Value.absent(),
                Value<String?> dueOn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChoresCompanion(
                id: id,
                householdId: householdId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                hlc: hlc,
                serverVersion: serverVersion,
                updatedBy: updatedBy,
                deviceId: deviceId,
                name: name,
                assignedTo: assignedTo,
                repeat: repeat,
                weekday: weekday,
                dueOn: dueOn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String householdId,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> hlc = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                required String name,
                Value<String?> assignedTo = const Value.absent(),
                Value<String> repeat = const Value.absent(),
                Value<int?> weekday = const Value.absent(),
                Value<String?> dueOn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChoresCompanion.insert(
                id: id,
                householdId: householdId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                hlc: hlc,
                serverVersion: serverVersion,
                updatedBy: updatedBy,
                deviceId: deviceId,
                name: name,
                assignedTo: assignedTo,
                repeat: repeat,
                weekday: weekday,
                dueOn: dueOn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChoresTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChoresTable,
      Chore,
      $$ChoresTableFilterComposer,
      $$ChoresTableOrderingComposer,
      $$ChoresTableAnnotationComposer,
      $$ChoresTableCreateCompanionBuilder,
      $$ChoresTableUpdateCompanionBuilder,
      (Chore, BaseReferences<_$AppDatabase, $ChoresTable, Chore>),
      Chore,
      PrefetchHooks Function()
    >;
typedef $$ChoreCompletionsTableCreateCompanionBuilder =
    ChoreCompletionsCompanion Function({
      required String id,
      required String householdId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> hlc,
      Value<int?> serverVersion,
      Value<String?> updatedBy,
      Value<String?> deviceId,
      required String choreId,
      Value<String?> memberId,
      required String doneOn,
      Value<int> rowid,
    });
typedef $$ChoreCompletionsTableUpdateCompanionBuilder =
    ChoreCompletionsCompanion Function({
      Value<String> id,
      Value<String> householdId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> hlc,
      Value<int?> serverVersion,
      Value<String?> updatedBy,
      Value<String?> deviceId,
      Value<String> choreId,
      Value<String?> memberId,
      Value<String> doneOn,
      Value<int> rowid,
    });

class $$ChoreCompletionsTableFilterComposer
    extends Composer<_$AppDatabase, $ChoreCompletionsTable> {
  $$ChoreCompletionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get choreId => $composableBuilder(
    column: $table.choreId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get doneOn => $composableBuilder(
    column: $table.doneOn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChoreCompletionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChoreCompletionsTable> {
  $$ChoreCompletionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get choreId => $composableBuilder(
    column: $table.choreId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get doneOn => $composableBuilder(
    column: $table.doneOn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChoreCompletionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChoreCompletionsTable> {
  $$ChoreCompletionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get choreId =>
      $composableBuilder(column: $table.choreId, builder: (column) => column);

  GeneratedColumn<String> get memberId =>
      $composableBuilder(column: $table.memberId, builder: (column) => column);

  GeneratedColumn<String> get doneOn =>
      $composableBuilder(column: $table.doneOn, builder: (column) => column);
}

class $$ChoreCompletionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChoreCompletionsTable,
          ChoreCompletion,
          $$ChoreCompletionsTableFilterComposer,
          $$ChoreCompletionsTableOrderingComposer,
          $$ChoreCompletionsTableAnnotationComposer,
          $$ChoreCompletionsTableCreateCompanionBuilder,
          $$ChoreCompletionsTableUpdateCompanionBuilder,
          (
            ChoreCompletion,
            BaseReferences<
              _$AppDatabase,
              $ChoreCompletionsTable,
              ChoreCompletion
            >,
          ),
          ChoreCompletion,
          PrefetchHooks Function()
        > {
  $$ChoreCompletionsTableTableManager(
    _$AppDatabase db,
    $ChoreCompletionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChoreCompletionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChoreCompletionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChoreCompletionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> householdId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> hlc = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<String> choreId = const Value.absent(),
                Value<String?> memberId = const Value.absent(),
                Value<String> doneOn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChoreCompletionsCompanion(
                id: id,
                householdId: householdId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                hlc: hlc,
                serverVersion: serverVersion,
                updatedBy: updatedBy,
                deviceId: deviceId,
                choreId: choreId,
                memberId: memberId,
                doneOn: doneOn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String householdId,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> hlc = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                required String choreId,
                Value<String?> memberId = const Value.absent(),
                required String doneOn,
                Value<int> rowid = const Value.absent(),
              }) => ChoreCompletionsCompanion.insert(
                id: id,
                householdId: householdId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                hlc: hlc,
                serverVersion: serverVersion,
                updatedBy: updatedBy,
                deviceId: deviceId,
                choreId: choreId,
                memberId: memberId,
                doneOn: doneOn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChoreCompletionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChoreCompletionsTable,
      ChoreCompletion,
      $$ChoreCompletionsTableFilterComposer,
      $$ChoreCompletionsTableOrderingComposer,
      $$ChoreCompletionsTableAnnotationComposer,
      $$ChoreCompletionsTableCreateCompanionBuilder,
      $$ChoreCompletionsTableUpdateCompanionBuilder,
      (
        ChoreCompletion,
        BaseReferences<_$AppDatabase, $ChoreCompletionsTable, ChoreCompletion>,
      ),
      ChoreCompletion,
      PrefetchHooks Function()
    >;
typedef $$EventsTableCreateCompanionBuilder =
    EventsCompanion Function({
      required String id,
      required String householdId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> hlc,
      Value<int?> serverVersion,
      Value<String?> updatedBy,
      Value<String?> deviceId,
      required String title,
      required String startsOn,
      Value<String?> endsOn,
      Value<String?> startTime,
      Value<String?> endTime,
      Value<String> repeat,
      Value<String?> color,
      Value<String?> memberId,
      Value<String?> location,
      Value<String?> note,
      Value<String?> createdBy,
      Value<int> rowid,
    });
typedef $$EventsTableUpdateCompanionBuilder =
    EventsCompanion Function({
      Value<String> id,
      Value<String> householdId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> hlc,
      Value<int?> serverVersion,
      Value<String?> updatedBy,
      Value<String?> deviceId,
      Value<String> title,
      Value<String> startsOn,
      Value<String?> endsOn,
      Value<String?> startTime,
      Value<String?> endTime,
      Value<String> repeat,
      Value<String?> color,
      Value<String?> memberId,
      Value<String?> location,
      Value<String?> note,
      Value<String?> createdBy,
      Value<int> rowid,
    });

class $$EventsTableFilterComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startsOn => $composableBuilder(
    column: $table.startsOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endsOn => $composableBuilder(
    column: $table.endsOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repeat => $composableBuilder(
    column: $table.repeat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EventsTableOrderingComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startsOn => $composableBuilder(
    column: $table.startsOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endsOn => $composableBuilder(
    column: $table.endsOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repeat => $composableBuilder(
    column: $table.repeat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get startsOn =>
      $composableBuilder(column: $table.startsOn, builder: (column) => column);

  GeneratedColumn<String> get endsOn =>
      $composableBuilder(column: $table.endsOn, builder: (column) => column);

  GeneratedColumn<String> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<String> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<String> get repeat =>
      $composableBuilder(column: $table.repeat, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get memberId =>
      $composableBuilder(column: $table.memberId, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);
}

class $$EventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EventsTable,
          CalendarEvent,
          $$EventsTableFilterComposer,
          $$EventsTableOrderingComposer,
          $$EventsTableAnnotationComposer,
          $$EventsTableCreateCompanionBuilder,
          $$EventsTableUpdateCompanionBuilder,
          (
            CalendarEvent,
            BaseReferences<_$AppDatabase, $EventsTable, CalendarEvent>,
          ),
          CalendarEvent,
          PrefetchHooks Function()
        > {
  $$EventsTableTableManager(_$AppDatabase db, $EventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> householdId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> hlc = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> startsOn = const Value.absent(),
                Value<String?> endsOn = const Value.absent(),
                Value<String?> startTime = const Value.absent(),
                Value<String?> endTime = const Value.absent(),
                Value<String> repeat = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<String?> memberId = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventsCompanion(
                id: id,
                householdId: householdId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                hlc: hlc,
                serverVersion: serverVersion,
                updatedBy: updatedBy,
                deviceId: deviceId,
                title: title,
                startsOn: startsOn,
                endsOn: endsOn,
                startTime: startTime,
                endTime: endTime,
                repeat: repeat,
                color: color,
                memberId: memberId,
                location: location,
                note: note,
                createdBy: createdBy,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String householdId,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> hlc = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                required String title,
                required String startsOn,
                Value<String?> endsOn = const Value.absent(),
                Value<String?> startTime = const Value.absent(),
                Value<String?> endTime = const Value.absent(),
                Value<String> repeat = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<String?> memberId = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventsCompanion.insert(
                id: id,
                householdId: householdId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                hlc: hlc,
                serverVersion: serverVersion,
                updatedBy: updatedBy,
                deviceId: deviceId,
                title: title,
                startsOn: startsOn,
                endsOn: endsOn,
                startTime: startTime,
                endTime: endTime,
                repeat: repeat,
                color: color,
                memberId: memberId,
                location: location,
                note: note,
                createdBy: createdBy,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EventsTable,
      CalendarEvent,
      $$EventsTableFilterComposer,
      $$EventsTableOrderingComposer,
      $$EventsTableAnnotationComposer,
      $$EventsTableCreateCompanionBuilder,
      $$EventsTableUpdateCompanionBuilder,
      (
        CalendarEvent,
        BaseReferences<_$AppDatabase, $EventsTable, CalendarEvent>,
      ),
      CalendarEvent,
      PrefetchHooks Function()
    >;
typedef $$DebtsTableCreateCompanionBuilder =
    DebtsCompanion Function({
      required String id,
      required String householdId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> hlc,
      Value<int?> serverVersion,
      Value<String?> updatedBy,
      Value<String?> deviceId,
      required String kind,
      required String name,
      Value<String?> counterparty,
      Value<String?> reference,
      Value<int> principalMinor,
      Value<String> currency,
      Value<int?> installmentMinor,
      Value<String?> nextDueOn,
      Value<String?> repeat,
      Value<String?> startedOn,
      Value<bool> isClosed,
      Value<DateTime?> closedAt,
      Value<String?> closedBy,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$DebtsTableUpdateCompanionBuilder =
    DebtsCompanion Function({
      Value<String> id,
      Value<String> householdId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> hlc,
      Value<int?> serverVersion,
      Value<String?> updatedBy,
      Value<String?> deviceId,
      Value<String> kind,
      Value<String> name,
      Value<String?> counterparty,
      Value<String?> reference,
      Value<int> principalMinor,
      Value<String> currency,
      Value<int?> installmentMinor,
      Value<String?> nextDueOn,
      Value<String?> repeat,
      Value<String?> startedOn,
      Value<bool> isClosed,
      Value<DateTime?> closedAt,
      Value<String?> closedBy,
      Value<String?> note,
      Value<int> rowid,
    });

class $$DebtsTableFilterComposer extends Composer<_$AppDatabase, $DebtsTable> {
  $$DebtsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get counterparty => $composableBuilder(
    column: $table.counterparty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get principalMinor => $composableBuilder(
    column: $table.principalMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get installmentMinor => $composableBuilder(
    column: $table.installmentMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nextDueOn => $composableBuilder(
    column: $table.nextDueOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repeat => $composableBuilder(
    column: $table.repeat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startedOn => $composableBuilder(
    column: $table.startedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isClosed => $composableBuilder(
    column: $table.isClosed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get closedBy => $composableBuilder(
    column: $table.closedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DebtsTableOrderingComposer
    extends Composer<_$AppDatabase, $DebtsTable> {
  $$DebtsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get counterparty => $composableBuilder(
    column: $table.counterparty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get principalMinor => $composableBuilder(
    column: $table.principalMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get installmentMinor => $composableBuilder(
    column: $table.installmentMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nextDueOn => $composableBuilder(
    column: $table.nextDueOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repeat => $composableBuilder(
    column: $table.repeat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startedOn => $composableBuilder(
    column: $table.startedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isClosed => $composableBuilder(
    column: $table.isClosed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get closedBy => $composableBuilder(
    column: $table.closedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DebtsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DebtsTable> {
  $$DebtsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get counterparty => $composableBuilder(
    column: $table.counterparty,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<int> get principalMinor => $composableBuilder(
    column: $table.principalMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<int> get installmentMinor => $composableBuilder(
    column: $table.installmentMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nextDueOn =>
      $composableBuilder(column: $table.nextDueOn, builder: (column) => column);

  GeneratedColumn<String> get repeat =>
      $composableBuilder(column: $table.repeat, builder: (column) => column);

  GeneratedColumn<String> get startedOn =>
      $composableBuilder(column: $table.startedOn, builder: (column) => column);

  GeneratedColumn<bool> get isClosed =>
      $composableBuilder(column: $table.isClosed, builder: (column) => column);

  GeneratedColumn<DateTime> get closedAt =>
      $composableBuilder(column: $table.closedAt, builder: (column) => column);

  GeneratedColumn<String> get closedBy =>
      $composableBuilder(column: $table.closedBy, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$DebtsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DebtsTable,
          Debt,
          $$DebtsTableFilterComposer,
          $$DebtsTableOrderingComposer,
          $$DebtsTableAnnotationComposer,
          $$DebtsTableCreateCompanionBuilder,
          $$DebtsTableUpdateCompanionBuilder,
          (Debt, BaseReferences<_$AppDatabase, $DebtsTable, Debt>),
          Debt,
          PrefetchHooks Function()
        > {
  $$DebtsTableTableManager(_$AppDatabase db, $DebtsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DebtsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DebtsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DebtsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> householdId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> hlc = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> counterparty = const Value.absent(),
                Value<String?> reference = const Value.absent(),
                Value<int> principalMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<int?> installmentMinor = const Value.absent(),
                Value<String?> nextDueOn = const Value.absent(),
                Value<String?> repeat = const Value.absent(),
                Value<String?> startedOn = const Value.absent(),
                Value<bool> isClosed = const Value.absent(),
                Value<DateTime?> closedAt = const Value.absent(),
                Value<String?> closedBy = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DebtsCompanion(
                id: id,
                householdId: householdId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                hlc: hlc,
                serverVersion: serverVersion,
                updatedBy: updatedBy,
                deviceId: deviceId,
                kind: kind,
                name: name,
                counterparty: counterparty,
                reference: reference,
                principalMinor: principalMinor,
                currency: currency,
                installmentMinor: installmentMinor,
                nextDueOn: nextDueOn,
                repeat: repeat,
                startedOn: startedOn,
                isClosed: isClosed,
                closedAt: closedAt,
                closedBy: closedBy,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String householdId,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> hlc = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                required String kind,
                required String name,
                Value<String?> counterparty = const Value.absent(),
                Value<String?> reference = const Value.absent(),
                Value<int> principalMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<int?> installmentMinor = const Value.absent(),
                Value<String?> nextDueOn = const Value.absent(),
                Value<String?> repeat = const Value.absent(),
                Value<String?> startedOn = const Value.absent(),
                Value<bool> isClosed = const Value.absent(),
                Value<DateTime?> closedAt = const Value.absent(),
                Value<String?> closedBy = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DebtsCompanion.insert(
                id: id,
                householdId: householdId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                hlc: hlc,
                serverVersion: serverVersion,
                updatedBy: updatedBy,
                deviceId: deviceId,
                kind: kind,
                name: name,
                counterparty: counterparty,
                reference: reference,
                principalMinor: principalMinor,
                currency: currency,
                installmentMinor: installmentMinor,
                nextDueOn: nextDueOn,
                repeat: repeat,
                startedOn: startedOn,
                isClosed: isClosed,
                closedAt: closedAt,
                closedBy: closedBy,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DebtsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DebtsTable,
      Debt,
      $$DebtsTableFilterComposer,
      $$DebtsTableOrderingComposer,
      $$DebtsTableAnnotationComposer,
      $$DebtsTableCreateCompanionBuilder,
      $$DebtsTableUpdateCompanionBuilder,
      (Debt, BaseReferences<_$AppDatabase, $DebtsTable, Debt>),
      Debt,
      PrefetchHooks Function()
    >;
typedef $$DebtPaymentsTableCreateCompanionBuilder =
    DebtPaymentsCompanion Function({
      required String id,
      required String householdId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> hlc,
      Value<int?> serverVersion,
      Value<String?> updatedBy,
      Value<String?> deviceId,
      required String debtId,
      required String kind,
      required int amountMinor,
      Value<String> currency,
      required String paidOn,
      Value<String?> memberId,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$DebtPaymentsTableUpdateCompanionBuilder =
    DebtPaymentsCompanion Function({
      Value<String> id,
      Value<String> householdId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> hlc,
      Value<int?> serverVersion,
      Value<String?> updatedBy,
      Value<String?> deviceId,
      Value<String> debtId,
      Value<String> kind,
      Value<int> amountMinor,
      Value<String> currency,
      Value<String> paidOn,
      Value<String?> memberId,
      Value<String?> note,
      Value<int> rowid,
    });

class $$DebtPaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $DebtPaymentsTable> {
  $$DebtPaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get debtId => $composableBuilder(
    column: $table.debtId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paidOn => $composableBuilder(
    column: $table.paidOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DebtPaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $DebtPaymentsTable> {
  $$DebtPaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get debtId => $composableBuilder(
    column: $table.debtId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paidOn => $composableBuilder(
    column: $table.paidOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DebtPaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DebtPaymentsTable> {
  $$DebtPaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get debtId =>
      $composableBuilder(column: $table.debtId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get paidOn =>
      $composableBuilder(column: $table.paidOn, builder: (column) => column);

  GeneratedColumn<String> get memberId =>
      $composableBuilder(column: $table.memberId, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$DebtPaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DebtPaymentsTable,
          DebtPayment,
          $$DebtPaymentsTableFilterComposer,
          $$DebtPaymentsTableOrderingComposer,
          $$DebtPaymentsTableAnnotationComposer,
          $$DebtPaymentsTableCreateCompanionBuilder,
          $$DebtPaymentsTableUpdateCompanionBuilder,
          (
            DebtPayment,
            BaseReferences<_$AppDatabase, $DebtPaymentsTable, DebtPayment>,
          ),
          DebtPayment,
          PrefetchHooks Function()
        > {
  $$DebtPaymentsTableTableManager(_$AppDatabase db, $DebtPaymentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DebtPaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DebtPaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DebtPaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> householdId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> hlc = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<String> debtId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> paidOn = const Value.absent(),
                Value<String?> memberId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DebtPaymentsCompanion(
                id: id,
                householdId: householdId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                hlc: hlc,
                serverVersion: serverVersion,
                updatedBy: updatedBy,
                deviceId: deviceId,
                debtId: debtId,
                kind: kind,
                amountMinor: amountMinor,
                currency: currency,
                paidOn: paidOn,
                memberId: memberId,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String householdId,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> hlc = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                required String debtId,
                required String kind,
                required int amountMinor,
                Value<String> currency = const Value.absent(),
                required String paidOn,
                Value<String?> memberId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DebtPaymentsCompanion.insert(
                id: id,
                householdId: householdId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                hlc: hlc,
                serverVersion: serverVersion,
                updatedBy: updatedBy,
                deviceId: deviceId,
                debtId: debtId,
                kind: kind,
                amountMinor: amountMinor,
                currency: currency,
                paidOn: paidOn,
                memberId: memberId,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DebtPaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DebtPaymentsTable,
      DebtPayment,
      $$DebtPaymentsTableFilterComposer,
      $$DebtPaymentsTableOrderingComposer,
      $$DebtPaymentsTableAnnotationComposer,
      $$DebtPaymentsTableCreateCompanionBuilder,
      $$DebtPaymentsTableUpdateCompanionBuilder,
      (
        DebtPayment,
        BaseReferences<_$AppDatabase, $DebtPaymentsTable, DebtPayment>,
      ),
      DebtPayment,
      PrefetchHooks Function()
    >;
typedef $$VehiclesTableCreateCompanionBuilder =
    VehiclesCompanion Function({
      required String id,
      required String householdId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> hlc,
      Value<int?> serverVersion,
      Value<String?> updatedBy,
      Value<String?> deviceId,
      required String kind,
      required String name,
      Value<String?> plate,
      Value<String?> color,
      Value<String?> registrationDueOn,
      Value<String?> insuranceDueOn,
      Value<String?> pmsDueOn,
      Value<int?> pmsDueKm,
      Value<int?> pmsEveryMonths,
      Value<int?> pmsEveryKm,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$VehiclesTableUpdateCompanionBuilder =
    VehiclesCompanion Function({
      Value<String> id,
      Value<String> householdId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> hlc,
      Value<int?> serverVersion,
      Value<String?> updatedBy,
      Value<String?> deviceId,
      Value<String> kind,
      Value<String> name,
      Value<String?> plate,
      Value<String?> color,
      Value<String?> registrationDueOn,
      Value<String?> insuranceDueOn,
      Value<String?> pmsDueOn,
      Value<int?> pmsDueKm,
      Value<int?> pmsEveryMonths,
      Value<int?> pmsEveryKm,
      Value<String?> note,
      Value<int> rowid,
    });

class $$VehiclesTableFilterComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plate => $composableBuilder(
    column: $table.plate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get registrationDueOn => $composableBuilder(
    column: $table.registrationDueOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get insuranceDueOn => $composableBuilder(
    column: $table.insuranceDueOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pmsDueOn => $composableBuilder(
    column: $table.pmsDueOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pmsDueKm => $composableBuilder(
    column: $table.pmsDueKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pmsEveryMonths => $composableBuilder(
    column: $table.pmsEveryMonths,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pmsEveryKm => $composableBuilder(
    column: $table.pmsEveryKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VehiclesTableOrderingComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plate => $composableBuilder(
    column: $table.plate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get registrationDueOn => $composableBuilder(
    column: $table.registrationDueOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get insuranceDueOn => $composableBuilder(
    column: $table.insuranceDueOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pmsDueOn => $composableBuilder(
    column: $table.pmsDueOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pmsDueKm => $composableBuilder(
    column: $table.pmsDueKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pmsEveryMonths => $composableBuilder(
    column: $table.pmsEveryMonths,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pmsEveryKm => $composableBuilder(
    column: $table.pmsEveryKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VehiclesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get plate =>
      $composableBuilder(column: $table.plate, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get registrationDueOn => $composableBuilder(
    column: $table.registrationDueOn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get insuranceDueOn => $composableBuilder(
    column: $table.insuranceDueOn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pmsDueOn =>
      $composableBuilder(column: $table.pmsDueOn, builder: (column) => column);

  GeneratedColumn<int> get pmsDueKm =>
      $composableBuilder(column: $table.pmsDueKm, builder: (column) => column);

  GeneratedColumn<int> get pmsEveryMonths => $composableBuilder(
    column: $table.pmsEveryMonths,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pmsEveryKm => $composableBuilder(
    column: $table.pmsEveryKm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$VehiclesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VehiclesTable,
          Vehicle,
          $$VehiclesTableFilterComposer,
          $$VehiclesTableOrderingComposer,
          $$VehiclesTableAnnotationComposer,
          $$VehiclesTableCreateCompanionBuilder,
          $$VehiclesTableUpdateCompanionBuilder,
          (Vehicle, BaseReferences<_$AppDatabase, $VehiclesTable, Vehicle>),
          Vehicle,
          PrefetchHooks Function()
        > {
  $$VehiclesTableTableManager(_$AppDatabase db, $VehiclesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VehiclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VehiclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VehiclesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> householdId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> hlc = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> plate = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<String?> registrationDueOn = const Value.absent(),
                Value<String?> insuranceDueOn = const Value.absent(),
                Value<String?> pmsDueOn = const Value.absent(),
                Value<int?> pmsDueKm = const Value.absent(),
                Value<int?> pmsEveryMonths = const Value.absent(),
                Value<int?> pmsEveryKm = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VehiclesCompanion(
                id: id,
                householdId: householdId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                hlc: hlc,
                serverVersion: serverVersion,
                updatedBy: updatedBy,
                deviceId: deviceId,
                kind: kind,
                name: name,
                plate: plate,
                color: color,
                registrationDueOn: registrationDueOn,
                insuranceDueOn: insuranceDueOn,
                pmsDueOn: pmsDueOn,
                pmsDueKm: pmsDueKm,
                pmsEveryMonths: pmsEveryMonths,
                pmsEveryKm: pmsEveryKm,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String householdId,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> hlc = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                required String kind,
                required String name,
                Value<String?> plate = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<String?> registrationDueOn = const Value.absent(),
                Value<String?> insuranceDueOn = const Value.absent(),
                Value<String?> pmsDueOn = const Value.absent(),
                Value<int?> pmsDueKm = const Value.absent(),
                Value<int?> pmsEveryMonths = const Value.absent(),
                Value<int?> pmsEveryKm = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VehiclesCompanion.insert(
                id: id,
                householdId: householdId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                hlc: hlc,
                serverVersion: serverVersion,
                updatedBy: updatedBy,
                deviceId: deviceId,
                kind: kind,
                name: name,
                plate: plate,
                color: color,
                registrationDueOn: registrationDueOn,
                insuranceDueOn: insuranceDueOn,
                pmsDueOn: pmsDueOn,
                pmsDueKm: pmsDueKm,
                pmsEveryMonths: pmsEveryMonths,
                pmsEveryKm: pmsEveryKm,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VehiclesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VehiclesTable,
      Vehicle,
      $$VehiclesTableFilterComposer,
      $$VehiclesTableOrderingComposer,
      $$VehiclesTableAnnotationComposer,
      $$VehiclesTableCreateCompanionBuilder,
      $$VehiclesTableUpdateCompanionBuilder,
      (Vehicle, BaseReferences<_$AppDatabase, $VehiclesTable, Vehicle>),
      Vehicle,
      PrefetchHooks Function()
    >;
typedef $$VehicleLogsTableCreateCompanionBuilder =
    VehicleLogsCompanion Function({
      required String id,
      required String householdId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> hlc,
      Value<int?> serverVersion,
      Value<String?> updatedBy,
      Value<String?> deviceId,
      required String vehicleId,
      required String kind,
      Value<int?> amountMinor,
      Value<String> currency,
      required String loggedOn,
      Value<int?> odometerKm,
      Value<double?> litres,
      Value<String?> memberId,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$VehicleLogsTableUpdateCompanionBuilder =
    VehicleLogsCompanion Function({
      Value<String> id,
      Value<String> householdId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> hlc,
      Value<int?> serverVersion,
      Value<String?> updatedBy,
      Value<String?> deviceId,
      Value<String> vehicleId,
      Value<String> kind,
      Value<int?> amountMinor,
      Value<String> currency,
      Value<String> loggedOn,
      Value<int?> odometerKm,
      Value<double?> litres,
      Value<String?> memberId,
      Value<String?> note,
      Value<int> rowid,
    });

class $$VehicleLogsTableFilterComposer
    extends Composer<_$AppDatabase, $VehicleLogsTable> {
  $$VehicleLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vehicleId => $composableBuilder(
    column: $table.vehicleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get loggedOn => $composableBuilder(
    column: $table.loggedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get odometerKm => $composableBuilder(
    column: $table.odometerKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get litres => $composableBuilder(
    column: $table.litres,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VehicleLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $VehicleLogsTable> {
  $$VehicleLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vehicleId => $composableBuilder(
    column: $table.vehicleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get loggedOn => $composableBuilder(
    column: $table.loggedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get odometerKm => $composableBuilder(
    column: $table.odometerKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get litres => $composableBuilder(
    column: $table.litres,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VehicleLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VehicleLogsTable> {
  $$VehicleLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get vehicleId =>
      $composableBuilder(column: $table.vehicleId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get loggedOn =>
      $composableBuilder(column: $table.loggedOn, builder: (column) => column);

  GeneratedColumn<int> get odometerKm => $composableBuilder(
    column: $table.odometerKm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get litres =>
      $composableBuilder(column: $table.litres, builder: (column) => column);

  GeneratedColumn<String> get memberId =>
      $composableBuilder(column: $table.memberId, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$VehicleLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VehicleLogsTable,
          VehicleLog,
          $$VehicleLogsTableFilterComposer,
          $$VehicleLogsTableOrderingComposer,
          $$VehicleLogsTableAnnotationComposer,
          $$VehicleLogsTableCreateCompanionBuilder,
          $$VehicleLogsTableUpdateCompanionBuilder,
          (
            VehicleLog,
            BaseReferences<_$AppDatabase, $VehicleLogsTable, VehicleLog>,
          ),
          VehicleLog,
          PrefetchHooks Function()
        > {
  $$VehicleLogsTableTableManager(_$AppDatabase db, $VehicleLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VehicleLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VehicleLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VehicleLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> householdId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> hlc = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<String> vehicleId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int?> amountMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> loggedOn = const Value.absent(),
                Value<int?> odometerKm = const Value.absent(),
                Value<double?> litres = const Value.absent(),
                Value<String?> memberId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VehicleLogsCompanion(
                id: id,
                householdId: householdId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                hlc: hlc,
                serverVersion: serverVersion,
                updatedBy: updatedBy,
                deviceId: deviceId,
                vehicleId: vehicleId,
                kind: kind,
                amountMinor: amountMinor,
                currency: currency,
                loggedOn: loggedOn,
                odometerKm: odometerKm,
                litres: litres,
                memberId: memberId,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String householdId,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> hlc = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                required String vehicleId,
                required String kind,
                Value<int?> amountMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                required String loggedOn,
                Value<int?> odometerKm = const Value.absent(),
                Value<double?> litres = const Value.absent(),
                Value<String?> memberId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VehicleLogsCompanion.insert(
                id: id,
                householdId: householdId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                hlc: hlc,
                serverVersion: serverVersion,
                updatedBy: updatedBy,
                deviceId: deviceId,
                vehicleId: vehicleId,
                kind: kind,
                amountMinor: amountMinor,
                currency: currency,
                loggedOn: loggedOn,
                odometerKm: odometerKm,
                litres: litres,
                memberId: memberId,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VehicleLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VehicleLogsTable,
      VehicleLog,
      $$VehicleLogsTableFilterComposer,
      $$VehicleLogsTableOrderingComposer,
      $$VehicleLogsTableAnnotationComposer,
      $$VehicleLogsTableCreateCompanionBuilder,
      $$VehicleLogsTableUpdateCompanionBuilder,
      (
        VehicleLog,
        BaseReferences<_$AppDatabase, $VehicleLogsTable, VehicleLog>,
      ),
      VehicleLog,
      PrefetchHooks Function()
    >;
typedef $$BudgetsTableCreateCompanionBuilder =
    BudgetsCompanion Function({
      required String id,
      required String householdId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> hlc,
      Value<int?> serverVersion,
      Value<String?> updatedBy,
      Value<String?> deviceId,
      required String category,
      Value<int> limitMinor,
      Value<String> currency,
      Value<int> rowid,
    });
typedef $$BudgetsTableUpdateCompanionBuilder =
    BudgetsCompanion Function({
      Value<String> id,
      Value<String> householdId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> hlc,
      Value<int?> serverVersion,
      Value<String?> updatedBy,
      Value<String?> deviceId,
      Value<String> category,
      Value<int> limitMinor,
      Value<String> currency,
      Value<int> rowid,
    });

class $$BudgetsTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get limitMinor => $composableBuilder(
    column: $table.limitMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BudgetsTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get limitMinor => $composableBuilder(
    column: $table.limitMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BudgetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get limitMinor => $composableBuilder(
    column: $table.limitMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);
}

class $$BudgetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BudgetsTable,
          Budget,
          $$BudgetsTableFilterComposer,
          $$BudgetsTableOrderingComposer,
          $$BudgetsTableAnnotationComposer,
          $$BudgetsTableCreateCompanionBuilder,
          $$BudgetsTableUpdateCompanionBuilder,
          (Budget, BaseReferences<_$AppDatabase, $BudgetsTable, Budget>),
          Budget,
          PrefetchHooks Function()
        > {
  $$BudgetsTableTableManager(_$AppDatabase db, $BudgetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> householdId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> hlc = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int> limitMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetsCompanion(
                id: id,
                householdId: householdId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                hlc: hlc,
                serverVersion: serverVersion,
                updatedBy: updatedBy,
                deviceId: deviceId,
                category: category,
                limitMinor: limitMinor,
                currency: currency,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String householdId,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> hlc = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                required String category,
                Value<int> limitMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetsCompanion.insert(
                id: id,
                householdId: householdId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                hlc: hlc,
                serverVersion: serverVersion,
                updatedBy: updatedBy,
                deviceId: deviceId,
                category: category,
                limitMinor: limitMinor,
                currency: currency,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BudgetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BudgetsTable,
      Budget,
      $$BudgetsTableFilterComposer,
      $$BudgetsTableOrderingComposer,
      $$BudgetsTableAnnotationComposer,
      $$BudgetsTableCreateCompanionBuilder,
      $$BudgetsTableUpdateCompanionBuilder,
      (Budget, BaseReferences<_$AppDatabase, $BudgetsTable, Budget>),
      Budget,
      PrefetchHooks Function()
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      required String id,
      required String householdId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> hlc,
      Value<int?> serverVersion,
      Value<String?> updatedBy,
      Value<String?> deviceId,
      Value<String?> accountId,
      Value<String?> category,
      required int amountMinor,
      Value<String> currency,
      required DateTime occurredAt,
      Value<String?> memberId,
      Value<String?> sourceType,
      Value<String?> sourceId,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<String> id,
      Value<String> householdId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> hlc,
      Value<int?> serverVersion,
      Value<String?> updatedBy,
      Value<String?> deviceId,
      Value<String?> accountId,
      Value<String?> category,
      Value<int> amountMinor,
      Value<String> currency,
      Value<DateTime> occurredAt,
      Value<String?> memberId,
      Value<String?> sourceType,
      Value<String?> sourceId,
      Value<String?> note,
      Value<int> rowid,
    });

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get memberId =>
      $composableBuilder(column: $table.memberId, builder: (column) => column);

  GeneratedColumn<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          LedgerEntry,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (
            LedgerEntry,
            BaseReferences<_$AppDatabase, $TransactionsTable, LedgerEntry>,
          ),
          LedgerEntry,
          PrefetchHooks Function()
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> householdId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> hlc = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<String?> accountId = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<String?> memberId = const Value.absent(),
                Value<String?> sourceType = const Value.absent(),
                Value<String?> sourceId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                householdId: householdId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                hlc: hlc,
                serverVersion: serverVersion,
                updatedBy: updatedBy,
                deviceId: deviceId,
                accountId: accountId,
                category: category,
                amountMinor: amountMinor,
                currency: currency,
                occurredAt: occurredAt,
                memberId: memberId,
                sourceType: sourceType,
                sourceId: sourceId,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String householdId,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> hlc = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<String?> accountId = const Value.absent(),
                Value<String?> category = const Value.absent(),
                required int amountMinor,
                Value<String> currency = const Value.absent(),
                required DateTime occurredAt,
                Value<String?> memberId = const Value.absent(),
                Value<String?> sourceType = const Value.absent(),
                Value<String?> sourceId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                householdId: householdId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                hlc: hlc,
                serverVersion: serverVersion,
                updatedBy: updatedBy,
                deviceId: deviceId,
                accountId: accountId,
                category: category,
                amountMinor: amountMinor,
                currency: currency,
                occurredAt: occurredAt,
                memberId: memberId,
                sourceType: sourceType,
                sourceId: sourceId,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      LedgerEntry,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (
        LedgerEntry,
        BaseReferences<_$AppDatabase, $TransactionsTable, LedgerEntry>,
      ),
      LedgerEntry,
      PrefetchHooks Function()
    >;
typedef $$ConflictsTableCreateCompanionBuilder =
    ConflictsCompanion Function({
      required String id,
      required String householdId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> hlc,
      Value<int?> serverVersion,
      Value<String?> updatedBy,
      Value<String?> deviceId,
      required String entity,
      required String entityId,
      required String field,
      Value<String?> keptValue,
      Value<String?> keptBy,
      Value<String?> lostValue,
      Value<String?> lostBy,
      Value<DateTime?> resolvedAt,
      Value<String?> resolvedBy,
      Value<int> rowid,
    });
typedef $$ConflictsTableUpdateCompanionBuilder =
    ConflictsCompanion Function({
      Value<String> id,
      Value<String> householdId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> hlc,
      Value<int?> serverVersion,
      Value<String?> updatedBy,
      Value<String?> deviceId,
      Value<String> entity,
      Value<String> entityId,
      Value<String> field,
      Value<String?> keptValue,
      Value<String?> keptBy,
      Value<String?> lostValue,
      Value<String?> lostBy,
      Value<DateTime?> resolvedAt,
      Value<String?> resolvedBy,
      Value<int> rowid,
    });

class $$ConflictsTableFilterComposer
    extends Composer<_$AppDatabase, $ConflictsTable> {
  $$ConflictsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get keptValue => $composableBuilder(
    column: $table.keptValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get keptBy => $composableBuilder(
    column: $table.keptBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lostValue => $composableBuilder(
    column: $table.lostValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lostBy => $composableBuilder(
    column: $table.lostBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resolvedBy => $composableBuilder(
    column: $table.resolvedBy,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ConflictsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConflictsTable> {
  $$ConflictsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get keptValue => $composableBuilder(
    column: $table.keptValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get keptBy => $composableBuilder(
    column: $table.keptBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lostValue => $composableBuilder(
    column: $table.lostValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lostBy => $composableBuilder(
    column: $table.lostBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resolvedBy => $composableBuilder(
    column: $table.resolvedBy,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConflictsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConflictsTable> {
  $$ConflictsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get field =>
      $composableBuilder(column: $table.field, builder: (column) => column);

  GeneratedColumn<String> get keptValue =>
      $composableBuilder(column: $table.keptValue, builder: (column) => column);

  GeneratedColumn<String> get keptBy =>
      $composableBuilder(column: $table.keptBy, builder: (column) => column);

  GeneratedColumn<String> get lostValue =>
      $composableBuilder(column: $table.lostValue, builder: (column) => column);

  GeneratedColumn<String> get lostBy =>
      $composableBuilder(column: $table.lostBy, builder: (column) => column);

  GeneratedColumn<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resolvedBy => $composableBuilder(
    column: $table.resolvedBy,
    builder: (column) => column,
  );
}

class $$ConflictsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConflictsTable,
          ConflictRecord,
          $$ConflictsTableFilterComposer,
          $$ConflictsTableOrderingComposer,
          $$ConflictsTableAnnotationComposer,
          $$ConflictsTableCreateCompanionBuilder,
          $$ConflictsTableUpdateCompanionBuilder,
          (
            ConflictRecord,
            BaseReferences<_$AppDatabase, $ConflictsTable, ConflictRecord>,
          ),
          ConflictRecord,
          PrefetchHooks Function()
        > {
  $$ConflictsTableTableManager(_$AppDatabase db, $ConflictsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConflictsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConflictsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConflictsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> householdId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> hlc = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> field = const Value.absent(),
                Value<String?> keptValue = const Value.absent(),
                Value<String?> keptBy = const Value.absent(),
                Value<String?> lostValue = const Value.absent(),
                Value<String?> lostBy = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<String?> resolvedBy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConflictsCompanion(
                id: id,
                householdId: householdId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                hlc: hlc,
                serverVersion: serverVersion,
                updatedBy: updatedBy,
                deviceId: deviceId,
                entity: entity,
                entityId: entityId,
                field: field,
                keptValue: keptValue,
                keptBy: keptBy,
                lostValue: lostValue,
                lostBy: lostBy,
                resolvedAt: resolvedAt,
                resolvedBy: resolvedBy,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String householdId,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> hlc = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                required String entity,
                required String entityId,
                required String field,
                Value<String?> keptValue = const Value.absent(),
                Value<String?> keptBy = const Value.absent(),
                Value<String?> lostValue = const Value.absent(),
                Value<String?> lostBy = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<String?> resolvedBy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConflictsCompanion.insert(
                id: id,
                householdId: householdId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                hlc: hlc,
                serverVersion: serverVersion,
                updatedBy: updatedBy,
                deviceId: deviceId,
                entity: entity,
                entityId: entityId,
                field: field,
                keptValue: keptValue,
                keptBy: keptBy,
                lostValue: lostValue,
                lostBy: lostBy,
                resolvedAt: resolvedAt,
                resolvedBy: resolvedBy,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ConflictsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConflictsTable,
      ConflictRecord,
      $$ConflictsTableFilterComposer,
      $$ConflictsTableOrderingComposer,
      $$ConflictsTableAnnotationComposer,
      $$ConflictsTableCreateCompanionBuilder,
      $$ConflictsTableUpdateCompanionBuilder,
      (
        ConflictRecord,
        BaseReferences<_$AppDatabase, $ConflictsTable, ConflictRecord>,
      ),
      ConflictRecord,
      PrefetchHooks Function()
    >;
typedef $$OutboxTableCreateCompanionBuilder =
    OutboxCompanion Function({
      Value<int> seq,
      required String opId,
      required String entity,
      required String entityId,
      required String op,
      required String fields,
      required String hlc,
      Value<int?> baseVersion,
      Value<bool> sending,
      required String memberId,
      required String deviceId,
      Value<DateTime> createdAt,
    });
typedef $$OutboxTableUpdateCompanionBuilder =
    OutboxCompanion Function({
      Value<int> seq,
      Value<String> opId,
      Value<String> entity,
      Value<String> entityId,
      Value<String> op,
      Value<String> fields,
      Value<String> hlc,
      Value<int?> baseVersion,
      Value<bool> sending,
      Value<String> memberId,
      Value<String> deviceId,
      Value<DateTime> createdAt,
    });

class $$OutboxTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get op => $composableBuilder(
    column: $table.op,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fields => $composableBuilder(
    column: $table.fields,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseVersion => $composableBuilder(
    column: $table.baseVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get sending => $composableBuilder(
    column: $table.sending,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get op => $composableBuilder(
    column: $table.op,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fields => $composableBuilder(
    column: $table.fields,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseVersion => $composableBuilder(
    column: $table.baseVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get sending => $composableBuilder(
    column: $table.sending,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get opId =>
      $composableBuilder(column: $table.opId, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get op =>
      $composableBuilder(column: $table.op, builder: (column) => column);

  GeneratedColumn<String> get fields =>
      $composableBuilder(column: $table.fields, builder: (column) => column);

  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<int> get baseVersion => $composableBuilder(
    column: $table.baseVersion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get sending =>
      $composableBuilder(column: $table.sending, builder: (column) => column);

  GeneratedColumn<String> get memberId =>
      $composableBuilder(column: $table.memberId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$OutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxTable,
          OutboxOp,
          $$OutboxTableFilterComposer,
          $$OutboxTableOrderingComposer,
          $$OutboxTableAnnotationComposer,
          $$OutboxTableCreateCompanionBuilder,
          $$OutboxTableUpdateCompanionBuilder,
          (OutboxOp, BaseReferences<_$AppDatabase, $OutboxTable, OutboxOp>),
          OutboxOp,
          PrefetchHooks Function()
        > {
  $$OutboxTableTableManager(_$AppDatabase db, $OutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                Value<String> opId = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> op = const Value.absent(),
                Value<String> fields = const Value.absent(),
                Value<String> hlc = const Value.absent(),
                Value<int?> baseVersion = const Value.absent(),
                Value<bool> sending = const Value.absent(),
                Value<String> memberId = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => OutboxCompanion(
                seq: seq,
                opId: opId,
                entity: entity,
                entityId: entityId,
                op: op,
                fields: fields,
                hlc: hlc,
                baseVersion: baseVersion,
                sending: sending,
                memberId: memberId,
                deviceId: deviceId,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                required String opId,
                required String entity,
                required String entityId,
                required String op,
                required String fields,
                required String hlc,
                Value<int?> baseVersion = const Value.absent(),
                Value<bool> sending = const Value.absent(),
                required String memberId,
                required String deviceId,
                Value<DateTime> createdAt = const Value.absent(),
              }) => OutboxCompanion.insert(
                seq: seq,
                opId: opId,
                entity: entity,
                entityId: entityId,
                op: op,
                fields: fields,
                hlc: hlc,
                baseVersion: baseVersion,
                sending: sending,
                memberId: memberId,
                deviceId: deviceId,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxTable,
      OutboxOp,
      $$OutboxTableFilterComposer,
      $$OutboxTableOrderingComposer,
      $$OutboxTableAnnotationComposer,
      $$OutboxTableCreateCompanionBuilder,
      $$OutboxTableUpdateCompanionBuilder,
      (OutboxOp, BaseReferences<_$AppDatabase, $OutboxTable, OutboxOp>),
      OutboxOp,
      PrefetchHooks Function()
    >;
typedef $$FieldClocksTableCreateCompanionBuilder =
    FieldClocksCompanion Function({
      required String entity,
      required String entityId,
      required String field,
      required String hlc,
      Value<int> rowid,
    });
typedef $$FieldClocksTableUpdateCompanionBuilder =
    FieldClocksCompanion Function({
      Value<String> entity,
      Value<String> entityId,
      Value<String> field,
      Value<String> hlc,
      Value<int> rowid,
    });

class $$FieldClocksTableFilterComposer
    extends Composer<_$AppDatabase, $FieldClocksTable> {
  $$FieldClocksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FieldClocksTableOrderingComposer
    extends Composer<_$AppDatabase, $FieldClocksTable> {
  $$FieldClocksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FieldClocksTableAnnotationComposer
    extends Composer<_$AppDatabase, $FieldClocksTable> {
  $$FieldClocksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get field =>
      $composableBuilder(column: $table.field, builder: (column) => column);

  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);
}

class $$FieldClocksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FieldClocksTable,
          FieldClock,
          $$FieldClocksTableFilterComposer,
          $$FieldClocksTableOrderingComposer,
          $$FieldClocksTableAnnotationComposer,
          $$FieldClocksTableCreateCompanionBuilder,
          $$FieldClocksTableUpdateCompanionBuilder,
          (
            FieldClock,
            BaseReferences<_$AppDatabase, $FieldClocksTable, FieldClock>,
          ),
          FieldClock,
          PrefetchHooks Function()
        > {
  $$FieldClocksTableTableManager(_$AppDatabase db, $FieldClocksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FieldClocksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FieldClocksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FieldClocksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entity = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> field = const Value.absent(),
                Value<String> hlc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FieldClocksCompanion(
                entity: entity,
                entityId: entityId,
                field: field,
                hlc: hlc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entity,
                required String entityId,
                required String field,
                required String hlc,
                Value<int> rowid = const Value.absent(),
              }) => FieldClocksCompanion.insert(
                entity: entity,
                entityId: entityId,
                field: field,
                hlc: hlc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FieldClocksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FieldClocksTable,
      FieldClock,
      $$FieldClocksTableFilterComposer,
      $$FieldClocksTableOrderingComposer,
      $$FieldClocksTableAnnotationComposer,
      $$FieldClocksTableCreateCompanionBuilder,
      $$FieldClocksTableUpdateCompanionBuilder,
      (
        FieldClock,
        BaseReferences<_$AppDatabase, $FieldClocksTable, FieldClock>,
      ),
      FieldClock,
      PrefetchHooks Function()
    >;
typedef $$SyncStateTableCreateCompanionBuilder =
    SyncStateCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SyncStateTableUpdateCompanionBuilder =
    SyncStateCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SyncStateTableFilterComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncStateTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SyncStateTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncStateTable,
          SyncStateEntry,
          $$SyncStateTableFilterComposer,
          $$SyncStateTableOrderingComposer,
          $$SyncStateTableAnnotationComposer,
          $$SyncStateTableCreateCompanionBuilder,
          $$SyncStateTableUpdateCompanionBuilder,
          (
            SyncStateEntry,
            BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateEntry>,
          ),
          SyncStateEntry,
          PrefetchHooks Function()
        > {
  $$SyncStateTableTableManager(_$AppDatabase db, $SyncStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStateCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SyncStateCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncStateTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncStateTable,
      SyncStateEntry,
      $$SyncStateTableFilterComposer,
      $$SyncStateTableOrderingComposer,
      $$SyncStateTableAnnotationComposer,
      $$SyncStateTableCreateCompanionBuilder,
      $$SyncStateTableUpdateCompanionBuilder,
      (
        SyncStateEntry,
        BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateEntry>,
      ),
      SyncStateEntry,
      PrefetchHooks Function()
    >;
typedef $$SyncErrorsTableCreateCompanionBuilder =
    SyncErrorsCompanion Function({
      Value<int> id,
      required String opId,
      required String entity,
      required String entityId,
      required String op,
      required String fields,
      required String error,
      Value<String?> details,
      Value<bool> dismissed,
      Value<DateTime> createdAt,
    });
typedef $$SyncErrorsTableUpdateCompanionBuilder =
    SyncErrorsCompanion Function({
      Value<int> id,
      Value<String> opId,
      Value<String> entity,
      Value<String> entityId,
      Value<String> op,
      Value<String> fields,
      Value<String> error,
      Value<String?> details,
      Value<bool> dismissed,
      Value<DateTime> createdAt,
    });

class $$SyncErrorsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncErrorsTable> {
  $$SyncErrorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get op => $composableBuilder(
    column: $table.op,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fields => $composableBuilder(
    column: $table.fields,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get details => $composableBuilder(
    column: $table.details,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dismissed => $composableBuilder(
    column: $table.dismissed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncErrorsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncErrorsTable> {
  $$SyncErrorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get op => $composableBuilder(
    column: $table.op,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fields => $composableBuilder(
    column: $table.fields,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get details => $composableBuilder(
    column: $table.details,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dismissed => $composableBuilder(
    column: $table.dismissed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncErrorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncErrorsTable> {
  $$SyncErrorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get opId =>
      $composableBuilder(column: $table.opId, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get op =>
      $composableBuilder(column: $table.op, builder: (column) => column);

  GeneratedColumn<String> get fields =>
      $composableBuilder(column: $table.fields, builder: (column) => column);

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);

  GeneratedColumn<String> get details =>
      $composableBuilder(column: $table.details, builder: (column) => column);

  GeneratedColumn<bool> get dismissed =>
      $composableBuilder(column: $table.dismissed, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SyncErrorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncErrorsTable,
          SyncError,
          $$SyncErrorsTableFilterComposer,
          $$SyncErrorsTableOrderingComposer,
          $$SyncErrorsTableAnnotationComposer,
          $$SyncErrorsTableCreateCompanionBuilder,
          $$SyncErrorsTableUpdateCompanionBuilder,
          (
            SyncError,
            BaseReferences<_$AppDatabase, $SyncErrorsTable, SyncError>,
          ),
          SyncError,
          PrefetchHooks Function()
        > {
  $$SyncErrorsTableTableManager(_$AppDatabase db, $SyncErrorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncErrorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncErrorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncErrorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> opId = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> op = const Value.absent(),
                Value<String> fields = const Value.absent(),
                Value<String> error = const Value.absent(),
                Value<String?> details = const Value.absent(),
                Value<bool> dismissed = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SyncErrorsCompanion(
                id: id,
                opId: opId,
                entity: entity,
                entityId: entityId,
                op: op,
                fields: fields,
                error: error,
                details: details,
                dismissed: dismissed,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String opId,
                required String entity,
                required String entityId,
                required String op,
                required String fields,
                required String error,
                Value<String?> details = const Value.absent(),
                Value<bool> dismissed = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SyncErrorsCompanion.insert(
                id: id,
                opId: opId,
                entity: entity,
                entityId: entityId,
                op: op,
                fields: fields,
                error: error,
                details: details,
                dismissed: dismissed,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncErrorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncErrorsTable,
      SyncError,
      $$SyncErrorsTableFilterComposer,
      $$SyncErrorsTableOrderingComposer,
      $$SyncErrorsTableAnnotationComposer,
      $$SyncErrorsTableCreateCompanionBuilder,
      $$SyncErrorsTableUpdateCompanionBuilder,
      (SyncError, BaseReferences<_$AppDatabase, $SyncErrorsTable, SyncError>),
      SyncError,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MembersTableTableManager get members =>
      $$MembersTableTableManager(_db, _db.members);
  $$GroceryItemsTableTableManager get groceryItems =>
      $$GroceryItemsTableTableManager(_db, _db.groceryItems);
  $$PantryItemsTableTableManager get pantryItems =>
      $$PantryItemsTableTableManager(_db, _db.pantryItems);
  $$BillsTableTableManager get bills =>
      $$BillsTableTableManager(_db, _db.bills);
  $$SubscriptionsTableTableManager get subscriptions =>
      $$SubscriptionsTableTableManager(_db, _db.subscriptions);
  $$ChoresTableTableManager get chores =>
      $$ChoresTableTableManager(_db, _db.chores);
  $$ChoreCompletionsTableTableManager get choreCompletions =>
      $$ChoreCompletionsTableTableManager(_db, _db.choreCompletions);
  $$EventsTableTableManager get events =>
      $$EventsTableTableManager(_db, _db.events);
  $$DebtsTableTableManager get debts =>
      $$DebtsTableTableManager(_db, _db.debts);
  $$DebtPaymentsTableTableManager get debtPayments =>
      $$DebtPaymentsTableTableManager(_db, _db.debtPayments);
  $$VehiclesTableTableManager get vehicles =>
      $$VehiclesTableTableManager(_db, _db.vehicles);
  $$VehicleLogsTableTableManager get vehicleLogs =>
      $$VehicleLogsTableTableManager(_db, _db.vehicleLogs);
  $$BudgetsTableTableManager get budgets =>
      $$BudgetsTableTableManager(_db, _db.budgets);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$ConflictsTableTableManager get conflicts =>
      $$ConflictsTableTableManager(_db, _db.conflicts);
  $$OutboxTableTableManager get outbox =>
      $$OutboxTableTableManager(_db, _db.outbox);
  $$FieldClocksTableTableManager get fieldClocks =>
      $$FieldClocksTableTableManager(_db, _db.fieldClocks);
  $$SyncStateTableTableManager get syncState =>
      $$SyncStateTableTableManager(_db, _db.syncState);
  $$SyncErrorsTableTableManager get syncErrors =>
      $$SyncErrorsTableTableManager(_db, _db.syncErrors);
}
