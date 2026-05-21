import 'package:flutter/foundation.dart';

@immutable
class AdminDiscurso {
  final int id;
  final String tema;
  final String? data;
  final String? numero;
  final String? cantico;
  final String? objetivo;
  final String esbocoOriginal;
  final String manuscritoCompleto;
  final String? fonteMaterias;
  final String? guide;
  final DateTime? createdAt;

  const AdminDiscurso({
    required this.id,
    required this.tema,
    this.data,
    this.numero,
    this.cantico,
    this.objetivo,
    this.esbocoOriginal = '',
    this.manuscritoCompleto = '',
    this.fonteMaterias,
    this.guide,
    this.createdAt,
  });

  AdminDiscurso copyWith({
    int? id,
    String? tema,
    String? data,
    String? numero,
    String? cantico,
    String? objetivo,
    String? esbocoOriginal,
    String? manuscritoCompleto,
    String? fonteMaterias,
    String? guide,
    DateTime? createdAt,
  }) {
    return AdminDiscurso(
      id: id ?? this.id,
      tema: tema ?? this.tema,
      data: data ?? this.data,
      numero: numero ?? this.numero,
      cantico: cantico ?? this.cantico,
      objetivo: objetivo ?? this.objetivo,
      esbocoOriginal: esbocoOriginal ?? this.esbocoOriginal,
      manuscritoCompleto: manuscritoCompleto ?? this.manuscritoCompleto,
      fonteMaterias: fonteMaterias ?? this.fonteMaterias,
      guide: guide ?? this.guide,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'tema': tema,
        if (data != null && data!.isNotEmpty) 'data': data,
        if (numero != null && numero!.isNotEmpty) 'numero': numero,
        if (cantico != null && cantico!.isNotEmpty) 'cantico': cantico,
        if (objetivo != null && objetivo!.isNotEmpty) 'objetivo': objetivo,
        'esboco_original': esbocoOriginal,
        'manuscrito_completo': manuscritoCompleto,
        if (fonteMaterias != null) 'fonte_materias': fonteMaterias,
        if (guide != null) 'guide': guide,
      };

  factory AdminDiscurso.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    return AdminDiscurso(
      id: rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '0') ?? 0,
      tema: (json['tema'] ?? '').toString(),
      data: json['data']?.toString(),
      numero: json['numero']?.toString(),
      cantico: json['cantico']?.toString(),
      objetivo: (json['objetivo'] ?? json['objetivo_central'])?.toString(),
      esbocoOriginal: (json['esboco_original'] ?? '').toString(),
      manuscritoCompleto: (json['manuscrito_completo'] ?? '').toString(),
      fonteMaterias: json['fonte_materias']?.toString(),
      guide: json['guide']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}
