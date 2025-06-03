// test/pages/artatlas_gallery_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hack_front/models/artwork_model.dart';
import 'package:hack_front/models/gallery_model.dart';
import 'package:hack_front/pages/artatlas_gallery_page.dart';
import 'package:hack_front/providers/gallery_provider.dart';
import 'package:hack_front/providers/navigation_provider.dart';
import 'package:hack_front/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Import your mocks
import '../mocks/mock_providers.dart'; // Adjust path if needed

void main() {
  // It's good practice to create these mocks once
  late MockGalleryProvider mockGalleryProvider;
  late MockNavigationProvider mockNavigationProvider;
  late MockThemeProvider mockThemeProvider;

  setUp(() {
    mockGalleryProvider = MockGalleryProvider();
    mockNavigationProvider =
        MockNavigationProvider(); // Assuming simple mock for now
    mockThemeProvider = MockThemeProvider(); // Assuming simple mock

    // Set up default return values for getters that might be accessed during build
    // For instance, if ArtatlasGalleryPage accesses these immediately
    mockGalleryProvider.setMockGalleries(
      [],
    ); // Start with empty galleries in drawer
    mockGalleryProvider.setMockIsLoadingGalleries(false);
    mockGalleryProvider.setMockHasMoreGalleries(true);

    mockGalleryProvider.setMockSelectedGallery(null);
    mockGalleryProvider.setMockGalleryArtworks([]);
    mockGalleryProvider.setMockSelectedArtwork(null);
    mockGalleryProvider.setMockIsLoadingGalleryArtworks(false);
    mockGalleryProvider.setMockHasMoreGalleryArtworks(true);
  });

  Widget createTestableWidget(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GalleryProvider>.value(
          value: mockGalleryProvider,
        ),
        ChangeNotifierProvider<NavigationProvider>.value(
          value: mockNavigationProvider,
        ),
        ChangeNotifierProvider<ThemeProvider>.value(value: mockThemeProvider),
      ],
      child: MaterialApp(
        home: child,
        //If your app uses named routes extensively, you might need a mock navigator
        //or use MaterialApp.router with a mock router delegate.
      ),
    );
  }

  group('ArtatlasGalleryPage', () {
    testWidgets(
      'displays "Select a gallery" message when no gallery is selected',
      (WidgetTester tester) async {
        // Arrange: Default setup has no selected gallery

        await tester.pumpWidget(
          createTestableWidget(const ArtatlasGalleryPage()),
        );
        await tester
            .pumpAndSettle(); // Allow initState and initial builds to complete

        // Assert
        expect(find.text('Gallery'), findsOneWidget); // AppBar title
        expect(find.text('Select a gallery from the drawer.'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );

    testWidgets(
      'displays loading indicator when artworks are being fetched for a selected gallery',
      (WidgetTester tester) async {
        // Arrange
        final testGallery = GalleryModel(id: 'g1', name: 'Test Gallery 1');
        // Simulate a gallery is selected and artworks are loading
        mockGalleryProvider.setMockSelectedGallery(testGallery);
        mockGalleryProvider.setMockGalleryArtworks([]); // No artworks yet
        mockGalleryProvider.setMockSelectedArtwork(null);
        mockGalleryProvider.setMockIsLoadingGalleryArtworks(
          true,
        ); // Key: set loading to true

        await tester.pumpWidget(
          createTestableWidget(const ArtatlasGalleryPage()),
        );
        // No need to pumpAndSettle if we are checking the loading state immediately

        // Assert
        expect(find.text('Gallery'), findsOneWidget); // Static AppBar title
        // The main display area should show a loading indicator
        expect(
          find.descendant(
            of: find.byType(AspectRatio),
            matching: find.byType(CircularProgressIndicator),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets('displays selected artwork image when available', (
      WidgetTester tester,
    ) async {
      // Arrange
      final testGallery = GalleryModel(id: 'g1', name: 'Awesome Art');
      final testArtwork = Artwork(
        id: 'art1',
        artworkTitle: 'My Masterpiece',
        imageUrl:
            'http://example.com/image.jpg', // Mocked URL, won't actually fetch
      );
      mockGalleryProvider.setMockSelectedGallery(testGallery);
      mockGalleryProvider.setMockGalleryArtworks([
        testArtwork,
      ]); // Artworks list
      mockGalleryProvider.setMockSelectedArtwork(
        testArtwork,
      ); // Selected artwork
      mockGalleryProvider.setMockIsLoadingGalleryArtworks(false); // Not loading

      await tester.pumpWidget(
        createTestableWidget(const ArtatlasGalleryPage()),
      );
      await tester.pumpAndSettle(); // Let CachedNetworkImage try to resolve

      // Assert
      expect(find.text('Gallery'), findsOneWidget);
      // Check for CachedNetworkImage presence. We can't easily check the actual image source
      // in widget tests without more complex image mocking.
      expect(find.byType(CachedNetworkImage), findsOneWidget);
      // Check FAB which shows info for selected artwork
      expect(find.widgetWithText(FloatingActionButton, 'Info'), findsOneWidget);
    });

    testWidgets('FAB shows dialog with artwork details when tapped', (
      WidgetTester tester,
    ) async {
      final testArtwork = Artwork(
        id: 'art1',
        artworkTitle: 'My Masterpiece',
        artistName: 'Test Artist',
        year: '2024',
        description: 'A beautiful piece.',
        imageUrl: 'http://example.com/image.jpg',
      );
      mockGalleryProvider.setMockSelectedArtwork(testArtwork);
      mockGalleryProvider.setMockIsLoadingGalleryArtworks(false);

      await tester.pumpWidget(
        createTestableWidget(const ArtatlasGalleryPage()),
      );
      await tester.pumpAndSettle();

      expect(
        find.byType(AlertDialog),
        findsNothing,
      ); // Dialog not visible initially

      await tester.tap(find.widgetWithText(FloatingActionButton, 'Info'));
      await tester.pumpAndSettle(); // Allow dialog to appear

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('My Masterpiece'), findsOneWidget); // Dialog title
      expect(find.text('Artist: Test Artist'), findsOneWidget);
      expect(find.text('A beautiful piece.'), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle(); // Allow dialog to dismiss

      expect(find.byType(AlertDialog), findsNothing);
    });

    // TODO: Add tests for drawer interaction:
    // - Opening the drawer
    // - Displaying gallery items in the drawer
    // - Tapping a gallery item in the drawer and verifying selectGalleryAndLoadArtworks is called on provider
    // - Testing pagination in the drawer

    // TODO: Add tests for horizontal artwork list (if re-enabled):
    // - Displaying artwork items
    // - Tapping an item updates selectedArtwork
    // - Pagination for the horizontal list
  });
}
