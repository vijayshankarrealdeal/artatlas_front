// lib/app_shell.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
// import 'package:hack_front/providers/auth_provider.dart'; // No longer directly used here
import 'package:hack_front/providers/navigation_provider.dart';
// import 'package:hack_front/providers/theme_provider.dart'; // No longer directly used here
// import 'package:hack_front/utils/responsive_util.dart'; // Not used if _appBarNavLink is removed
import 'package:provider/provider.dart';

class AppShell extends StatelessWidget {
  final Widget currentPage;

  const AppShell({super.key, required this.currentPage});

  Future<bool> _shouldPop(BuildContext context) async {
    // This function determines if a pop should be allowed to proceed.
    // It encapsulates the logic previously in _onWillPop.
    final navigationProvider = Provider.of<NavigationProvider>(
      context,
      listen: false,
    );

    if (!kIsWeb && navigationProvider.selectedIndex != 0) {
      // On mobile, and not on the first tab: navigate back through tabs
      navigationProvider.onItemTapped(navigationProvider.selectedIndex - 1);
      return false; // We handled it, so prevent the system/router from popping further.
    }
    // On web, or on the first tab on mobile: allow the pop.
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);
    final isMobile =
        !kIsWeb &&
        (MediaQuery.of(context).size.width < 650); // Simplified mobile check

    // AppShell's AppBar is now effectively disabled for all main tabs on desktop
    final bool isCollectionsPage = navigationProvider.selectedIndex == 2;
    final bool isHomePage = navigationProvider.selectedIndex == 0;
    final bool isGalleryPage = navigationProvider.selectedIndex == 1;
    final bool showGenericAppBar =
        !isMobile && !isCollectionsPage && !isHomePage && !isGalleryPage;

    Widget scaffoldContent = Scaffold(
      appBar: showGenericAppBar
          ? AppBar(
              title: const Text('Art Atlas'), // Generic title
            )
          : null,
      body: currentPage,

      bottomNavigationBar: isMobile
          ? NavigationBar(
              labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
              destinations: const <NavigationDestination>[
                NavigationDestination(
                  icon: Icon(CupertinoIcons.home),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(CupertinoIcons.circle_grid_hex),
                  label: 'Galleries',
                ),
                NavigationDestination(
                  icon: Icon(CupertinoIcons.collections),
                  label: 'Collection',
                ),
              ],
              selectedIndex: navigationProvider.selectedIndex,
              onDestinationSelected: (index) =>
                  navigationProvider.onItemTapped(index),
            )
          : null,
    );

    return PopScope(
      // canPop determines if the current route can be popped.
      // We make this dynamic based on our _shouldPop logic.
      // However, onPopInvoked is called *before* canPop is re-evaluated for the actual pop.
      // So, we'll use onPopInvoked to decide and then, if needed, programmatically pop.
      canPop:
          false, // Initially prevent direct system pops, let onPopInvoked decide.
      // ignore: deprecated_member_use
      onPopInvoked: (bool didPop) async {
        if (didPop) {
          // The pop happened for a reason outside of our control (e.g. iOS swipe, or nested navigator popped)
          return;
        }

        final bool allowPop = await _shouldPop(context);

        if (allowPop && context.mounted) {
          // If _shouldPop returns true, it means we want the navigation stack to pop.
          // This could be the browser history (web) or exiting the app (mobile, root route).
          // We need to allow the pop to happen.
          // For Router based navigation, we ask the RouterDelegate to handle it.
          // Navigator.maybePop(context) is for imperative Navigator.
          // Router.of(context).pop() is not a method.
          // We should call Router.maybePop or let the system handle it if canPop was true.
          // Since canPop is false, we need to explicitly tell the router to attempt a pop
          // if our logic dictates it.
          final router = Router.of(context);
          if (await router.routerDelegate.popRoute()) {
            // The router delegate handled the pop (e.g., went back in its own stack or browser history).
            return;
          }
          // If routerDelegate.popRoute() returns false, it means it couldn't handle it.
          // On mobile, if at the root, this might lead to app exit.
          // On web, this might mean no more history in the Flutter app's part.
          // If you truly want to exit the app on mobile in this scenario:
          // if (!kIsWeb && mounted) { SystemNavigator.pop(); }
        }
        // If allowPop is false, _shouldPop already handled the navigation (e.g., changed tabs),
        // so we do nothing more here, the pop is suppressed.
      },
      child: scaffoldContent,
    );
  }
}
