import 'package:flutter/material.dart';
import 'package:hack_front/models/artwork_model.dart';
import 'package:hack_front/responsive_util.dart';

class ArtatlasCollectionsPage extends StatefulWidget {
  final Function(int)? onNavigateToTab;
  const ArtatlasCollectionsPage({super.key, this.onNavigateToTab});

  @override
  State<ArtatlasCollectionsPage> createState() =>
      _ArtatlasCollectionsPageState();
}

class _ArtatlasCollectionsPageState extends State<ArtatlasCollectionsPage> {
  bool _filtersVisible = false;

  String? _selectedSort = 'Sort: By Relevance';
  String? _selectedDate = 'Date: 1800 - 1980';
  String? _selectedClassification;
  String? _selectedArtist;
  String? _selectedStyle;

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
    _selectedClassification = _classificationOptions.first;
    _selectedArtist = _artistOptions.first;
    _selectedStyle = _styleOptions.first;
    _updateActiveFilterChips();
  }

  void _toggleFiltersVisibility() {
    setState(() {
      _filtersVisible = !_filtersVisible;
    });
  }

  void _updateActiveFilterChips() {
    _activeFilterChips.clear();
    if (_selectedSort == 'Sort: By Relevance') {
      _activeFilterChips.add({'type': 'sort', 'label': _selectedSort});
    }
    if (_selectedDate == 'Date: 1800 - 1980') {
      _activeFilterChips.add({'type': 'date', 'label': _selectedDate});
    }
    if (_selectedClassification != null &&
        _selectedClassification != _classificationOptions.first) {
      _activeFilterChips.add({
        'type': 'classification',
        'label': _selectedClassification,
      });
    }
    if (_selectedArtist != null && _selectedArtist != _artistOptions.first) {
      _activeFilterChips.add({'type': 'artist', 'label': _selectedArtist});
    }
    if (_selectedStyle != null && _selectedStyle != _styleOptions.first) {
      _activeFilterChips.add({'type': 'style', 'label': _selectedStyle});
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _removeFilterChip(String type, String? label) {
    setState(() {
      if (type == 'sort') {
        _selectedSort = _sortOptions.first;
      }
      if (type == 'date') {
        _selectedDate = _dateOptions.first;
      }
      if (type == 'classification') {
        _selectedClassification = _classificationOptions.first;
      }
      if (type == 'artist') {
        _selectedArtist = _artistOptions.first;
      }
      if (type == 'style') {
        _selectedStyle = _styleOptions.first;
      }
      _updateActiveFilterChips();
    });
  }

  void _clearAllFilters() {
    setState(() {
      _selectedSort = _sortOptions.first;
      _selectedDate = _dateOptions.first;
      _selectedClassification = _classificationOptions.first;
      _selectedArtist = _artistOptions.first;
      _selectedStyle = _styleOptions.first;
      _updateActiveFilterChips();
    });
  }

  Widget _buildDesktopHeader(BuildContext context) {
    final navFontSize = ResponsiveUtil.getHeaderNavFontSize(context);
    final headerPadding = ResponsiveUtil.getBodyPadding(context);

    void handleDesktopHeaderLinkTap(String routeName) {
      int targetIndex = -1;
      if (routeName == 'Home') targetIndex = 0;
      if (routeName == 'Galleries') targetIndex = 1;

      if (targetIndex != -1 && widget.onNavigateToTab != null) {
        widget.onNavigateToTab!(targetIndex);
      } else {
        print("Desktop header link tapped: $routeName (no action or self)");
      }
    }

    Widget navLink(String text) {
      bool isThisPageLink = text == "Collection";
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: GestureDetector(
          onTap: () => handleDesktopHeaderLinkTap(text),
          child: Text(
            text,
            style: TextStyle(
              fontSize: navFontSize,
              color: isThisPageLink
                  ? Colors.blueAccent
                  : Theme.of(context).brightness == Brightness.dark
                  ? Colors.white38
                  : Colors.black87,
              fontWeight: isThisPageLink ? FontWeight.w400 : FontWeight.w300,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: headerPadding, vertical: 30.0),
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
                ),
              ),
              Text(
                'ATLAS',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w100,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          Row(
            children: [
              navLink('Home'),
              navLink('Galleries'),
              navLink('Collection'),
              const SizedBox(width: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdowns(BuildContext context) {
    final isMobile = ResponsiveUtil.isMobile(context);
    Widget filterDropdown({
      required String? value,
      required List<String> items,
      required ValueChanged<String?> onChanged,
    }) {
      Widget dropdown = Container(
        margin: EdgeInsets.symmetric(
          horizontal: isMobile ? 0 : 6.0,
          vertical: isMobile ? 4.0 : 0,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: value,
            items: items
                .map<DropdownMenuItem<String>>(
                  (String val) => DropdownMenuItem<String>(
                    value: val,
                    child: Text(
                      val,
                      style: TextStyle(
                        fontSize: 13,
                        color: val == items.first
                            ? Colors.grey.shade600
                            : Colors.black87,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (newValue) {
              onChanged(newValue);
              _updateActiveFilterChips();
            },
            style: const TextStyle(fontSize: 14),
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          ),
        ),
      );
      return isMobile ? dropdown : Expanded(child: dropdown);
    }

    List<Widget> dropdownWidgets = [
      filterDropdown(
        value: _selectedSort,
        items: _sortOptions,
        onChanged: (val) => setState(() => _selectedSort = val),
      ),
      filterDropdown(
        value: _selectedDate,
        items: _dateOptions,
        onChanged: (val) => setState(() => _selectedDate = val),
      ),
      filterDropdown(
        value: _selectedClassification,
        items: _classificationOptions,
        onChanged: (val) => setState(() => _selectedClassification = val),
      ),
      filterDropdown(
        value: _selectedArtist,
        items: _artistOptions,
        onChanged: (val) => setState(() => _selectedArtist = val),
      ),
      filterDropdown(
        value: _selectedStyle,
        items: _styleOptions,
        onChanged: (val) => setState(() => _selectedStyle = val),
      ),
    ];
    return Visibility(
      visible: _filtersVisible,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        child: isMobile
            ? Column(children: dropdownWidgets)
            : Row(children: dropdownWidgets),
      ),
    );
  }

  Widget _buildActiveFilters(BuildContext context) {
    if (_activeFilterChips.isEmpty && !_filtersVisible) {
      return const SizedBox.shrink();
    }
    if (_activeFilterChips.isEmpty && _filtersVisible) {
      return Padding(
        padding: const EdgeInsets.only(top: 0, bottom: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (_filtersVisible)
              TextButton(
                onPressed: _clearAllFilters,
                child: const Text(
                  'Clear All',
                  style: TextStyle(color: Colors.blueAccent, fontSize: 13),
                ),
              ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 15.0),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _activeFilterChips
                  .map(
                    (chipData) => Chip(
                      label: Text(
                        chipData['label']!,
                        style: const TextStyle(fontSize: 12),
                      ),
                      onDeleted: () => _removeFilterChip(
                        chipData['type']!,
                        chipData['label'],
                      ),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      backgroundColor: Colors.grey.shade200,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6.0,
                        vertical: 2.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                        side: BorderSide.none,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          if (_activeFilterChips.isNotEmpty)
            TextButton(
              onPressed: _clearAllFilters,
              child: const Text(
                'Clear All',
                style: TextStyle(color: Colors.blueAccent, fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildArtworkGrid(BuildContext context) {
    final crossAxisCount = ResponsiveUtil.getCrossAxisCountForCollectionsGrid(
      context,
    );
    final childAspectRatio = ResponsiveUtil.getCollectionsGridAspectRatio(
      context,
    );
    const double spacing = 16.0;
    final filteredArtworks = sampleArtworks;
    return GridView.builder(
      padding: const EdgeInsets.only(top: 20.0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: filteredArtworks.length,
      itemBuilder: (context, index) {
        final artwork = filteredArtworks[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Image.network(
                  artwork.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade300,
                    child: const Center(child: Icon(Icons.broken_image)),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${artwork.title} — ${artwork.year}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              artwork.artist,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
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
    final isMobile = ResponsiveUtil.isMobile(context);
    final bodyPadding = ResponsiveUtil.getBodyPadding(context);
    double contentMaxWidth = ResponsiveUtil.isDesktop(context)
        ? MediaQuery.of(context).size.width * 0.90
        : MediaQuery.of(context).size.width;

    Widget searchBar = Padding(
      padding: EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: isMobile ? 0 : 0,
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 8),
          const Expanded(
            child: TextField(
              decoration: InputDecoration.collapsed(
                hintText: 'Search by painting, artists or keyword',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );

    Widget pageContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isMobile) _buildDesktopHeader(context),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: bodyPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isMobile) const SizedBox(height: 16),
              searchBar,
              if (!isMobile)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _toggleFiltersVisibility,
                    icon: Icon(
                      _filtersVisible
                          ? Icons.filter_list_off_outlined
                          : Icons.filter_list,
                      color: Colors.black54,
                    ),
                    label: Text(
                      _filtersVisible ? 'Hide Filters' : 'Show Filters',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
              _buildFilterDropdowns(context),
              _buildActiveFilters(context),
              const Divider(height: 1, thickness: 1),
              _buildArtworkGrid(context),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );

    if (isMobile) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Collections'),
          centerTitle: false,
          actions: [
            IconButton(
              icon: Icon(
                _filtersVisible
                    ? Icons.filter_list_off_outlined
                    : Icons.filter_list,
                color: Colors.black54,
              ),
              onPressed: _toggleFiltersVisibility,
              tooltip: _filtersVisible ? 'Hide Filters' : 'Show Filters',
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  (AppBar().preferredSize.height +
                      MediaQuery.of(context).padding.top +
                      kBottomNavigationBarHeight),
              maxWidth: contentMaxWidth,
            ),
            child: pageContent,
          ),
        ),
      );
    } else {
      return SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: contentMaxWidth),
            child: pageContent,
          ),
        ),
      );
    }
  }
}
