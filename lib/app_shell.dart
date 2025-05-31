// lib/app_shell.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hack_front/artatlas_collections_page.dart';
import 'package:hack_front/artatlas_gallery_page.dart';
import 'package:hack_front/main.dart'; // For MuseumHomePage
import 'package:hack_front/responsive_util.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      MuseumHomePage(onNavigateToTab: _onItemTapped), // Already had it
      ArtatlasGalleryPage(onNavigateToTab: _onItemTapped), // Add callback
      ArtatlasCollectionsPage(onNavigateToTab: _onItemTapped), // Add callback
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtil.isMobile(context);

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      floatingActionButton: _selectedIndex == 1
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
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
            )
          : null,
    );
  }
}
