import 'package:flutter/material.dart';
import 'package:hack_front/models/artwork_model.dart';
import 'package:hack_front/providers/collections_provider.dart';
import 'package:hack_front/providers/navigation_provider.dart';
import 'package:hack_front/utils/responsive_util.dart';
import 'package:provider/provider.dart';

class ArtatlasCollectionsPage extends StatelessWidget {
  const ArtatlasCollectionsPage({super.key});

  Widget _buildDesktopHeader(BuildContext context) {
    final navFontSize = ResponsiveUtil.getHeaderNavFontSize(context);
    final headerPadding = ResponsiveUtil.getBodyPadding(context);
    final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);

    void handleDesktopHeaderLinkTap(String routeName) {
      int targetIndex = -1;
      if (routeName == 'Home') targetIndex = 0;
      if (routeName == 'Galleries') targetIndex = 1;
      // "Collection" is the current page, no action or handled by provider if it were a different page.

      if (targetIndex != -1) {
        navigationProvider.onItemTapped(targetIndex);
      }
    }

    Widget navLink(String text) {
      bool isThisPageLink = text == "Collection";
      int currentTabIndex = navigationProvider.selectedIndex;
      bool isActive = (text == 'Home' && currentTabIndex == 0) ||
                      (text == 'Galleries' && currentTabIndex == 1) ||
                      (text == 'Collection' && currentTabIndex == 2);

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: GestureDetector(
          onTap: () => handleDesktopHeaderLinkTap(text),
          child: Text(
            text,
            style: TextStyle(
              fontSize: navFontSize,
              color: isActive
                  ? Colors.blueAccent
                  : Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70 // Adjusted for better visibility in dark theme
                      : Colors.black87,
              fontWeight: isActive ? FontWeight.w400 : FontWeight.w300,
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

  Widget _buildFilterDropdowns(
      BuildContext context, CollectionsProvider provider) {
    final isMobile = ResponsiveUtil.isMobile(context);

    Widget filterDropdown({
      required String? value,
      required List<String> items,
      required ValueChanged<String?> onChanged,
      required String hintText,
    }) {
      Widget dropdown = Container(
        margin: EdgeInsets.symmetric(
          horizontal: isMobile ? 0 : 6.0,
          vertical: isMobile ? 4.0 : 0,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        decoration: BoxDecoration(
          // Use Theme colors for border
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: value,
            hint: Text(hintText, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            items: items
                .map<DropdownMenuItem<String>>(
                  (String val) => DropdownMenuItem<String>(
                    value: val,
                    child: Text(
                      val,
                      style: TextStyle(
                        fontSize: 13,
                        // Use Theme colors for text
                        color: val == items.first && items.first.contains(":") // Heuristic for placeholder
                            ? Theme.of(context).hintColor
                            : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: onChanged,
            style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyLarge?.color),
            icon: Icon(Icons.keyboard_arrow_down, color: Theme.of(context).hintColor),
            dropdownColor: Theme.of(context).cardColor,
          ),
        ),
      );
      return isMobile ? dropdown : Expanded(child: dropdown);
    }

    List<Widget> dropdownWidgets = [
      filterDropdown(
        value: provider.selectedSort,
        items: provider.sortOptions,
        onChanged: (val) => provider.updateSelectedSort(val),
        hintText: "Sort by"
      ),
      filterDropdown(
        value: provider.selectedDate,
        items: provider.dateOptions,
        onChanged: (val) => provider.updateSelectedDate(val),
        hintText: "Date range"
      ),
      filterDropdown(
        value: provider.selectedClassification,
        items: provider.classificationOptions,
        onChanged: (val) => provider.updateSelectedClassification(val),
        hintText: "Classification"
      ),
      filterDropdown(
        value: provider.selectedArtist,
        items: provider.artistOptions,
        onChanged: (val) => provider.updateSelectedArtist(val),
        hintText: "Artist"
      ),
      filterDropdown(
        value: provider.selectedStyle,
        items: provider.styleOptions,
        onChanged: (val) => provider.updateSelectedStyle(val),
        hintText: "Style"
      ),
    ];

    return Visibility(
      visible: provider.filtersVisible,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        child: isMobile
            ? Column(
                children: dropdownWidgets
                    .map((w) => Padding(padding: const EdgeInsets.symmetric(vertical: 4.0), child: w))
                    .toList())
            : Row(
                children: dropdownWidgets
                    .map((w) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4.0), child: w)))
                    .toList()),
      ),
    );
  }

  Widget _buildActiveFilters(
      BuildContext context, CollectionsProvider provider) {
    if (provider.activeFilterChips.isEmpty && !provider.filtersVisible) {
      return const SizedBox.shrink();
    }
    if (provider.activeFilterChips.isEmpty && provider.filtersVisible) {
      return Padding(
        padding: const EdgeInsets.only(top: 0, bottom: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (provider.filtersVisible)
              TextButton(
                onPressed: provider.clearAllFilters,
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
              children: provider.activeFilterChips
                  .map(
                    (chipData) => Chip(
                      label: Text(
                        chipData['label']!,
                        style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color),
                      ),
                      onDeleted: () => provider.removeFilterChip(
                        chipData['type']!,
                        chipData['label'],
                      ),
                      deleteIcon: Icon(Icons.close, size: 14, color: Theme.of(context).iconTheme.color?.withOpacity(0.7)),
                      backgroundColor: Theme.of(context).chipTheme.backgroundColor,
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
          if (provider.activeFilterChips.isNotEmpty)
            TextButton(
              onPressed: provider.clearAllFilters,
              child: const Text(
                'Clear All',
                style: TextStyle(color: Colors.blueAccent, fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildArtworkGrid(
      BuildContext context, CollectionsProvider provider) {
    final crossAxisCount = ResponsiveUtil.getCrossAxisCountForCollectionsGrid(
      context,
    );
    final childAspectRatio = ResponsiveUtil.getCollectionsGridAspectRatio(
      context,
    );
    const double spacing = 16.0;

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.artworks.isEmpty && !provider.isLoading) {
      return const Center(child: Text("No artworks found matching your criteria."));
    }

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
      itemCount: provider.artworks.length,
      itemBuilder: (context, index) {
        final artwork = provider.artworks[index];
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
                    color: Theme.of(context).colorScheme.surfaceVariant,
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
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Theme.of(context).textTheme.bodyLarge?.color),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              artwork.artist,
              style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
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
    final collectionsProvider = Provider.of<CollectionsProvider>(context);
    final isMobile = ResponsiveUtil.isMobile(context);
    final bodyPadding = ResponsiveUtil.getBodyPadding(context);
    double contentMaxWidth = ResponsiveUtil.isDesktop(context)
        ? MediaQuery.of(context).size.width * 0.90
        : MediaQuery.of(context).size.width;

    // Theme adjustments for TextField and Icons to work with dark/light themes
    final hintColor = Theme.of(context).hintColor;
    final iconColor = Theme.of(context).iconTheme.color;


    Widget searchBar = Padding(
      padding: EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: isMobile ? 0 : 0, // No extra horizontal padding if already in bodyPadding
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
              decoration: InputDecoration.collapsed(
                hintText: 'Search by painting, artists or keyword',
                hintStyle: TextStyle(color: hintColor, fontSize: 14),
              ),
              onChanged: (query) {
                // collectionsProvider.updateSearchQuery(query); // Implement in provider
              },
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
              if (isMobile) const SizedBox(height: 16), // Top padding for mobile content
              searchBar,
              if (!isMobile)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: collectionsProvider.toggleFiltersVisibility,
                    icon: Icon(
                      collectionsProvider.filtersVisible
                          ? Icons.filter_list_off_outlined
                          : Icons.filter_list,
                      color: iconColor,
                    ),
                    label: Text(
                      collectionsProvider.filtersVisible
                          ? 'Hide Filters'
                          : 'Show Filters',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.labelLarge?.color,
                        fontSize: 14,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
              _buildFilterDropdowns(context, collectionsProvider),
              _buildActiveFilters(context, collectionsProvider),
              Divider(height: 1, thickness: 1, color: Theme.of(context).dividerColor),
              _buildArtworkGrid(context, collectionsProvider),
              const SizedBox(height: 40), // Bottom padding
            ],
          ),
        ),
      ],
    );

    if (isMobile) {
      return Scaffold(
        // Use theme for AppBar colors
        appBar: AppBar(
          title: const Text('Collections'),
          centerTitle: false, // Typically false for Material Design on mobile
          actions: [
            IconButton(
              icon: Icon(
                collectionsProvider.filtersVisible
                    ? Icons.filter_list_off_outlined
                    : Icons.filter_list,
                color: Theme.of(context).appBarTheme.actionsIconTheme?.color ?? Theme.of(context).iconTheme.color,
              ),
              onPressed: collectionsProvider.toggleFiltersVisibility,
              tooltip: collectionsProvider.filtersVisible
                  ? 'Hide Filters'
                  : 'Show Filters',
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Center( // Center the content if narrower than screen
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    (AppBar().preferredSize.height +
                        MediaQuery.of(context).padding.top +
                        (isMobile ? kBottomNavigationBarHeight : 0)), // Account for nav bar
                maxWidth: contentMaxWidth,
              ),
              child: pageContent,
            ),
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