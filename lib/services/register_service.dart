import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class RegisterService {
  final String _baseUrl = 'http://10.1.20.216:8080';

  // 上传头像接口
  Future<String?> uploadAvatar(File imageFile) async {
    final url = Uri.parse('$_baseUrl/common/file_upload');

    // 创建一个 multipart 请求
    final request = http.MultipartRequest('POST', url)
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path)); // 使用 'file' 作为参数名

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 200) {
          print('头像上传成功: ${data['url']}');
          return data['url']; // 假设服务器返回图片的URL
        } else {
          print('头像上传失败: ${data['message']}');
          return null;
        }
      } else {
        print('头像上传接口调用失败: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('头像上传异常: $e');
      return null;
    }
  }

  // 注册接口
  Future<bool> registerUser({
    required String username,
    required String realname,
    required String password,
    String? phoneNumber,
    String? gender,
    List<double>? faceFeature,
    String? avatar, // 现在这里的 avatar 是上传后返回的 URL
  }) async {
    final url = Uri.parse('$_baseUrl/auth/register');
    final Map<String, dynamic> body = {
      'username': username,
      'realname': realname,
      'password': password,
      'phoneNumber': phoneNumber,
      'gender': gender,
      'faceFeature': faceFeature,
      'avatar': avatar,
    };

    body.removeWhere((key, value) => value == null);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['code'] == 200) {
        print('注册成功: ${response.body}');
        return true;
      } else {
        print('注册失败: ${data['message']}');
        return false;
      }
    } catch (e) {
      print('注册接口调用异常: $e');
      return false;
    }
  }
}