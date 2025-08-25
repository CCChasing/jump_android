import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/register_service.dart';
import '../views/login_page.dart';
import '../views/face_recognition_page.dart';

class RegisterController {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController realnameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  String? selectedGender;
  final RegisterService _registerService = RegisterService();
  File? avatarImage;
  List<double>? faceFeature; // 新增字段，用于存储人脸特征

  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<bool> hasFaceFeature = ValueNotifier(false); // 新增状态，表示是否已获取人脸特征

  void onGenderChanged(String? newValue) {
    selectedGender = newValue;
  }

  Future<void> onUploadAvatarPressed() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      avatarImage = File(pickedFile.path);
      // 由于 Controller 不直接持有 State，我们将在 View 中监听该变量的变化
    }
  }

  Future<void> onRegisterPressed(BuildContext context) async {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('用户名和密码不能为空！')),
      );
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('两次输入的密码不一致！')),
      );
      return;
    }

    isLoading.value = true;

    String? avatarPath;
    if (avatarImage != null) {
      avatarPath = await _registerService.uploadAvatar(avatarImage!);
      if (avatarPath == null) {
        isLoading.value = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('头像上传失败，请重试')),
        );
        return;
      }
    }

    final success = await _registerService.registerUser(
      username: usernameController.text,
      realname: realnameController.text,
      password: passwordController.text,
      gender: selectedGender,
      avatar: avatarPath,
      faceFeature: faceFeature, // 传入人脸特征
    );

    isLoading.value = false;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('注册成功！正在跳转到登录页面...')),
      );
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
              (Route<dynamic> route) => false,
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('注册失败，请检查您的信息')),
      );
    }
  }

  void onLoginLinkPressed(BuildContext context) {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  void onBackButtonPressed(BuildContext context) {
    Navigator.of(context).pop();
  }

  Future<void> onFaceRecognitionButtonPressed(BuildContext context) async {
    // 导航到人脸识别页面并等待返回值
    final result = await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const FaceRecognitionPage()));

    // 如果返回值是 List<double> 类型，则更新 faceFeature
    if (result != null && result is List<double>) {
      faceFeature = result;
      hasFaceFeature.value = true;
      print('成功获取人脸特征，长度: ${faceFeature!.length}');
    } else {
      // 否则，舍弃人脸特征
      faceFeature = null;
      hasFaceFeature.value = false;
      print('未获取到人脸特征，或用户取消。');
    }
  }

  void dispose() {
    usernameController.dispose();
    realnameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    isLoading.dispose();
    hasFaceFeature.dispose();
  }
}