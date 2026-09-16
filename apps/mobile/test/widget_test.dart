import 'package:flutter_test/flutter_test.dart';
import 'package:dakkana_mobile/app/app.dart';

void main() {
  testWidgets('Dakkana app starts', (tester) async {
    await tester.pumpWidget(const DakkanaApp());
    await tester.pump();
    expect(find.textContaining('دَكانة'), findsOneWidget);
  });
}
