import 'package:flutter/foundation.dart';

@immutable
class RespostaGerada {
  final String id;
  final String? pergunta;
  final String textoBase;
  final String fontePesquisa;
  final String? promptEspecifico;
  final String respostaGerada;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RespostaGerada({
    required this.id,
    this.pergunta,
    required this.textoBase,
    required this.fontePesquisa,
    this.promptEspecifico,
    required this.respostaGerada,
    required this.createdAt,
    required this.updatedAt,
  });

  RespostaGerada copyWith({
    String? id,
    String? pergunta,
    String? textoBase,
    String? fontePesquisa,
    String? promptEspecifico,
    String? respostaGerada,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RespostaGerada(
      id: id ?? this.id,
      pergunta: pergunta ?? this.pergunta,
      textoBase: textoBase ?? this.textoBase,
      fontePesquisa: fontePesquisa ?? this.fontePesquisa,
      promptEspecifico: promptEspecifico ?? this.promptEspecifico,
      respostaGerada: respostaGerada ?? this.respostaGerada,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'pergunta': pergunta,
        'texto_base': textoBase,
        'fonte_pesquisa': fontePesquisa,
        'prompt_especifico': promptEspecifico,
        'resposta_gerada': respostaGerada,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory RespostaGerada.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    return RespostaGerada(
      id: rawId?.toString() ?? '',
      pergunta: json['pergunta']?.toString(),
      textoBase: (json['texto_base'] ?? '').toString(),
      fontePesquisa: (json['fonte_pesquisa'] ?? '').toString(),
      promptEspecifico: json['prompt_especifico']?.toString(),
      respostaGerada: (json['resposta_gerada'] ?? json['content'] ?? '').toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
