import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

class FaceRecognitionService {
  final String _baseUrl = 'http://10.1.20.216:8080';


  Future<List<double>?> extractFaceFeatures(CameraImage image) async {
    try {
      // 注意：这里需要一个正确的实现来将 CameraImage 转换为 JPEG 字节。
      // 因为 CameraImage 是 YUV 格式，你需要将其转换为 RGB 再编码为 JPEG。
      final bytes = await _convertCameraImageToJpeg(image);
      final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';

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
          print('人脸特征提取成功。');
          print(embeddingList);
          return embeddingList.cast<double>();
        } else {
          print('API响应缺少嵌入数据。');
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

  /// 将 CameraImage (YUV420) 转换为 JPEG 字节。
  Future<Uint8List> _convertCameraImageToJpeg(CameraImage image) async {
    final int width = image.width;
    final int height = image.height;

    final img.Image rgbImage = img.Image(width: width, height: height, numChannels: 3);

    final Uint8List yPlane = image.planes[0].bytes;
    final Uint8List uPlane = image.planes[1].bytes;
    final Uint8List vPlane = image.planes[2].bytes;

    final int uvRowStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel ?? 1;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int uvX = x ~/ 2;
        final int uvY = y ~/ 2;
        final int yIndex = y * image.planes[0].bytesPerRow + x;
        final int uIndex = uvY * uvRowStride + uvX * uvPixelStride;
        final int vIndex = uvY * uvRowStride + uvX * uvPixelStride;

        final int yValue = yPlane[yIndex];
        final int uValue = uPlane[uIndex];
        final int vValue = vPlane[vIndex];

        final int c = yValue - 16;
        final int d = uValue - 128;
        final int e = vValue - 128;

        int red = (298 * c + 409 * e + 128) >> 8;
        int green = (298 * c - 100 * d - 208 * e + 128) >> 8;
        int blue = (298 * c + 516 * d + 128) >> 8;

        red = red.clamp(0, 255);
        green = green.clamp(0, 255);
        blue = blue.clamp(0, 255);

        rgbImage.setPixelRgb(x, y, red, green, blue);
      }
    }

    return Uint8List.fromList(img.encodeJpg(rgbImage));
  }
}