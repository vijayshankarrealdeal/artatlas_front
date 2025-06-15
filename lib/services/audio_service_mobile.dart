// lib/services/audio_service_mobile.dart
import 'dart:async';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'audio_service_interface.dart';
import 'package:flutter/foundation.dart' show kDebugMode;


class AudioServiceMobile implements AudioServiceInterface {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentRecordingPath;

  final StreamController<void> _playerCompleteController = StreamController.broadcast();
  final StreamController<dynamic> _playerErrorController = StreamController.broadcast(); // Use dynamic for simplicity

  AudioServiceMobile() {
    _audioPlayer.onPlayerComplete.listen((event) {
      _playerCompleteController.add(event);
    });
     _audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.stopped) { // A way to infer some errors or explicit stops
        // This might not capture all low-level errors, onLog is better for detailed debugging.
         if (kDebugMode) {
          print("AudioServiceMobile: Player stopped. This might indicate an error or explicit stop.");
        }
        // You might want to signal a generic error or just completion if not already handled
      }
    });
    if (kDebugMode) {
      _audioPlayer.onLog.listen((msg) {
        if (msg.contains("Error") || msg.contains("error") || msg.contains("Exception")) {
          _playerErrorController.add(msg); // Forward log messages that seem like errors
        }
      });
    }
  }


  @override
  Future<bool> hasPermission() {
    return _audioRecorder.hasPermission();
  }

  @override
  Future<void> startRecording({String? filePath}) async {
    String path;
    if (filePath != null) {
      path = filePath;
    } else {
      final directory = await getApplicationDocumentsDirectory();
      path = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
    }
    _currentRecordingPath = path;
    return _audioRecorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: path);
  }

  @override
  Future<String?> stopRecording() async {
    final path = await _audioRecorder.stop();
    return path ?? _currentRecordingPath; 
  }

  @override
  Future<void> playFromBytes(Uint8List bytes) {
    return _audioPlayer.play(BytesSource(bytes));
  }
  
  @override
  Future<void> playFromUrl(String url) {
    return _audioPlayer.play(UrlSource(url));
  }


  @override
  Future<void> stopPlayback() {
    return _audioPlayer.stop();
  }

  @override
  Stream<void> get onPlayerComplete => _playerCompleteController.stream;

  @override
  Stream<dynamic> get onPlayerError => _playerErrorController.stream;


  @override
  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    _playerCompleteController.close();
    _playerErrorController.close();
  }
}