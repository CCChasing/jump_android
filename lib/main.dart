import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For MethodChannel
import 'package:jump/scene_repository/repository_factory.dart';
import 'package:provider/provider.dart'; // 导入 provider 包
import 'dart:async';
import 'dart:convert';

// 新的 MVC 结构导入
import 'package:jump/controllers/navigation_controller.dart'; // 导入导航控制器
import 'package:jump/views/home_screen.dart';

import 'features/command_factory.dart'; // 导入主屏幕视图

/// 应用的入口函数
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 确保 Flutter 绑定初始化

  runApp(const MyApp()); // 运行 Flutter 应用

}


/// 执行清理操作的函数
/// 这部分逻辑通常在应用生命周期结束时调用
Future<void> doCleanup() async {
  await CommandFactory.stopAllLiveCmd();
  await RepositoryFactory.freeAllRepository();
}

/// 应用的根 Widget
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

/// MyApp 的状态类，处理应用生命周期
class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // 监听应用生命周期
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // 移除生命周期监听
    super.dispose();
  }

  /// 当应用生命周期状态改变时调用
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // 当应用进入后台或被销毁时，执行清理操作
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      print('App is paused or detached, cleaning up...');
      doCleanup();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 使用 MultiProvider 来提供多个控制器/模型
    return MultiProvider(
      providers: [
        // 提供 NavigationController 实例，使其在整个应用中可用
        ChangeNotifierProvider(create: (_) => NavigationController()),
        // 如果有其他控制器或数据模型，可以在这里添加
      ],
      child: MaterialApp(
        title: 'Unity in Flutter',
        debugShowCheckedModeBanner: false, // 禁用调试横幅
        theme: ThemeData(
          primarySwatch: Colors.blue, // 设置主题主色
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const HomeScreen(), // 将 HomeScreen 设置为应用的起始页面
      ),
    );
  }
}
