import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/user_model.dart';

class LoginService {
  final String _baseUrl = 'http://10.1.20.216:8080';

  Future<User?> login({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/auth/login/password');
    final Map<String, dynamic> body = {
      'username': username,
      'password': password,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200 && responseBody['code'] == 200) {
        final userData = responseBody['data'];
        return User.fromJson(userData);
      } else {
        throw Exception(responseBody['message'] ?? '登录失败');
      }
    } catch (e) {
      print('登录接口调用异常: $e');
      return null;
    }
  }
}