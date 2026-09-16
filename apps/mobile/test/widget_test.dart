import 'package:flutter_test/flutter_test.dart';
import 'package:dakkana_mobile/main.dart';

void main() {
  testWidgets('Dakkana app starts', (tester) async {
    await tester.pumpWidget(const DakkanaApp());
    expect(find.text('دَكانة'), findsOneWidget);
    expect(find.text('كل حساب دَكانتك بإيدك'), findsOneWidget);
  });
}
