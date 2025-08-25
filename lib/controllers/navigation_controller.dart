import 'package:flutter/material.dart';

/// 导航控制器，管理底部导航栏的选中索引
class NavigationController extends ChangeNotifier {
  int _selectedIndex = 0; // 当前选中的索引，默认为第一个页面

  /// 获取当前选中的索引
  int get selectedIndex => _selectedIndex;

  /// 当底部导航栏的项被点击时调用
  /// [index] 被点击项的索引
  void onItemTapped(int index) {
    if (_selectedIndex != index) {
      _selectedIndex = index;
      notifyListeners(); // 通知所有监听器更新UI
    }
  }
}
