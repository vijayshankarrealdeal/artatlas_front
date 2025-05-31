import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hack_front/providers/navigation_provider.dart';
import 'package:hack_front/utils/responsive_util.dart';
import 'package:provider/provider.dart';

class ArtatlasHomePage extends StatelessWidget {
  const ArtatlasHomePage({super.key});

  final String imageUrl =
      'https://images.pexels.com/photos/297494/pexels-photo-297494.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2';

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
    // On desktop, AppShell has no AppBar for Home, so this header is the main one.
    // On mobile, this header is also the main one as AppShell has no AppBar.
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
    double contentMaxWidth = ResponsiveUtil.isDesktop(context)
        ? MediaQuery.of(context).size.width * 0.85
        : MediaQuery.of(context).size.width;

    final isMobile = ResponsiveUtil.isMobile(context);
    final bodyPadding = ResponsiveUtil.getBodyPadding(context);
    final titleFontSize = ResponsiveUtil.getMuseumHomeTitleFontSize(context);
    final quoteFontSize = ResponsiveUtil.getMuseumHomeQuoteFontSize(context);

    Widget mainContentArea = isMobile
        ? _buildMobileContent(context, titleFontSize, quoteFontSize)
        : _buildDesktopTabletContent(context, titleFontSize, quoteFontSize);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: contentMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPageHeader(context), // This is the page's own header
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
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final isMobile = ResponsiveUtil.isMobile(context);
    const double desiredAspectRatio = 3 / 4;

    Widget imageWidget = AspectRatio(
      aspectRatio: desiredAspectRatio,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        errorWidget: (context, error, stackTrace) {
          return Container(
            color: theme.colorScheme.surfaceVariant,
            child: Center(
              child: Text(
                'Image failed to load',
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
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
  ) {
    final ThemeData theme = Theme.of(context);
    final isMobile = ResponsiveUtil.isMobile(context);
    return Padding(
      padding: EdgeInsets.only(top: isMobile ? 24.0 : 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            'Picture',
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w300,
              letterSpacing: 1.2,
              height: 1.1,
              color: theme.colorScheme.onBackground,
            ),
          ),
          Text(
            'OF Day',
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w300,
              letterSpacing: 1.2,
              height: 1.1,
              color: theme.colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '"It is good to love many things, for therein lies the true strength, and whosoever loves much performs much, and can accomplish much, and what is done in love is well done."',
            style: TextStyle(
              fontSize: quoteFontSize,
              height: 1.5,
              fontStyle: FontStyle.normal,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 15),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '— Vincent Van Gogh',
              style: TextStyle(
                fontSize: quoteFontSize,
                fontStyle: FontStyle.italic,
                color: theme.textTheme.bodyMedium?.color,
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
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 6, child: _buildImageSection(context)),
        SizedBox(width: ResponsiveUtil.isTablet(context) ? 30 : 40),
        Expanded(
          flex: 4,
          child: _buildTextSection(context, titleFontSize, quoteFontSize),
        ),
      ],
    );
  }

  Widget _buildMobileContent(
    BuildContext context,
    double titleFontSize,
    double quoteFontSize,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageSection(context),
          _buildTextSection(context, titleFontSize, quoteFontSize),
        ],
      ),
    );
  }
}
