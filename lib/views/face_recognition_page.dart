import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../data_stream/video_stream_capture.dart';
import '../scene_repository/repository_factory.dart';
import '../services/face_recognition_service.dart';

class FaceRecognitionPage extends StatefulWidget {
  const FaceRecognitionPage({super.key});

  @override
  State<FaceRecognitionPage> createState() => _FaceRecognitionPageState();
}

class _FaceRecognitionPageState extends State<FaceRecognitionPage> {
  VideoStreamCapture? _videoStreamCapture;
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  FaceDetector? _faceDetector;
  List<Face> _detectedFaces = [];
  InputImageRotation _cameraRotation = InputImageRotation.rotation0deg;
  CameraLensDirection? _cameraLensDirection;
  bool _isProcessing = false;
  bool _isFrozen = false;
  bool _isExtracting = false;
  List<double>? _extractedEmbedding;

  final FaceRecognitionService _faceRecognitionService = FaceRecognitionService();

  @override
  void initState() {
    super.initState();
    _initializeCameraAndFaceDetector();
  }

  Future<void> _initializeCameraAndFaceDetector() async {
    final options = FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
      enableClassification: true,
      minFaceSize: 0.1,
      performanceMode: FaceDetectorMode.fast,
    );
    _faceDetector = FaceDetector(options: options);

    try {
      _videoStreamCapture = RepositoryFactory.getVideoStreamRepository();
      _cameraController = _videoStreamCapture!.cameraController;

      if (_cameraController == null || !_cameraController!.value.isInitialized) {
        final cameras = await availableCameras();
        final CameraDescription cameraDescription = cameras.firstWhere(
              (camera) => camera.lensDirection == CameraLensDirection.back,
          orElse: () => cameras.first,
        );
        _cameraLensDirection = cameraDescription.lensDirection;
        _cameraRotation = _rotationIntToInputImageRotation(cameraDescription.sensorOrientation);

        final success = await _videoStreamCapture!.start((timestamp, cameraImage) async {
          if (_isFrozen || _isProcessing) return;

          _isProcessing = true;

          final inputImage = _inputImageFromCameraImage(cameraImage);
          if (inputImage == null) {
            _isProcessing = false;
            return;
          }

          final faces = await _faceDetector!.processImage(inputImage);
          setState(() {
            _detectedFaces = faces;
          });

          if (faces.isNotEmpty && !_isFrozen) {
            setState(() {
              _isFrozen = true;
            });
            await _cameraController?.stopImageStream();
            print('检测到人脸！摄像头流已冻结。');

            _extractFaceFeatures(cameraImage);
          }

          _isProcessing = false;
        }, fps: 30);

        if (success) {
          _cameraController = _videoStreamCapture!.cameraController;
          if (_cameraController != null && _cameraController!.value.isInitialized) {
            setState(() {
              _isCameraInitialized = true;
            });
          } else {
            print('错误：摄像头控制器在流启动后未初始化。');
          }
        } else {
          print('错误：无法启动视频流捕获。');
        }
      } else {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      print('初始化摄像头或人脸检测器时发生错误: $e');
    }
  }

  Future<void> _extractFaceFeatures(CameraImage image) async {
    if (_isExtracting) return;

    setState(() {
      _isExtracting = true;
      _extractedEmbedding = null;
    });

    try {
      final embedding = await _faceRecognitionService.extractFaceFeatures(image);
      setState(() {
        _extractedEmbedding = embedding;
      });
      if (embedding != null) {
        print('人脸特征提取成功。');
        // 返回特征向量到上一页面
        Navigator.of(context).pop(embedding);
      } else {
        print('提取人脸特征失败。');
      }
    } catch (e) {
      print('特征提取时发生错误: $e');
    } finally {
      setState(() {
        _isExtracting = false;
      });
    }
  }

  Future<void> _restartCamera() async {
    if (_cameraController == null) return;

    setState(() {
      _detectedFaces = [];
      _isFrozen = false;
      _extractedEmbedding = null;
    });

    if (!_cameraController!.value.isStreamingImages) {
      await _cameraController!.startImageStream((cameraImage) async {
        if (_faceDetector == null || !_isCameraInitialized) return;
        if (_isFrozen || _isProcessing) return;

        _isProcessing = true;

        final inputImage = _inputImageFromCameraImage(cameraImage);
        if (inputImage == null) {
          _isProcessing = false;
          return;
        }

        final faces = await _faceDetector!.processImage(inputImage);
        setState(() {
          _detectedFaces = faces;
        });

        if (faces.isNotEmpty && !_isFrozen) {
          setState(() {
            _isFrozen = true;
          });
          await _cameraController?.stopImageStream();
          print('检测到人脸！摄像头流已冻结。');
          _extractFaceFeatures(cameraImage);
        }

        _isProcessing = false;
      });
      print('摄像头流已重新启动。');
    }
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
  void dispose() {
    _videoStreamCapture?.freeRepository();
    _faceDetector?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized || _cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final size = MediaQuery.of(context).size;
    final double aspectRatio = _cameraController!.value.aspectRatio;
    double cameraWidth = size.width;
    double cameraHeight = cameraWidth / aspectRatio;

    if (cameraHeight < size.height) {
      cameraHeight = size.height;
      cameraWidth = cameraHeight * aspectRatio;
    }

    final double circleDiameter = size.width * 0.7;

    return Scaffold(
      appBar: AppBar(
        title: const Text('人脸识别'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: SizedBox(
              width: cameraWidth,
              height: cameraHeight,
              child: CameraPreview(_cameraController!),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: FaceDetectorPainter(
                _detectedFaces,
                _cameraController!.value.previewSize!,
                _cameraRotation,
                MediaQuery.of(context).size,
                _cameraLensDirection,
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: FullScreenCircleMaskPainter(
                circleDiameter: circleDiameter,
                maskColor: Colors.black54,
              ),
            ),
          ),
          Center(
            child: Container(
              width: circleDiameter,
              height: circleDiameter,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 4.0,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Text(
              _isFrozen ? '人脸已捕捉' : '请将人脸置于圆形框内',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 5.0,
                    color: Colors.black.withOpacity(0.5),
                    offset: const Offset(2.0, 2.0),
                  ),
                ],
              ),
            ),
          ),
          if (_isFrozen)
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: Center(
                child: _isExtracting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : ElevatedButton.icon(
                  onPressed: () {
                    if (_extractedEmbedding != null) {
                      Navigator.of(context).pop(_extractedEmbedding);
                    } else {
                      _restartCamera();
                    }
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('重新开始'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                ),
              ),
            ),
          if (_extractedEmbedding != null)
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '提取到的特征向量:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _extractedEmbedding!.take(5).toString() + '...',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
        ],
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
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