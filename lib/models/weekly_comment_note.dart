import 'package:flutter/foundation.dart';

@immutable
class WeeklyCommentNote {
  final String weekKey;
  final int commentIndex;
  final bool isFavorite;
  final String personalNote;

  const WeeklyCommentNote({
    required this.weekKey,
    required this.commentIndex,
    this.isFavorite = false,
    this.personalNote = '',
  });

  String get storageId => '${weekKey}_$commentIndex';

  WeeklyCommentNote copyWith({
    String? weekKey,
    int? commentIndex,
    bool? isFavorite,
    String? personalNote,
  }) {
    return WeeklyCommentNote(
      weekKey: weekKey ?? this.weekKey,
      commentIndex: commentIndex ?? this.commentIndex,
      isFavorite: isFavorite ?? this.isFavorite,
      personalNote: personalNote ?? this.personalNote,
    );
  }

  Map<String, dynamic> toJson() => {
        'weekKey': weekKey,
        'commentIndex': commentIndex,
        'isFavorite': isFavorite,
        'personalNote': personalNote,
      };

  factory WeeklyCommentNote.fromJson(Map<String, dynamic> json) {
    return WeeklyCommentNote(
      weekKey: (json['weekKey'] ?? '').toString(),
      commentIndex: json['commentIndex'] is int
          ? json['commentIndex'] as int
          : int.tryParse(json['commentIndex']?.toString() ?? '0') ?? 0,
      isFavorite: json['isFavorite'] == true,
      personalNote: (json['personalNote'] ?? '').toString(),
    );
  }
}
