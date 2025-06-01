// lib/pages/museum_home_page.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hack_front/models/artwork_model.dart';
import 'package:hack_front/providers/navigation_provider.dart';
import 'package:hack_front/repositories/artwork_repository.dart';
import 'package:hack_front/utils/responsive_util.dart';
import 'package:provider/provider.dart';

class ArtatlasHomePage extends StatefulWidget {
  const ArtatlasHomePage({super.key});

  @override
  State<ArtatlasHomePage> createState() => _ArtatlasHomePageState();
}

class _ArtatlasHomePageState extends State<ArtatlasHomePage> {
  late Future<Artwork> _pictureOfTheDayFuture;

  @override
  void initState() {
    super.initState();
    _loadPictureOfTheDay();
  }

  void _loadPictureOfTheDay() {
    final artworkRepository = Provider.of<ArtworkRepository>(
      context,
      listen: false,
    );
    setState(() {
      _pictureOfTheDayFuture = artworkRepository.getPictureOfTheDay();
    });
  }

  void _handleNavigation(BuildContext context, String routeName) {
    int targetIndex = -1;
    if (routeName == 'Home') targetIndex = 0;
    if (routeName == 'Galleries') targetIndex = 1;
    if (routeName == 'Collection') targetIndex = 2;

    if (targetIndex != -1) {
      Provider.of<NavigationProvider>(
        context,
        listen: false,
      ).onItemTapped(targetIndex);
    }
  }

