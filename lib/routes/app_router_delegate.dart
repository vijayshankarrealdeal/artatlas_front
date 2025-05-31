import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hack_front/app_shell.dart';
import 'package:hack_front/pages/artatlas_home_page.dart';
import 'package:hack_front/pages/auth/auth_page.dart'; // For AuthPage and AuthMode enum
import 'package:hack_front/pages/artatlas_gallery_page.dart';
import 'package:hack_front/pages/artatlas_collections_page.dart';
import 'package:hack_front/providers/auth_provider.dart';
import 'package:hack_front/providers/navigation_provider.dart';
import 'app_route_path.dart';

class AppRouterDelegate extends RouterDelegate<AppRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoutePath> {
  // --- Correctly declare fields ---
  final NavigationProvider navigationProvider;
  final AuthProvider authProvider;
  @override // This navigatorKey is required by PopNavigatorRouterDelegateMixin
  final GlobalKey<NavigatorState> navigatorKey;
  // --- End field declarations ---

  AppRoutePath _currentAuthScreenPathIntent = const LoginPath();

  AppRouterDelegate(this.navigationProvider, this.authProvider)
    : navigatorKey = GlobalKey<NavigatorState>() {
    // Initialize navigatorKey
    navigationProvider.addListener(notifyListeners);
    authProvider.addListener(notifyListeners);
  }

  void updateCurrentAuthScreenPathIntent(AppRoutePath path) {
    if (path is LoginPath || path is SignupPath) {
      if (_currentAuthScreenPathIntent.runtimeType != path.runtimeType) {
        _currentAuthScreenPathIntent = path;
        notifyListeners();
      }
    }
  }

  // --- Implement _currentInternalAppPath as a getter ---
  AppRoutePath get _currentInternalAppPath {
    switch (navigationProvider.selectedIndex) {
      case 0:
        return const HomePath();
      case 1:
        return const GalleryPath();
      case 2:
        return const CollectionsPath();
      default:
        return const HomePath();
    }
  }
  // --- End _currentInternalAppPath ---

  @override
  AppRoutePath? get currentConfiguration {
    if (authProvider.status == AuthStatus.uninitialized ||
        authProvider.status == AuthStatus.authenticating) {
      return _currentAuthScreenPathIntent;
    }
    if (!authProvider.isAuthenticated) {
      return _currentAuthScreenPathIntent;
    }
    return _currentInternalAppPath; // Now correctly calls the getter
  }

  @override
  Future<void> setNewRoutePath(AppRoutePath path) async {
    if (path is LoginPath) {
      _currentAuthScreenPathIntent = const LoginPath();
      if (authProvider.isAuthenticated) {
        navigationProvider.onItemTapped(0);
      }
    } else if (path is SignupPath) {
      _currentAuthScreenPathIntent = const SignupPath();
      if (authProvider.isAuthenticated) {
        navigationProvider.onItemTapped(0);
      }
    } else if (path is HomePath ||
        path is GalleryPath ||
        path is CollectionsPath) {
      if (!authProvider.isAuthenticated &&
          authProvider.status != AuthStatus.uninitialized &&
          authProvider.status != AuthStatus.authenticating) {
        _currentAuthScreenPathIntent = const LoginPath();
      } else if (authProvider.isAuthenticated) {
        int newIndex = 0;
        if (path is GalleryPath) newIndex = 1;
        if (path is CollectionsPath) newIndex = 2;
        navigationProvider.onItemTapped(newIndex);
      }
    } else if (path is UnknownPath) {
      if (!authProvider.isAuthenticated &&
          authProvider.status != AuthStatus.uninitialized &&
          authProvider.status != AuthStatus.authenticating) {
        _currentAuthScreenPathIntent = const LoginPath();
      } else {
        navigationProvider.onItemTapped(0);
      }
    }
    notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    List<Page<dynamic>> pages = [];

    if (authProvider.status == AuthStatus.uninitialized ||
        authProvider.status == AuthStatus.authenticating) {
      pages.add(
        const MaterialPage(
          key: ValueKey('LoadingPage'),
          child: Scaffold(body: Center(child: CircularProgressIndicator())),
        ),
      );
    } else if (!authProvider.isAuthenticated) {
      AuthMode initialMode = (_currentAuthScreenPathIntent is SignupPath)
          ? AuthMode.signup
          : AuthMode.login;
      pages.add(
        MaterialPage(
          key: ValueKey('AuthPage_$initialMode'),
          child: AuthPage(initialAuthMode: initialMode),
        ),
      );
    } else {
      Widget currentPageWidget;
      switch (navigationProvider.selectedIndex) {
        case 0:
          currentPageWidget = const ArtatlasHomePage();
          break;
        case 1:
          currentPageWidget = const ArtatlasGalleryPage();
          break;
        case 2:
          currentPageWidget = const ArtatlasCollectionsPage();
          break;
        default:
          currentPageWidget = const Center(
            child: Text("Error: Page not found"),
          );
      }
      pages.add(
        MaterialPage(
          key: ValueKey('AppShell_Tab_${navigationProvider.selectedIndex}'),
          child: AppShell(currentPage: currentPageWidget),
        ),
      );
    }

    return Navigator(
      key: navigatorKey,
      pages: pages,
      // onPopPage is deprecated. PopNavigatorRouterDelegateMixin handles basic popping.
      // Override popRoute for custom behavior.
    );
  }

  @override
  Future<bool> popRoute() {
    if (!authProvider.isAuthenticated &&
        authProvider.status != AuthStatus.uninitialized) {
      if (_currentAuthScreenPathIntent is SignupPath) {
        updateCurrentAuthScreenPathIntent(const LoginPath());
        return Future.value(
          true,
        ); // Handled by changing state, allow pop (which rebuilds with new state)
      }
    } else if (authProvider.isAuthenticated) {
      if (kIsWeb) {
        if (navigationProvider.selectedIndex != 0) {
          navigationProvider.onItemTapped(navigationProvider.selectedIndex - 1);
          return Future.value(true); // Handled
        }
      } else {
        // Mobile
        if (navigationProvider.selectedIndex != 0) {
          navigationProvider.onItemTapped(navigationProvider.selectedIndex - 1);
          return Future.value(true); // Handled
        }
      }
    }
    // Let the mixin handle the pop if not handled above (e.g., if it can pop from `navigatorKey.currentState`)
    // If it can't pop (e.g., only one page in the stack), it might lead to app exit on Android.
    return super.popRoute();
  }
}
