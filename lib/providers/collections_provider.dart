import 'package:flutter/foundation.dart';
import 'package:hack_front/models/artwork_model.dart';

class CollectionsProvider with ChangeNotifier {
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

  List<Map<String, String?>> _activeFilterChips = [];
  List<Map<String, String?>> get activeFilterChips => _activeFilterChips;

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
    'Artists: All',
    'Vincent van Gogh (Style)',
    'Georges Seurat',
    'Grant Wood (Style)',
    'Edward Hopper (Style)',
    'Raphael',
    'Leonardo da Vinci (Style)',
    'Unknown Modernist',
    'Claude Monet (Style)',
  ];
  final List<String> styleOptions = [
    'Styles: All',
    'Impressionism',
    'Post-Impressionism',
    'Renaissance',
    'Modernism',
    'Realism',
    // 'Cubism', // Not in sample data
    // 'Surrealism', // Not in sample data
  ];

  List<Artwork> _allArtworks = [];
  List<Artwork> _filteredArtworks = [];
  List<Artwork> get artworks => _filteredArtworks;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _searchQuery = '';

  CollectionsProvider() {
    _selectedSort = sortOptions.first;
    _selectedDate = dateOptions.first;
    _selectedClassification = classificationOptions.first;
    _selectedArtist = artistOptions.first;
    _selectedStyle = styleOptions.first;
    _loadArtworks();
  }

  Future<void> _loadArtworks() async {
    _isLoading = true;
    notifyListeners();
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));
    _allArtworks = List.from(sampleArtworks); // Use a copy
    _applyFilters();
    _isLoading = false;
    notifyListeners();
  }

  void toggleFiltersVisibility() {
    _filtersVisible = !_filtersVisible;
    notifyListeners();
  }

  void updateSelectedSort(String? value) {
    if (value == null || _selectedSort == value) return;
    _selectedSort = value;
    _applyFilters();
  }

  void updateSelectedDate(String? value) {
    if (value == null || _selectedDate == value) return;
    _selectedDate = value;
    _applyFilters();
  }

  void updateSelectedClassification(String? value) {
    if (value == null || _selectedClassification == value) return;
    _selectedClassification = value;
    _applyFilters();
  }

  void updateSelectedArtist(String? value) {
    if (value == null || _selectedArtist == value) return;
    _selectedArtist = value;
    _applyFilters();
  }

  void updateSelectedStyle(String? value) {
    if (value == null || _selectedStyle == value) return;
    _selectedStyle = value;
    _applyFilters();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
  }


  void _updateActiveFilterChips() {
    _activeFilterChips.clear();
    if (_selectedSort != null && _selectedSort != sortOptions.first) {
      _activeFilterChips.add({'type': 'sort', 'label': _selectedSort});
    }
    if (_selectedDate != null && _selectedDate != dateOptions.first) {
      _activeFilterChips.add({'type': 'date', 'label': _selectedDate});
    }
    if (_selectedClassification != null &&
        _selectedClassification != classificationOptions.first) {
      _activeFilterChips.add({
        'type': 'classification',
        'label': _selectedClassification,
      });
    }
    if (_selectedArtist != null && _selectedArtist != artistOptions.first) {
      _activeFilterChips.add({'type': 'artist', 'label': _selectedArtist});
    }
    if (_selectedStyle != null && _selectedStyle != styleOptions.first) {
      _activeFilterChips.add({'type': 'style', 'label': _selectedStyle});
    }
    // notifyListeners(); // Called by _applyFilters
  }

  void removeFilterChip(String type, String? label) {
    switch (type) {
      case 'sort':
        _selectedSort = sortOptions.first;
        break;
      case 'date':
        _selectedDate = dateOptions.first;
        break;
      case 'classification':
        _selectedClassification = classificationOptions.first;
        break;
      case 'artist':
        _selectedArtist = artistOptions.first;
        break;
      case 'style':
        _selectedStyle = styleOptions.first;
        break;
    }
    _applyFilters();
  }

  void clearAllFilters() {
    _selectedSort = sortOptions.first;
    _selectedDate = dateOptions.first;
    _selectedClassification = classificationOptions.first;
    _selectedArtist = artistOptions.first;
    _selectedStyle = styleOptions.first;
    _searchQuery = ''; // Also clear search query
    _applyFilters();
  }

  void _applyFilters() {
    _isLoading = true; // Indicate filtering is in progress
    notifyListeners();

    List<Artwork> newlyFiltered = List.from(_allArtworks);

    // Search Query Filter
    if (_searchQuery.isNotEmpty) {
      newlyFiltered = newlyFiltered.where((artwork) {
        return artwork.title.toLowerCase().contains(_searchQuery) ||
               artwork.artist.toLowerCase().contains(_searchQuery) ||
               artwork.year.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    // Date Filter (example, needs proper parsing and comparison)
    if (_selectedDate != null && _selectedDate != dateOptions.first) {
      // This is a placeholder. Real date filtering requires parsing year strings.
      // For example, if _selectedDate is "1900 - 1999"
      // You'd parse artwork.year and check if it falls in that range.
      // For simplicity, this example won't implement full date range logic.
      if (_selectedDate == 'Date: 1900 - 1999') {
         newlyFiltered = newlyFiltered.where((art) {
           final year = int.tryParse(art.year.split('/').first.trim());
           return year != null && year >= 1900 && year <= 1999;
         }).toList();
      }
      // Add more conditions for other date ranges
    }

    // Classification Filter
    if (_selectedClassification != null &&
        _selectedClassification != classificationOptions.first) {
      // Sample artworks don't have classification. This is a placeholder.
      // Example: newlyFiltered = newlyFiltered.where((art) => art.classification == _selectedClassification).toList();
    }

    // Artist Filter
    if (_selectedArtist != null && _selectedArtist != artistOptions.first) {
      newlyFiltered = newlyFiltered.where((art) => art.artist == _selectedArtist).toList();
    }

    // Style Filter
    if (_selectedStyle != null && _selectedStyle != styleOptions.first) {
      // Sample artworks don't have explicit style. This is a placeholder.
      // Example: newlyFiltered = newlyFiltered.where((art) => art.style == _selectedStyle).toList();
       if (_selectedStyle == 'Impressionism' || _selectedStyle == 'Post-Impressionism') {
         newlyFiltered = newlyFiltered.where((art) => art.artist.contains('Monet') || art.artist.contains('Seurat') || art.artist.contains('Gogh')).toList();
       }
    }
    
    // Sort Filter
    if (_selectedSort != null && _selectedSort != sortOptions.first) {
        if (_selectedSort == 'Sort: By Artist (A-Z)') {
            newlyFiltered.sort((a, b) => a.artist.compareTo(b.artist));
        } else if (_selectedSort == 'Sort: By Date (Newest)') {
            newlyFiltered.sort((a, b) {
                final yearA = int.tryParse(a.year.split('/').last.trim()) ?? 0;
                final yearB = int.tryParse(b.year.split('/').last.trim()) ?? 0;
                return yearB.compareTo(yearA);
            });
        } else if (_selectedSort == 'Sort: By Date (Oldest)') {
             newlyFiltered.sort((a, b) {
                final yearA = int.tryParse(a.year.split('/').first.trim()) ?? 9999;
                final yearB = int.tryParse(b.year.split('/').first.trim()) ?? 9999;
                return yearA.compareTo(yearB);
            });
        }
        // Add other sort conditions
    }


    _filteredArtworks = newlyFiltered;
    _updateActiveFilterChips();
    _isLoading = false;
    notifyListeners();
  }
}