import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hack_front/providers/auth_provider.dart'; // For potential logout in settings
import 'package:hack_front/providers/collections_provider.dart';
import 'package:hack_front/providers/navigation_provider.dart';
import 'package:hack_front/providers/theme_provider.dart';
import 'package:hack_front/utils/responsive_util.dart';
import 'package:provider/provider.dart';

class ArtatlasCollectionsPage extends StatelessWidget {
  const ArtatlasCollectionsPage({super.key});

  Widget _buildSettingsButton(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isCurrentlyDark = themeProvider.isDarkMode;
    final ThemeData theme = Theme.of(context);

    return PopupMenuButton<String>(
      icon: Icon(Icons.settings_outlined, color: theme.iconTheme.color),
      tooltip: "Settings",
      color: theme.cardColor, // Ensure popup menu background is themed
      onSelected: (value) {
        if (value == 'toggle_theme') {
          themeProvider.toggleTheme();
        }
        if (value == 'logout') {
          // Optional: Logout from here
          final authProvider = Provider.of<AuthProvider>(
            context,
            listen: false,
          );
          authProvider.signOut();
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'toggle_theme',
          child: Row(
            children: [
              Icon(
                isCurrentlyDark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
                color: theme.iconTheme.color,
              ),
              const SizedBox(width: 12),
              Text(
                isCurrentlyDark
                    ? 'Switch to Light Mode'
                    : 'Switch to Dark Mode',
                style: TextStyle(color: theme.textTheme.bodyMedium?.color),
              ),
            ],
          ),
        ),
        // Optional Logout Item
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(
                Icons.logout,
                color: theme.iconTheme.color?.withOpacity(0.8),
              ),
              const SizedBox(width: 12),
              Text(
                'Sign Out',
                style: TextStyle(color: theme.textTheme.bodyMedium?.color),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleNavLink(
    String text,
    int targetIndex,
    BuildContext context,
  ) {
    final ThemeData theme = Theme.of(context);
    final navigationProvider = Provider.of<NavigationProvider>(
      context,
      listen: false,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: InkWell(
        onTap: () => navigationProvider.onItemTapped(targetIndex),
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(
            text,
            style: TextStyle(
              fontSize: ResponsiveUtil.getHeaderNavFontSize(context) * 0.9,
              color: theme.colorScheme.onBackground.withOpacity(0.7),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterDropdowns(
    BuildContext context,
    CollectionsProvider provider,
  ) {
    final ThemeData theme = Theme.of(context);
    final isMobile = ResponsiveUtil.isMobile(context);

    Widget filterDropdown({
      required String? value,
      required List<String> items,
      required ValueChanged<String?> onChanged,
      required String hintText,
    }) {
      return Container(
        margin: EdgeInsets.symmetric(
          horizontal: isMobile ? 0 : 4.0,
          vertical: isMobile ? 4.0 : 0,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border.all(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: value,
            hint: Text(
              hintText,
              style: TextStyle(
                fontSize: 13,
                color: theme.hintColor.withOpacity(0.8),
              ),
            ),
            items: items
                .map<DropdownMenuItem<String>>(
                  (String val) => DropdownMenuItem<String>(
                    value: val,
                    child: Text(
                      val,
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            val == items.first &&
                                (val.contains("Sort:") ||
                                    val.contains("Date:") ||
                                    val.contains(": All"))
                            ? theme.hintColor
                            : theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: onChanged,
            style: TextStyle(
              fontSize: 14,
              color: theme.textTheme.bodyLarge?.color,
            ),
            icon: Icon(Icons.keyboard_arrow_down, color: theme.hintColor),
            dropdownColor: theme.cardColor,
          ),
        ),
      );
    }

    List<Widget> dropdownWidgets = [
      filterDropdown(
        value: provider.selectedSort,
        items: provider.sortOptions,
        onChanged: (val) => provider.updateSelectedSort(val),
        hintText: "Sort by",
      ),
      filterDropdown(
        value: provider.selectedDate,
        items: provider.dateOptions,
        onChanged: (val) => provider.updateSelectedDate(val),
        hintText: "Date range",
      ),
      filterDropdown(
        value: provider.selectedClassification,
        items: provider.classificationOptions,
        onChanged: (val) => provider.updateSelectedClassification(val),
        hintText: "Classification",
      ),
      filterDropdown(
        value: provider.selectedArtist,
        items: provider.artistOptions,
        onChanged: (val) => provider.updateSelectedArtist(val),
        hintText: "Artist",
      ),
      filterDropdown(
        value: provider.selectedStyle,
        items: provider.styleOptions,
        onChanged: (val) => provider.updateSelectedStyle(val),
        hintText: "Style",
      ),
    ];

    return Visibility(
      visible: provider.filtersVisible,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        child: isMobile
            ? Column(
                children: dropdownWidgets
                    .map(
                      (w) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: w,
                      ),
                    )
                    .toList(),
              )
            : Row(
                children: dropdownWidgets
                    .map(
                      (w) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: w,
                        ),
                      ),
                    )
                    .toList(),
              ),
      ),
    );
  }

  Widget _buildActiveFilters(
    BuildContext context,
    CollectionsProvider provider,
  ) {
    final ThemeData theme = Theme.of(context);
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
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    color: theme.colorScheme.secondary,
                    fontSize: 13,
                  ),
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
                      // Chip styling will come from AppTheme.chipTheme
                      label: Text(chipData['label']!),
                      onDeleted: () => provider.removeFilterChip(
                        chipData['type']!,
                        chipData['label'],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          if (provider.activeFilterChips.isNotEmpty)
            TextButton(
              onPressed: provider.clearAllFilters,
              child: Text(
                'Clear All',
                style: TextStyle(
                  color: theme.colorScheme.secondary,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildArtworkGrid(BuildContext context, CollectionsProvider provider) {
    final ThemeData theme = Theme.of(context);
    final crossAxisCount = ResponsiveUtil.getCrossAxisCountForCollectionsGrid(
      context,
    );
    final childAspectRatio = ResponsiveUtil.getCollectionsGridAspectRatio(
      context,
    );
    const double spacing = 16.0;

    if (provider.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
        ),
      );
    }
    if (provider.artworks.isEmpty && !provider.isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: Text(
            "No artworks found matching your criteria.",
            style: TextStyle(
              color: theme.colorScheme.onBackground.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ),
      );
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
                  color: theme.colorScheme.surfaceVariant.withOpacity(
                    0.3,
                  ), // Slightly transparent bg
                ),
                child: CachedNetworkImage(
                  imageUrl: artwork.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,

                  errorWidget: (context, error, stackTrace) => Container(
                    color: theme.colorScheme.surfaceVariant,
                    child: Center(
                      child: Icon(
                        Icons.broken_image,
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(
                          0.7,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${artwork.title} — ${artwork.year}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: theme.textTheme.bodyLarge?.color,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              artwork.artist,
              style: TextStyle(fontSize: 12, color: theme.hintColor),
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
    final ThemeData theme = Theme.of(context);
    final collectionsProvider = Provider.of<CollectionsProvider>(context);
    final isMobile = ResponsiveUtil.isMobile(context);
    final bodyPadding = ResponsiveUtil.getBodyPadding(context);
    double contentMaxWidth = ResponsiveUtil.isDesktop(context)
        ? MediaQuery.of(context).size.width * 0.90
        : MediaQuery.of(context).size.width;

    Widget searchBar = Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: TextField(
        style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Search by painting, artists or keyword',
          hintStyle: TextStyle(color: theme.hintColor, fontSize: 16),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 10.0),
            child: Icon(Icons.search, color: theme.iconTheme.color, size: 22),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14.0,
            horizontal: 20.0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.7)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.7)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 1.5,
            ),
          ),
          // fillColor: theme.colorScheme.surface.withOpacity(0.5), // Optional fill
          // filled: true,
        ),
        onChanged: (query) {
          collectionsProvider.updateSearchQuery(query);
        },
      ),
    );

    Widget filterAndSettingsControls = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          onPressed: collectionsProvider.toggleFiltersVisibility,
          icon: Icon(
            collectionsProvider.filtersVisible
                ? Icons.filter_list_off_outlined
                : Icons.filter_list,
            color: theme.iconTheme.color,
          ),
          label: Text(
            collectionsProvider.filtersVisible
                ? 'Hide Filters'
                : 'Show Filters',
            style: TextStyle(
              color: theme.textTheme.labelLarge?.color,
              fontSize: 14,
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 8),
        _buildSettingsButton(context),
      ],
    );

    Widget pageContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            bodyPadding,
            isMobile ? 16.0 : 30.0,
            bodyPadding,
            isMobile ? 0 : 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isMobile)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        "Collections",
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildSimpleNavLink("Home", 0, context),
                        _buildSimpleNavLink("Galleries", 1, context),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            "Collection",
                            style: TextStyle(
                              fontSize:
                                  ResponsiveUtil.getHeaderNavFontSize(context) *
                                  0.9,
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              searchBar,
              if (!isMobile)
                Padding(
                  padding: const EdgeInsets.only(top: 0.0, bottom: 10.0),
                  child: filterAndSettingsControls,
                ),
              _buildFilterDropdowns(context, collectionsProvider),
              _buildActiveFilters(context, collectionsProvider),
              Divider(height: 1, thickness: 1, color: theme.dividerColor),
            ],
          ),
        ),
        // Artwork grid needs its own padding or to be outside the main Padding widget
        // if its internal padding `const EdgeInsets.only(top: 20.0)` is sufficient.
        // For now, let's assume the grid manages its own top padding and bodyPadding handles horizontal.
        Padding(
          padding: EdgeInsets.only(
            left: bodyPadding,
            right: bodyPadding,
            bottom: 40.0,
          ),
          child: _buildArtworkGrid(context, collectionsProvider),
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
                collectionsProvider.filtersVisible
                    ? Icons.filter_list_off_outlined
                    : Icons.filter_list,
              ),
              onPressed: collectionsProvider.toggleFiltersVisibility,
              tooltip: collectionsProvider.filtersVisible
                  ? 'Hide Filters'
                  : 'Show Filters',
            ),
            _buildSettingsButton(context),
          ],
        ),
        body: SingleChildScrollView(
          child: pageContent, // pageContent already includes necessary padding
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentMaxWidth),
              child: pageContent,
            ),
          ),
        ),
      );
    }
  }
}
