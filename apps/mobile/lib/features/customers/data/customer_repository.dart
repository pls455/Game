import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../../../core/database/local_database.dart';

class Customer {
  const Customer({required this.id, required this.name, this.phone, this.balance = 0});
  final String id;
  final String name;
  final String? phone;
  final double balance;

  factory Customer.fromMap(Map<String, Object?> map) => Customer(
        id: map['id'] as String,
        name: map['name'] as String,
        phone: map['phone'] as String?,
        balance: (map['balance'] as num?)?.toDouble() ?? 0,
      );
}

class CustomerRepository {
  CustomerRepository({LocalDatabase? database}) : _database = database ?? LocalDatabase.instance;
  final LocalDatabase _database;
  final _uuid = const Uuid();

  Future<List<Customer>> list(String storeId, {String search = ''}) async {
    final db = await _database.database;
    final rows = await db.query(
      'customers',
      where: 'store_id = ? AND name LIKE ?',
      whereArgs: [storeId, '%$search%'],
      orderBy: 'name COLLATE NOCASE ASC',
      limit: 100,
    );
    return rows.map(Customer.fromMap).toList();
  }

  Future<Customer> add({required String storeId, required String name, String? phone, double openingBalance = 0}) async {
    final db = await _database.database;
    final id = _uuid.v4();
    final now = DateTime.now().toUtc().toIso8601String();
    final clientTransactionId = _uuid.v4();

    await db.transaction((txn) async {
      await txn.insert('customers', {
        'id': id,
        'store_id': storeId,
        'name': name.trim(),
        'phone': phone?.trim(),
        'opening_balance': openingBalance,
        'balance': openingBalance,
        'version': 1,
        'updated_at': now,
      });
      await txn.insert('sync_queue', {
        'id': _uuid.v4(),
        'store_id': storeId,
        'client_transaction_id': clientTransactionId,
        'entity_type': 'customer',
        'operation': 'create',
        'payload': jsonEncode({
          'id': id,
          'name': name.trim(),
          'phone': phone?.trim(),
          'opening_balance': openingBalance,
        }),
        'status': 'pending',
        'attempts': 0,
        'created_at': now,
      });
    });

    return Customer(id: id, name: name.trim(), phone: phone?.trim(), balance: openingBalance);
  }
}
