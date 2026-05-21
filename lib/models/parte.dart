import 'package:flutter/foundation.dart';

@immutable
class ParteTopico {
  final String descricao;
  final String? texto;
  final String? fonte;

  const ParteTopico({
    required this.descricao,
    this.texto,
    this.fonte,
  });

  ParteTopico copyWith({
    String? descricao,
    String? texto,
    String? fonte,
  }) {
    return ParteTopico(
      descricao: descricao ?? this.descricao,
      texto: texto ?? this.texto,
      fonte: fonte ?? this.fonte,
    );
  }

  Map<String, dynamic> toJson() => {
        'descricao': descricao,
        'texto': texto,
        'fonte': fonte,
      };

  factory ParteTopico.fromJson(Map<String, dynamic> json) {
    return ParteTopico(
      descricao: (json['descricao'] ?? '').toString(),
      texto: json['texto']?.toString(),
      fonte: json['fonte']?.toString(),
    );
  }
}

@immutable
class Parte {
  final String id;
  final String tema;
  final List<ParteTopico> topicos;
  final String? conteudoOriginal;
  final String? esbocoManuscrito;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Parte({
    required this.id,
    required this.tema,
    required this.topicos,
    this.conteudoOriginal,
    this.esbocoManuscrito,
    required this.createdAt,
    required this.updatedAt,
  });

  Parte copyWith({
    String? id,
    String? tema,
    List<ParteTopico>? topicos,
    String? conteudoOriginal,
    String? esbocoManuscrito,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Parte(
      id: id ?? this.id,
      tema: tema ?? this.tema,
      topicos: topicos ?? this.topicos,
      conteudoOriginal: conteudoOriginal ?? this.conteudoOriginal,
      esbocoManuscrito: esbocoManuscrito ?? this.esbocoManuscrito,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tema': tema,
        'topicos': topicos.map((t) => t.toJson()).toList(),
        'conteudo_original': conteudoOriginal,
        'esboco_manuscrito': esbocoManuscrito,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory Parte.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    
    var rawTopicos = json['topicos'];
    List<ParteTopico> parsedTopicos = [];
    if (rawTopicos is List) {
      parsedTopicos = rawTopicos
          .map((item) => ParteTopico.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    
    return Parte(
      id: rawId?.toString() ?? '',
      tema: (json['tema'] ?? '').toString(),
      topicos: parsedTopicos,
      conteudoOriginal: (json['conteudo_original'] ?? json['conteudo'])?.toString(),
      esbocoManuscrito: (json['esboco_manuscrito'] ?? json['esboco'])?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
