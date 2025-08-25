library;

import '../data_stream/video_stream_capture.dart';
import 'base_repository.dart';

/// ## RepositoryFactory
///
/// ### RepositoryFactory is a factory class which creates a global instance for each repository.
///
/// The RepositoryFactory manages all repository instances and provides an access to each one
class RepositoryFactory {

  /// List of all the created repositories
  static final List<BaseRepository> _repositoryList = <BaseRepository>[];

  // 静态变量，用于存储 VideoStreamCapture 的单例实例。
  // 注意：这个实例也会被添加到 _repositoryList 中。
  static VideoStreamCapture? _videoStreamCaptureInstance;

  /// Add a repoistory to the factory
  ///
  /// Note: This method is typically used internally by the factory to register created repositories.
  static void _addToFactory(BaseRepository refRepository){ // 改为私有方法，由工厂内部管理
    if( !_repositoryList.contains(refRepository) ){
      _repositoryList.add(refRepository);
    }
  }

  /// 获取视频流数据仓库的单例实例。
  /// 如果实例尚未创建，则创建一个新的 VideoStreamCaptureFromCamera 实例，并将其添加到工厂列表中。
  /// 返回的是抽象的 VideoStreamCapture 接口，使用者无需关心具体实现。
  static VideoStreamCapture getVideoStreamRepository() {
    if (_videoStreamCaptureInstance == null) {
      _videoStreamCaptureInstance = VideoStreamCaptureFromCamera(width: 640, height: 480); // 示例尺寸
      _addToFactory(_videoStreamCaptureInstance!); // 将其添加到统一管理列表
      print('RepositoryFactory: Created and provided VideoStreamCapture instance.');
    } else {
      print('RepositoryFactory: Providing existing VideoStreamCapture instance.');
    }
    return _videoStreamCaptureInstance!;
  }

  // 您可以在这里添加其他获取不同类型数据仓库的方法，并确保它们也通过 _addToFactory 注册。
  // 例如：
  // static JumpRopeRepository getJumpRopeRepository() {
  //   if (_jumpRopeRepositoryInstance == null) {
  //     _jumpRopeRepositoryInstance = JumpRopeRepositoryImpl(); // 假设 JumpRopeRepositoryImpl 是具体实现
  //     _addToFactory(_jumpRopeRepositoryInstance!);
  //     print('RepositoryFactory: Created and provided JumpRopeRepository instance.');
  //   } else {
  //     print('RepositoryFactory: Providing existing JumpRopeRepository instance.');
  //   }
  //   return _jumpRopeRepositoryInstance!;
  // }
  // static JumpRopeRepository? _jumpRopeRepositoryInstance;


  /// destroy all repository
  /// 遍历所有已注册的仓库，并调用它们的 freeRepository 方法来释放资源。
  @override // 标记为覆盖父类方法，尽管这里没有父类，但表示其职责
  static Future<void> freeAllRepository() async{
    print('RepositoryFactory: Freeing all repository resources...');
    for(var repos in _repositoryList){
      await repos.freeRepository(); // 调用每个仓库的 freeRepository 方法
    }
    _repositoryList.clear(); // 清空列表
    _videoStreamCaptureInstance = null; // 确保特定实例也置空
    // _jumpRopeRepositoryInstance = null; // 如果有其他特定实例，也置空
    print('RepositoryFactory: All repository resources freed.');
  }
}
