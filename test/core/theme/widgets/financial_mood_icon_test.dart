import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:residence_lamandier_b/core/theme/luxury_theme.dart';
import 'package:residence_lamandier_b/core/theme/widgets/financial_mood_icon.dart';

void main() {
  group('FinancialMoodIcon', () {
    testWidgets('displays correct icon and color for good health (>= 3.0 months)', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FinancialMoodIcon(monthsOfSurvival: 3.5),
          ),
        ),
      );

      final iconFinder = find.byType(Icon);
      expect(iconFinder, findsOneWidget);

      final Icon icon = tester.widget(iconFinder);
      expect(icon.icon, Icons.sentiment_very_satisfied);
      expect(icon.color, const Color(0xFF00E5FF));
    });

    testWidgets('displays correct icon and color for boundary good health (3.0 months)', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FinancialMoodIcon(monthsOfSurvival: 3.0),
          ),
        ),
      );

      final iconFinder = find.byType(Icon);
      expect(iconFinder, findsOneWidget);

      final Icon icon = tester.widget(iconFinder);
      expect(icon.icon, Icons.sentiment_very_satisfied);
      expect(icon.color, const Color(0xFF00E5FF));
    });

    testWidgets('displays correct icon and color for medium health (>= 0.0 and < 3.0 months)', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FinancialMoodIcon(monthsOfSurvival: 1.5),
          ),
        ),
      );

      final iconFinder = find.byType(Icon);
      expect(iconFinder, findsOneWidget);

      final Icon icon = tester.widget(iconFinder);
      expect(icon.icon, Icons.sentiment_neutral);
      expect(icon.color, const Color(0xFFFFAB00));
    });

    testWidgets('displays correct icon and color for boundary medium health (0.0 months)', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FinancialMoodIcon(monthsOfSurvival: 0.0),
          ),
        ),
      );

      final iconFinder = find.byType(Icon);
      expect(iconFinder, findsOneWidget);

      final Icon icon = tester.widget(iconFinder);
      expect(icon.icon, Icons.sentiment_neutral);
      expect(icon.color, const Color(0xFFFFAB00));
    });

    testWidgets('displays correct icon and color for bad health (< 0.0 months)', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FinancialMoodIcon(monthsOfSurvival: -1.0),
          ),
        ),
      );

      final iconFinder = find.byType(Icon);
      expect(iconFinder, findsOneWidget);

      final Icon icon = tester.widget(iconFinder);
      expect(icon.icon, Icons.add_alert);
      expect(icon.color, AppTheme.errorRed);
    });
  });
}
