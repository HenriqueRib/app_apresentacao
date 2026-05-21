import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/masterclass_step.dart';

class MasterclassService {
  static MasterclassService? _instance;
  List<MasterclassStep> _steps = [];

  MasterclassService._();

  static MasterclassService get instance {
    _instance ??= MasterclassService._();
    return _instance!;
  }

  List<MasterclassStep> get steps => List.unmodifiable(_steps);

  Future<void> loadData() async {
    if (_steps.isNotEmpty) return;
    final raw = await rootBundle.loadString(
      'assets/data/shinyashiki_masterclass.json',
    );
    final data = jsonDecode(raw) as Map<String, dynamic>;
    _steps = (data['steps'] as List)
        .map((e) => MasterclassStep.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
