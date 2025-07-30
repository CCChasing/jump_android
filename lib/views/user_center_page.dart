import 'package:flutter/material.dart';

/// 用户中心页面
class UserCenterPage extends StatelessWidget {
  const UserCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('用户中心'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          '这里是用户中心内容',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
