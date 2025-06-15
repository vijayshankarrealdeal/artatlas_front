// lib/services/audio_service_interface.dart
import 'dart:async';
import 'dart:typed_data';

abstract class AudioServiceInterface {
  Future<bool> hasPermission();
  Future<void> startRecording({String? filePath});
  Future<String?> stopRecording(); // Returns path (mobile) or blob URL (web)
  
  Future<void> playFromBytes(Uint8List bytes);
  Future<void> playFromUrl(String url);
  Future<void> stopPlayback();
  
  Stream<void> get onPlayerComplete;
  Stream<dynamic> get onPlayerError; // Make it dynamic or a specific error type
  // Consider adding Stream<PlayerState> get onPlayerStateChanged if needed across platforms

  void dispose();
}