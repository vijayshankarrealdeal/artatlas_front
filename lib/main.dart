  // lib/main.dart
  import 'package:flutter/material.dart';
  import 'package:firebase_core/firebase_core.dart';
  import 'package:hack_front/firebase_options.dart';
  import 'package:hack_front/providers/auth_provider.dart';
  import 'package:hack_front/providers/collections_provider.dart';
  import 'package:hack_front/providers/gallery_provider.dart';
  import 'package:hack_front/providers/navigation_provider.dart';
  import 'package:hack_front/providers/theme_provider.dart';
  import 'package:hack_front/repositories/artwork_repository.dart';
  import 'package:hack_front/routes/app_route_information_parser.dart';
  import 'package:hack_front/routes/app_router_delegate.dart';
  import 'package:hack_front/services/api_service.dart';
  import 'package:hack_front/services/auth_service.dart';
  import 'package:hack_front/theme/app_theme.dart';
  import 'package:provider/provider.dart';

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    final authService = AuthService();
    final apiService = ApiService();
    final artworkRepository = ArtworkRepository(apiService);

    final navigationProvider = NavigationProvider();
    // Pass artworkRepository to GalleryProvider
    final galleryProvider = GalleryProvider(artworkRepository);
    final collectionsProvider = CollectionsProvider(artworkRepository);
    final authProvider = AuthProvider(authService);
    final themeProvider = ThemeProvider();

    runApp(
      MultiProvider(
        providers: [
          Provider<AuthService>.value(value: authService),
          Provider<ApiService>.value(value: apiService),
          Provider<ArtworkRepository>.value(value: artworkRepository),

          ChangeNotifierProvider.value(value: authProvider),
          ChangeNotifierProvider.value(value: navigationProvider),
          ChangeNotifierProvider.value(
            value: galleryProvider,
          ), // GalleryProvider uses artworkRepository
          ChangeNotifierProvider.value(value: collectionsProvider),
          ChangeNotifierProvider.value(value: themeProvider),
        ],
        child: MyApp(
          navigationProvider: navigationProvider,
          authProvider: authProvider,
        ),
      ),
    );
  }

  class MyApp extends StatefulWidget {
    final NavigationProvider navigationProvider;
    final AuthProvider authProvider;

    const MyApp({
      super.key,
      required this.navigationProvider,
      required this.authProvider,
    });

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
      _routerDelegate = AppRouterDelegate(
        widget.navigationProvider,
        widget.authProvider,
      );
    }

    @override
    Widget build(BuildContext context) {
      final themeProvider = Provider.of<ThemeProvider>(context);

      return MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Art Atlas',
        themeMode: themeProvider.themeMode,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        routerDelegate: _routerDelegate,
        routeInformationParser: _routeInformationParser,
      );
    }
  }
