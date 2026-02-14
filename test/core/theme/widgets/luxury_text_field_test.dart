import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:residence_lamandier_b/core/theme/widgets/luxury_text_field.dart';

void main() {
  group('LuxuryTextField', () {
    testWidgets('shows visibility toggle when obscureText is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LuxuryTextField(
              label: 'Password',
              obscureText: true,
            ),
          ),
        ),
      );

      // Initially, text is obscured. We expect to see Icons.visibility (click to show).
      final toggleFinder = find.byIcon(Icons.visibility);
      expect(toggleFinder, findsOneWidget);
    });

    testWidgets('toggles obscureText state when icon is pressed', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LuxuryTextField(
              label: 'Password',
              obscureText: true,
            ),
          ),
        ),
      );

      // Verify initial state: Obscured
      final textFieldFinder = find.byType(TextField); // It might use TextFormField which uses TextField internally
      // LuxuryTextField uses TextFormField.
      final textFormFieldFinder = find.byType(TextFormField);
      expect(textFormFieldFinder, findsOneWidget);

      // To check obscureText, we can check the EditableText widget which is low level
      final editableTextFinder = find.byType(EditableText);
      final editableText = tester.widget<EditableText>(editableTextFinder);
      expect(editableText.obscureText, isTrue);

      // Find toggle
      final toggleFinder = find.byIcon(Icons.visibility);

      // Tap toggle
      await tester.tap(toggleFinder);
      await tester.pump();

      // Verify state: Visible
      final editableTextVisible = tester.widget<EditableText>(editableTextFinder);
      expect(editableTextVisible.obscureText, isFalse);

      // Verify icon changed to visibility_off
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsNothing);

      // Tap toggle again
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      // Verify state: Obscured again
      final editableTextObscured = tester.widget<EditableText>(editableTextFinder);
      expect(editableTextObscured.obscureText, isTrue);
    });

    testWidgets('does NOT show visibility toggle when obscureText is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LuxuryTextField(
              label: 'Username',
              obscureText: false,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.visibility), findsNothing);
      expect(find.byIcon(Icons.visibility_off), findsNothing);
    });
  });
}
