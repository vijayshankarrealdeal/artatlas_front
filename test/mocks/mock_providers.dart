// test/mocks/mock_gallery_provider.dart (or at top of test file)
import 'package:flutter/material.dart';
import 'package:hack_front/models/artwork_model.dart';
import 'package:hack_front/models/gallery_model.dart';
import 'package:hack_front/providers/gallery_provider.dart';
import 'package:hack_front/providers/navigation_provider.dart';
import 'package:hack_front/providers/theme_provider.dart';
import 'package:mockito/mockito.dart';

// Create a mock class for GalleryProvider
class MockGalleryProvider extends Mock implements GalleryProvider {
  // We need to provide concrete implementations for getters that will be accessed
  // or stub them if they are called during widget build.
  // For this example, we'll assume some initial empty/default states.

  @override
  List<GalleryModel> get galleries => _galleries;
  List<GalleryModel> _galleries = [];
  void setMockGalleries(List<GalleryModel> galleries) {
    _galleries = galleries;
    // If you need to notify listeners, you'd have to manage that manually or
    // use a real ChangeNotifier and stub its methods. For simple getter mocking, this is often enough.
  }

  @override
  bool get isLoadingGalleries => _isLoadingGalleries;
  bool _isLoadingGalleries = false;
  void setMockIsLoadingGalleries(bool isLoading) =>
      _isLoadingGalleries = isLoading;

  @override
  bool get hasMoreGalleries => _hasMoreGalleries;
  bool _hasMoreGalleries = true;
  void setMockHasMoreGalleries(bool hasMore) => _hasMoreGalleries = hasMore;

  @override
  String? get selectedGalleryId => _selectedGalleryId;
  String? _selectedGalleryId;
  void setMockSelectedGalleryId(String? id) => _selectedGalleryId = id;

  @override
  GalleryModel? get selectedGallery => _selectedGallery;
  GalleryModel? _selectedGallery;
  void setMockSelectedGallery(GalleryModel? gallery) {
    _selectedGallery = gallery;
    _selectedGalleryId = gallery?.id;
  }

  @override
  List<Artwork> get galleryArtworks => _galleryArtworks;
  List<Artwork> _galleryArtworks = [];
  void setMockGalleryArtworks(List<Artwork> artworks) =>
      _galleryArtworks = artworks;

  @override
  bool get isLoadingGalleryArtworks => _isLoadingGalleryArtworks;
  bool _isLoadingGalleryArtworks = false;
  void setMockIsLoadingGalleryArtworks(bool isLoading) =>
      _isLoadingGalleryArtworks = isLoading;

  @override
  bool get hasMoreGalleryArtworks => _hasMoreGalleryArtworks;
  bool _hasMoreGalleryArtworks = true;
  void setMockHasMoreGalleryArtworks(bool hasMore) =>
      _hasMoreGalleryArtworks = hasMore;

  @override
  Artwork? get selectedArtwork => _selectedArtwork;
  Artwork? _selectedArtwork;
  void setMockSelectedArtwork(Artwork? artwork) => _selectedArtwork = artwork;

  // Mock methods if they are called directly during widget build or interactions
  // For now, we'll assume they aren't for the initial display test.
  // If selectGalleryAndLoadArtworks is called in initState, you'd mock it:
  @override
  Future<void> selectGalleryAndLoadArtworks(GalleryModel gallery) {
    // Simulate loading, then setting data
    setMockSelectedGallery(gallery);
    setMockIsLoadingGalleryArtworks(true);
    // In a real test, you might notifyListeners here if your mock supports it.
    // Then, after a delay/pump, set artworks and loading to false.
    // For simplicity, we'll assume the widget test handles the async part via tester.pump.
    return Future.value(); // Or super.selectGalleryAndLoadArtworks(gallery) if calling real logic
  }

  @override
  Future<void> fetchGalleries({bool loadMore = false}) async {
    // Mock implementation if needed
    return Future.value();
  }

  @override
  Future<void> loadMoreGalleryArtworks() async {
    return Future.value();
  }
}

// You would also create mocks for NavigationProvider and ThemeProvider if their states affect the widget's rendering significantly
class MockNavigationProvider extends Mock implements NavigationProvider {}

class MockThemeProvider extends Mock implements ThemeProvider {
  @override
  ThemeMode get themeMode => ThemeMode.dark; // Default mock theme
  @override
  bool get isDarkMode => true;
}
