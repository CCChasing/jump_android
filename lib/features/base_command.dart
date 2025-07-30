
/// **Author**: wwyang
/// **Date**: 2025.5.7
/// **Copyright**: Multimedia Lab, Zhejiang Gongshang University
/// **Version**: 1.0
///
/// This program is free software: you can redistribute it and/or modify
/// it under the terms of the GNU General Public License as published by
/// the Free Software Foundation, either version 3 of the License, or
/// (at your option) any later version.
///
/// This program is distributed in the hope that it will be useful,
/// but WITHOUT ANY WARRANTY; without even the implied warranty of
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
/// GNU General Public License for more details.
///
/// You should have received a copy of the GNU General Public License
/// along with this program. If not, see <http://www.gnu.org/licenses/>.
library command_lib;

import 'dart:typed_data';
import 'package:jump/data_stream/video_stream_capture.dart';
import 'command_factory.dart';


abstract class BaseCommand {

  // the command status
  bool _isAlive = false;

  /// Begin a command. The specific behaviors are implemented in
  /// [beginCmdImplement] of the subclass
  ///
  Future<void> beginCmd() async{
    if(_isAlive) return;

    _modifyOtherCmdState();  // Modify the status of the currently running commands

    _isAlive = true;
    CommandFactory.addToLiveList_(this);

    await _beginCmdImplement(); // start running
  }

  Future<void> endCmd() async{
    if(!_isAlive) return;

    _isAlive = false;
    await _endCmdImplement();

    CommandFactory.delLiveCmd_(this);
  }

  bool isAlive() => _isAlive;

  // Internal functions

  Future<void> _modifyOtherCmdState() async {
    await CommandFactory.stopAllLiveCmd();
  }

  Future<void> _beginCmdImplement();

  Future<void> _endCmdImplement();


}