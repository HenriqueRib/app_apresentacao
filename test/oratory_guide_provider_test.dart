import 'package:flutter_test/flutter_test.dart';
import 'package:palestrante_de_sucesso/models/self_assessment_record.dart';
import 'package:palestrante_de_sucesso/providers/oratory_guide_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'self_assessments': '[]',
      'weekly_focus_characteristics': <String>[],
    });
  });

  tearDown(() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  });

  test('saveAssessment adds record', () async {
    final provider = OratoryGuideProvider();
    await provider.load();
    await provider.saveAssessment(
      scores: [
        const CharacteristicScore(
          characteristicId: 1,
          level: AssessmentLevel.yes,
        ),
      ],
      speechTitle: 'Parte teste',
    );
    expect(provider.records.length, 1);
    expect(provider.records.first.countLevel(AssessmentLevel.yes), 1);
  });

  test('toggleWeeklyFocus adds and removes id', () async {
    final provider = OratoryGuideProvider();
    await provider.load();
    await provider.toggleWeeklyFocus(5);
    expect(provider.isWeeklyFocus(5), isTrue);
    await provider.toggleWeeklyFocus(5);
    expect(provider.isWeeklyFocus(5), isFalse);
  });
}