  Widget _buildPageHeader(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final isMobile = ResponsiveUtil.isMobile(context);
    final logoSize = ResponsiveUtil.getHeaderLogoSize(context);
    final navFontSize = ResponsiveUtil.getHeaderNavFontSize(context);
    final headerPaddingHorizontal = ResponsiveUtil.getBodyPadding(context);
    final headerPaddingVertical = isMobile ? 15.0 : 30.0;

    Widget logo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'ART',
          style: TextStyle(
            fontSize: logoSize,
            fontWeight: FontWeight.w300,
            letterSpacing: 1.5,
            color: theme.colorScheme.onBackground,
          ),
        ),
        Text(
          'ATLAS',
          style: TextStyle(
            fontSize: logoSize,
            fontWeight: FontWeight.w300,
            letterSpacing: 1.5,
            color: theme.colorScheme.onBackground,
          ),
        ),
      ],
    );

    Widget headerContent;
    if (isMobile) {
      headerContent = Padding(
        padding: EdgeInsets.symmetric(
          horizontal: headerPaddingHorizontal,
          vertical: headerPaddingVertical,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [logo],
        ),
      );
    } else {
      headerContent = Padding(
        padding: EdgeInsets.symmetric(
          horizontal: headerPaddingHorizontal,
          vertical: headerPaddingVertical,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            logo,
            Row(
              children: [
                _navLink('Home', context, navFontSize),
                _navLink('Galleries', context, navFontSize),
                _navLink('Collection', context, navFontSize),
                const SizedBox(width: 20),
              ],
            ),
          ],
        ),
      );
    }
    return isMobile
        ? SafeArea(bottom: false, child: headerContent)
        : headerContent;
  }

  Widget _navLink(String text, BuildContext context, double fontSize) {
    final ThemeData theme = Theme.of(context);
    final navigationProvider = Provider.of<NavigationProvider>(
      context,
      listen: false,
    );
    final currentTabIndex = navigationProvider.selectedIndex;
    bool isActive =
        (text == 'Home' && currentTabIndex == 0) ||
        (text == 'Galleries' && currentTabIndex == 1) ||
        (text == 'Collection' && currentTabIndex == 2);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: GestureDetector(
        onTap: () => _handleNavigation(context, text),
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isActive ? FontWeight.w500 : FontWeight.w300,
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.onBackground.withOpacity(0.7),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: FutureBuilder<Artwork>(
        future: _pictureOfTheDayFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
              ),
            );
          } else if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data == null) {
            String errorMessage = 'Failed to load Picture of the Day.';
            if (snapshot.error != null) {
              errorMessage += '\nError: ${snapshot.error.toString()}';
            } else if (!snapshot.hasData || snapshot.data == null) {
              errorMessage = 'No picture available today.';
            }

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.error,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Oops! Something went wrong.",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      onPressed: _loadPictureOfTheDay, // Call the retry method
                    ),
                  ],
                ),
              ),
            );
          } else {
            // snapshot.hasData is true and snapshot.data is not null
            final artwork = snapshot.data!;
            return _buildPageContent(context, artwork);
          }
        },
      ),
    );
  }

  Widget _buildPageContent(BuildContext context, Artwork artworkOfTheDay) {
    double contentMaxWidth = ResponsiveUtil.isDesktop(context)
        ? MediaQuery.of(context).size.width * 0.85
        : MediaQuery.of(context).size.width;
    final isMobile = ResponsiveUtil.isMobile(context);
    final bodyPadding = ResponsiveUtil.getBodyPadding(context);
    final titleFontSize = ResponsiveUtil.getMuseumHomeTitleFontSize(context);
    final quoteFontSize = ResponsiveUtil.getMuseumHomeQuoteFontSize(context);

    Widget mainContentArea = isMobile
        ? _buildMobileContent(
            context,
            titleFontSize,
            quoteFontSize,
            artworkOfTheDay,
          )
        : _buildDesktopTabletContent(
            context,
            titleFontSize,
            quoteFontSize,
            artworkOfTheDay,
          );

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: contentMaxWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPageHeader(context),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: bodyPadding,
                  right: bodyPadding,
                  bottom: bodyPadding,
                ),
                child: mainContentArea,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context, String imageUrlFromApi) {
    print(imageUrlFromApi);
    final ThemeData theme = Theme.of(context);
    final isMobile = ResponsiveUtil.isMobile(context);
    const double desiredAspectRatio = 3 / 4;

    Widget imageWidget = AspectRatio(
      aspectRatio: desiredAspectRatio,
      child: CachedNetworkImage(
        imageUrl: imageUrlFromApi,
        httpHeaders: {'Referer': 'https://artvee.com/'},
        fit: BoxFit.cover,
        errorWidget: (context, error, stackTrace) {
          print(error);
          return Container(
            color: theme.colorScheme.surfaceVariant,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image,
                    color: theme.colorScheme.onSurfaceVariant.withAlpha(
                      (0.7 * 255).round(),
                    ),
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Image failed to load',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant.withAlpha(
                        (0.7 * 255).round(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    if (isMobile) {
      return Container(
        margin: const EdgeInsets.only(top: 8.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.45,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.1 * 255).round()),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: imageWidget,
      );
    } else {
      return imageWidget;
    }
  }

  Widget _buildTextSection(
    BuildContext context,
    double titleFontSize,
    double quoteFontSize,
    Artwork artwork,
  ) {
    final ThemeData theme = Theme.of(context);
    final isMobile = ResponsiveUtil.isMobile(context);

    String displayTitleLine1 = "Picture";
    String displayTitleLine2 = "OF Day";
    if (artwork.artworkTitle!.isNotEmpty) {
      List<String> titleWords = artwork.artworkTitle!.split(" ");
      if (titleWords.length > 2 && titleWords.length <= 4) {
        // Simple split for 3-4 words
        displayTitleLine1 = titleWords
            .sublist(0, titleWords.length ~/ 2)
            .join(" ");
        displayTitleLine2 = titleWords
            .sublist(titleWords.length ~/ 2)
            .join(" ");
      } else if (titleWords.length > 4) {
        // For longer titles, maybe just first few words
        displayTitleLine1 = titleWords.sublist(0, 2).join(" ");
        displayTitleLine2 =
            titleWords
                .sublist(2, (titleWords.length > 4 ? 4 : titleWords.length))
                .join(" ") +
            (titleWords.length > 4 ? "..." : "");
      } else {
        displayTitleLine1 = artwork.artworkTitle!;
        displayTitleLine2 = "";
      }
    }

    return Padding(
      padding: EdgeInsets.only(
        top: isMobile ? 24.0 : 40.0,
        left: isMobile ? 0 : 20.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            displayTitleLine1.toUpperCase(),
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w300,
              letterSpacing: 1.2,
              height: 1.1,
              color: theme.colorScheme.onBackground,
            ),
          ),
          if (displayTitleLine2.isNotEmpty)
            Text(
              displayTitleLine2.toUpperCase(),
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.w300,
                letterSpacing: 1.2,
                height: 1.1,
                color: theme.colorScheme.onBackground,
              ),
            ),
          const SizedBox(height: 25),
          Text(
            artwork.description ??
                '"Art is the lie that enables us to realize the truth." - Pablo Picasso', // Use category as description
            style: TextStyle(
              fontSize: quoteFontSize,
              height: 1.6,
              fontStyle: FontStyle.normal,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '— ${artwork.artistName}', // Use artistName
              style: TextStyle(
                fontSize: quoteFontSize * 0.95,
                fontStyle: FontStyle.italic,
                color: theme.textTheme.bodyMedium?.color?.withAlpha(
                  (0.8 * 255).round(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTabletContent(
    BuildContext context,
    double titleFontSize,
    double quoteFontSize,
    Artwork artwork,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 6,
          child: _buildImageSection(context, artwork.imageUrl!),
        ),
        SizedBox(width: ResponsiveUtil.isTablet(context) ? 30 : 50),
        Expanded(
          flex: 4,
          child: _buildTextSection(
            context,
            titleFontSize,
            quoteFontSize,
            artwork,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileContent(
    BuildContext context,
    double titleFontSize,
    double quoteFontSize,
    Artwork artwork,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageSection(context, artwork.imageUrl!),
          _buildTextSection(context, titleFontSize, quoteFontSize, artwork),
        ],
      ),
    );
  }
}
