// lib/main.dart

// lib/main.dart
import 'package:flutter/material.dart';
import 'package:hack_front/providers/collections_provider.dart';
import 'package:hack_front/providers/gallery_provider.dart';
import 'package:hack_front/providers/navigation_provider.dart';
import 'package:hack_front/routes/app_route_information_parser.dart'; // New import
import 'package:hack_front/routes/app_router_delegate.dart'; // New import
import 'package:provider/provider.dart';
// AppShell is now built by the RouterDelegate, so direct import here might not be needed
// import 'package:hack_front/app_shell.dart';

void main() {
  // For RouterDelegate to access NavigationProvider early, create it here
  final navigationProvider = NavigationProvider();
  final galleryProvider = GalleryProvider();
  final collectionsProvider = CollectionsProvider();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: navigationProvider),
        ChangeNotifierProvider.value(value: galleryProvider),
        ChangeNotifierProvider.value(value: collectionsProvider),
      ],
      child: MyApp(navigationProvider: navigationProvider), // Pass provider
    ),
  );
}

class MyApp extends StatefulWidget {
  final NavigationProvider navigationProvider;
  const MyApp({super.key, required this.navigationProvider});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppRouterDelegate _routerDelegate;
  final AppRouteInformationParser _routeInformationParser =
      AppRouteInformationParser();

  @override
  void initState() {
    super.initState();
    _routerDelegate = AppRouterDelegate(widget.navigationProvider);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Art Atlas',

      theme: ThemeData(
        fontFamily: 'FuturaPT',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
          dynamicSchemeVariant: DynamicSchemeVariant.monochrome,
          primary: Colors.blue,
        ),
        // textTheme: Theme.of(context).textTheme.apply(fontFamily: 'FuturaPT'),
        // primaryTextTheme: Theme.of(
        //   context,
        // ).primaryTextTheme.apply(fontFamily: 'FuturaPT'),
      ),
      routerDelegate: _routerDelegate,
      routeInformationParser: _routeInformationParser,
      // No 'home' property. The RouterDelegate builds the initial UI.
    );
  }
}
