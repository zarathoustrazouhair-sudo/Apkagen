import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:residence_lamandier_b/data/local/database.dart';
import 'package:residence_lamandier_b/features/auth/presentation/login_screen.dart';
import 'package:residence_lamandier_b/core/theme/widgets/luxury_text_field.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedData() async {
    await db.into(db.users).insert(
      UsersCompanion.insert(
        name: "Test User Secure",
        floor: 1,
        apartmentNumber: drift.Value(1),
        role: "resident",
        accessCode: drift.Value("1234"),
      ),
    );
  }

  // Helper to find the pin field
  Finder findPinField() {
    Finder luxuryField = find.byWidgetPredicate((w) => w is LuxuryTextField && (w.label == "CODE PIN (Défaut: 0000)" || w.label == "CODE PIN"));
    if (luxuryField.evaluate().isNotEmpty) {
      return find.descendant(of: luxuryField, matching: find.byType(TextFormField));
    }
    return find.descendant(of: find.byType(LuxuryTextField).last, matching: find.byType(TextFormField));
  }

  testWidgets('Security Fix: Bypass 0000 should FAIL for user with custom PIN', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await seedData();

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const LoginScreen()),
        GoRoute(path: '/resident', builder: (context, state) => const Scaffold(body: Text("Resident Home"))),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
        ],
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text("RÉSIDENT"));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    final dropdownFinder = find.byType(DropdownButtonFormField<User>);
    await tester.ensureVisible(dropdownFinder);
    await tester.tap(dropdownFinder);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text("Apt 1 - Test User Secure").last);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    final pinField = findPinField();
    await tester.ensureVisible(pinField);
    await tester.enterText(pinField, "0000");
    await tester.pump();

    final loginButton = find.text("CONNEXION (RÉSIDENT)");
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);

    // Wait for login processing delay (500ms)
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(); // SnackBar appears here

    // Verify Logic: "Resident Home" is NOT found (login failed)
    expect(find.text("Resident Home"), findsNothing, reason: "Bypass 0000 should NOT work for user with PIN 1234");

    // Force cleanup
    await tester.pumpWidget(const Placeholder());
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('Regression Test: Correct PIN 1234 should SUCCEED', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await seedData();

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const LoginScreen()),
        GoRoute(path: '/resident', builder: (context, state) => const Scaffold(body: Text("Resident Home"))),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
        ],
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text("RÉSIDENT"));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    final dropdownFinder = find.byType(DropdownButtonFormField<User>);
    await tester.ensureVisible(dropdownFinder);
    await tester.tap(dropdownFinder);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text("Apt 1 - Test User Secure").last);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    final pinField = findPinField();
    await tester.ensureVisible(pinField);
    await tester.enterText(pinField, "1234");
    await tester.pump();

    final loginButton = find.text("CONNEXION (RÉSIDENT)");
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);

    // Wait for login processing delay (500ms)
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100)); // Navigation frame

    // Verify Logic: "Resident Home" IS found (login success)
    expect(find.text("Resident Home"), findsOneWidget, reason: "Correct PIN should work");

    // Force cleanup
    await tester.pumpWidget(const Placeholder());
    await tester.pump(const Duration(seconds: 5));
  });
}
