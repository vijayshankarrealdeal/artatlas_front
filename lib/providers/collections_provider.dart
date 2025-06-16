// lib/providers/collections_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hack_front/models/artwork_model.dart';
import 'package:hack_front/repositories/artwork_repository.dart';

class CollectionsProvider with ChangeNotifier {
  final ArtworkRepository _artworkRepository;

  // --- Filter States ---
  bool _filtersVisible = false;
  bool get filtersVisible => _filtersVisible;

  String? _selectedSort;
  String? get selectedSort => _selectedSort;

  String? _selectedDate;
  String? get selectedDate => _selectedDate;

  String? _selectedClassification;
  String? get selectedClassification => _selectedClassification;

  String? _selectedArtist;
  String? get selectedArtist => _selectedArtist;

  String? _selectedStyle;
  String? get selectedStyle => _selectedStyle;

  final List<Map<String, String?>> _activeFilterChips = [];
  List<Map<String, String?>> get activeFilterChips => _activeFilterChips;

  // --- Filter Options (Ensure these are populated with meaningful defaults or loaded) ---
  final List<String> sortOptions = [
    'Sort: By Relevance',
    'Sort: By Date (Newest)',
    'Sort: By Date (Oldest)',
    'Sort: By Artist (A-Z)',
  ];
  final List<String> dateOptions = [
    'Date: All',
    'Date: 2000 - Present',
    'Date: 1900 - 1999',
    'Date: 1800 - 1899',
    'Date: Before 1800',
  ];
  final List<String> classificationOptions = [
    'Classifications: All',
    'Painting',
    'Sculpture',
    'Photography',
    'Drawing',
    'Print',
  ];
  final List<String> artistOptions = [
    // Populate with actual artist names or load dynamically
    'Artists: All',
    'Childe Hassam',
    'Georges Seurat',
    'Vincent van Gogh (Style)', // Keep if you have styled data
    'Grant Wood (Style)',
    'Edward Hopper (Style)',
    'Raphael',
  ];
  final List<String> styleOptions = [
    // Populate with actual styles
    'Styles: All',
    'Impressionism',
    'Post-Impressionism',
    'Pointillism',
    'Regionalism',
    'American Realism',
    'High Renaissance',
  ];

  // --- Data & Loading States ---
  List<Artwork> _artworks = [];
  List<Artwork> get artworks => _artworks;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  bool _hasMoreArtworks = true;
  bool get hasMoreArtworks => _hasMoreArtworks;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // --- Search & Pagination ---
  String _searchQuery = '';
  String get searchQuery => _searchQuery; // Getter for UI if needed
  Timer? _debounce;
  final int _limit = 10; // Items per page
  int _currentPage = 0;

  CollectionsProvider(this._artworkRepository) {
    // Initialize filters to default values
    _selectedSort = sortOptions.firstWhere(
      (opt) => opt.contains("Relevance"),
      orElse: () => sortOptions.first,
    );
    _selectedDate = dateOptions.firstWhere(
      (opt) => opt.contains("All"),
      orElse: () => dateOptions.first,
    );
    _selectedClassification = classificationOptions.firstWhere(
      (opt) => opt.contains("All"),
      orElse: () => classificationOptions.first,
    );
    _selectedArtist = artistOptions.firstWhere(
      (opt) => opt.contains("All"),
      orElse: () => artistOptions.first,
    );
    _selectedStyle = styleOptions.firstWhere(
      (opt) => opt.contains("All"),
      orElse: () => styleOptions.first,
    );

    fetchArtworks(isNewSearchOrFilter: true); // Initial fetch
  }

