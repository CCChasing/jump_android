import 'package:flutter/material.dart';
// 导入 main.dart 以访问 sendGameConfigToUnity 函数
import 'package:jump/main.dart';

/// 运动页面，显示“hi jump”文本和 Unity 游戏内容
class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key});

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  //UnityWidgetController? _unityWidgetController; // 用于控制 Unity 实例

  @override
  void dispose() {
    //_unityWidgetController?.dispose(); // 页面销毁时释放 Unity 控制器资源
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('运动'),
        centerTitle: true, // 标题居中
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'hi jump',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20), // 添加一些垂直间距

            // Unity 游戏内容区域
            // Expanded(
            //   child: UnityWidget(
            //     // 当 Unity 实例创建完成时调用
            //     onUnityCreated: (controller) {
            //       _unityWidgetController = controller;
            //       // 调用 main.dart 中的函数发送游戏配置到 Unity
            //       sendGameConfigToUnity(_unityWidgetController);
            //     },
            //     // 您可能需要根据您的 Unity 项目构建路径进行配置
            //     // 例如：unityProjectPath: 'path/to/your/unity/project'
            //     // 如果您已经通过 flutter_unity_widget 的集成步骤将 Unity 项目构建为库
            //     // 则通常不需要指定此路径，插件会自动找到
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
