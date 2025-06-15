// lib/services/audio_service.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'audio_service_interface.dart';
import 'audio_service_mobile.dart' as mobile_service;
import 'audio_service_web.dart' as web_service;

class AudioService {
  static AudioServiceInterface getInstance() {
    if (kIsWeb) {
      return web_service.AudioServiceWeb();
    } else {
      return mobile_service.AudioServiceMobile();
    }
  }
}
