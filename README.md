# jump

A new Flutter project.

## 项目配置

在开始配置项目之前，请确保您的开发环境满足以下要求：

1. Flutter SDK： 稳定版（推荐最新稳定版）。

2. Android Studio (或 VS Code)： 用于 Flutter 开发。

3. Android SDK Platform 36 及以上： 必须安装。

4. Android NDK (Side by side) 27.0.12077973 或更高版本： 必须安装。


## 具体配置

1. 安装 flutter 依赖：进入项目根目录后，运行 flutter pub get 命令来安装所有 Dart/Flutter 依赖。

2. Android 平台配置：打开 Android Studio，进入 SDK Manager (可以通过 File > Settings > Appearance & Behavior > System Settings > Android SDK 或工具栏图标进入)。

  在 "SDK Platforms" 选项卡中，勾选并安装 "Android API 36"。

  在 "SDK Tools" 选项卡中，展开 "NDK (Side by side)"，勾选并安装 "27.0.12077973" 或任何更高的稳定版本（例如 29.x.x）。

  点击 Apply 或 OK 完成安装。

3. 配置 Android Studio 虚拟机：在 Device Manager 中下载 Medium Phone API 36。

4. 完成以上所有配置后，通过flutter run 在连接的设备或模拟器上运行应用程序。

## 项目结构说明
主要目录结构如下：

  lib/

    controllers/：存放控制器（或 ViewModel），负责处理业务逻辑和状态管理（例如 NavigationController）。

    data_stream/：存放视频流捕获相关的代码（例如 video_stream_capture.dart 和 video_stream_capture_from_camera.dart）。

    features/：存放应用的核心功能模块，例如命令模式的实现 (command_factory.dart)。
  
    scene_repository/：存放数据仓库的抽象和实现，负责数据访问和管理 (repository_factory.dart)。

    unity/：存放与 Unity 集成相关的辅助文件（例如 simple_parameters.dart）。

    views/：存放所有用户界面相关的 Widget（例如 home_screen.dart, exercise_page.dart 等）。

    main.dart：应用的入口文件，负责初始化 Flutter 应用、Provider 和生命周期管理。

