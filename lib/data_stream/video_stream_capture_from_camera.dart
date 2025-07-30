
part of video_stream_capture_lib;

class VideoStreamCaptureFromCamera extends VideoStreamCapture {
  /// Frame's size
  int _width = 800, _height = 600;

  /// Camera controller from the `camera` plugin
  CameraController? _cameraController;

  /// Constructor with the specified frame size
  VideoStreamCaptureFromCamera({int width = 800, int height = 600})
      : _width = width,
        _height = height;

  /// {@macro start_implement}
  @override
  Future<bool> _startImplement() async {
    // 1. Check if a default camera exists
    bool hasCamera = await _checkCameraAvailability();

    if (!hasCamera) return false;

    try {
      // 2. Get available cameras
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        print('No cameras available.');
        return false;
      }
      // 通常选择第一个后置摄像头
      final CameraDescription cameraDescription = cameras.first;

      // 3. Initialize CameraController
      // 根据你的需求选择分辨率和图像格式
      // 注意：camera 插件通常提供 YUV420_888 格式的图像数据，可能需要自行转换到 RGB
      _cameraController = CameraController(
        cameraDescription,
        ResolutionPreset.medium, // 或 .high, .max, 根据需要调整
        enableAudio: false, // 摄像头视频流通常不需要音频
        imageFormatGroup: ImageFormatGroup.yuv420, // 获取 YUV 格式数据
      );

      await _cameraController!.initialize();

      if (!_cameraController!.value.isInitialized) {
        print('Camera controller not initialized.');
        return false;
      }

      // 获取实际的视频尺寸
      _width = _cameraController!.value.previewSize?.width.toInt() ?? _width;
      _height = _cameraController!.value.previewSize?.height.toInt() ?? _height;

      // 4. Start image stream
      // 监听图像数据流，每当有新帧可用时，将其存入 _curFrameData
      _cameraController!.startImageStream((CameraImage image) {
        // 只有当上一次的数据被读取后，才更新新数据，避免数据覆盖
        if (!_curFrameData.isNewData) {
          // 这里需要处理 CameraImage 到 VideoFrameData 的转换
          // CameraImage 通常是 YUV 格式，如果需要 RGB，这里需要进行转换。
          // 简化的处理：直接将 YUV 数据的第一个 plane 的 bytes 作为图像数据
          final Uint8List bytes = image.planes[0].bytes;
          final int width = image.width;
          final int height = image.height;

          // TODO: 如果需要 RGB 数据，这里需要实现 YUV 到 RGB 的转换
          // 可以考虑使用第三方库如 `image` 或 `image_converter`
          // 例如：
          // final img.Image? rgbImage = convertYUV420toRGBA(image);
          // if (rgbImage != null) {
          //    final Uint8List rgbBytes = Uint8List.fromList(img.encodePng(rgbImage));
          //    _curFrameData = (timestamp: _curFrameData.timestamp + 1, curFrameData: VideoFrameData(bytes: rgbBytes, width: width, height: height), isNewData: true);
          // }

          _curFrameData = (
          timestamp: _curFrameData.timestamp + 1,
          curFrameData: VideoFrameData(bytes: bytes, width: width, height: height),
          isNewData: true,
          );
        }
      });

      print('✅ Camera stream started successfully. Actual size: $_width x $_height');
      return true;
    } catch (e) {
      print('❌ Error starting camera stream: $e');
      return false;
    }
  }

  /// {@macro stop_implement}
  @override
  Future<void> _stopImplement() async {
    if (_cameraController != null) {
      if (_cameraController!.value.isStreamingImages) {
        await _cameraController!.stopImageStream();
      }
      await _cameraController!.dispose();
      _cameraController = null;
      print('Camera stream stopped and disposed.');
    }
  }

  /// {@macro read_current_data}
  @override
  Future<void> _readCurrentDataAsyn() async {
    // 在 mobile 端，startImageStream 已经将新数据直接存入 _curFrameData
    // 所以这里不需要额外的异步读取操作
    // _fetchCurrentData 逻辑会检查 _curFrameData.isNewData 来决定是否返回数据
    // 并触发下一次的数据读取（通过 startImageStream 的回调）
    return;
  }

  /// Check if camera is available
  @override
  Future<bool> _checkCameraAvailability() async {
    try {
      final cameras = await availableCameras();
      return cameras.isNotEmpty;
    } on CameraException catch (e) {
      print('Error checking camera availability: ${e.code}, ${e.description}');
      return false;
    } catch (e) {
      print('An unexpected error occurred while checking camera availability: $e');
      return false;
    }
  }

// TODO: 如果需要 YUV 到 RGB 转换，可以在这里添加辅助函数
// 例如，使用 `image` 库
/*
  img.Image? convertYUV420toRGBA(CameraImage image) {
    // 这是一个简化示例，实际转换可能更复杂，取决于具体的 YUV 格式
    // 并且需要处理 planeStride 和 pixelStride
    final int width = image.width;
    final int height = image.height;

    final img.Image rgbImage = img.Image(width: width, height: height);

    final Uint8List yPlane = image.planes[0].bytes;
    final Uint8List uPlane = image.planes[1].bytes;
    final Uint8List vPlane = image.planes[2].bytes;

    // 假设是 YUV420_888 格式
    // 这是一个非常简化的转换逻辑，实际应用中可能需要更精确的 YUV 到 RGB 转换算法
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int Y = yPlane[y * image.planes[0].bytesPerRow + x];
        final int U = uPlane[(y ~/ 2) * image.planes[1].bytesPerRow + (x ~/ 2)];
        final int V = vPlane[(y ~/ 2) * image.planes[2].bytesPerRow + (x ~/ 2)];

        // YUV to RGB conversion formula (simplified)
        int C = Y - 16;
        int D = U - 128;
        int E = V - 128;

        int R = (298 * C + 409 * E + 128) >> 8;
        int G = (298 * C - 100 * D - 208 * E + 128) >> 8;
        int B = (298 * C + 516 * D + 128) >> 8;

        R = R.clamp(0, 255);
        G = G.clamp(0, 255);
        B = B.clamp(0, 255);

        rgbImage.setPixelRgb(x, y, R, G, B);
      }
    }
    return rgbImage;
  }
  */
}