import 'package:flutter/material.dart';
import 'package:hack_front/models/artwork_model.dart';

class ArtatlasCollectionsPage extends StatefulWidget {
  const ArtatlasCollectionsPage({super.key});

  @override
  State<ArtatlasCollectionsPage> createState() =>
      _ArtatlasCollectionsPageState();
}

class _ArtatlasCollectionsPageState extends State<ArtatlasCollectionsPage> {
  // String _activeSubNav = 'Artworks';
  bool _filtersVisible = false;

  // Filter states
  String? _selectedSort = 'Sort: By Relevance';
  String? _selectedDate = 'Date: 1800 - 1980';
  String? _selectedClassification;
  String? _selectedArtist;
  String? _selectedStyle;

  // Active filter chips
  // Store as a list of tuples or small classes to manage label and an identifier for removal
  List<Map<String, String?>> _activeFilterChips = [];

  final List<String> _sortOptions = [
    'Sort: By Relevance',
    'Sort: By Date',
    'Sort: By Artist',
  ];
  final List<String> _dateOptions = [
    'Date: 1800 - 1980',
    'Date: 1900 - Present',
    'All Dates',
  ];
  final List<String> _classificationOptions = [
    'Classifications',
    'Painting',
    'Sculpture',
    'Photography',
  ];
  final List<String> _artistOptions = [
    'Artists',
    'Van Gogh',
    'Monet',
    'Picasso',
  ];
  final List<String> _styleOptions = [
    'Styles',
    'Impressionism',
    'Cubism',
    'Surrealism',
  ];

  @override
  void initState() {
    super.initState();
    _updateActiveFilterChips(); // Initialize with default filters
  }

  void _updateActiveFilterChips() {
    _activeFilterChips.clear();
    if (_selectedSort != null && _selectedSort != _sortOptions.first)
      _activeFilterChips.add({'type': 'sort', 'label': _selectedSort});
    if (_selectedDate != null && _selectedDate != _dateOptions.first)
      _activeFilterChips.add({'type': 'date', 'label': _selectedDate});
    if (_selectedClassification != null &&
        _selectedClassification != _classificationOptions.first)
      _activeFilterChips.add({
        'type': 'classification',
        'label': _selectedClassification,
      });
    if (_selectedArtist != null && _selectedArtist != _artistOptions.first)
      _activeFilterChips.add({'type': 'artist', 'label': _selectedArtist});
    if (_selectedStyle != null && _selectedStyle != _styleOptions.first)
      _activeFilterChips.add({'type': 'style', 'label': _selectedStyle});

    // The problem shows default filters as chips, let's adjust:
    // The image shows "Date: 1800-1980" and "Sort: By Relevance" as active chips by default.
    // So, we'll manually add them if they are the initial values.
    _activeFilterChips.clear(); // Clear previous logic
    if (_selectedSort == 'Sort: By Relevance')
      _activeFilterChips.add({'type': 'sort', 'label': _selectedSort});
    if (_selectedDate == 'Date: 1800 - 1980')
      _activeFilterChips.add({'type': 'date', 'label': _selectedDate});
    // Add others if they are selected and not the placeholder
    if (_selectedClassification != null &&
        _selectedClassification != _classificationOptions.first)
      _activeFilterChips.add({
        'type': 'classification',
        'label': _selectedClassification,
      });
    if (_selectedArtist != null && _selectedArtist != _artistOptions.first)
      _activeFilterChips.add({'type': 'artist', 'label': _selectedArtist});
    if (_selectedStyle != null && _selectedStyle != _styleOptions.first)
      _activeFilterChips.add({'type': 'style', 'label': _selectedStyle});

    // This logic ensures initial filters from image are shown as chips
  }

  void _removeFilterChip(String type, String? label) {
    setState(() {
      if (type == 'sort')
        _selectedSort = _sortOptions.first; // Reset to default
      if (type == 'date') _selectedDate = _dateOptions.first;
      if (type == 'classification')
        _selectedClassification = null; // Or _classificationOptions.first
      if (type == 'artist') _selectedArtist = null;
      if (type == 'style') _selectedStyle = null;
      _updateActiveFilterChips();
    });
  }

  void _clearAllFilters() {
    setState(() {
      _selectedSort = _sortOptions.first;
      _selectedDate = _dateOptions.first;
      _selectedClassification = null;
      _selectedArtist = null;
      _selectedStyle = null;
      _updateActiveFilterChips();
    });
  }

