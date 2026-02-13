import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// A simple widget that mimics the list structure
class InefficientList extends StatelessWidget {
  final int itemCount;

  const InefficientList({super.key, required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ListView(
          children: List.generate(
            itemCount,
            (index) => ListTile(
              title: Text('Item $index'),
              subtitle: Text('Subtitle $index'),
            ),
          ),
        ),
      ),
    );
  }
}

class EfficientList extends StatelessWidget {
  final int itemCount;

  const EfficientList({super.key, required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ListView.builder(
          itemCount: itemCount,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text('Item $index'),
              subtitle: Text('Subtitle $index'),
            );
          },
        ),
      ),
    );
  }
}

void main() {
  testWidgets('Compare ListView vs ListView.builder performance', (WidgetTester tester) async {
    const int itemCount = 5000; // Use a large number to see the difference clearly

    // Benchmark 1: Inefficient List (ListView(children: ...))
    final stopwatch1 = Stopwatch()..start();
    await tester.pumpWidget(InefficientList(itemCount: itemCount));
    stopwatch1.stop();
    final duration1 = stopwatch1.elapsedMilliseconds;
    print('ListView(children: ...) took: ${duration1}ms');

    // Reset tester state
    await tester.pumpWidget(const SizedBox());

    // Benchmark 2: Efficient List (ListView.builder)
    final stopwatch2 = Stopwatch()..start();
    await tester.pumpWidget(EfficientList(itemCount: itemCount));
    stopwatch2.stop();
    final duration2 = stopwatch2.elapsedMilliseconds;
    print('ListView.builder took: ${duration2}ms');

    // Verify significant improvement
    expect(duration2, lessThan(duration1), reason: "ListView.builder should be faster than ListView(children: ...)");

    // Also check for memory impact? No, difficult to measure in this test environment.
  });
}
