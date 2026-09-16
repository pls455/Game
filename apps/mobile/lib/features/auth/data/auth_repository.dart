import 'package:sqflite/sqflite.dart';
import '../../../core/database/local_database.dart';
import '../../../core/network/api_client.dart';

class Session {
  const Session({required this.accessToken, required this.userId, required this.name, required this.phone});
  final String accessToken;
  final String userId;
  final String name;
  final String phone;
}

class StoreInfo {
  const StoreInfo({required this.id, required this.name, required this.currency, required this.role});
  final String id;
  final String name;
  final String currency;
  final String role;
}

class AuthRepository {
  AuthRepository({ApiClient? api, LocalDatabase? database}) : _api = api ?? ApiClient(), _database = database ?? LocalDatabase.instance;
  final ApiClient _api;
  final LocalDatabase _database;

  ApiClient get api => _api;

  Future<Session> login(String phone, String password) async {
    final result = await _api.post('/auth/login', {'phone': phone, 'password': password});
    return _saveSession(result);
  }

  Future<Session> register(String name, String phone, String password) async {
    final result = await _api.post('/auth/register', {'name': name, 'phone': phone, 'password': password});
    return _saveSession(result);
  }

  Future<Session?> restoreSession() async {
    final db = await _database.database;
    final tokenRows = await db.query('settings', where: 'key=?', whereArgs: ['access_token'], limit: 1);
    final userRows = await db.query('settings', where: 'key=?', whereArgs: ['session_user'], limit: 1);
    if (tokenRows.isEmpty || userRows.isEmpty) return null;
    _api.accessToken = tokenRows.first['value'] as String?;
    final user = (userRows.first['value'] as String).split('|');
    if (_api.accessToken == null || user.length < 3) return null;
    return Session(accessToken: _api.accessToken!, userId: user[0], name: user[1], phone: user[2]);
  }

  Future<StoreInfo?> loadStore() async {
    final db = await _database.database;
    final rows = await db.query('stores', limit: 1);
    if (rows.isEmpty) return null;
    final row = rows.first;
    return StoreInfo(id: row['id'] as String, name: row['name'] as String, currency: row['currency'] as String, role: row['role'] as String);
  }

  Future<StoreInfo> createStore(String name, {String? phone, String? address, String currency = 'ILS'}) async {
    final result = await _api.post('/store', {'name': name, 'phone': phone, 'address': address, 'currency': currency}, auth: true);
    final db = await _database.database;
    await db.delete('stores');
    await db.insert('stores', {'id': result['id'], 'name': result['name'], 'phone': result['phone'], 'address': result['address'], 'currency': result['currency'], 'role': 'owner'});
    return StoreInfo(id: result['id'], name: result['name'], currency: result['currency'], role: 'owner');
  }

  Future<Session> _saveSession(Map<String, dynamic> result) async {
    _api.accessToken = result['accessToken'] as String;
    final user = Map<String, dynamic>.from(result['user'] as Map);
    final db = await _database.database;
    final sessionValue = '${user['id']}|${user['name']}|${user['phone']}';
    await db.insert('settings', {'key': 'access_token', 'value': _api.accessToken}, conflictAlgorithm: ConflictAlgorithm.replace);
    await db.insert('settings', {'key': 'session_user', 'value': sessionValue}, conflictAlgorithm: ConflictAlgorithm.replace);
    return Session(accessToken: _api.accessToken!, userId: user['id'] as String, name: user['name'] as String, phone: user['phone'] as String);
  }
}
