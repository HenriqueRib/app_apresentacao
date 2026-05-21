import 'package:flutter/foundation.dart';

@immutable
class WeeklyCommentItem {
  final int? id;
  final String comentario;
  final List<String> tags;

  const WeeklyCommentItem({
    this.id,
    required this.comentario,
    this.tags = const [],
  });

  factory WeeklyCommentItem.fromJson(dynamic json) {
    if (json is String) {
      return WeeklyCommentItem(comentario: json);
    }
    final map = json as Map<String, dynamic>;
    final rawId = map['id'];
    final tagList = (map['tags'] as List?)
            ?.map((t) {
              if (t is Map) return (t['name'] ?? t['tag'] ?? '').toString();
              return t.toString();
            })
            .where((s) => s.isNotEmpty)
            .toList() ??
        const <String>[];

    return WeeklyCommentItem(
      id: rawId is int ? rawId : int.tryParse(rawId?.toString() ?? ''),
      comentario: (map['comentario'] ?? map['texto'] ?? map['comment'] ?? '')
          .toString(),
      tags: tagList,
    );
  }
}
