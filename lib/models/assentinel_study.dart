import 'package:flutter/foundation.dart';

@immutable
class AssentinelStudy {
  final String id;
  final String conteudoEstudo;
  final String? comentarioInicial;
  final String? comentarioFinal;
  final String? resumoComentarios;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AssentinelStudy({
    required this.id,
    required this.conteudoEstudo,
    this.comentarioInicial,
    this.comentarioFinal,
    this.resumoComentarios,
    required this.createdAt,
    required this.updatedAt,
  });

  AssentinelStudy copyWith({
    String? id,
    String? conteudoEstudo,
    String? comentarioInicial,
    String? comentarioFinal,
    String? resumoComentarios,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AssentinelStudy(
      id: id ?? this.id,
      conteudoEstudo: conteudoEstudo ?? this.conteudoEstudo,
      comentarioInicial: comentarioInicial ?? this.comentarioInicial,
      comentarioFinal: comentarioFinal ?? this.comentarioFinal,
      resumoComentarios: resumoComentarios ?? this.resumoComentarios,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'conteudo_estudo': conteudoEstudo,
        'comentario_inicial': comentarioInicial,
        'comentario_final': comentarioFinal,
        'resumo_comentarios': resumoComentarios,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory AssentinelStudy.fromJson(Map<String, dynamic> json) {
    // Tratar IDs que podem vir como inteiros do backend
    final rawId = json['id'];
    return AssentinelStudy(
      id: rawId?.toString() ?? '',
      conteudoEstudo: (json['conteudo_estudo'] ?? json['conteudo'] ?? '').toString(),
      comentarioInicial: (json['comentario_inicial'] ?? json['inicial'] ?? json['comment_inicial'])?.toString(),
      comentarioFinal: (json['comentario_final'] ?? json['final'] ?? json['comment_final'])?.toString(),
      resumoComentarios: (json['resumo_comentarios'] ?? json['resumo'])?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
