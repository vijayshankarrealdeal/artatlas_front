import 'package:flutter/material.dart';
import 'package:hack_front/providers/gallery_provider.dart';
import 'package:hack_front/utils/responsive_util.dart';
import 'package:provider/provider.dart';

class ArtatlasGalleryPage extends StatelessWidget {
  const ArtatlasGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final galleryProvider = Provider.of<GalleryProvider>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = ResponsiveUtil.isMobile(context);

    final infoPanelWidth = ResponsiveUtil.getGalleryInfoPanelWidth(context);
    final appBarHeight = isMobile ? kToolbarHeight : 0;
    final infoPanelTopPadding = isMobile
        ? screenHeight * 0.60 - appBarHeight
        : screenHeight * 0.20;

    final infoPanelSidePadding = isMobile
        ? (screenWidth - infoPanelWidth) / 2
        : 30.0;

    // Ensure assets are in pubspec.yaml and at these paths
    // assets:
    //  - assets/images/xx.png
    //  - assets/images/night.png
    Widget galleryContent = Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            Theme.of(context).brightness == Brightness.light
                ? 'assets/images/xx.png' // Make sure this image exists
                : 'assets/images/night.png', // Make sure this image exists
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[800],
                child: Center(
                    child: Text(
                  "Error loading background image. Check asset path.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                )),
              );
            },
          ),
        ),
        if (!isMobile)
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Gallery',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black.withOpacity(0.7),
                      offset: const Offset(2.0, 2.0),
                    ),
                  ],
                ),
              ),
            ),
          ),
        Positioned(
          top: infoPanelTopPadding + (isMobile ? appBarHeight : 0),
          left: isMobile ? infoPanelSidePadding : null,
          right: isMobile ? infoPanelSidePadding : 30.0,
          width: isMobile ? null : infoPanelWidth,
          height: isMobile
              ? screenHeight * 0.35 - (kBottomNavigationBarHeight / 2)
              : null,
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(isMobile ? 0.85 : 0.75),
              borderRadius: isMobile
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    )
                  : BorderRadius.circular(10),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'About: Right Main ° Hall 1',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ResponsiveUtil.getGalleryInfoPanelTitleFontSize(
                        context,
                      ),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Museum has huge hall that leads to other sections with masterpieces. Left side of the hall have been attached to it in 1989.',
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: ResponsiveUtil.getGalleryInfoPanelFontSize(
                        context,
                      ),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Major events are took part in this hall, so the walls of it is full with different kind of art woks.',
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: ResponsiveUtil.getGalleryInfoPanelFontSize(
                        context,
                      ),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildAudioPlayerControls(context, galleryProvider),
                ],
              ),
            ),
          ),
        ),
      ],
    );

    if (isMobile) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Gallery'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
            fontFamily: 'FuturaPT', // Ensure font family is applied
          ),
        ),
        body: galleryContent,
      );
    } else {
      return Container(color: Colors.black, child: galleryContent);
    }
  }

  Widget _buildAudioPlayerControls(
      BuildContext context, GalleryProvider provider) {
    final isMobile = ResponsiveUtil.isMobile(context);
    final iconSize = isMobile ? 28.0 : 36.0;
    final smallIconSize = isMobile ? 18.0 : 20.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.skip_previous,
                      color: Colors.white,
                      size: smallIconSize + 4,
                    ),
                    onPressed: () {
                      // TODO: Implement skip previous logic in provider
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  SizedBox(width: isMobile ? 4 : 8),
                  IconButton(
                    icon: Icon(
                      provider.isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      color: Colors.white,
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
                      color: Colors.white,
                      size: smallIconSize + 4,
                    ),
                    onPressed: () {
                      // TODO: Implement skip next logic in provider
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            SizedBox(width: isMobile ? 4 : 8),
            Flexible(
              flex: isMobile ? 0 : 1,
              child: Text(
                '01:13/10:52', // TODO: Get from provider
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 10 : 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: isMobile ? 4 : 8),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 6 : 8,
                vertical: isMobile ? 2 : 4,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '1.3x', // TODO: Get playback speed from provider
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 10 : 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 0),
        Row(
          children: [
            Icon(Icons.volume_up, color: Colors.white, size: smallIconSize),
            const SizedBox(width: 8),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2.0,
                  thumbShape: RoundSliderThumbShape(
                    enabledThumbRadius: isMobile ? 5.0 : 6.0,
                  ),
                  overlayShape: RoundSliderOverlayShape(
                    overlayRadius: isMobile ? 10.0 : 12.0,
                  ),
                  activeTrackColor: Colors.white,
                  inactiveTrackColor: Colors.grey[700],
                  thumbColor: Colors.white,
                ),
                child: Slider(
                  value: provider.volume,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (newVolume) => provider.setVolume(newVolume),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}