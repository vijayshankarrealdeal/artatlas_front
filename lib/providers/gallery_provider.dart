import 'package:flutter/foundation.dart';

class GalleryProvider with ChangeNotifier {
  double _volume = 0.7;
  double get volume => _volume;

  bool _isPlaying = true;
  bool get isPlaying => _isPlaying;

  // TODO: Add state for currentTrackTime, totalTrackTime, playbackSpeed

  void setVolume(double newVolume) {
    _volume = newVolume.clamp(0.0, 1.0); // Ensure volume is within bounds
    notifyListeners();
  }

  void togglePlayPause() {
    _isPlaying = !_isPlaying;
    notifyListeners();
    // TODO: Implement actual play/pause logic with an audio player
  }

  void skipPrevious() {
    // TODO: Implement skip previous track
    print("Skip Previous Tapped");
    notifyListeners();
  }

  void skipNext() {
    // TODO: Implement skip next track
    print("Skip Next Tapped");
    notifyListeners();
  }

  void setPlaybackSpeed(double speed) {
    // TODO: Implement playback speed change
    print("Playback speed set to $speed");
    notifyListeners();
  }
}