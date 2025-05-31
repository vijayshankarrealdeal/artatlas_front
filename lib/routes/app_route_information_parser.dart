// lib/routing/app_route_information_parser.dart
import 'package:flutter/widgets.dart';
import 'app_route_path.dart';

class AppRouteInformationParser extends RouteInformationParser<AppRoutePath> {
  @override
  Future<AppRoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = routeInformation.uri;

    if (uri.pathSegments.isEmpty) {
      // Default to login if root path could be ambiguous or based on auth state
      // Or, could be HomePath if you want to attempt direct access and let delegate redirect.
      // For now, let's make it LoginPath if unauthenticated is the app's "default" state.
      return const LoginPath(); // Or HomePath() and let delegate handle redirection
    }

    final firstSegment = uri.pathSegments.first;
    switch (firstSegment) {
      case 'home':
        return const HomePath();
      case 'gallery':
        return const GalleryPath();
      case 'collections':
        return const CollectionsPath();
      case 'login':
        return const LoginPath();
      case 'signup':
        return const SignupPath();
      default:
        return const UnknownPath();
    }
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
    if (configuration is LoginPath) {
      return RouteInformation(uri: Uri.parse('/login'));
    }
    if (configuration is SignupPath) {
      return RouteInformation(uri: Uri.parse('/signup'));
    }
    if (configuration is UnknownPath) {
      return RouteInformation(uri: Uri.parse('/unknown_route_page')); // Or redirect to /login or /home
    }
    return null; // Should not happen if all paths are covered
  }
}