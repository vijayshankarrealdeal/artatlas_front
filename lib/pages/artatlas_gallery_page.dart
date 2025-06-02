// lib/pages/artatlas_gallery_page.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hack_front/providers/gallery_provider.dart';
import 'package:hack_front/providers/navigation_provider.dart';
import 'package:hack_front/providers/theme_provider.dart';
import 'package:hack_front/utils/responsive_util.dart';
import 'package:provider/provider.dart';

class ArtatlasGalleryPage extends StatefulWidget {
  const ArtatlasGalleryPage({super.key});

  @override
  State<ArtatlasGalleryPage> createState() => _ArtatlasGalleryPageState();
}

class _ArtatlasGalleryPageState extends State<ArtatlasGalleryPage> {
  final ScrollController _drawerScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _drawerScrollController.addListener(_onDrawerScroll);
    // Initial fetch is handled by GalleryProvider constructor
  }

  void _onDrawerScroll() {
    final provider = Provider.of<GalleryProvider>(context, listen: false);
    // Load more when near the bottom of the drawer list
    if (_drawerScrollController.position.pixels >=
            _drawerScrollController.position.maxScrollExtent -
                200 && // 200px threshold
        !provider.isLoadingGalleries &&
        provider.hasMoreGalleries) {
      provider.fetchGalleries(loadMore: true);
    }
  }

  @override
  void dispose() {
    _drawerScrollController.removeListener(_onDrawerScroll);
    _drawerScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = ResponsiveUtil.isMobile(context);

    final infoPanelWidth = ResponsiveUtil.getGalleryInfoPanelWidth(context);
    final galleryProvider = Provider.of<GalleryProvider>(
      context,
    ); // Listen for changes
    const double desktopEdgePadding = 30.0;
    final Color overlayTextColor = Colors.white;
    final Color overlayIconColor = Colors.white;
    final Color overlayMutedTextColor = Colors.grey.shade300;
    final Color overlayBackgroundColor = Colors.black.withOpacity(
      isMobile ? 0.85 : 0.75,
    );
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed:
            null, // Consider making this functional or removing if not used
        label: Row(
          children: [
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {},
              icon: const Icon(CupertinoIcons.info_circle),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {},
              icon: const Icon(CupertinoIcons.search),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Builder(
          builder: (innerContext) => IconButton(
            icon: const Icon(CupertinoIcons.app),
            onPressed: () {
              Scaffold.of(innerContext).openDrawer();
            },
            color: theme
                .colorScheme
                .onBackground, // Ensure icon color contrasts with transparent appbar
          ),
        ),
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Gallery',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w300,
              color: theme
                  .colorScheme
                  .onBackground, // Ensure title color contrasts
            ),
          ),
        ),
        elevation: 0,
        actions: ResponsiveUtil.isMobile(context)
            ? []
            : [
                _buildSimpleNavLink("Home", 0, context),
                _buildSimpleNavLink("Collection", 2, context),
              ],
      ),
      drawer: Drawer(
        clipBehavior: Clip.none,
        child: Consumer<GalleryProvider>(
          // Use Consumer for targeted rebuilds
          builder: (context, provider, child) {
            // Initial loading state for the entire drawer
            if (provider.isLoadingGalleries && provider.galleries.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            // Error state for initial load
            if (provider.galleriesErrorMessage != null &&
                provider.galleries.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Error: ${provider.galleriesErrorMessage}"),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => provider.fetchGalleries(),
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
              );
            }
            // Empty state (after successful fetch but no data)
            if (provider.galleries.isEmpty && !provider.isLoadingGalleries) {
              return Column(
                // Wrap ListView in Column to add header even if list is empty
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).appBarTheme.backgroundColor ??
                          theme.colorScheme.surface,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(CupertinoIcons.back),
                          color: theme.colorScheme.onSurface,
                        ),
                        Text(
                          'Artatlas Galleries',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w300,
                                color: theme.textTheme.headlineMedium?.color,
                              ),
                        ),
                        const SizedBox(width: 48), // Balance
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "No galleries found.",
                        style: TextStyle(color: theme.hintColor),
                      ),
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              controller: _drawerScrollController,
              itemCount:
                  provider.galleries.length +
                  (provider.hasMoreGalleries ? 1 : 0) +
                  1, // +1 for header, +1 for loading
              itemBuilder: (_, index) {
                if (index == 0) {
                  return DrawerHeader(
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).appBarTheme.backgroundColor ??
                          theme.colorScheme.surface,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(CupertinoIcons.back),
                          color: theme.colorScheme.onSurface,
                        ),
                        Text(
                          'Artatlas Galleries',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w300,
                                color: theme.textTheme.headlineMedium?.color,
                              ),
                        ),
                        const SizedBox(
                          width: 48,
                        ), // Placeholder to balance the Row
                      ],
                    ),
                  );
                }
                final galleryItemIndex = index - 1;

                if (galleryItemIndex < provider.galleries.length) {
                  final gallery = provider.galleries[galleryItemIndex];
                  return ListTile(
                    leading:
                        gallery.imageUrl != null && gallery.imageUrl!.isNotEmpty
                        ? CircleAvatar(
                            backgroundImage: CachedNetworkImageProvider(
                              gallery.imageUrl!,
                            ),
                            onBackgroundImageError: (exception, stackTrace) {
                              if (kDebugMode)
                                print(
                                  "Error loading gallery image: ${gallery.imageUrl}, $exception",
                                );
                            },
                            backgroundColor: theme.colorScheme.surfaceVariant,
                            child: gallery.imageUrl!.isEmpty
                                ? Icon(
                                    Icons.image_not_supported_outlined,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  )
                                : null,
                          )
                        : CircleAvatar(
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: Icon(
                              Icons.collections_bookmark_outlined,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                    title: Text(
                      gallery.name ?? gallery.title ?? 'Unnamed Gallery',
                      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                    ),
                    subtitle: Text(
                      'Curator: ${gallery.curator ?? "N/A"}\nItems: ${gallery.itemsCountGalleriesPage ?? "N/A"}',
                      style: TextStyle(fontSize: 12, color: theme.hintColor),
                    ),
                    isThreeLine: true,
                    onTap: () {
                      // TODO: Handle gallery item tap (e.g., load artworks for this gallery)
                      if (kDebugMode)
                        print(
                          "Tapped on gallery: ${gallery.name} (ID: ${gallery.id})",
                        );
                      Navigator.pop(context); // Close the drawer
                    },
                  );
                } else if (provider.hasMoreGalleries) {
                  // Loading indicator at the end of the list
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2.0),
                    ),
                  );
                }
                return const SizedBox.shrink(); // Should not be reached if itemCount is correct
              },
            );
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              Provider.of<ThemeProvider>(context).isDarkMode
                  ? 'assets/images/night.png'
                  : 'assets/images/xx.png',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            /// Main gallery content
            Positioned(
              top: isMobile
                  ? MediaQuery.of(context).size.height * 0.03
                  : MediaQuery.of(context).size.height * 0.3,
              left: isMobile
                  ? MediaQuery.of(context).size.width * 0.05
                  : MediaQuery.of(context).size.width * 0.3,
              right: isMobile
                  ? MediaQuery.of(context).size.width * 0.05
                  : MediaQuery.of(context).size.width * 0.35,
              child: Container(
                height: isMobile
                    ? MediaQuery.of(context).size.height * 0.3
                    : MediaQuery.of(context).size.height * 0.4,
                width: isMobile
                    ? MediaQuery.of(context).size.width * 0.9
                    : MediaQuery.of(context).size.width * 0.4,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 13,
                      spreadRadius: 4,
                    ),
                  ],
                  color: Theme.of(
                    context,
                  ).scaffoldBackgroundColor.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  'Gallery content goes here', // Placeholder
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.9),
                  ),
                ),
              ),
            ),

            /// similar artwork as shown in the main
            Positioned(
              bottom: isMobile
                  ? MediaQuery.of(context).size.width * 0.2
                  : MediaQuery.of(context).size.width * 0.01,
              right: isMobile
                  ? MediaQuery.of(context).size.width * 0.05
                  : MediaQuery.of(context).size.width * 0.3,
              left: isMobile
                  ? MediaQuery.of(context).size.width * 0.05
                  : MediaQuery.of(context).size.width * 0.3,
              child: Container(
                width: isMobile
                    ? MediaQuery.of(context).size.width *
                          0.1 // This seems too small if it's 10% of width
                    : MediaQuery.of(context).size.width * 0.5,
                height: isMobile
                    ? MediaQuery.of(context).size.height * 0.07
                    : MediaQuery.of(context).size.height * 0.08,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(
                    context,
                  ).scaffoldBackgroundColor.withOpacity(0.8),
                ),
                child: ListView.builder(
                  // Placeholder similar artworks
                  scrollDirection: Axis.horizontal,
                  itemCount: 5, // Example count
                  itemBuilder: (_, index) {
                    return Container(
                      width: isMobile ? 100 : 150, // Adjusted width for items
                      margin: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant.withOpacity(
                          0.7,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Center(
                        child: Text(
                          'Artwork ${index + 1}',
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            /// Audio player controls
            Positioned(
              top: isMobile ? MediaQuery.of(context).size.width * 0.7 : null,
              left: isMobile
                  ? (screenWidth - infoPanelWidth) / 2
                  : desktopEdgePadding / 5, // Adjusted desktop left
              bottom: !isMobile
                  ? desktopEdgePadding
                  : MediaQuery.of(context).size.width * 0.4,
              right: isMobile ? (screenWidth - infoPanelWidth) / 2 : null,
              child: Container(
                width: !isMobile
                    ? infoPanelWidth /
                          1.4 // Use calculated infoPanelWidth for desktop/tablet
                    : screenWidth *
                          0.9, // Full width for mobile bottom sheet style
                constraints: !isMobile
                    ? BoxConstraints(maxHeight: screenHeight * 0.5)
                    : null, // Max height for desktop panel
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).scaffoldBackgroundColor.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'About: Right Main ° Hall 1', // Placeholder
                        style: TextStyle(
                          fontSize:
                              ResponsiveUtil.getGalleryInfoPanelTitleFontSize(
                                context,
                              ),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Museum has huge hall that leads to other sections with masterpieces. Left side of the hall have been attached to it in 1989.', // Placeholder
                        style: TextStyle(
                          fontSize: ResponsiveUtil.getGalleryInfoPanelFontSize(
                            context,
                          ),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Major events are took part in this hall, so the walls of it is full with different kind of art woks.', // Placeholder
                        style: TextStyle(
                          fontSize: ResponsiveUtil.getGalleryInfoPanelFontSize(
                            context,
                          ),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildAudioPlayerControls(
                        context,
                        galleryProvider,
                        overlayIconColor,
                        overlayTextColor,
                        overlayMutedTextColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
    // Using theme.colorScheme.onSurface which should be good for transparent app bar background
    final Color navLinkColor = theme.colorScheme.onSurface.withOpacity(0.7);

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
              color: navLinkColor,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAudioPlayerControls(
    BuildContext context,
    GalleryProvider provider,
    Color iconColor,
    Color textColor,
    Color mutedTextColor,
  ) {
    final isMobile = ResponsiveUtil.isMobile(context);
    final iconSize = isMobile ? 26.0 : 28.0; // Slightly larger non-mobile icons
    final smallIconSize = isMobile ? 20.0 : 22.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 2.5,
            thumbShape: RoundSliderThumbShape(
              enabledThumbRadius: isMobile ? 6.0 : 7.0,
            ),
            overlayShape: RoundSliderOverlayShape(
              overlayRadius: isMobile ? 12.0 : 14.0,
            ),
            activeTrackColor: iconColor,
            inactiveTrackColor: mutedTextColor.withOpacity(0.4),
            thumbColor: iconColor,
            overlayColor: iconColor.withOpacity(0.15),
          ),
          child: Slider(
            value: provider.volume,
            min: 0.0,
            max: 1.0,
            onChanged: (newVolume) => provider.setVolume(newVolume),
          ),
        ),
        Row(
          // Group playback controls
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.skip_previous_rounded,
                color: iconColor,
                size: smallIconSize,
              ),
              onPressed: () => provider.skipPrevious(),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              constraints: const BoxConstraints(),
            ),
            IconButton(
              icon: Icon(
                provider.isPlaying
                    ? Icons.pause_circle_filled_rounded
                    : Icons.play_circle_filled_rounded,
                color: iconColor,
                size: iconSize,
              ),
              onPressed: () => provider.togglePlayPause(),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              constraints: const BoxConstraints(),
            ),
            IconButton(
              icon: Icon(
                Icons.skip_next_rounded,
                color: iconColor,
                size: smallIconSize,
              ),
              onPressed: () => provider.skipNext(),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.volume_up, color: iconColor, size: smallIconSize),
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute space
          children: [
            Text(
              '01:13', // TODO: Get current time from provider
              style: TextStyle(color: textColor, fontSize: isMobile ? 11 : 12),
            ),

            Text(
              '10:52', // TODO: Get total duration from provider
              style: TextStyle(
                color: mutedTextColor,
                fontSize: isMobile ? 11 : 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
