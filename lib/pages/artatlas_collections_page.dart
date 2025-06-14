// lib/pages/artatlas_collections_page.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hack_front/providers/auth_provider.dart';
import 'package:hack_front/providers/collections_provider.dart';
import 'package:hack_front/providers/navigation_provider.dart';
import 'package:hack_front/providers/theme_provider.dart';
import 'package:hack_front/utils/responsive_util.dart';
import 'package:provider/provider.dart';

class ArtatlasCollectionsPage extends StatefulWidget {
  const ArtatlasCollectionsPage({super.key});

  @override
  State<ArtatlasCollectionsPage> createState() =>
      _ArtatlasCollectionsPageState();
}

class _ArtatlasCollectionsPageState extends State<ArtatlasCollectionsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final provider = Provider.of<CollectionsProvider>(context, listen: false);
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 300 &&
        !provider.isLoadingMore &&
        provider.hasMoreArtworks) {
      provider.loadMoreArtworks();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildSettingsButton(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isCurrentlyDark = themeProvider.isDarkMode;
    final ThemeData theme = Theme.of(context);

    return PopupMenuButton<String>(
      icon: Icon(Icons.settings_outlined, color: theme.iconTheme.color),
      tooltip: "Settings",
      color: theme.cardColor,
      onSelected: (value) {
        if (value == 'toggle_theme') {
          themeProvider.toggleTheme();
        }
        if (value == 'logout') {
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
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(
                Icons.logout,
                color: theme.iconTheme.color?.withAlpha((0.8 * 255).round()),
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
              color: theme.colorScheme.onSurface.withAlpha((0.7 * 255).round()),
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
                color: theme.hintColor.withAlpha((0.8 * 255).round()),
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

  // This method now returns a Sliver type for use in CustomScrollView
  Widget _buildArtworkGridSliver(
    BuildContext context,
    CollectionsProvider provider,
  ) {
    final ThemeData theme = Theme.of(context);
    final crossAxisCount = ResponsiveUtil.getCrossAxisCountForCollectionsGrid(
      context,
    );
    final childAspectRatio = ResponsiveUtil.getCollectionsGridAspectRatio(
      context,
    );
    const double spacing = 16.0;
    final bodyPadding = ResponsiveUtil.getBodyPadding(
      context,
    ); // Get bodyPadding

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        bodyPadding,
        20.0,
        bodyPadding,
        20.0,
      ), // Apply horizontal padding here
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: childAspectRatio,
        ),
        delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
          final artwork = provider.artworks[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: theme.colorScheme.surfaceContainerHighest.withAlpha(
                      (0.3 * 255).round(),
                    ),
                  ),
                  child:
                      (artwork.imageUrl != null && artwork.imageUrl!.isNotEmpty)
                      ? CachedNetworkImage(
                          imageUrl: artwork.imageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) => Container(
                            color: theme.colorScheme.surfaceContainerHighest.withAlpha(
                              (0.1 * 255).round(),
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                valueColor: AlwaysStoppedAnimation(
                                  theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: Center(
                              child: Icon(
                                Icons.broken_image,
                                color: theme.colorScheme.onSurfaceVariant
                                    .withAlpha((0.7 * 255).round()),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: theme.colorScheme.onSurfaceVariant
                                  .withAlpha((0.7 * 255).round()),
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${artwork.artworkTitle ?? "Untitled"} — ${artwork.year ?? "N/A"}',
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
                artwork.artistName ?? "Unknown Artist",
                style: TextStyle(fontSize: 12, color: theme.hintColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );
        }, childCount: provider.artworks.length),
      ),
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
      padding: EdgeInsets.symmetric(
        horizontal: isMobile
            ? 0
            : 0, // Horizontal padding handled by parent on mobile
        vertical: 16.0,
      ),
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
            borderSide: BorderSide(
              color: theme.dividerColor.withAlpha((0.7 * 255).round()),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(
              color: theme.dividerColor.withAlpha((0.7 * 255).round()),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 1.5,
            ),
          ),
        ),
        onChanged: (query) {
          collectionsProvider.updateSearchQuery(query);
        },
      ),
    );

    Widget filterAndSettingsControlsDesktop = Row(
      // Renamed for clarity
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

    if (isMobile) {
      // --- Mobile Layout with CustomScrollView ---
      return Scaffold(
        body: CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            SliverAppBar(
              title: const Text('Collections'),
              pinned: true,
              floating: true,
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
            // Search bar and filters are part of the scrollable content on mobile
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: bodyPadding,
                ), // Apply bodyPadding
                child: searchBar,
              ),
            ),
            if (collectionsProvider.filtersVisible)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: bodyPadding),
                  child: _buildFilterDropdowns(context, collectionsProvider),
                ),
              ),
            if (collectionsProvider.filtersVisible ||
                collectionsProvider.activeFilterChips.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: bodyPadding),
                  child: _buildActiveFilters(context, collectionsProvider),
                ),
              ),
            if (collectionsProvider.filtersVisible ||
                collectionsProvider.activeFilterChips.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: bodyPadding),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: theme.dividerColor,
                  ),
                ),
              ),

            // Main content based on loading/data state
            if (collectionsProvider.isLoading &&
                collectionsProvider.artworks.isEmpty)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
            if (collectionsProvider.artworks.isEmpty &&
                !collectionsProvider.isLoadingMore &&
                !collectionsProvider.isLoading)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      collectionsProvider.errorMessage ?? "No artworks found.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: collectionsProvider.errorMessage != null
                            ? theme.colorScheme.error
                            : theme.colorScheme.onSurface.withAlpha(
                                (0.7 * 255).round(),
                              ),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              )
            else
              _buildArtworkGridSliver(
                context,
                collectionsProvider,
              ), // Use the SliverGrid version
            // Loading more indicator or end of list message
            if (collectionsProvider.isLoadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            if (!collectionsProvider.hasMoreArtworks &&
                collectionsProvider.artworks.isNotEmpty &&
                !collectionsProvider.isLoadingMore)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: Text(
                      "You've reached the end!",
                      style: TextStyle(color: theme.hintColor),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    } else {
      // --- Desktop/Tablet Layout (Column structure) ---
      Widget topSectionDesktop = Padding(
        padding: EdgeInsets.fromLTRB(bodyPadding, 30.0, bodyPadding, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            searchBar, // searchBar does not need extra horizontal padding here
            Padding(
              padding: const EdgeInsets.only(top: 0.0, bottom: 10.0),
              child: filterAndSettingsControlsDesktop, // Use the renamed widget
            ),
            _buildFilterDropdowns(context, collectionsProvider),
            _buildActiveFilters(context, collectionsProvider),
            Divider(height: 1, thickness: 1, color: theme.dividerColor),
          ],
        ),
      );

      Widget bodyContentDesktop;
      if (collectionsProvider.isLoading &&
          collectionsProvider.artworks.isEmpty) {
        bodyContentDesktop = const Expanded(
          child: Center(child: CircularProgressIndicator()),
        );
      } else if (collectionsProvider.artworks.isEmpty &&
          !collectionsProvider.isLoadingMore &&
          !collectionsProvider.isLoading) {
        bodyContentDesktop = Expanded(
          child: Center(
            /* ... No artworks message ... */
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                collectionsProvider.errorMessage ?? "No artworks found.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: collectionsProvider.errorMessage != null
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurface.withAlpha(
                          (0.7 * 255).round(),
                        ),
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
      } else {
        bodyContentDesktop = Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(
              horizontal: bodyPadding,
            ), // Padding for the list view itself
            itemCount:
                1 +
                (collectionsProvider.isLoadingMore ||
                        (!collectionsProvider.hasMoreArtworks &&
                            collectionsProvider.artworks.isNotEmpty)
                    ? 1
                    : 0),
            itemBuilder: (context, index) {
              if (index == 0) {
                // _buildArtworkGridItself for desktop still returns a regular Widget (GridView.builder)
                // It should be adapted to return a non-sliver widget or we use the old _buildArtworkGrid
                // For now, let's assume _buildArtworkGridItself is flexible or we use a dedicated one for non-slivers.
                // Let's rename the sliver one to _buildArtworkSliverGrid and keep original _buildArtworkGrid for this path.
                return _buildArtworkGridItselfNonSliver(
                  context,
                  collectionsProvider,
                ); // Using a non-sliver version
              } else {
                if (collectionsProvider.isLoadingMore) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (!collectionsProvider.hasMoreArtworks &&
                    collectionsProvider.artworks.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(
                      child: Text(
                        "You've reached the end!",
                        style: TextStyle(color: theme.hintColor),
                      ),
                    ),
                  );
                }
              }
              return const SizedBox.shrink();
            },
          ),
        );
      }

      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: contentMaxWidth),
            child: Column(children: [topSectionDesktop, bodyContentDesktop]),
          ),
        ),
      );
    }
  }

  // Keep the original _buildArtworkGrid for non-sliver contexts (Desktop/Tablet)
  Widget _buildArtworkGridItselfNonSliver(
    BuildContext context,
    CollectionsProvider provider,
  ) {
    final ThemeData theme = Theme.of(context);
    final crossAxisCount = ResponsiveUtil.getCrossAxisCountForCollectionsGrid(
      context,
    );
    final childAspectRatio = ResponsiveUtil.getCollectionsGridAspectRatio(
      context,
    );
    const double spacing = 16.0;

    return GridView.builder(
      padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
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
          /* ... Same item Column as in _buildArtworkGridSliver ... */
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: theme.colorScheme.surfaceContainerHighest.withAlpha(
                    (0.3 * 255).round(),
                  ),
                ),
                child:
                    (artwork.imageUrl != null && artwork.imageUrl!.isNotEmpty)
                    ? CachedNetworkImage(
                        imageUrl: artwork.imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (context, url) => Container(
                          color: theme.colorScheme.surfaceContainerHighest.withAlpha(
                            (0.1 * 255).round(),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              valueColor: AlwaysStoppedAnimation(
                                theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: Center(
                            child: Icon(
                              Icons.broken_image,
                              color: theme.colorScheme.onSurfaceVariant
                                  .withAlpha((0.7 * 255).round()),
                            ),
                          ),
                        ),
                      )
                    : Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: theme.colorScheme.onSurfaceVariant.withAlpha(
                              (0.7 * 255).round(),
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${artwork.artworkTitle ?? "Untitled"} — ${artwork.year ?? "N/A"}',
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
              artwork.artistName ?? "Unknown Artist",
              style: TextStyle(fontSize: 12, color: theme.hintColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      },
    );
  }
}
