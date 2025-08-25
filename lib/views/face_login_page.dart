import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'dart:ui' as ui;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import '../controllers/face_login_controller.dart';

class FaceLoginPage extends StatefulWidget {
  const FaceLoginPage({Key? key}) : super(key: key);

  @override
  State<FaceLoginPage> createState() => _FaceLoginPageState();
}

class _FaceLoginPageState extends State<FaceLoginPage> {
  late final FaceLoginController _controller;

  CameraController? _cameraController;
  FaceDetector? _faceDetector;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  List<Face> _detectedFaces = [];
  InputImageRotation _cameraRotation = InputImageRotation.rotation0deg;
  CameraLensDirection? _cameraLensDirection;

  bool _isRecognizing = false;
  bool _isLoginSuccessful = false; // 新增状态变量

  // 定义中间区域的固定尺寸
  static const double _centralWidgetSize = 250;

  @override
  void initState() {
    super.initState();
    _controller = FaceLoginController();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector?.close();
    super.dispose();
  }

  Future<void> _startFaceRecognition() async {
    // 每次开始时都重置状态
    setState(() {
      _isRecognizing = true;
      _isLoginSuccessful = false;
    });

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception('未找到可用摄像头。');
      }

      final CameraDescription cameraDescription = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      _cameraLensDirection = cameraDescription.lensDirection;
      _cameraRotation = _rotationIntToInputImageRotation(cameraDescription.sensorOrientation);

