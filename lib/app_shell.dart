// lib/app_shell.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hack_front/providers/navigation_provider.dart';
import 'package:hack_front/utils/responsive_util.dart';
import 'package:provider/provider.dart';

class AppShell extends StatelessWidget {
  final Widget currentPage; // This will be MuseumHomePage, GalleryPage, etc.

  const AppShell({super.key, required this.currentPage});

  // static final List<Widget> _pages = <Widget>[...]; // This is no longer needed here

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(
      context,
    ); // Still listen for BottomNav
    final isMobile = ResponsiveUtil.isMobile(context);

    return Scaffold(
      body:
          currentPage, // Display the page content determined by the RouterDelegate
      floatingActionButton:
          navigationProvider.selectedIndex ==
              1 // Gallery page
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
              // When a destination is selected, NavigationProvider updates its state.
              // The RouterDelegate listens to NavigationProvider and updates the URL.
              onDestinationSelected: (index) =>
                  navigationProvider.onItemTapped(index),
            )
          : null,
    );
  }
}
