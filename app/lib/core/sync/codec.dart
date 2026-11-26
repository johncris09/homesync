import 'package:drift/drift.dart';

/// Converts between wire values (JSON) and Drift column values, using the
/// column's SQL type. Lets the sync engine write any synced table generically.
class SyncCodec {
  const SyncCodec._();

  /// JSON value from the server -> Dart value for [column].
  static Object? fromWire(GeneratedColumn column, Object? value) {
    if (value == null) return null;
    switch (column.type) {
      case DriftSqlType.dateTime:
        return value is DateTime ? value.toUtc() : DateTime.parse(value as String).toUtc();
      case DriftSqlType.bool:
        return value is bool ? value : value == 1 || value == '1';
      case DriftSqlType.double:
        return value is num ? value.toDouble() : double.parse('$value');
      case DriftSqlType.int:
      case DriftSqlType.bigInt:
        return value is int ? value : (value is num ? value.toInt() : int.parse('$value'));
      case DriftSqlType.string:
        return value.toString();
      default:
        return value;
    }
  }

  /// Dart value -> JSON value for an op.
  static Object? toWire(Object? value) =>
      value is DateTime ? value.toUtc().toIso8601String() : value;

  /// SQL variable of the right type for [column].
  static Expression<Object> variable(GeneratedColumn column, Object? value) {
    final v = fromWire(column, value);
    return switch (column.type) {
      DriftSqlType.string => Variable<String>(v as String?),
      DriftSqlType.int => Variable<int>(v as int?),
      DriftSqlType.bool => Variable<bool>(v as bool?),
      DriftSqlType.double => Variable<double>(v as double?),
      DriftSqlType.dateTime => Variable<DateTime>(v as DateTime?),
      _ => Variable<Object>(v),
    };
  }

  /// Column -> SQL variable for the keys of [wire] that are columns of
  /// [table]. Nulls for required columns are dropped so defaults apply.
  static Map<String, Expression<Object>> _columns(
    TableInfo<Table, dynamic> table,
    Map<String, Object?> wire,
  ) {
    final out = <String, Expression<Object>>{};
    wire.forEach((name, value) {
      final column = table.columnsByName[name];
      if (column == null) return;
      if (value == null && !column.$nullable) return;
      out[name] = variable(column, value);
    });
    return out;
  }

  /// Inserts a row given in wire form. With [replace], an existing row with
  /// the same id is replaced (used when applying pulled rows).
  static Future<void> insert(
    DatabaseConnectionUser db,
    TableInfo<Table, dynamic> table,
    Map<String, Object?> wire, {
    bool replace = false,
  }) async {
    final now = DateTime.now().toUtc();
    final cols = _columns(table, {
      ...wire,
      'created_at': wire['created_at'] ?? now,
      'updated_at': wire['updated_at'] ?? now,
    });
    final names = cols.keys.map((c) => '"$c"').join(', ');
    final marks = List.filled(cols.length, '?').join(', ');
    await db.customInsert(
      'INSERT ${replace ? 'OR REPLACE ' : ''}INTO "${table.actualTableName}" ($names) VALUES ($marks)',
      variables: cols.values.cast<Variable>().toList(),
      updates: {table},
    );
  }

  /// Updates the given columns of the row with [id].
  static Future<void> update(
    DatabaseConnectionUser db,
    TableInfo<Table, dynamic> table,
    String id,
    Map<String, Object?> wire,
  ) async {
    final cols = _columns(table, wire);
    if (cols.isEmpty) return;
    final sets = cols.keys.map((c) => '"$c" = ?').join(', ');
    await db.customUpdate(
      'UPDATE "${table.actualTableName}" SET $sets WHERE id = ?',
      variables: [...cols.values.cast<Variable>(), Variable<String>(id)],
      updates: {table},
      updateKind: UpdateKind.update,
    );
  }
}
