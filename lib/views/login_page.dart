import 'package:flutter/material.dart';
import '../controllers/login_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final LoginController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LoginController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //get_screenHeight
    final screenHeight = MediaQuery.of(context).size.height;

    //background
    const Gradient backgroundGradient = LinearGradient(
      colors: [Color(0xFFAFDFFA), Color(0xFFE8EAF6)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      body: Container(
        height: screenHeight,
        decoration: const BoxDecoration(
          gradient: backgroundGradient,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 180),
              //top_Logo
              Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Color(0xB091DFE7),
                  ),
                  Transform.translate(
                    offset: Offset(-20,0),
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: Color(0xB0A8A5FA),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              //text_welcome
              const Text(
                '您好, 欢迎登录!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Superbold',
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 60),
              //input_username
              _buildInputBox(
                hintText: '用户名',
                controller: _controller.usernameController,
              ),
              const SizedBox(height: 30),
              //input_password
              _buildInputBox(
                hintText: '密码',
                controller: _controller.passwordController,
                isPassword: true,
              ),
              const SizedBox(height: 12),
              //context
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => _controller.onFaceLoginPressed(context),
                    child: const Text(
                      '人脸识别登录',
                      style: TextStyle(
                        color: Color(0xFF9C7CFB),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Superbold',
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _controller.onForgotPasswordPressed(context),
                    child: const Text(
                      '忘记密码?',
                      style: TextStyle(
                        color: Color(0xFF9C7CFB),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Superbold',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),
              //button_login
              _buildLoginButton(),
              const SizedBox(height: 20),
              //context_register
              Center(
                child: GestureDetector(
                  onTap: () => _controller.onRegisterLinkPressed(context),
                  child: const Text(
                    '还没有账号？去注册>',
                    style: TextStyle(
                      color: Color(0xFF9C7CFB),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Superbold',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputBox({
    required String hintText,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFFCCCCCC)),
          border: InputBorder.none,
        ),
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Superbold',
          color: Colors.black87,
        ),
        keyboardType: isPassword ? TextInputType.visiblePassword : TextInputType.text,
      ),
    );
  }

  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFC4B2F6),
        borderRadius: BorderRadius.circular(30),
      ),
      child: ElevatedButton(
        onPressed: () => _controller.onLoginPressed(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          '登录',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Superbold',
          ),
        ),
      ),
    );
  }
}