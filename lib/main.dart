import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hack_front/app_shell.dart';
import 'package:hack_front/responsive_util.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Art Atlas',
      theme: ThemeData(
        fontFamily: 'FuturaPT',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
          dynamicSchemeVariant: DynamicSchemeVariant.monochrome,
          primary: Colors.blue,
        ),
      ),
      home: const AppShell(),
    );
  }
}

class MuseumHomePage extends StatelessWidget {
  final Function(int)? onNavigateToTab;
  const MuseumHomePage({super.key, this.onNavigateToTab});

  final String imageUrl =
      'https://images.pexels.com/photos/297494/pexels-photo-297494.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2';

  void _handleNavigation(String routeName) {
    int targetIndex = -1;
    if (routeName == 'Home') targetIndex = 0;
    if (routeName == 'Galleries') targetIndex = 1;
    if (routeName == 'Collection') targetIndex = 2;

    if (targetIndex != -1 && onNavigateToTab != null) {
      onNavigateToTab!(targetIndex);
    }
  }

  Widget _buildPageHeader(BuildContext context) {
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
          ),
        ),
        Text(
          'ATLAS',
          style: TextStyle(
            fontSize: logoSize,
            fontWeight: FontWeight.w300,
            letterSpacing: 1.5,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: GestureDetector(
        onTap: () => _handleNavigation(text),
        child: Text(
          text,
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w200),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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

  Widget _buildImageSection(BuildContext context) {
    final isMobile = ResponsiveUtil.isMobile(context);
    const double desiredAspectRatio = 3 / 4; //  3:4 width to height ratio

    Widget imageWidget = AspectRatio(
      aspectRatio: desiredAspectRatio,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return SizedBox(
            child: const Center(child: Text('Image failed to load')),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return SizedBox(
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
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
            ),
          ),
          Text(
            'OF Day',
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w300,
              letterSpacing: 1.2,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '"It is good to love many things, for therein lies the true strength, and whosoever loves much performs much, and can accomplish much, and what is done in love is well done."',
            style: TextStyle(
              fontSize: quoteFontSize,
              height: 1.5,
              fontStyle: FontStyle.normal,
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
