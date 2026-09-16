import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({String? baseUrl}) : baseUrl = baseUrl ?? const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:3000/api/v1');

  final String baseUrl;
  String? accessToken;

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body, {bool auth = false}) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers(auth),
      body: jsonEncode(body),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> get(String path, {bool auth = false}) async {
    final response = await http.get(Uri.parse('$baseUrl$path'), headers: _headers(auth));
    return _decode(response);
  }

  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body, {bool auth = true}) async {
    final response = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: _headers(auth),
      body: jsonEncode(body),
    );
    return _decode(response);
  }

  Map<String, String> _headers(bool auth) => {
        'Content-Type': 'application/json',
        if (auth && accessToken != null) 'Authorization': 'Bearer $accessToken',
      };

  Map<String, dynamic> _decode(http.Response response) {
    final dynamic body = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = body is Map && body['message'] != null ? body['message'].toString() : 'تعذر تنفيذ الطلب';
      throw Exception(message);
    }
    return Map<String, dynamic>.from(body as Map);
  }
}
