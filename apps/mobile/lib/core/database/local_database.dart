import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  LocalDatabase._();
  static final instance = LocalDatabase._();
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final path = p.join(await getDatabasesPath(), 'dakkana.db');
    _db = await openDatabase(path, version: 1, onCreate: (db, _) async {
      await db.execute('''
        CREATE TABLE settings (
          key TEXT PRIMARY KEY,
          value TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE stores (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          phone TEXT,
          address TEXT,
          currency TEXT NOT NULL DEFAULT 'ILS',
          role TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE customers (
          id TEXT PRIMARY KEY,
          store_id TEXT NOT NULL,
          name TEXT NOT NULL,
          phone TEXT,
          address TEXT,
          notes TEXT,
          opening_balance REAL NOT NULL DEFAULT 0,
          balance REAL NOT NULL DEFAULT 0,
          version INTEGER NOT NULL DEFAULT 1,
          updated_at TEXT NOT NULL
        )
      ''');
      await db.execute('CREATE INDEX idx_customers_store_name ON customers(store_id,name)');
      await db.execute('''
        CREATE TABLE sync_queue (
          id TEXT PRIMARY KEY,
          store_id TEXT NOT NULL,
          client_transaction_id TEXT NOT NULL UNIQUE,
          entity_type TEXT NOT NULL,
          operation TEXT NOT NULL,
          payload TEXT NOT NULL,
          status TEXT NOT NULL DEFAULT 'pending',
          attempts INTEGER NOT NULL DEFAULT 0,
          last_error TEXT,
          created_at TEXT NOT NULL,
          synced_at TEXT
        )
      ''');
    });
    return _db!;
  }
}
