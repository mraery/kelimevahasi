import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kelimevahasi/main.dart';
import 'package:kelimevahasi/services/vocab_service.dart';

void main() {
  testWidgets('KelimeVahasi smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final service = await VocabService.init();

    await tester.pumpWidget(KelimeVahasiApp(vocabService: service));
    await tester.pump();

    // Verify key titles and tabs
    expect(find.text('Kelime Kartları'), findsOneWidget);
    expect(find.text('Kartlar'), findsOneWidget);
    expect(find.text('Sözlük'), findsOneWidget);
    expect(find.text('Kelime Avı'), findsOneWidget);
    expect(find.text('İstatistik'), findsOneWidget);
  });
}
