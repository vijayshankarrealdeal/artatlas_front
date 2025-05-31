import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hack_front/firebase_options.dart';
import 'package:hack_front/providers/auth_provider.dart';
import 'package:hack_front/providers/collections_provider.dart';
import 'package:hack_front/providers/gallery_provider.dart';
import 'package:hack_front/providers/navigation_provider.dart';
import 'package:hack_front/providers/theme_provider.dart'; // Import ThemeProvider
import 'package:hack_front/routes/app_route_information_parser.dart';
import 'package:hack_front/routes/app_router_delegate.dart';
import 'package:hack_front/services/auth_service.dart';
import 'package:hack_front/theme/app_theme.dart'; // Import AppTheme
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final authService = AuthService();
  final navigationProvider = NavigationProvider();
  final galleryProvider = GalleryProvider();
  final collectionsProvider = CollectionsProvider();
  final authProvider = AuthProvider(authService);
  final themeProvider = ThemeProvider(); // Create ThemeProvider instance

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>.value(value: authService),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: navigationProvider),
        ChangeNotifierProvider.value(value: galleryProvider),
        ChangeNotifierProvider.value(value: collectionsProvider),
        ChangeNotifierProvider.value(
          value: themeProvider,
        ), // Provide ThemeProvider
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
    // Listen to ThemeProvider for theme changes
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Art Atlas',
      themeMode: themeProvider.themeMode, // Use themeMode from provider
      theme: AppTheme.lightTheme, // Provide light theme
      darkTheme: AppTheme.darkTheme, // Provide dark theme
      routerDelegate: _routerDelegate,
      routeInformationParser: _routeInformationParser,
    );
  }
}
