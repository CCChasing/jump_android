import 'package:flutter/material.dart';

/// 排行榜页面
class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('排行榜'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          '这里是排行榜内容',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
