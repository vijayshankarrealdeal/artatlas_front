// lib/services/audio_service_web.dart
import 'dart:async';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';
import 'audio_service_interface.dart';
import 'package:flutter/foundation.dart' show kDebugMode;


class AudioServiceWeb implements AudioServiceInterface {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  final StreamController<void> _playerCompleteController = StreamController.broadcast();
  final StreamController<dynamic> _playerErrorController = StreamController.broadcast();

   AudioServiceWeb() {
    _audioPlayer.onPlayerComplete.listen((event) {
      _playerCompleteController.add(event);
    });
     _audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.stopped) {
         if (kDebugMode) {
          print("AudioServiceWeb: Player stopped. This might indicate an error or explicit stop.");
        }
      }
    });
     if (kDebugMode) {
      _audioPlayer.onLog.listen((msg) {
        if (msg.contains("Error") || msg.contains("error") || msg.contains("Exception")) {
          _playerErrorController.add(msg);
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
    return _audioRecorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: ''); 
  }

  @override
  Future<String?> stopRecording() async {
    return _audioRecorder.stop();
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