// lib/responsive_util.dart
import 'package:flutter/material.dart';

class ResponsiveUtil {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 650 && width < 1100;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  static int getCrossAxisCountForCollectionsGrid(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return 4; // Large Desktop
    if (width >= 900) return 3; // Desktop / Large Tablet
    if (width >= 600) return 2; // Tablet / Large Mobile
    return 2; // Mobile (can be 1 for very narrow, but 2 is common)
  }

  static double getCollectionsGridAspectRatio(BuildContext context) {
    if (isMobile(context)) return 0.7; // More height for mobile items
    return 0.75;
  }

  static double getHeaderLogoSize(BuildContext context) {
    if (isMobile(context)) return 20;
    if (isTablet(context)) return 22;
    return 26;
  }

  static double getHeaderNavFontSize(BuildContext context) {
    if (isMobile(context)) return 14; // Will be in a menu, so can be smaller
    return 16;
  }

  static double getBodyPadding(BuildContext context) {
    if (isMobile(context)) return 16.0;
    if (isTablet(context)) return 24.0;
    return 40.0;
  }

  // Specific for MuseumHomePage title
  static double getMuseumHomeTitleFontSize(BuildContext context) {
    if (isMobile(context)) return 36;
    if (isTablet(context)) return 48;
    return 60;
  }

  // Specific for MuseumHomePage quote
  static double getMuseumHomeQuoteFontSize(BuildContext context) {
    if (isMobile(context)) return 14;
    return 16;
  }

  // Specific for ArtatlasGalleryPage info panel
  static double getGalleryInfoPanelWidth(BuildContext context) {
    if (isDesktop(context)) return MediaQuery.of(context).size.width * 0.30;
    if (isTablet(context)) return MediaQuery.of(context).size.width * 0.40;
    return MediaQuery.of(context).size.width * 0.9; // For mobile bottom sheet
  }

  static double getGalleryInfoPanelFontSize(BuildContext context) {
    if (isMobile(context)) return 12;
    return 13;
  }

  static double getGalleryInfoPanelTitleFontSize(BuildContext context) {
    if (isMobile(context)) return 16;
    return 18;
  }
}
