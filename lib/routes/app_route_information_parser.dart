// lib/routing/app_route_information_parser.dart
import 'package:flutter/widgets.dart';
import 'app_route_path.dart';

class AppRouteInformationParser extends RouteInformationParser<AppRoutePath> {
  @override
  Future<AppRoutePath> parseRouteInformation(RouteInformation routeInformation) async {
    final uri = routeInformation.uri; // Use routeInformation.uri

    if (uri.pathSegments.isEmpty || uri.pathSegments.first == 'home') {
      return const HomePath();
    }
    if (uri.pathSegments.length == 1) {
      final firstSegment = uri.pathSegments.first;
      if (firstSegment == 'gallery') {
        return const GalleryPath();
      }
      if (firstSegment == 'collections') {
        return const CollectionsPath();
      }
    }
    return const UnknownPath(); // Default for unrecognized paths
  }

  @override
  RouteInformation? restoreRouteInformation(AppRoutePath configuration) {
    if (configuration is HomePath) {
      return RouteInformation(uri: Uri.parse('/home'));
    }
    if (configuration is GalleryPath) {
      return RouteInformation(uri: Uri.parse('/gallery'));
    }
    if (configuration is CollectionsPath) {
      return RouteInformation(uri: Uri.parse('/collections'));
    }
    // For UnknownPath, you might want to show a 404 URL or keep the current one.
    // Returning null means the URL doesn't change from the app's perspective for this configuration.
    // Or return a specific '/404' or similar.
    return RouteInformation(uri: Uri.parse('/unknown'));
  }
}