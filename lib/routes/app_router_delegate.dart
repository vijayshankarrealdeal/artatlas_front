// lib/routing/app_router_delegate.dart
import 'package:flutter/material.dart';
import 'package:hack_front/app_shell.dart';
import 'package:hack_front/pages/artatlas_collections_page.dart';
import 'package:hack_front/pages/artatlas_gallery_page.dart';
import 'package:hack_front/pages/museum_home_page.dart';
import 'package:hack_front/providers/navigation_provider.dart';
import 'app_route_path.dart';

class AppRouterDelegate extends RouterDelegate<AppRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoutePath> {
  @override
  final GlobalKey<NavigatorState> navigatorKey;
  final NavigationProvider navigationProvider;

  AppRouterDelegate(this.navigationProvider) : navigatorKey = GlobalKey<NavigatorState>() {
    // When NavigationProvider changes (e.g., user taps bottom nav),
    // tell the Router to update the URL and rebuild.
    navigationProvider.addListener(() {
      notifyListeners();
    });
  }

  AppRoutePath get _currentPath {
    switch (navigationProvider.selectedIndex) {
      case 0:
        return const HomePath();
      case 1:
        return const GalleryPath();
      case 2:
        return const CollectionsPath();
      default:
        return const HomePath(); // Default to home
    }
  }

  @override
  AppRoutePath? get currentConfiguration => _currentPath;

  @override
  Future<void> setNewRoutePath(AppRoutePath path) async {
    // This is called when the browser URL changes (e.g., back/forward, direct entry)
    int newIndex = 0;
    if (path is HomePath) {
      newIndex = 0;
    } else if (path is GalleryPath) {
      newIndex = 1;
    } else if (path is CollectionsPath) {
      newIndex = 2;
    }
    // Update the NavigationProvider. This will also trigger UI updates (e.g., BottomNavBar selection)
    // because AppShell listens to NavigationProvider.
    // The check `if (_selectedIndex == index) return;` in onItemTapped prevents infinite loops.
    navigationProvider.onItemTapped(newIndex);
  }

  @override
  Widget build(BuildContext context) {
    Widget currentPageWidget;
    switch (navigationProvider.selectedIndex) {
      case 0:
        currentPageWidget = const MuseumHomePage();
        break;
      case 1:
        currentPageWidget = const ArtatlasGalleryPage();
        break;
      case 2:
        currentPageWidget = const ArtatlasCollectionsPage();
        break;
      default:
        // This case should ideally not be reached if selectedIndex is managed well.
        currentPageWidget = const Center(child: Text("Error: Page not found"));
    }

    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage(
          key: ValueKey('AppShell_${navigationProvider.selectedIndex}'),
          // The AppShell wraps the current page content
          child: AppShell(currentPage: currentPageWidget),
        ),
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }
        // For a simple tab-based app on the web, popping the only page in the Navigator
        // might not be desired directly. Browser back/forward is handled by setNewRoutePath.
        // If you had detail pages *within* a tab, you'd handle popping them here
        // and update the AppRoutePath accordingly.
        // For now, returning true allows the pop, but it won't do much if it's the root.
        return true;
      },
    );
  }
}