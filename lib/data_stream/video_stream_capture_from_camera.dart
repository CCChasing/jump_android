// ignore: use_string_in_part_of_directives
/// **Author**: wwyang
/// **Date**: 2025.5.2
/// **Copyright**: Multimedia Lab, Zhejiang Gongshang University
/// **Version**: 1.0
///
/// This program is free software: you can redistribute it and/or modify
/// it under the terms of the GNU General Public License as published by
/// the Free Software Foundation, either version 3 of the License, or
/// (at your option) any later version).
///
/// This program is distributed in the hope that it will be useful,
/// but WITHOUT ANY WARRANTY; without even the implied warranty of
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
/// GNU General Public License for more details.
///
/// You should have received a copy of the GNU General Public License
/// along with this program. If not, see <http://www.gnu.org/licenses/>.
part of video_stream_capture_lib; // Note: Only 'part of' directive here

/// ## VideoStreamCaptureFromCamera
///
/// ### Instanceclass of the Video Data Stream Generator
///
/// This class is used for generating the data stream from a camera. This version is for mobile application
///
/// Example usage:
///
/// ```dart
/// // Create a camera data capturer with the frame size [800, 600]
/// VideoStreamCaptureFromCamera captureCamera = VideoStreamCaptureFromCamera(width: 800, height: 600);
///
/// bool isStart = false;
/// CameraImage curFrameData; // Changed to CameraImage
/// try{
///    // Begin to capture the camera data by 25 FPS
///    isStart = await captureCamera.start((int timestamp, CameraImage frameData) { // Changed to CameraImage
///         // Obtain and process the per-frame data
///         curFrameData = frameData;
///    }, fps: 25);
///  }catch(e){
///    print('Errors occur when opening the camera video stream');
///  }
/// ```
class VideoStreamCaptureFromCamera extends VideoStreamCapture {
  /// Frame's size
  int _width = 800, _height = 600;

  /// Camera controller from the `camera` plugin
  CameraController? _cameraController;

  /// Constructor with the specified frame size
  VideoStreamCaptureFromCamera({int width = 800, int height = 600})
      : _width = width,
        _height = height;

  /// Provides access to the internal CameraController instance.
  /// This is required by the abstract VideoStreamCapture class.
  @override
  CameraController? get cameraController => _cameraController;

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
      // Usually select the first back camera
      final CameraDescription cameraDescription = cameras.first;

      // 3. Initialize CameraController
      // Select resolution and image format based on your needs
      // Note: The camera plugin usually provides YUV420_888 format image data, which may need to be converted to RGB
      _cameraController = CameraController(
        cameraDescription,
        ResolutionPreset.medium, // Or .high, .max, adjust as needed
        enableAudio: false, // Camera video stream usually does not require audio
        imageFormatGroup: ImageFormatGroup.yuv420, // Get YUV format data
      );

      await _cameraController!.initialize();

      if (!_cameraController!.value.isInitialized) {
        print('Camera controller not initialized.');
        return false;
      }

      // Get actual video dimensions
      _width = _cameraController!.value.previewSize?.width.toInt() ?? _width;
      _height = _cameraController!.value.previewSize?.height.toInt() ?? _height;

      // 4. Start image stream
      // Listen to the image data stream, and store it in _curFrameData whenever a new frame is available
      _cameraController!.startImageStream((CameraImage image) {
        // Only update new data when the previous data has been read, to avoid data overwrite
        if (!_curFrameData.isNewData) {
          _curFrameData = (
          timestamp: _curFrameData.timestamp + 1,
          curFrameData: image, // Store CameraImage directly
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
    // On mobile, startImageStream has already stored new data directly into _curFrameData
    // So no additional asynchronous read operation is needed here
    // _fetchCurrentData logic will check _curFrameData.isNewData to decide whether to return data
    // And trigger the next data read (via startImageStream callback)
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
}
