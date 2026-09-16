import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Dakkana branding smoke test', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('دَكانة')),
        ),
      ),
    );

    expect(find.text('دَكانة'), findsOneWidget);
  });
}
