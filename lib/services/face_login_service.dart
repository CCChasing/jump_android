import 'dart:convert';
import 'package:http/http.dart' as http;

class FaceLoginService {
  final String _baseUrl = 'http://10.1.20.216:8080';


  /// 调用后端接口提取人脸特征。
  /// 接口路径：/test/face
  Future<List<double>?> extractFaceFeatures({required String base64Image}) async {
    try {
      final url = Uri.parse('$_baseUrl/test/face');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'image': base64Image}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['data'] != null && jsonResponse['data']['embedding'] != null) {
          final List<dynamic> embeddingList = jsonResponse['data']['embedding'];
          return embeddingList.cast<double>();
        } else {
          return null;
        }
      } else {
        print('提取人脸特征失败。状态码: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('特征提取时发生错误: $e');
      return null;
    }
  }

  /// 调用后端接口进行人脸登录。
  /// 接口路径：/auth/login/face
  Future<bool> faceLogin({required List<double> faceFeature}) async {
    try {
      // 关键改动：更新接口路径
      final url = Uri.parse('$_baseUrl/auth/login/face');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        // 关键改动：更新请求参数的键名
        body: jsonEncode({'faceFeature': faceFeature}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        // 关键改动：根据响应示例判断登录成功
        return jsonResponse['code'] == 200;
      } else {
        print('人脸登录请求失败。状态码: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('人脸登录时发生错误: $e');
      return false;
    }
  }
}