      _cameraController = CameraController(
        cameraDescription,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      final options = FaceDetectorOptions(
        enableContours: true,
        enableLandmarks: true,
        enableClassification: true,
        minFaceSize: 0.1,
        performanceMode: FaceDetectorMode.fast,
      );
      _faceDetector = FaceDetector(options: options);

      setState(() {
        _isCameraInitialized = true;
      });

      _cameraController!.startImageStream((CameraImage image) async {
        if (_isProcessing || _isLoginSuccessful) return; // 新增：如果登录成功则停止处理
        _isProcessing = true;

        final inputImage = _inputImageFromCameraImage(image);
        if (inputImage == null) {
          _isProcessing = false;
          return;
        }

        final faces = await _faceDetector!.processImage(inputImage);
        setState(() {
          _detectedFaces = faces;
        });

        if (faces.isNotEmpty) {
          await _cameraController?.stopImageStream();
          final base64Image = await _convertCameraImageToBase64(image);

          final loginSuccess = await _controller.processFaceRecognitionAndLogin(
            context: context,
            base64Image: base64Image,
          );

          if (loginSuccess) {
            setState(() {
              _isLoginSuccessful = true; // 登录成功，更新状态
            });
            // 登录成功后，您可以选择进行页面跳转，例如：
            // Navigator.of(context).pushReplacementNamed('/home');
          } else {
            _resetState();
          }
        }

        _isProcessing = false;
      });
    } catch (e) {
      print('初始化摄像头或人脸检测器时发生错误: $e');
      if (mounted) {
        setState(() {
          _isRecognizing = false;
          _isLoginSuccessful = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('启动人脸识别失败: $e')),
        );
      }
    }
  }

  Future<void> _resetState() async {
    _cameraController?.dispose();
    setState(() {
      _isRecognizing = false;
      _isCameraInitialized = false;
      _isLoginSuccessful = false;
      _detectedFaces = [];
      _cameraController = null;
    });
  }

  Future<String> _convertCameraImageToBase64(CameraImage image) async {
    final int width = image.width;
    final int height = image.height;

    final img.Image rgbImage = img.Image(width: width, height: height, numChannels: 3);

    final Uint8List yPlane = image.planes[0].bytes;
    final Uint8List uPlane = image.planes[1].bytes;
    final Uint8List vPlane = image.planes[2].bytes;

    final int uvRowStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel ?? 1;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int uvX = x ~/ 2;
        final int uvY = y ~/ 2;
        final int yIndex = y * image.planes[0].bytesPerRow + x;
        final int uIndex = uvY * uvRowStride + uvX * uvPixelStride;
        final int vIndex = uvY * uvRowStride + uvX * uvPixelStride;

        final int yValue = yPlane.elementAt(yIndex);
        final int uValue = uPlane.elementAt(uIndex);
        final int vValue = vPlane.elementAt(vIndex);

        final int c = yValue - 16;
        final int d = uValue - 128;
        final int e = vValue - 128;

        int red = (298 * c + 409 * e + 128) >> 8;
        int green = (298 * c - 100 * d - 208 * e + 128) >> 8;
        int blue = (298 * c + 516 * d + 128) >> 8;

        red = red.clamp(0, 255);
        green = green.clamp(0, 255);
        blue = blue.clamp(0, 255);

        rgbImage.setPixelRgb(x, y, red, green, blue);
      }
    }
    final jpgBytes = img.encodeJpg(rgbImage);
    return 'data:image/jpeg;base64,${base64Encode(jpgBytes)}';
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final InputImageFormat inputImageFormat = InputImageFormat.yuv420;

    final InputImageMetadata metadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: _cameraRotation,
      format: inputImageFormat,
      bytesPerRow: image.planes[0].bytesPerRow,
    );

    final Uint8List allBytes = _concatenatePlanes(image.planes);

    return InputImage.fromBytes(
      bytes: allBytes,
      metadata: metadata,
    );
  }

  InputImageRotation _rotationIntToInputImageRotation(int rotation) {
    switch (rotation) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Gradient backgroundGradient = LinearGradient(
      colors: [Color(0xFFAFDFFA), Color(0xFFE8EAF6)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: backgroundGradient,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          children: [
            const SizedBox(height: 180),
            const Text(
              '您好, 欢迎登录!',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontFamily: 'Superbold',
              ),
            ),
            const SizedBox(height: 80),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isRecognizing ? _buildVideoView() : _buildInitialIcon(),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
            ),
            const SizedBox(height: 120),
            _buildFaceRecognitionButton(context),
            const SizedBox(height: 15),
            _buildPasswordLoginLink(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialIcon() {
    return SizedBox(
      key: const ValueKey<int>(0),
      width: _centralWidgetSize,
      height: _centralWidgetSize,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.face_retouching_natural,
            size: 120,
            color: Colors.black54,
          ),
          const SizedBox(height: 20),
          const Text(
            '检测开始后跟随动画完成指示动作',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Superbold',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVideoView() {
    if (_cameraController == null || !_isCameraInitialized) {
      return const SizedBox(
        key: ValueKey<int>(1),
        width: _centralWidgetSize,
        height: _centralWidgetSize,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SizedBox(
      key: const ValueKey<int>(1),
      width: _centralWidgetSize,
      height: _centralWidgetSize,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AspectRatio(
              aspectRatio: _cameraController!.value.aspectRatio,
              child: Transform.scale(
                scaleX: _cameraLensDirection == CameraLensDirection.front ? -1 : 1,
                child: CameraPreview(_cameraController!),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaceRecognitionButton(BuildContext context) {
    String buttonText = '开始人脸识别';
    if (_isLoginSuccessful) {
      buttonText = '识别成功';
    } else if (_isRecognizing) {
      buttonText = '正在识别...';
    }

    return GestureDetector(
      onTap: _isRecognizing || _isLoginSuccessful ? null : _startFaceRecognition,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: _isRecognizing || _isLoginSuccessful ? Colors.grey : const Color(0xFFC4B2F6),
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          buttonText,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Superbold',
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildPasswordLoginLink(BuildContext context) {
    return GestureDetector(
      onTap: _isRecognizing || _isLoginSuccessful ? null : () => _controller.onPasswordLoginLinkPressed(context),
      child: Text(
        '返回密码登录',
        style: TextStyle(
          color: _isRecognizing || _isLoginSuccessful ? Colors.grey : const Color(0xFF9C7CFB),
          fontSize: 14,
          fontWeight: FontWeight.bold,
          fontFamily: 'Superbold',
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}

class FullScreenCircleMaskPainter extends CustomPainter {
  final double circleDiameter;
  final Color maskColor;

  FullScreenCircleMaskPainter({
    required this.circleDiameter,
    this.maskColor = Colors.black54,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = circleDiameter / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);

    final Path fullPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final Path circlePath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));

    final Path finalPath = Path.combine(
      PathOperation.difference,
      fullPath,
      circlePath,
    );

    canvas.drawPath(
      finalPath,
      Paint()..color = maskColor,
    );
  }

  @override
  bool shouldRepaint(covariant FullScreenCircleMaskPainter oldDelegate) {
    final oldPainter = oldDelegate as FullScreenCircleMaskPainter;
    return oldPainter.circleDiameter != circleDiameter ||
        oldPainter.maskColor != maskColor;
  }
}

class FaceDetectorPainter extends CustomPainter {
  final List<Face> faces;
  final Size imageSize;
  final InputImageRotation rotation;
  final Size widgetSize;
  final CameraLensDirection? cameraLensDirection;

  FaceDetectorPainter(this.faces, this.imageSize, this.rotation, this.widgetSize, this.cameraLensDirection);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.red;

    double actualImageWidth = imageSize.width;
    double actualImageHeight = imageSize.height;

    if (rotation == InputImageRotation.rotation90deg || rotation == InputImageRotation.rotation270deg) {
      actualImageWidth = imageSize.height;
      actualImageHeight = imageSize.width;
    }

    final FittedSizes fittedSizes = applyBoxFit(BoxFit.cover, Size(actualImageWidth, actualImageHeight), widgetSize);
    final Size sourceSize = fittedSizes.source;
    final Size destinationSize = fittedSizes.destination;

    final double scaleFactor = destinationSize.width / sourceSize.width;
    final double dx = (widgetSize.width - destinationSize.width) / 2;
    final double dy = (widgetSize.height - destinationSize.height) / 2;

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scaleFactor);

    if (cameraLensDirection == CameraLensDirection.front) {
      canvas.scale(-1, 1);
      canvas.translate(-actualImageWidth, 0);
    }

    for (final face in faces) {
      final Rect boundingBox = face.boundingBox;
      canvas.drawRect(boundingBox, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    final oldPainter = oldDelegate as FaceDetectorPainter;
    return oldPainter.faces != faces ||
        oldPainter.imageSize != imageSize ||
        oldPainter.rotation != rotation ||
        oldPainter.widgetSize != widgetSize ||
        oldPainter.cameraLensDirection != cameraLensDirection;
  }
}