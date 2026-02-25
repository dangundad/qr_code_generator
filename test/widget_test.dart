import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_generator/main.dart';

void main() {
  testWidgets('qr_code_generator smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const QrCodeGeneratorApp());

    expect(find.byType(QrCodeGeneratorApp), findsOneWidget);
  });
}