  Future<void> fetchArtworks({bool isNewSearchOrFilter = false}) async {
    if (isNewSearchOrFilter) {
      _currentPage = 0;
      _artworks = [];
      _hasMoreArtworks = true;
      _isLoading = true;
    } else {
      // Loading more
      if (_isLoadingMore || !_hasMoreArtworks) return;
      _isLoadingMore = true;
    }
    _errorMessage = null;
    // Notify listeners at the beginning of the fetch operation, especially for isLoading state
    notifyListeners();

    try {
      final newArtworks = await _artworkRepository.getArtworks(
        sortBy: _selectedSort,
        dateRange: _selectedDate,
        classification: _selectedClassification,
        artist: _selectedArtist,
        style: _selectedStyle,
        searchQuery: _searchQuery, // Ensure _searchQuery is passed
        limit: _limit,
        skip: _currentPage * _limit,
      );

      if (isNewSearchOrFilter) {
        // For a new search/filter, replace artworks
        _artworks = newArtworks;
      } else {
        // For loading more, append
        _artworks.addAll(newArtworks);
      }

      if (newArtworks.isEmpty || newArtworks.length < _limit) {
        _hasMoreArtworks = false;
      } else {
        _hasMoreArtworks = true; // There might be more
      }

      if (newArtworks.isNotEmpty) {
        // Only increment page if we got results
        _currentPage++;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _hasMoreArtworks = false;
      _artworks = [];
    }

    if (isNewSearchOrFilter) {
      _isLoading = false;
    } else {
      _isLoadingMore = false;
    }

    _updateActiveFilterChips();
    notifyListeners(); // Notify listeners again after data is fetched and states are updated
  }

  void loadMoreArtworks() {
    if (!_isLoading && !_isLoadingMore && _hasMoreArtworks) {
      fetchArtworks(isNewSearchOrFilter: false);
    }
  }

  void updateSearchQuery(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      // Only fetch if the query has actually changed to avoid redundant calls
      // especially if the user clears the search bar and it was already empty.
      final newQuery = query.trim().toLowerCase();
      if (_searchQuery != newQuery) {
        _searchQuery = newQuery;
        fetchArtworks(isNewSearchOrFilter: true);
      } else if (newQuery.isEmpty && _searchQuery.isNotEmpty) {
        _searchQuery = '';
        fetchArtworks(isNewSearchOrFilter: true);
      }
    });
  }

  void toggleFiltersVisibility() {
    _filtersVisible = !_filtersVisible;
    notifyListeners();
  }

  void updateSelectedSort(String? value) {
    if (value == null || _selectedSort == value) return;
    _selectedSort = value;
    fetchArtworks(isNewSearchOrFilter: true);
  }

  void updateSelectedDate(String? value) {
    if (value == null || _selectedDate == value) return;
    _selectedDate = value;
    fetchArtworks(isNewSearchOrFilter: true);
  }

  void updateSelectedClassification(String? value) {
    if (value == null || _selectedClassification == value) return;
    _selectedClassification = value;
    fetchArtworks(isNewSearchOrFilter: true);
  }

  void updateSelectedArtist(String? value) {
    if (value == null || _selectedArtist == value) return;
    _selectedArtist = value;
    fetchArtworks(isNewSearchOrFilter: true);
  }

  void updateSelectedStyle(String? value) {
    if (value == null || _selectedStyle == value) return;
    _selectedStyle = value;
    fetchArtworks(isNewSearchOrFilter: true);
  }

  void _updateActiveFilterChips() {
    _activeFilterChips.clear();
    // Helper to check if a filter is active (not the default "All" or "Relevance" option)
    bool isFilterActive(String? selectedValue, List<String> optionsList) {
      if (selectedValue == null) return false;
      // Assuming the first item in optionsList is the default/inactive state
      return selectedValue !=
          optionsList.firstWhere(
            (opt) => opt.contains("All") || opt.contains("Relevance"),
            orElse: () => optionsList.first,
          );
    }

    if (isFilterActive(_selectedSort, sortOptions)) {
      _activeFilterChips.add({'type': 'sort', 'label': _selectedSort});
    }
    if (isFilterActive(_selectedDate, dateOptions)) {
      _activeFilterChips.add({'type': 'date', 'label': _selectedDate});
    }
    if (isFilterActive(_selectedClassification, classificationOptions)) {
      _activeFilterChips.add({
        'type': 'classification',
        'label': _selectedClassification,
      });
    }
    if (isFilterActive(_selectedArtist, artistOptions)) {
      _activeFilterChips.add({'type': 'artist', 'label': _selectedArtist});
    }
    if (isFilterActive(_selectedStyle, styleOptions)) {
      _activeFilterChips.add({'type': 'style', 'label': _selectedStyle});
    }
    // No notifyListeners() here; it's called by fetchArtworks which usually calls this.
  }

  void removeFilterChip(String type, String? label) {
    switch (type) {
      case 'sort':
        _selectedSort = sortOptions.firstWhere(
          (opt) => opt.contains("Relevance"),
          orElse: () => sortOptions.first,
        );
        break;
      case 'date':
        _selectedDate = dateOptions.firstWhere(
          (opt) => opt.contains("All"),
          orElse: () => dateOptions.first,
        );
        break;
      case 'classification':
        _selectedClassification = classificationOptions.firstWhere(
          (opt) => opt.contains("All"),
          orElse: () => classificationOptions.first,
        );
        break;
      case 'artist':
        _selectedArtist = artistOptions.firstWhere(
          (opt) => opt.contains("All"),
          orElse: () => artistOptions.first,
        );
        break;
      case 'style':
        _selectedStyle = styleOptions.firstWhere(
          (opt) => opt.contains("All"),
          orElse: () => styleOptions.first,
        );
        break;
    }
    fetchArtworks(isNewSearchOrFilter: true);
  }

  void clearAllFilters() {
    _selectedSort = sortOptions.firstWhere(
      (opt) => opt.contains("Relevance"),
      orElse: () => sortOptions.first,
    );
    _selectedDate = dateOptions.firstWhere(
      (opt) => opt.contains("All"),
      orElse: () => dateOptions.first,
    );
    _selectedClassification = classificationOptions.firstWhere(
      (opt) => opt.contains("All"),
      orElse: () => classificationOptions.first,
    );
    _selectedArtist = artistOptions.firstWhere(
      (opt) => opt.contains("All"),
      orElse: () => artistOptions.first,
    );
    _selectedStyle = styleOptions.firstWhere(
      (opt) => opt.contains("All"),
      orElse: () => styleOptions.first,
    );
    if (_searchQuery.isNotEmpty) {
      // Only clear search if it was active
      _searchQuery = '';
    }
    fetchArtworks(isNewSearchOrFilter: true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
