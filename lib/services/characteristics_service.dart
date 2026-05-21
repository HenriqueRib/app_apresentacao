import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/oratory_characteristic.dart';

class CharacteristicsService {
  static CharacteristicsService? _instance;
  List<OratoryCharacteristic> _characteristics = [];
  List<CharacteristicCategory> _categories = [];
  List<CompetencyFeedback> _competencies = [];
  List<ShinyashikiPillar> _pillars = [];
  bool _isLoaded = false;

  CharacteristicsService._();

  static CharacteristicsService get instance {
    _instance ??= CharacteristicsService._();
    return _instance!;
  }

  Future<void> loadData() async {
    if (_isLoaded) return;

    final String jsonString = await rootBundle.loadString(
      'assets/data/caracteristicas_oratoria.json',
    );
    final Map<String, dynamic> data = jsonDecode(jsonString);

    _characteristics = (data['characteristics'] as List)
        .map((c) => OratoryCharacteristic.fromJson(c))
        .toList();

    _categories = (data['categories'] as List)
        .map((c) => CharacteristicCategory.fromJson(c))
        .toList();

    _competencies = (data['competencies_feedback'] as List)
        .map((c) => CompetencyFeedback.fromJson(c))
        .toList();

    _pillars = (data['shinyashiki_pillars'] as List)
        .map((p) => ShinyashikiPillar.fromJson(p))
        .toList();

    _isLoaded = true;
  }

  List<OratoryCharacteristic> get allCharacteristics => _characteristics;

  List<CharacteristicCategory> get allCategories => _categories;

  List<CompetencyFeedback> get allCompetencies => _competencies;

  List<ShinyashikiPillar> get allPillars => _pillars;

  OratoryCharacteristic? getCharacteristicById(int id) {
    try {
      return _characteristics.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  List<OratoryCharacteristic> getCharacteristicsByCategory(String categoryId) {
    final category = _categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => const CharacteristicCategory(
        id: '',
        name: '',
        characteristicsIds: [],
      ),
    );

    return _characteristics
        .where((c) => category.characteristicsIds.contains(c.id))
        .toList();
  }

  List<OratoryCharacteristic> searchCharacteristics(String query) {
    if (query.isEmpty) return _characteristics;

    final lowerQuery = query.toLowerCase();
    return _characteristics.where((c) {
      return c.title.toLowerCase().contains(lowerQuery) ||
          c.category.toLowerCase().contains(lowerQuery) ||
          c.action.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  List<OratoryCharacteristic> getRecommendedForSpeechType(bool isPublic) {
    if (isPublic) {
      return _characteristics.where((c) {
        return [25, 26, 36, 37, 38, 39, 41, 48, 49, 51].contains(c.id);
      }).toList();
    } else {
      return _characteristics.where((c) {
        return [1, 4, 10, 13, 14, 23, 27, 28, 32].contains(c.id);
      }).toList();
    }
  }
}
