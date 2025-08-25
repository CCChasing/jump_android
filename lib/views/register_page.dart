import 'package:flutter/material.dart';
import '../controllers/register_controller.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late final RegisterController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RegisterController();
    _controller.avatarImage = null;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFFFFFFFF);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: backgroundColor,
            ),
          ),
          // top_logo
          Positioned(
            top: 60,
            left: 50,
            right: 50,
            child: Container(
              height: 15,
              decoration: BoxDecoration(
                color: const Color(0xFFA8E7E7),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Positioned(
            top: 90,
            left: 25,
            right: 25,
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                color: const Color(0xFFA8E7E7),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          // bottom_logo
          Positioned(
            bottom: -50,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: const Color(0xFFB3E0EB).withOpacity(0.4),
                borderRadius: BorderRadius.circular(125),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: 50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: const Color(0xFFD3C5F8).withOpacity(0.4),
                borderRadius: BorderRadius.circular(150),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      _buildInputBox(
                        hintText: '用户名',
                        controller: _controller.usernameController,
                      ),
                      const SizedBox(height: 20),
                      _buildInputBox(
                        hintText: '真实姓名',
                        controller: _controller.realnameController,
                      ),
                      const SizedBox(height: 20),
                      _buildGenderDropdown(),
                      const SizedBox(height: 20),
                      _buildInputBox(
                        hintText: '密码',
                        controller: _controller.passwordController,
                        isPassword: true,
                      ),
                      const SizedBox(height: 20),
                      _buildInputBox(
                        hintText: '请再次输入密码',
                        controller: _controller.confirmPasswordController,
                        isPassword: true,
                      ),
                      const SizedBox(height: 20),
                      _buildFaceRecognitionButton(),
                      const SizedBox(height: 20),
                      _buildRegisterButton(),
                      const SizedBox(height: 15),
                      _buildLoginLink(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 105, left: 40, right: 40, bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //button_back
          GestureDetector(
            onTap: () => _controller.onBackButtonPressed(context),
            child: const Icon(Icons.arrow_back, color: Colors.black),
          ),
          const SizedBox(width: 0),
          //text_welcome
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),
              const Text(
                '您好, 欢迎注册',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'Superbold',
                ),
              ),
            ],
          ),

          //button_UploadAvatar
          const Spacer(),
          GestureDetector(
            onTap: () async {
              await _controller.onUploadAvatarPressed();
              if (mounted) {
                setState(() {});
              }
            },
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xFFC4B2F6),
                image: _controller.avatarImage != null
                    ? DecorationImage(
                  image: FileImage(_controller.avatarImage!),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: _controller.avatarImage == null
                  ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person, size: 70, color: Colors.white),
                  SizedBox(height: 4),
                  Text(
                    '点击上传头像',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontFamily: 'Superbold',
                    ),
                  ),
                ],
              )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBox({
    required String hintText,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFD3C5F8), width: 5),
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
          hintStyle: const TextStyle(
            color: Color(0xFFCCCCCC),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Superbold',
          ),
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

  Widget _buildGenderDropdown() {
    return Container(
      width: 320,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFD3C5F8), width: 5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButton<String>(
              value: _controller.selectedGender,
              hint: Text(
                '性别',
                style: TextStyle(
                  color: const Color(0xFFCCCCCC),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Superbold',
                ),
              ),
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFFD3C5F8)),
              iconSize: 24,
              underline: Container(),
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Superbold',
              ),
              items: ['male', 'female'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value == 'male' ? '男' : '女',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Superbold',
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _controller.onGenderChanged(newValue);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaceRecognitionButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: _controller.isLoading,
      builder: (context, isLoading, child) {
        return Container(
          width: 320,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFFC4B2F6), width: 5),
          ),
          child: ElevatedButton(
            onPressed: isLoading ? null : () => _controller.onFaceRecognitionButtonPressed(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: isLoading
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3.0,
              ),
            )
                : const Text(
              '录入人脸信息',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF9C7CFB),
                fontWeight: FontWeight.bold,
                fontFamily: 'Superbold',
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRegisterButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: _controller.isLoading,
      builder: (context, isLoading, child) {
        return Container(
          width: 320,
          decoration: BoxDecoration(
            color: const Color(0xFFC4B2F6),
            borderRadius: BorderRadius.circular(30),
          ),
          child: ElevatedButton(
            onPressed: isLoading ? null : () => _controller.onRegisterPressed(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: isLoading
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3.0,
              ),
            )
                : const Text(
              '注册',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Superbold',
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoginLink() {
    return GestureDetector(
      onTap: () => _controller.onLoginLinkPressed(context),
      child: const Text(
        '已有账号？去登录>',
        style: TextStyle(
          color: Color(0xFF9C7CFB),
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Superbold',
        ),
      ),
    );
  }
}