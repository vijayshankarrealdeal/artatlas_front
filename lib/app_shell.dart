// lib/app_shell.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hack_front/providers/auth_provider.dart';
import 'package:hack_front/providers/navigation_provider.dart';
import 'package:hack_front/providers/theme_provider.dart';
import 'package:hack_front/utils/responsive_util.dart';
import 'package:provider/provider.dart';

class AppShell extends StatelessWidget {
  final Widget currentPage; // Declare currentPage as a final field

  // Add Key? key and make currentPage a required named parameter
  const AppShell({super.key, required this.currentPage});

  Future<bool> _onWillPop(BuildContext context) async {
    final navigationProvider = Provider.of<NavigationProvider>(
      context,
      listen: false,
    );
    // On mobile, if not on the first tab, navigate back through tabs.
    // Otherwise (on first tab or on web), allow the default pop behavior.
    if (!kIsWeb && navigationProvider.selectedIndex != 0) {
      navigationProvider.onItemTapped(navigationProvider.selectedIndex - 1);
      return false; // We handled the pop.
    }
    return true; // Allow default pop.
  }

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isMobile = ResponsiveUtil.isMobile(context);
    final bool isCurrentlyDark = themeProvider.isDarkMode;

    Widget scaffoldContent = Scaffold(
      appBar:
          (isMobile ||
              (kIsWeb &&
                  ResponsiveUtil.isMobile(
                    context,
                  ))) // Simplified: Show AppBar for non-desktop like experiences
          ? null
          : AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                navigationProvider.selectedIndex == 0
                    ? 'Art Atlas - Home'
                    : navigationProvider.selectedIndex == 1
                    ? 'Gallery'
                    : 'Collections',
                style: Theme.of(
                  context,
                ).appBarTheme.titleTextStyle, // Use themed title style
              ),
              iconTheme: Theme.of(
                context,
              ).appBarTheme.iconTheme, // Use themed icon style
              actions: [
                IconButton(
                  icon: Icon(
                    isCurrentlyDark
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                  ),
                  tooltip: isCurrentlyDark
                      ? 'Switch to Light Mode'
                      : 'Switch to Dark Mode',
                  onPressed: () {
                    themeProvider.toggleTheme();
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: IconButton(
                    icon: const Icon(Icons.logout),
                    tooltip: 'Sign Out',
                    onPressed: () async {
                      await authProvider.signOut();
                    },
                  ),
                ),
              ],
            ),
      body: currentPage, // Use the currentPage field here
      floatingActionButton: navigationProvider.selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Search Tapped!')));
              },
              child: const Icon(CupertinoIcons.search),
            )
          : null,
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

    // Replace WillPopScope with PopScope
    if (!kIsWeb) {
      return PopScope(
        canPop: false, // We'll handle pop manually via onPopInvoked
        onPopInvoked: (bool didPop) async {
          if (didPop) {
            // If system already popped (e.g. swipe gesture on iOS)
            return;
          }
          final bool shouldPop = await _onWillPop(context);
          if (shouldPop && context.mounted) {
            // If _onWillPop allows it (e.g., on home tab), then really pop.
            // For Android, this usually means exiting the app.
            // Navigator.maybePop(context) could be used if there were nested routes in AppShell.
            // For exiting, system handles it if canPop is true after this.
            // To actually exit, you might need SystemNavigator.pop() but that's aggressive.
            // Allowing the Navigator to pop when `canPop` becomes true is standard.
            // Here, since we're at the top level, if _onWillPop returns true,
            // we effectively let the system action proceed if this was a system back.
            // If you need to ensure the app exits, you might need to control `canPop` more directly
            // or handle it in RouterDelegate.popRoute.
            // For now, if _onWillPop says true, we let the system handle it (which implies exit on Android if it's the root).
            // If you want to programmatically pop the router's current page:
            // Router.of(context).pop(); // This would call RouterDelegate.popRoute()
          }
        },
        child: scaffoldContent,
      );
    } else {
      return scaffoldContent;
    }
  }
}
