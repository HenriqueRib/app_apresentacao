import 'package:flutter_test/flutter_test.dart';
import 'package:palestrante_de_sucesso/models/study_outline.dart';
import 'package:palestrante_de_sucesso/providers/study_studio_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  });

  test('createOutline adds to list', () async {
    final provider = StudyStudioProvider();
    await provider.load();
    final outline = await provider.createOutline('Teste');
    expect(provider.outlines.length, 1);
    expect(provider.getById(outline.id)?.title, 'Teste');
  });

  test('updateOutline with topics', () async {
    final provider = StudyStudioProvider();
    await provider.load();
    final outline = await provider.createOutline('Parte');
    final updated = outline.copyWith(
      topics: [
        const StudyTopic(id: 't1', shortIdea: 'Ideia', bibleReference: 'Sl 23:1'),
      ],
    );
    await provider.updateOutline(updated);
    expect(provider.getById(outline.id)?.topics.length, 1);
  });

  test('deleteOutline removes item', () async {
    final provider = StudyStudioProvider();
    final outline = await provider.createOutline('Remover');
    await provider.deleteOutline(outline.id);
    expect(provider.getById(outline.id), isNull);
    expect(
      provider.outlines.any((o) => o.id == outline.id),
      isFalse,
    );
  });
}
