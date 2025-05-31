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

  // Tracks the intended auth screen for URL and initial mode purposes
  AppRoutePath _currentAuthScreenPathIntent = const LoginPath();

  // --- Constructor ---
  AppRouterDelegate(this.navigationProvider, this.authProvider)
    : navigatorKey = GlobalKey<NavigatorState>() {
    // Listen to providers to rebuild/update URL when their state changes
    navigationProvider.addListener(notifyListeners);
    authProvider.addListener(notifyListeners);
  }

  // --- Public Methods ---
  // Called by AuthPage to signal a desired change in the auth screen URL intent
  void updateCurrentAuthScreenPathIntent(AppRoutePath path) {
    if (path is LoginPath || path is SignupPath) {
      if (_currentAuthScreenPathIntent.runtimeType != path.runtimeType) {
        _currentAuthScreenPathIntent = path;
        notifyListeners(); // Triggers Router to update URL via currentConfiguration and rebuild
      }
    }
  }

  // --- RouterDelegate Overrides ---
  // Determines the current app path when authenticated
  AppRoutePath get _currentInternalAppPath {
    switch (navigationProvider.selectedIndex) {
      case 0:
        return const HomePath();
      case 1:
        return const GalleryPath();
      case 2:
        return const CollectionsPath();
      default:
        return const HomePath(); // Fallback
    }
  }

  @override
  AppRoutePath? get currentConfiguration {
    // This is used by the Router to get the current route configuration for URL updates
    if (authProvider.status == AuthStatus.uninitialized ||
        authProvider.status == AuthStatus.authenticating) {
      return _currentAuthScreenPathIntent; // Show login/signup path even while loading
    }
    if (!authProvider.isAuthenticated) {
      return _currentAuthScreenPathIntent; // Current intended auth path (LoginPath or SignupPath)
    }
    return _currentInternalAppPath; // Current authenticated app path
  }

  @override
  Future<void> setNewRoutePath(AppRoutePath path) async {
    // Called when the platform reports a new route (e.g., URL change in browser)
    if (path is LoginPath) {
      _currentAuthScreenPathIntent = const LoginPath();
      if (authProvider.isAuthenticated) {
        // If logged in and trying to go to /login, redirect to home
        navigationProvider.onItemTapped(0);
      }
    } else if (path is SignupPath) {
      _currentAuthScreenPathIntent = const SignupPath();
      if (authProvider.isAuthenticated) {
        // If logged in and trying to go to /signup, redirect to home
        navigationProvider.onItemTapped(0);
      }
    } else if (path is HomePath ||
        path is GalleryPath ||
        path is CollectionsPath) {
      if (!authProvider.isAuthenticated &&
          authProvider.status !=
              AuthStatus.uninitialized && // Allow if auth is still loading
          authProvider.status != AuthStatus.authenticating) {
        // Not logged in, trying to access app content -> redirect to login
        _currentAuthScreenPathIntent = const LoginPath();
      } else if (authProvider.isAuthenticated) {
        // If authenticated, navigate to the specified app tab
        int newIndex = 0; // Default to HomePath
        if (path is GalleryPath) newIndex = 1;
        if (path is CollectionsPath) newIndex = 2;
        navigationProvider.onItemTapped(newIndex);
      }
    } else if (path is UnknownPath) {
      if (!authProvider.isAuthenticated &&
          authProvider.status != AuthStatus.uninitialized &&
          authProvider.status != AuthStatus.authenticating) {
        _currentAuthScreenPathIntent = const LoginPath(); // Redirect to login
      } else {
        navigationProvider.onItemTapped(
          0,
        ); // Go home for unknown if authenticated
      }
    }
    // Important: Notify listeners if the internal state (_currentAuthScreenPathIntent or provider states)
    // has changed as a result of processing the new path.
    // The listeners on providers in the constructor will handle most cases.
    // Calling notifyListeners() here ensures that if setNewRoutePath directly
    // changes _currentAuthScreenPathIntent without a provider change, the UI still updates.
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
      // Determine which auth mode to show based on the URL intent
      AuthMode initialMode = (_currentAuthScreenPathIntent is SignupPath)
          ? AuthMode.signup
          : AuthMode.login;
      pages.add(
        MaterialPage(
          key: ValueKey(
            'AuthPage_$initialMode',
          ), // Key helps Flutter diff correctly
          child: AuthPage(initialAuthMode: initialMode),
        ),
      );
    } else {
      // User is authenticated, show the main app shell with the current page
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
      key: navigatorKey, // From PopNavigatorRouterDelegateMixin
      pages: List.of(pages), // Pass a copy of the pages list
      // DO NOT PROVIDE onPopPage or onDidRemovePage here.
      // The PopNavigatorRouterDelegateMixin provides the necessary onPopPage.
      // Custom pop logic goes into the overridden popRoute() method.
    );
  }

  @override
  Future<bool> popRoute() {
    // This method is called when a pop is requested (e.g., system back button).
    // It should return true if the pop was handled (route changed or consumed),
    // or false if this delegate cannot handle it (allowing parent routers or system to).

    if (!authProvider.isAuthenticated &&
        authProvider.status != AuthStatus.uninitialized &&
        authProvider.status != AuthStatus.authenticating) {
      // If in auth flow and currently intending to show signup URL
      if (_currentAuthScreenPathIntent is SignupPath) {
        // Change intent to login (which will update URL and rebuild AuthPage)
        updateCurrentAuthScreenPathIntent(const LoginPath());
        return Future.value(true); // We handled the pop by changing state
      }
      // If on LoginPath, let super.popRoute() decide (might exit app on mobile)
    } else if (authProvider.isAuthenticated) {
      // If authenticated and not on the first tab (Home)
      if (navigationProvider.selectedIndex != 0) {
        navigationProvider.onItemTapped(navigationProvider.selectedIndex - 1);
        return Future.value(true); // We handled the pop by changing tabs
      }
    }

    // If none of the above conditions met, delegate to the mixin's popRoute.
    // This will attempt to pop from the navigatorKey.currentState.
    // If that navigator can't pop (e.g., it's at its root), it returns false.
    // On mobile, a false return from the root router often leads to app exit.
    // On web, a false return might allow the browser to pop its history.
    return super.popRoute();
  }
}
