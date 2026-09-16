import 'package:flutter_test/flutter_test.dart';
import 'package:dakkana_mobile/main.dart';

void main() {
  testWidgets('Dakkana app starts', (tester) async {
    await tester.pumpWidget(const DakkanaApp());
    expect(find.textContaining('دَكانة'), findsOneWidget);
    expect(find.textContaining('كل حساب دَكانتك بإيدك'), findsOneWidget);
  });
}
