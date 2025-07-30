import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 导入 provider 包
import 'package:jump/controllers/navigation_controller.dart'; // 导入导航控制器
import 'package:jump/views/exercise_page.dart'; // 导入运动页面
import 'package:jump/views/leaderboard_page.dart'; // 导入排行榜页面
import 'package:jump/views/user_center_page.dart'; // 导入用户中心页面

/// 应用的主屏幕，包含底部导航栏和页面切换逻辑
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // 定义底部导航栏对应的页面列表
  final List<Widget> _pages = const [
    ExercisePage(),      // 运动页面
    LeaderboardPage(),   // 排行榜页面
    UserCenterPage(),    // 用户中心页面
  ];

  @override
  Widget build(BuildContext context) {
    // 使用 Consumer 监听 NavigationController 的变化
    return Consumer<NavigationController>(
      builder: (context, controller, child) {
        return Scaffold(
          // 使用 IndexedStack 来保持页面状态，避免每次切换时重新构建
          body: IndexedStack(
            index: controller.selectedIndex, // 根据控制器选中的索引显示对应页面
            children: _pages,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: controller.selectedIndex, // 当前选中的导航项
            onTap: controller.onItemTapped, // 点击导航项时调用控制器的方法
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.fitness_center), // 运动图标
                label: '运动', // 运动标签
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.leaderboard), // 排行榜图标
                label: '排行榜', // 排行榜标签
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person), // 用户中心图标
                label: '用户中心', // 用户中心标签
              ),
            ],
          ),
        );
      },
    );
  }
}
