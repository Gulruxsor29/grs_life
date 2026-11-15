import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grs_life/core/widgets/charts.dart';
import 'package:grs_life/core/widgets/ui_kit.dart';

void main() {
  testWidgets('GlassCard renders its child', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GlassCard(child: Text('content')),
        ),
      ),
    );
    expect(find.text('content'), findsOneWidget);
  });

  testWidgets('GradientButton triggers onTap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GradientButton(label: 'Save', onTap: () => tapped = true),
          ),
        ),
      ),
    );
    expect(tapped, isFalse);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
  });

  testWidgets('ProgressBar accepts out-of-range values', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProgressBar(value: 1.7),
        ),
      ),
    );
    expect(find.byType(ProgressBar), findsOneWidget);
  });

  testWidgets('RingProgress builds with center label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RingProgress(
            progress: 0.5,
            size: 80,
            center: Text('50%'),
          ),
        ),
      ),
    );
    expect(find.text('50%'), findsOneWidget);
  });

  testWidgets('BarChart lays out data', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BarChart(
            data: [
              BarDatum(label: 'jan', value: 10),
              BarDatum(label: 'feb', value: 20, highlight: true),
            ],
          ),
        ),
      ),
    );
    expect(find.byType(BarChart), findsOneWidget);
  });
}