  Widget _buildHeader(String activePage) {
    // This header is slightly different from the previous one
    // "Collection" is highlighted
    Widget navLink(String text, bool isActivePageOverride) {
      bool isActuallyActive = text == activePage || isActivePageOverride;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: isActuallyActive ? Colors.blueAccent : Colors.black87,
            fontWeight: FontWeight.w300,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ART',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w100,
                  letterSpacing: 1.5,
                  color: Colors.black,
                ),
              ),
              Text(
                'ATLAS',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w100,
                  letterSpacing: 1.5,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Row(
            children: [
              navLink('Top Picks', false),

              navLink(
                'Galleries',
                false,
              ), // Hardcode Collection as active for this page
              navLink('Collection', true),
              const SizedBox(width: 20),
            ],
          ),
        ],
      ),
    );
  }

  // Widget _buildSubNavigation() {
  //   Widget tab(String title) {
  //     bool isActive = _activeSubNav == title;
  //     return GestureDetector(
  //       onTap: () => setState(() => _activeSubNav = title),
  //       child: Container(
  //         padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
  //         decoration: BoxDecoration(
  //           border: Border(
  //             bottom: BorderSide(
  //               color: isActive ? Colors.black : Colors.transparent,
  //               width: 2.0,
  //             ),
  //           ),
  //         ),
  //         child: Text(
  //           title,
  //           style: TextStyle(
  //             fontSize: 16,
  //             fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
  //             color: Colors.black87,
  //           ),
  //         ),
  //       ),
  //     );
  //   }

  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 20.0),
  //     child: Row(
  //       children: [tab('Artworks'), tab('Writings'), tab('Resources')],
  //     ),
  //   );
  // }

  Widget _buildSearchAndFilterToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 8),
          const Expanded(
            child: TextField(
              decoration: InputDecoration.collapsed(
                hintText: 'Search by painting, artists or keyword',
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () => setState(() => _filtersVisible = !_filtersVisible),
            icon: Icon(
              _filtersVisible
                  ? Icons.filter_list_off_outlined
                  : Icons.filter_list,
              color: Colors.black54,
            ),
            label: Text(
              _filtersVisible ? 'Hide Filters' : 'Show Filters',
              style: const TextStyle(color: Colors.black54),
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdowns() {
    Widget filterDropdown({
      required String? value,
      required List<String> items,
      required String hint,
      required ValueChanged<String?> onChanged,
    }) {
      return Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6.0),
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value:
                  value ??
                  items
                      .first, // Ensure a value is always selected, use hint as default
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              hint: Text(hint, style: const TextStyle(color: Colors.grey)),
              items: items.map<DropdownMenuItem<String>>((String val) {
                return DropdownMenuItem<String>(
                  value: val,
                  child: Text(val, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: (newValue) {
                onChanged(newValue);
                _updateActiveFilterChips();
                setState(() {});
              },
              style: const TextStyle(color: Colors.black87, fontSize: 14),
            ),
          ),
        ),
      );
    }

    return Visibility(
      visible: _filtersVisible,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        child: Row(
          children: [
            filterDropdown(
              value: _selectedSort,
              items: _sortOptions,
              hint: 'Sort By',
              onChanged: (val) => _selectedSort = val,
            ),
            filterDropdown(
              value: _selectedDate,
              items: _dateOptions,
              hint: 'Date',
              onChanged: (val) => _selectedDate = val,
            ),
            filterDropdown(
              value: _selectedClassification,
              items: _classificationOptions,
              hint: 'Classifications',
              onChanged: (val) => _selectedClassification = val,
            ),
            filterDropdown(
              value: _selectedArtist,
              items: _artistOptions,
              hint: 'Artists',
              onChanged: (val) => _selectedArtist = val,
            ),
            filterDropdown(
              value: _selectedStyle,
              items: _styleOptions,
              hint: 'Styles',
              onChanged: (val) => _selectedStyle = val,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveFilters() {
    if (_activeFilterChips.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 15.0),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _activeFilterChips.map((chipData) {
                return Chip(
                  label: Text(
                    chipData['label']!,
                    style: const TextStyle(fontSize: 13),
                  ),
                  onDeleted: () =>
                      _removeFilterChip(chipData['type']!, chipData['label']),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  backgroundColor: Colors.grey.shade200,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                    side: BorderSide.none,
                  ),
                );
              }).toList(),
            ),
          ),
          TextButton(
            onPressed: _clearAllFilters,
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.blueAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtworkGrid() {
    // Determine number of columns based on screen width, for simplicity using fixed 4 here
    const int crossAxisCount = 4;
    const double childAspectRatio = 0.75; // Adjust as needed (width / height)
    const double spacing = 20.0;

    return GridView.builder(
      padding: const EdgeInsets.only(top: 20.0),
      shrinkWrap:
          true, // Important if GridView is inside a non-scrollable parent like Column
      physics:
          const NeverScrollableScrollPhysics(), // If parent is SingleChildScrollView
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: sampleArtworks.length,
      itemBuilder: (context, index) {
        final artwork = sampleArtworks[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Image.network(
                artwork.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade300,
                  child: const Center(child: Icon(Icons.broken_image)),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${artwork.title} — ${artwork.year}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              artwork.artist,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use a maximum width for the content area on larger screens
    double contentMaxWidth = MediaQuery.of(context).size.width * 0.95;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: contentMaxWidth),
          child: Column(
            children: [
              _buildHeader('Galleries'), // Pass active page identifier
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 10.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //     _buildSubNavigation(),
                      _buildSearchAndFilterToggle(),
                      _buildFilterDropdowns(),
                      _buildActiveFilters(),
                      const Divider(height: 1, thickness: 1),
                      _buildArtworkGrid(),
                      const SizedBox(height: 40), // Some padding at the bottom
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
