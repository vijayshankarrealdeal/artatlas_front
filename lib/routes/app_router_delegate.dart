// lib/routing/app_router_delegate.dart
import 'package:flutter/material.dart';
import 'package:hack_front/app_shell.dart';
import 'package:hack_front/pages/artatlas_home_page.dart';
import 'package:hack_front/pages/auth/auth_page.dart'; // For AuthPage and AuthMode enum
import 'package:hack_front/pages/artatlas_gallery_page.dart';
import 'package:hack_front/pages/artatlas_collections_page.dart';
import 'package:hack_front/providers/auth_provider.dart'; // For AuthStatus enum
import 'package:hack_front/providers/navigation_provider.dart';
import 'app_route_path.dart';

class AppRouterDelegate extends RouterDelegate<AppRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoutePath> {
  // --- Fields ---
  final NavigationProvider navigationProvider;
  final AuthProvider authProvider;
  @override // Required by PopNavigatorRouterDelegateMixin
  final GlobalKey<NavigatorState> navigatorKey;

  AppRoutePath _currentAuthScreenPathIntent = const LoginPath();

  // --- Constructor ---
  AppRouterDelegate(this.navigationProvider, this.authProvider)
    : navigatorKey = GlobalKey<NavigatorState>() {
    navigationProvider.addListener(notifyListeners);
    authProvider.addListener(notifyListeners);
  }

  // --- Public Methods ---
  void updateCurrentAuthScreenPathIntent(AppRoutePath path) {
    if (path is LoginPath || path is SignupPath) {
      if (_currentAuthScreenPathIntent.runtimeType != path.runtimeType) {
        _currentAuthScreenPathIntent = path;
        notifyListeners();
      }
    }
  }

  // --- RouterDelegate Overrides ---
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

  @override
  AppRoutePath? get currentConfiguration {
    if (authProvider.status == AuthStatus.uninitialized ||
        authProvider.status == AuthStatus.authenticating) {
      return _currentAuthScreenPathIntent;
    }
    if (!authProvider.isAuthenticated) {
      return _currentAuthScreenPathIntent;
    }
    return _currentInternalAppPath;
  }

  @override
  Future<void> setNewRoutePath(AppRoutePath path) async {
    if (path is LoginPath) {
      _currentAuthScreenPathIntent = const LoginPath();
      if (authProvider.isAuthenticated) navigationProvider.onItemTapped(0);
    } else if (path is SignupPath) {
      _currentAuthScreenPathIntent = const SignupPath();
      if (authProvider.isAuthenticated) navigationProvider.onItemTapped(0);
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
      print(authProvider.token);
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
            child: Text("Error: Internal Page not found"),
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
      pages: List.of(pages), // Using a copy of the list
      // NO onPopPage or onDidRemovePage HERE!
      // The PopNavigatorRouterDelegateMixin handles this by using its own
      // onPopPage that eventually calls your overridden popRoute().
    );
  }

  @override
  Future<bool> popRoute() {
    if (!authProvider.isAuthenticated &&
        authProvider.status != AuthStatus.uninitialized &&
        authProvider.status != AuthStatus.authenticating) {
      if (_currentAuthScreenPathIntent is SignupPath) {
        updateCurrentAuthScreenPathIntent(const LoginPath());
        return Future.value(true);
      }
    } else if (authProvider.isAuthenticated) {
      if (navigationProvider.selectedIndex != 0) {
        navigationProvider.onItemTapped(navigationProvider.selectedIndex - 1);
        return Future.value(true);
      }
    }
    return super.popRoute(); // Fallback to mixin's default behavior
  }
}
