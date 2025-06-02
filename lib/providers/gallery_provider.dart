// lib/providers/gallery_provider.dart
import 'package:flutter/foundation.dart';
import 'package:hack_front/models/gallery_model.dart';
import 'package:hack_front/repositories/artwork_repository.dart';

class GalleryProvider with ChangeNotifier {
  final ArtworkRepository _artworkRepository;

  // Existing audio player state
  double _volume = 0.7;
  double get volume => _volume;

  bool _isPlaying = true;
  bool get isPlaying => _isPlaying;

  // New state for galleries list
  List<GalleryModel> _galleries = [];
  List<GalleryModel> get galleries => _galleries;

  bool _isLoadingGalleries = false;
  bool get isLoadingGalleries => _isLoadingGalleries;

  bool _hasMoreGalleries = true;
  bool get hasMoreGalleries => _hasMoreGalleries;

  String? _galleriesErrorMessage;
  String? get galleriesErrorMessage => _galleriesErrorMessage;

  int _currentGalleriesPage = 0;
  final int _galleriesLimit = 10; // Items per page for galleries

  GalleryProvider(this._artworkRepository) {
    fetchGalleries(); // Initial fetch when provider is created
  }

  Future<void> fetchGalleries({bool loadMore = false}) async {
    if (loadMore) {
      if (_isLoadingGalleries || !_hasMoreGalleries) return; // Don't fetch if already loading or no more data
      _isLoadingGalleries = true;
    } else { // This is for an initial load or a refresh action
      _currentGalleriesPage = 0;
      _galleries = [];
      _hasMoreGalleries = true; // Reset for refresh
      _isLoadingGalleries = true;
    }
    _galleriesErrorMessage = null; // Clear previous error
    notifyListeners(); // Notify UI about loading state change

    try {
      final newGalleries = await _artworkRepository.getGalleries(
        limit: _galleriesLimit,
        skip: _currentGalleriesPage * _galleriesLimit,
      );

      if (loadMore) {
        _galleries.addAll(newGalleries);
      } else {
        _galleries = newGalleries;
      }

      if (newGalleries.isEmpty || newGalleries.length < _galleriesLimit) {
        _hasMoreGalleries = false; // No more galleries to load
      } else {
        _currentGalleriesPage++; // Increment page for next fetch
      }
    } catch (e) {
      _galleriesErrorMessage = e.toString();
      if (kDebugMode) print("GalleryProvider: Error fetching galleries: $_galleriesErrorMessage");
      // Optionally, set _hasMoreGalleries to false on error for initial load
      // if (!loadMore) _hasMoreGalleries = false;
    }

    _isLoadingGalleries = false;
    notifyListeners(); // Notify UI about data and loading state update
  }


  void setVolume(double newVolume) {
    _volume = newVolume.clamp(0.0, 1.0);
    notifyListeners();
  }

  void togglePlayPause() {
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  void skipPrevious() {
    print("Skip Previous Tapped");
    notifyListeners();
  }

  void skipNext() {
    print("Skip Next Tapped");
    notifyListeners();
  }

  void setPlaybackSpeed(double speed) {
    print("Playback speed set to $speed");
    notifyListeners();
  }
}