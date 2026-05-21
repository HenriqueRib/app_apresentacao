import 'package:flutter_test/flutter_test.dart';
import 'package:palestrante_de_sucesso/models/weekly_comment_note.dart';
import 'package:palestrante_de_sucesso/providers/meeting_hub_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({'weekly_comment_pins': '[]'});
  });

  tearDown(() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  });

  test('toggleFavorite creates and updates note', () async {
    final provider = MeetingHubProvider();
    await provider.load();
    await provider.toggleFavorite('semana_1', 0);
    expect(provider.getNote('semana_1', 0)?.isFavorite, isTrue);
    await provider.toggleFavorite('semana_1', 0);
    expect(provider.getNote('semana_1', 0), isNull);
  });

  test('setPersonalNote persists text', () async {
    final provider = MeetingHubProvider();
    await provider.load();
    await provider.setPersonalNote('semana_1', 1, 'Minha prancheta');
    final note = provider.getNote('semana_1', 1);
    expect(note?.personalNote, 'Minha prancheta');
  });

  test('WeeklyCommentNote storageId format', () {
    const note = WeeklyCommentNote(weekKey: 'w1', commentIndex: 2);
    expect(note.storageId, 'w1_2');
  });
}
