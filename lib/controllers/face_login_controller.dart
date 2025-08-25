import 'package:flutter/material.dart';

import '../services/face_login_service.dart';
import '../views/login_page.dart';

class FaceLoginController {
  final FaceLoginService _faceLoginService = FaceLoginService();

  Future<bool> processFaceRecognitionAndLogin({
    required BuildContext context,
    required String base64Image,
  }) async {
    try {
      // 1. 调用服务层，提取人脸特征
      final faceFeature = await _faceLoginService.extractFaceFeatures(base64Image: base64Image);

      if (faceFeature != null) {
        print('成功获取人脸特征，正在尝试登录...');
        // 2. 调用服务层，进行人脸登录
        final success = await _faceLoginService.faceLogin(faceFeature: faceFeature);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('人脸登录成功！')),
          );
          // TODO: 登录成功后，导航到主页或其他页面
          // 这里我们只是为了示例，返回 true
          return true;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('人脸登录失败，请重试。')),
          );
          return false;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('提取人脸特征失败，请重试。')),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('人脸登录时发生错误: $e')),
      );
      return false;
    }
  }

  void onPasswordLoginLinkPressed(BuildContext context) {
    Navigator.of(context).pop();
  }
}