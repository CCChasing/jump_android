import 'package:flutter/material.dart';
import '../services/login_service.dart';
import '../views/face_login_page.dart';
import '../views/register_page.dart';

class LoginController {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final LoginService _loginService = LoginService();

  Future<void> onLoginPressed(BuildContext context) async {
    final String username = usernameController.text;
    final String password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('用户名和密码不能为空')),
      );
      return;
    }

    try {
      final user = await _loginService.login(
        username: username,
        password: password,
      );

      if (user != null) {
        // TODO: 登录成功后处理，例如保存用户信息和 token，并导航到主页
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('登录成功! 欢迎, ${user.username}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('登录失败，请检查用户名或密码')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('登录失败: $e')),
      );
    }
  }

  void onFaceLoginPressed(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const FaceLoginPage()),
    );
  }

  void onForgotPasswordPressed(BuildContext context) {
    // TODO: 导航到忘记密码页面
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('忘记密码被点击!')),
    );
  }

  void onRegisterLinkPressed(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  void onStartFaceRecognitionPressed(BuildContext context) {
    // TODO: 实现开始人脸识别的逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('开始人脸识别按钮被点击!')),
    );
  }

  void onPasswordLoginLinkPressed(BuildContext context) {
    Navigator.of(context).pop();
  }

  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
  }
}