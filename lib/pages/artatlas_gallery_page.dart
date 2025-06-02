// lib/pages/artatlas_gallery_page.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hack_front/providers/gallery_provider.dart';
import 'package:hack_front/providers/navigation_provider.dart'; // For navigation
import 'package:hack_front/providers/theme_provider.dart';
import 'package:hack_front/utils/responsive_util.dart';
import 'package:provider/provider.dart';

class ArtatlasGalleryPage extends StatelessWidget {
  const ArtatlasGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = ResponsiveUtil.isMobile(context);

    final infoPanelWidth = ResponsiveUtil.getGalleryInfoPanelWidth(context);
    final galleryProvider = Provider.of<GalleryProvider>(context);
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
        onPressed: null,
        label: Row(
          children: [
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {},
              icon: Icon(CupertinoIcons.info_circle),
            ),
            const SizedBox(width: 8),
            IconButton(onPressed: () {}, icon: Icon(CupertinoIcons.search)),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Builder(
          builder: (innerContext) => IconButton(
            icon: Icon(CupertinoIcons.app),
            onPressed: () {
              // This innerContext is now “inside” the Scaffold, so openDrawer() works:
              Scaffold.of(innerContext).openDrawer();
            },
          ),
        ),
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Gallery',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w300),
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
        child: ListView.builder(
          itemBuilder: (_, index) {
            if (index == 0) {
              return DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).appBarTheme.backgroundColor,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(CupertinoIcons.back),
                    ),
                    Text(
                      'Artatlas',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            fontWeight: FontWeight.w300,
                            color: theme.textTheme.headlineLarge?.color,
                          ),
                    ),
                  ],
                ),
              );
            }
            return ListTile(
              title: Text('Gallery Item ${index + 1}'),
              onTap: () {
                // Handle drawer item tap
                Navigator.pop(context); // Close the drawer
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
                  color: Theme.of(
                    context,
                  ).scaffoldBackgroundColor.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  'Gallery content goes here',
                  style: TextStyle(color: Colors.white),
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
                  : MediaQuery.of(context).size.width * 0.25,
              left: isMobile
                  ? MediaQuery.of(context).size.width * 0.05
                  : MediaQuery.of(context).size.width * 0.25,
              child: Container(
                width: isMobile
                    ? MediaQuery.of(context).size.width * 0.1
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
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, index) {
                    // Example content for the gallery
                    return Container(
                      width: isMobile ? 200 : 300,
                      margin: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'Gallery Item ${index + 1}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            /// Audio player controls
            Positioned(
              // Positioning logic for info panel (bottom-left on desktop, centered sheet on mobile)
              top: isMobile ? MediaQuery.of(context).size.width * 0.75 : null,
              left: isMobile ? (screenWidth - infoPanelWidth) / 2 : null,
              bottom: !isMobile
                  ? desktopEdgePadding
                  : MediaQuery.of(context).size.width * 0.4,
              right: isMobile ? (screenWidth - infoPanelWidth) / 2 : null,

              child: Container(
                width: !isMobile
                    ? MediaQuery.of(context).size.width * 0.2
                    : null,
                height: isMobile
                    ? screenHeight * 0.15 - (kBottomNavigationBarHeight / 2)
                    : null,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: overlayBackgroundColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: SingleChildScrollView(
                  // Info panel content
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        /* ... About title ... */
                        'About: Right Main ° Hall 1',
                        style: TextStyle(
                          color: overlayTextColor,
                          fontSize:
                              ResponsiveUtil.getGalleryInfoPanelTitleFontSize(
                                context,
                              ),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        /* ... About text ... */
                        'Museum has huge hall that leads to other sections with masterpieces. Left side of the hall have been attached to it in 1989.',
                        style: TextStyle(
                          color: overlayMutedTextColor,
                          fontSize: ResponsiveUtil.getGalleryInfoPanelFontSize(
                            context,
                          ),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        /* ... About text ... */
                        'Major events are took part in this hall, so the walls of it is full with different kind of art woks.',
                        style: TextStyle(
                          color: overlayMutedTextColor,
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

  Widget _buildAudioPlayerControls(
    BuildContext context,
    GalleryProvider provider,
    Color iconColor,
    Color textColor,
    Color mutedTextColor,
  ) {
    // ... (Audio player controls code remains the same as your last version)
    // Ensure it uses the passed iconColor, textColor, mutedTextColor.
    final isMobile = ResponsiveUtil.isMobile(context);
    final iconSize = isMobile ? 26.0 : 26.0;
    final smallIconSize = isMobile ? 18.0 : 20.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 2.0,
            thumbShape: RoundSliderThumbShape(
              enabledThumbRadius: isMobile ? 5.0 : 6.0,
            ),
            overlayShape: RoundSliderOverlayShape(
              overlayRadius: isMobile ? 10.0 : 12.0,
            ),
            activeTrackColor: iconColor,
            inactiveTrackColor: mutedTextColor.withOpacity(0.5),
            thumbColor: iconColor,
            overlayColor: iconColor.withOpacity(0.2),
          ),
          child: Slider(
            value: provider.volume,
            min: 0.0,
            max: 1.0,
            onChanged: (newVolume) => provider.setVolume(newVolume),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Icons.skip_previous,
                  color: iconColor,
                  size: smallIconSize,
                ),
                onPressed: () => provider.skipPrevious(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              SizedBox(width: isMobile ? 4 : 8),
              IconButton(
                icon: Icon(
                  provider.isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  color: iconColor,
                  size: iconSize,
                ),
                onPressed: () => provider.togglePlayPause(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              SizedBox(width: isMobile ? 4 : 8),
              IconButton(
                icon: Icon(
                  Icons.skip_next,
                  color: iconColor,
                  size: smallIconSize + 4,
                ),
                onPressed: () => provider.skipNext(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '01:13/10:52', // TODO: Get from provider
            style: TextStyle(color: textColor, fontSize: isMobile ? 10 : 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          icon: Icon(Icons.volume_up, color: iconColor, size: smallIconSize),
          onPressed: () {},
        ),
      ],
    );
  }
}
