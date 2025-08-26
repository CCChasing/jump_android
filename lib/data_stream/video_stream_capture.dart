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
library video_stream_capture_lib;

import 'dart:typed_data';
import 'dart:async';
import 'dart:core';
import 'package:camera/camera.dart'; // Import the camera plugin for CameraController and CameraImage
import 'dart:ui' as ui;

import '../scene_repository/base_repository.dart'; // Import dart:ui, if ImageByteFormat etc. are needed in part files

part 'video_stream_capture_from_camera.dart'; // Associate with the subclass file

/// ## VideoSteramCapture
///
/// ### Superclass of the Video Data Stream Generator
///
/// This class is used for generating the data stream. It provides an interface for fetching data from the
/// stream, while the data generation is handled internally, i.e., oblivious to the outer.
///
/// **Note**: The data in the stream is assumed to be an image.
///
/// The data stream can be from various sources such as a video sequence, camera, and others. A new class should
/// be derived for each source where the data generation is re-implemented.
///
abstract class VideoStreamCapture implements BaseRepository { // Implement BaseRepository interface
  /// Represents frame data with a timestamp, current frame data, and a flag indicating if it's new.
  ///
  /// - [timestamp] is an integer representing the timestamp of the frame.
  /// - [curFrameData] is an [CameraImage] representing the current frame data.
  /// - [bNewData] is a boolean indicating whether the data is new and has not been fetched.
  ({int timestamp, CameraImage? curFrameData, bool isNewData}) _curFrameData =
  (timestamp: 0, curFrameData: null, isNewData: false);

  /// Frame rate of the video stream
  int _fps = 25;

  /// Indicates whether the stream is currently running
  bool _isRunning = false;

  /// Timer used to fetch data at the specified FPS
  Timer? _timer;

  /// Gets/sets the frame rate of the video stream.
  int get fps => _fps;
  //set fps(int value) => _fps = value;

  /// Gets whether is the steram is currently running.
  bool get isRunning => _isRunning;

  /// Gets the CameraController instance if available.
  /// This is an abstract getter that concrete implementations (like VideoStreamCaptureFromCamera) must provide.
  CameraController? get cameraController;

  /// Starts the data stream and returns if successful.
  ///
  /// - [callback] is a function that will be called with each fetched data item.
  /// - [fps] is the desired frame rate for fetching data. Defaults to the current frame rate if not provided.
  ///
  /// Note that a stream cannot start again before it stops.
  ///
  /// Output: if the steram is successfully started.
  Future<bool> start(FetchDataCallback callback, {int fps = 0}) async{
    if(_isRunning) return false;

    _curFrameData = (timestamp: 0, curFrameData: null, isNewData: false);

    _fps = fps > 0 ? fps: 25; // user-specified fps for data fetching

    _isRunning = await _startImplement(); // Open the data source

    if(!_isRunning) return false;

    // start fetching
    _fetchDataByTimer(callback, _fps);

    return true;
  }

  /// stop the data stream
  /// This method is also the implementation of freeRepository from BaseRepository
  @override
  Future<void> freeRepository() async{ // Implement freeRepository method
    if(!_isRunning) return;

    await _stopImplement(); // Do something for stopping the dtream

    _isRunning = false;
    _timer?.cancel(); // Stop timer
  }

  // Internal functions -- cannot be accessed outside

  /// Fetch data with a timer at the specified FPS
  ///
  /// ***Note***: the data fetching process is performed in the thread of the invoker, instead of
  /// creating a new thread
  void _fetchDataByTimer(FetchDataCallback callback, int fps){
    // Set up a timer to fetch data at the specified FPS
    _timer = Timer.periodic(Duration(milliseconds: (1000 / fps).round()), (Timer timer) {
      try {
        final CameraImage? imageData = _fetchCurrentData(); // Get data directly
        if (imageData != null) { // Check for null before calling callback
          callback(_curFrameData.timestamp, imageData); // Pass the retrieved image
        }
      } catch (e) {
        print('Error fetching data: $e');
        // Only cancel the timer here, do not call freeRepository()
        // freeRepository() should be called from the widget's dispose method.
        _timer?.cancel(); // Stop the timer
        _isRunning = false; // Mark as not running
        print('VideoStreamCapture: Timer stopped due to error.');
      }
    });
  }

  /// Fetch current data in the stream
  ///
  /// This method should be implemented depending on the specified data source
  /// return true if current stream data is available; otherwise false
  CameraImage? _fetchCurrentData() { // Changed return type to CameraImage? and removed parameters
    if(!_isRunning) return null;

    if(_curFrameData.isNewData && _curFrameData.curFrameData != null){ // Check for null before using !
      final CameraImage imageToReturn = _curFrameData.curFrameData!;
      _curFrameData = (timestamp: _curFrameData.timestamp, curFrameData: null, isNewData: false); // Mark as consumed
      _readCurrentDataAsyn(); // Request next frame
      return imageToReturn;
    }
    else{
      _readCurrentDataAsyn(); // Request next frame, no new data to return yet
      return null;
    }
  }

  /// {@template start_implement}
  /// Do something to start the stream including open devices, preparing data, etc.
  ///
  /// This method should be implemented depending on the specified data source
  /// Return true if everything is ok; otherwise false
  /// {@endtemplate}
  Future<bool> _startImplement();

  /// {@template stop_implement}
  /// Do something to stop the stream
  ///
  /// This method should be implemented depending on the specified data source
  /// {@endtemplate}
  Future<void> _stopImplement();

  /// {@template read_current_data}
  /// Pick a data from the stream as the current data
  ///
  /// This method should be implemented depending on the specified data source
  /// {@endtemplate}
  Future<void> _readCurrentDataAsyn();
}

/// A class to hold mutable timestamp data.
class TimestampHolder {
  int timestamp;

  /// Creates a new instance of [TimestampHolder].
  ///
  /// Parameters:
  /// - [timestamp] is the initial timestamp value.
  TimestampHolder(this.timestamp);
}
typedef FetchDataCallback = void Function(int timestamp, CameraImage imageData);


/// Represents image data fetched from the data stream.
/// This class is no longer directly used for CameraImage data, but might be useful for other stream types.
class VideoFrameData {
  Uint8List bytes;
  int width;
  int height;

  /// Creates a new instance of [VideoFrameData].
  ///
  /// Parameters:
  /// - [bytes] is a byte array representing the image data.
  /// - [width] is the width of the image.
  /// - [height] is the height of the image.
  VideoFrameData({required this.bytes, required this.width, required this.height});
}
