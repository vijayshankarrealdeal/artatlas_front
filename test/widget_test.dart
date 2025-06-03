// test/widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hack_front/main.dart';
import 'package:hack_front/providers/auth_provider.dart';
import 'package:hack_front/providers/navigation_provider.dart';
import 'package:hack_front/services/auth_service.dart'; // Needed for AuthProvider
import 'package:mockito/mockito.dart'; // If you decide to mock AuthService

// --- Option 1: Using real instances (simpler for this smoke test) ---
// You might need to mock AuthService if it makes real Firebase calls you want to avoid
class MockAuthService extends Mock implements AuthService {}

void main() {
  testWidgets('MyApp smoke test - checks initial state', (
    WidgetTester tester,
  ) async {
    // Arrange: Create instances of the required providers
    final navigationProvider = NavigationProvider();

    // For AuthProvider, it needs an AuthService.
    // For a simple smoke test, you could use a real AuthService if it initializes cleanly
    // without side effects, or mock it. Let's mock AuthService for better isolation.
    final mockAuthService = MockAuthService();

    // Stub the authStateChanges stream if MyApp tries to listen to it immediately.
    // For a smoke test, we might assume it starts unauthenticated or uninitialized.
    when(
      mockAuthService.authStateChanges,
    ).thenAnswer((_) => Stream.value(null)); // Emits null (unauthenticated)
    when(mockAuthService.currentUser).thenReturn(null); // No current user

    final authProvider = AuthProvider(mockAuthService);

    // Act: Build our app and trigger a frame.
    // We need to wrap MyApp with MultiProvider if MyApp itself doesn't do it
    // and expects providers to be available above it (which it does via main.dart).
    // However, MyApp in main.dart is ALREADY the child of MultiProvider.
    // The issue is that the MyApp constructor itself needs these providers.
    await tester.pumpWidget(
      MaterialApp(
        // MaterialApp is usually at the root for testing pages/app structure
        home: MyApp(
          navigationProvider: navigationProvider,
          authProvider: authProvider,
        ),
      ),
    );

    // Assert:
    // This default test was for a counter app. Your app doesn't have a counter.
    // You need to change the assertions to match what your app displays in its
    // initial state (e.g., when unauthenticated).
    // For example, if it shows a login page:

    // Let the widget tree settle (e.g., for provider listeners, FutureBuilders)
    await tester.pumpAndSettle();

    // Assuming unauthenticated state leads to AuthPage with "Login" initially.
    // This depends on your AppRouterDelegate logic.
    // If AuthProvider starts as uninitialized, it might show a loading indicator first.
    // If AuthProvider.status is AuthStatus.uninitialized (common initial state)
    // then AppRouterDelegate shows a loading screen.
    // Let's assume it settles to the login form.
    // You'll need to adjust these finders based on your actual AuthPage content.

    // Example: If AuthPage shows a title "Art Atlas" when in login mode
    expect(
      find.text('Art Atlas'),
      findsWidgets,
    ); // Might find multiple if used elsewhere

    // Example: If AuthPage shows an "Email" TextFormField
    expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);

    // Example: If AuthPage shows a "Login" button
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);

    // The original counter assertions are no longer relevant:
    // expect(find.text('0'), findsOneWidget);
    // expect(find.text('1'), findsNothing);
    // await tester.tap(find.byIcon(Icons.add));
    // await tester.pump();
    // expect(find.text('0'), findsNothing);
    // expect(find.text('1'), findsOneWidget);
  });
}
