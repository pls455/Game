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

  Future<StoreInfo?> loadStore() async {
    final db = await _database.database;
    final rows = await db.query('stores', limit: 1);
    if (rows.isEmpty) return null;
    final row = rows.first;
    return StoreInfo(id: row['id'] as String, name: row['name'] as String, currency: row['currency'] as String, role: row['role'] as String);
  }

  Future<StoreInfo> createStore(String name, {String? phone, String? address, String currency = 'ILS'}) async {
    final result = await _api.post('/store', {'name': name, 'phone': phone, 'address': address, 'currency': currency}, auth: true);
    final store = result;
    final db = await _database.database;
    await db.delete('stores');
    await db.insert('stores', {'id': store['id'], 'name': store['name'], 'phone': store['phone'], 'address': store['address'], 'currency': store['currency'], 'role': 'owner'});
    return StoreInfo(id: store['id'], name: store['name'], currency: store['currency'], role: 'owner');
  }

  Future<Session> _saveSession(Map<String, dynamic> result) async {
    _api.accessToken = result['accessToken'] as String;
    final user = Map<String, dynamic>.from(result['user'] as Map);
    final db = await _database.database;
    await db.insert('settings', {'key': 'access_token', 'value': _api.accessToken}, conflictAlgorithm: ConflictAlgorithm.replace);
    await db.insert('settings', {'key': 'user_id', 'value': user['id']}, conflictAlgorithm: ConflictAlgorithm.replace);
    return Session(accessToken: _api.accessToken!, userId: user['id'] as String, name: user['name'] as String, phone: user['phone'] as String);
  }
}
