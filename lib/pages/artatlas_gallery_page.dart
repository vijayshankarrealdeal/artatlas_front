// lib/pages/artatlas_gallery_page.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hack_front/models/artwork_model.dart'; // Ensure this is imported
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
  final ScrollController _galleryArtworksScrollController =
      ScrollController(); // Reintroduced
  BoxFit _currentBoxFit = BoxFit.cover;

  @override
  void initState() {
    super.initState();
    _drawerScrollController.addListener(_onDrawerScroll);
    _galleryArtworksScrollController.addListener(
      _onGalleryArtworksScroll,
    ); // Add listener

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<GalleryProvider>(context, listen: false);
      if (provider.selectedGallery != null &&
          provider.galleryArtworks.isEmpty &&
          !provider.isLoadingGalleryArtworks) {
        provider.selectGalleryAndLoadArtworks(provider.selectedGallery!);
      }
    });
  }

  void _onDrawerScroll() {
    final provider = Provider.of<GalleryProvider>(context, listen: false);
    if (_drawerScrollController.position.pixels >=
            _drawerScrollController.position.maxScrollExtent - 200 &&
        !provider.isLoadingGalleries &&
        provider.hasMoreGalleries) {
      provider.fetchGalleries(loadMore: true);
    }
  }

  // Listener for the horizontal artwork list pagination
  void _onGalleryArtworksScroll() {
    final provider = Provider.of<GalleryProvider>(context, listen: false);
    if (_galleryArtworksScrollController.position.pixels >=
            _galleryArtworksScrollController.position.maxScrollExtent -
                150 && // Threshold for horizontal list
        !provider.isLoadingGalleryArtworks &&
        provider.hasMoreGalleryArtworks) {
      provider
          .loadMoreGalleryArtworks(); // Make sure this method exists and works in GalleryProvider
    }
  }

  @override
  void dispose() {
    _drawerScrollController.removeListener(_onDrawerScroll);
    _drawerScrollController.dispose();
    _galleryArtworksScrollController.removeListener(
      _onGalleryArtworksScroll,
    ); // Dispose controller
    _galleryArtworksScrollController.dispose();
    super.dispose();
  }

  void _show_info() {}

  Widget _buildMainArtworkDisplay(
    BuildContext context,
    GalleryProvider provider,
  ) {
    const Color placeholderTextColor = Colors.white70;
    Widget content;

    if (provider.isLoadingGalleryArtworks &&
        provider.selectedArtwork == null &&
        provider.selectedGallery != null) {
      content = const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(placeholderTextColor),
        ),
      );
    } else if (provider.selectedArtwork != null) {
      content =
          (provider.selectedArtwork!.imageUrl != null &&
              provider.selectedArtwork!.imageUrl!.isNotEmpty)
          ? GestureDetector(
              onTap: _show_info,
              child: AnimatedContainer(
                duration: const Duration(microseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                padding: const EdgeInsets.all(8),

                child: CachedNetworkImage(
                  imageUrl: provider.selectedArtwork!.imageUrl!,
                  fit: _currentBoxFit,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        placeholderTextColor,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) {
                    if (kDebugMode) {
                      print(
                        "Error loading main artwork image: ${provider.selectedArtwork!.imageUrl} - $error",
                      );
                    }
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image_outlined,
                            size: 60,
                            color: placeholderTextColor,
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Image not available",
                            style: TextStyle(color: placeholderTextColor),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            )
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported_outlined,
                    size: 60,
                    color: placeholderTextColor,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "No image for this artwork",
                    style: TextStyle(color: placeholderTextColor),
                  ),
                ],
              ),
            );
    } else if (provider.galleryArtworksErrorMessage != null &&
        provider.selectedGallery != null) {
      content = const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            "Error loading artworks for this gallery.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.redAccent, fontSize: 16),
          ),
        ),
      );
    } else if (provider.selectedGallery == null) {
      content = const Center(
        child: Text(
          'Select a gallery from the drawer.',
          textAlign: TextAlign.center,
          style: TextStyle(color: placeholderTextColor, fontSize: 16),
        ),
      );
    } else if (!provider.isLoadingGalleryArtworks &&
        provider.galleryArtworks.isEmpty &&
        provider.selectedGallery != null) {
      content = const Center(
        child: Text(
          'No artworks in this gallery.',
          textAlign: TextAlign.center,
          style: TextStyle(color: placeholderTextColor, fontSize: 16),
        ),
      );
    } else {
      content = const Center(
        child: Text(
          'Loading gallery content...',
          style: TextStyle(color: placeholderTextColor),
        ),
      );
    }

    return content;
  }

  // Reintroduced: Widget to build the horizontal list of other artworks in the gallery
  Widget _buildGalleryArtworksList(
    BuildContext context,
    GalleryProvider provider,
  ) {
    const Color itemPlaceholderColor = Colors.white60;

    if (provider.selectedGallery == null ||
        (provider.galleryArtworks.isEmpty &&
            !provider.isLoadingGalleryArtworks)) {
      // Don't show the strip if no gallery is selected, or if it's empty and not loading
      return const SizedBox.shrink();
    }
    List<Artwork> artworksToList = provider.galleryArtworks.where((artwork) {
      return artwork.imageUrl != provider.selectedArtwork!.imageUrl;
    }).toList();
    if (artworksToList.isEmpty &&
        !provider.isLoadingGalleryArtworks &&
        !provider.hasMoreGalleryArtworks) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Container(
        height: 110, // Height for the artwork strip
        width: MediaQuery.of(context).size.width * 0.5,
        margin: const EdgeInsets.only(top: 15), // Space above the strip
        child: ListView.builder(
          controller: _galleryArtworksScrollController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          itemCount:
              artworksToList.length + (provider.hasMoreGalleryArtworks ? 1 : 0),
          itemBuilder: (_, index) {
            if (index < artworksToList.length) {
              final artwork = artworksToList[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentBoxFit = BoxFit.cover;
                  }); // Reset fit for new selection
                  provider.setSelectedArtwork(artwork);
                },
                child: Container(
                  width: 90, // Width of each item
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 0.5,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child:
                      (artwork.imageUrl != null && artwork.imageUrl!.isNotEmpty)
                      ? CachedNetworkImage(
                          imageUrl: artwork.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.black12,
                            child: const Center(
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  valueColor: AlwaysStoppedAnimation(
                                    itemPlaceholderColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.black12,
                            child: Icon(
                              Icons.broken_image_outlined,
                              size: 30,
                              color: itemPlaceholderColor.withOpacity(0.7),
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.black12,
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 30,
                            color: itemPlaceholderColor.withOpacity(0.7),
                          ),
                        ),
                ),
              );
            } else if (provider.hasMoreGalleryArtworks) {
              // Loading indicator at the end of the list
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation(itemPlaceholderColor),
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = ResponsiveUtil.isMobile(context);

    final galleryProvider = Provider.of<GalleryProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final ThemeData currentTheme = Theme.of(context);

    final String backgroundImagePath = themeProvider.isDarkMode
        ? 'assets/images/night.png'
        : 'assets/images/xx.png';

    final Color navLinkColor = Colors.white.withOpacity(0.8);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (innerContext) => IconButton(
            icon: Icon(
              isMobile ? CupertinoIcons.bars : CupertinoIcons.app_badge,
              /* color will be from AppBarTheme or default */
            ),
            onPressed: () {
              Scaffold.of(innerContext).openDrawer();
            },
          ),
        ),
        centerTitle: true,
        title: Text(
          'Gallery',
          // style: currentTheme.appBarTheme.titleTextStyle, // Use theme's style
        ),
        actions: isMobile
            ? []
            : [
                _buildSimpleNavLink("Home", 0, context, navLinkColor),
                _buildSimpleNavLink("Collection", 2, context, navLinkColor),
                const SizedBox(width: 20),
              ],
      ),
      drawer: Drawer(
        /* ... Drawer code remains the same ... */
        backgroundColor: currentTheme.colorScheme.surface.withOpacity(0.95),
        child: Consumer<GalleryProvider>(
          builder: (context, provider, _) {
            if (provider.isLoadingGalleries && provider.galleries.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.galleriesErrorMessage != null &&
                provider.galleries.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Error: ${provider.galleriesErrorMessage}",
                        style: TextStyle(color: currentTheme.colorScheme.error),
                      ),
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
            if (provider.galleries.isEmpty && !provider.isLoadingGalleries) {
              return Column(
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: currentTheme.colorScheme.surfaceContainerHighest
                          .withOpacity(0.8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            CupertinoIcons.back,
                            color: currentTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          'Galleries',
                          style: currentTheme.textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w300,
                                color:
                                    currentTheme.colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "No galleries found.",
                        style: TextStyle(color: currentTheme.hintColor),
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
                  1,
              itemBuilder: (_, index) {
                if (index == 0) {
                  return DrawerHeader(
                    decoration: BoxDecoration(
                      color: currentTheme.colorScheme.surfaceContainerHighest
                          .withOpacity(0.8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            CupertinoIcons.back,
                            color: currentTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          'Galleries',
                          style: currentTheme.textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w300,
                                color:
                                    currentTheme.colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  );
                }
                final galleryItemIndex = index - 1;

                if (galleryItemIndex < provider.galleries.length) {
                  final gallery = provider.galleries[galleryItemIndex];
                  bool isSelected = provider.selectedGalleryId == gallery.id;
                  return ListTile(
                    leading:
                        gallery.imageUrl != null && gallery.imageUrl!.isNotEmpty
                        ? CircleAvatar(
                            backgroundImage: CachedNetworkImageProvider(
                              gallery.imageUrl!,
                            ),
                            backgroundColor: currentTheme
                                .colorScheme
                                .surfaceContainerHighest,
                          )
                        : CircleAvatar(
                            backgroundColor:
                                currentTheme.colorScheme.primaryContainer,
                            child: Icon(
                              Icons.collections_bookmark_outlined,
                              color:
                                  currentTheme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                    title: Text(
                      gallery.name ?? gallery.title ?? 'Unnamed Gallery',
                      style: TextStyle(
                        color: currentTheme.textTheme.bodyLarge?.color,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      'Curator: ${gallery.curator ?? "N/A"}\nArt: ${gallery.itemsCountGalleriesPage ?? "N/A"}',
                      style: TextStyle(
                        fontSize: 12,
                        color: currentTheme.hintColor,
                      ),
                    ),
                    selected: isSelected,
                    selectedTileColor: currentTheme.colorScheme.primaryContainer
                        .withOpacity(0.3),
                    isThreeLine: true,
                    onTap: () {
                      setState(() {
                        _currentBoxFit = BoxFit.cover;
                      });
                      provider.selectGalleryAndLoadArtworks(gallery);
                      Navigator.pop(context);
                    },
                  );
                } else if (provider.hasMoreGalleries) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        color: currentTheme.colorScheme.primary,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            );
          },
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(backgroundImagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          // Add SafeArea around the Column
          child: Column(
            // Use Column for main layout
            children: [
              Expanded(
                // Main artwork display takes up most space
                flex: 3, // Adjust flex factor as needed
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: isMobile ? screenWidth * 0.05 : screenWidth * 0.3,
                      right: isMobile ? screenWidth * 0.05 : screenWidth * 0.3,
                      top: isMobile ? screenWidth * 0.05 : screenWidth * 0.01,
                      bottom: isMobile
                          ? screenWidth * 0.05
                          : screenWidth * 0.01,
                      // Reduced top/bottom padding
                    ),
                    child: _buildMainArtworkDisplay(context, galleryProvider),
                  ),
                ),
              ),
              // Conditionally display the horizontal artwork list
              if (galleryProvider.selectedGallery != null &&
                  (galleryProvider.galleryArtworks.isNotEmpty ||
                      galleryProvider.isLoadingGalleryArtworks))
                _buildGalleryArtworksList(context, galleryProvider),

              SizedBox(height: isMobile ? 70 : 8), // Space for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (galleryProvider.selectedArtwork != null) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                final artwork = galleryProvider.selectedArtwork!;
                return AlertDialog(
                  backgroundColor: Colors.black.withOpacity(0.9),
                  title: Text(
                    artwork.artworkTitle ?? "Artwork Details",
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        Text(
                          'Artist: ${artwork.artistName ?? "N/A"}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Year: ${artwork.year ?? "N/A"}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        if (artwork.description != null &&
                            artwork.description!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            artwork.description!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                        if (artwork.interpretation != null &&
                            artwork.interpretation!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            artwork.interpretation!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text(
                        'Close',
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          } else if (kDebugMode) {
            print("FAB Tapped - No artwork selected or no gallery selected.");
          }
        },
        label: const Text(
          'Info',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        icon: const Icon(
          CupertinoIcons.info_circle_fill,
          color: Colors.white,
          size: 20,
        ),
        backgroundColor: Colors.black.withOpacity(0.7),
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildSimpleNavLink(
    String text,
    int targetIndex,
    BuildContext context,
    Color color,
  ) {
    final navigationProvider = Provider.of<NavigationProvider>(
      context,
      listen: false,
    );
    // Forcing white text for nav links on this page, as AppBar is transparent over a dark background
    final Color effectiveColor = Colors.white.withOpacity(0.85);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: InkWell(
        onTap: () => navigationProvider.onItemTapped(targetIndex),
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: effectiveColor,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
