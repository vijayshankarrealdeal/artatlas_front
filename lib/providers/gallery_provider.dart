// lib/providers/gallery_provider.dart
import 'package:flutter/foundation.dart';
import 'package:hack_front/models/gallery_model.dart';
import 'package:hack_front/models/artwork_model.dart';
import 'package:hack_front/repositories/artwork_repository.dart';

class GalleryProvider with ChangeNotifier {
  final ArtworkRepository _artworkRepository;

  double _volume = 0.7;
  double get volume => _volume;

  bool _isPlaying = true;
  bool get isPlaying => _isPlaying;

  List<GalleryModel> _galleries = [];
  List<GalleryModel> get galleries => _galleries;
  bool _isLoadingGalleries = false;
  bool get isLoadingGalleries => _isLoadingGalleries;
  bool _hasMoreGalleries = true;
  bool get hasMoreGalleries => _hasMoreGalleries;
  String? _galleriesErrorMessage;
  String? get galleriesErrorMessage => _galleriesErrorMessage;
  int _currentGalleriesPage = 0;
  final int _galleriesLimit = 10;

  String? _selectedGalleryIdInternal; // Renamed internal field
  String? get selectedGalleryId => _selectedGalleryIdInternal; // Public getter

  GalleryModel? _selectedGallery;
  GalleryModel? get selectedGallery => _selectedGallery;

  List<Artwork> _galleryArtworks = [];
  List<Artwork> get galleryArtworks => _galleryArtworks;
  bool _isLoadingGalleryArtworks = false;
  bool get isLoadingGalleryArtworks => _isLoadingGalleryArtworks;
  bool _hasMoreGalleryArtworks = true;
  bool get hasMoreGalleryArtworks => _hasMoreGalleryArtworks;
  String? _galleryArtworksErrorMessage;
  String? get galleryArtworksErrorMessage => _galleryArtworksErrorMessage;
  int _currentGalleryArtworksPage = 0;
  final int _galleryArtworksLimit = 10;

  Artwork? _selectedArtwork;
  Artwork? get selectedArtwork => _selectedArtwork;

  GalleryProvider(this._artworkRepository) {
    fetchGalleries();
  }

  Future<void> fetchGalleries({bool loadMore = false}) async {
    if (loadMore) {
      if (_isLoadingGalleries || !_hasMoreGalleries) return;
      _isLoadingGalleries = true;
    } else {
      _currentGalleriesPage = 0;
      _galleries = [];
      _hasMoreGalleries = true;
      _isLoadingGalleries = true;
    }
    _galleriesErrorMessage = null;
    notifyListeners();

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
        _hasMoreGalleries = false;
      } else {
        _currentGalleriesPage++;
      }
    } catch (e) {
      _galleriesErrorMessage = e.toString();
      if (kDebugMode)
        print(
          "GalleryProvider: Error fetching galleries: $_galleriesErrorMessage",
        );
    }
    _isLoadingGalleries = false;
    notifyListeners();
  }

  Future<void> selectGalleryAndLoadArtworks(GalleryModel gallery) async {
    if (_selectedGalleryIdInternal == gallery.id &&
        _galleryArtworks.isNotEmpty &&
        !_isLoadingGalleryArtworks) {
      if (_selectedArtwork == null && _galleryArtworks.isNotEmpty) {
        _selectedArtwork = _galleryArtworks.first;
        notifyListeners();
      }
      return;
    }

    _selectedGalleryIdInternal = gallery.id;
    _selectedGallery = gallery;
    _currentGalleryArtworksPage = 0;
    _galleryArtworks = [];
    _selectedArtwork = null;
    _hasMoreGalleryArtworks = true;
    _isLoadingGalleryArtworks = true;
    _galleryArtworksErrorMessage = null;
    notifyListeners();

    try {
      final newArtworks = await _artworkRepository.getArtworksByGalleryId(
        galleryId: _selectedGalleryIdInternal!,
        limit: _galleryArtworksLimit,
        skip: 0,
      );
      _galleryArtworks = newArtworks;
      if (_galleryArtworks.isNotEmpty) {
        _selectedArtwork = _galleryArtworks.first;
      }
      if (newArtworks.isEmpty || newArtworks.length < _galleryArtworksLimit) {
        _hasMoreGalleryArtworks = false;
      } else {
        _currentGalleryArtworksPage = 1;
      }
    } catch (e) {
      _galleryArtworksErrorMessage = e.toString();
      if (kDebugMode)
        print(
          "GalleryProvider: Error fetching artworks for gallery $_selectedGalleryIdInternal: $e",
        );
    }
    _isLoadingGalleryArtworks = false;
    notifyListeners();
  }

  Future<void> loadMoreGalleryArtworks() async {
    if (_isLoadingGalleryArtworks ||
        !_hasMoreGalleryArtworks ||
        _selectedGalleryIdInternal == null)
      return;

    _isLoadingGalleryArtworks = true;
    _galleryArtworksErrorMessage = null;
    notifyListeners();

    try {
      final newArtworks = await _artworkRepository.getArtworksByGalleryId(
        galleryId: _selectedGalleryIdInternal!,
        limit: _galleryArtworksLimit,
        skip: _currentGalleryArtworksPage * _galleryArtworksLimit,
      );
      _galleryArtworks.addAll(newArtworks);
      if (newArtworks.isEmpty || newArtworks.length < _galleryArtworksLimit) {
        _hasMoreGalleryArtworks = false;
      } else {
        _currentGalleryArtworksPage++;
      }
    } catch (e) {
      _galleryArtworksErrorMessage = e.toString();
      if (kDebugMode)
        print(
          "GalleryProvider: Error loading more artworks for gallery $_selectedGalleryIdInternal: $e",
        );
    }
    _isLoadingGalleryArtworks = false;
    notifyListeners();
  }

  void setSelectedArtwork(Artwork artwork) {
    if (_selectedArtwork?.imageUrl != artwork.imageUrl) {
      _selectedArtwork = artwork;
      notifyListeners();
    }
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
    if (_selectedArtwork != null && _galleryArtworks.isNotEmpty) {
      int currentIndex = _galleryArtworks.indexWhere(
        (art) => art.id == _selectedArtwork!.id,
      );
      if (currentIndex > 0) {
        setSelectedArtwork(_galleryArtworks[currentIndex - 1]);
      } else if (currentIndex == 0 && _galleryArtworks.length > 1) {
        setSelectedArtwork(_galleryArtworks.last);
      }
    }
    if (kDebugMode) print("Skip Previous Tapped");
    notifyListeners();
  }

  void skipNext() {
    if (_selectedArtwork != null && _galleryArtworks.isNotEmpty) {
      int currentIndex = _galleryArtworks.indexWhere(
        (art) => art.id == _selectedArtwork!.id,
      );
      if (currentIndex != -1 && currentIndex < _galleryArtworks.length - 1) {
        setSelectedArtwork(_galleryArtworks[currentIndex + 1]);
      } else if (currentIndex == _galleryArtworks.length - 1 &&
          _galleryArtworks.length > 1) {
        setSelectedArtwork(_galleryArtworks.first);
      }
    }
    if (kDebugMode) print("Skip Next Tapped");
    notifyListeners();
  }

  void setPlaybackSpeed(double speed) {
    if (kDebugMode) print("Playback speed set to $speed");
    notifyListeners();
  }
}
