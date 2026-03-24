import 'package:flutter/foundation.dart';

enum SpeechType {
  student10min,
  public30min,
}

enum SpeechGoalType {
  personalObjective,
  helpOthers,
}

enum SpeechStatus {
  planning,
  preparing,
  training,
  ready,
  executed,
  archived,
}

@immutable
class Speech {
  final String id;
  final int? backendId;
  final String title;
  final String theme;
  final DateTime? date;
  final String number;
  final String song;
  final SpeechType type;
  final SpeechGoalType goalType;
  final String centralObjective;
  final AudienceAnalysis? audienceAnalysis;
  final SpeechOutline? outline;
  final TrainingProgress? trainingProgress;
  final ExecutionRecord? executionRecord;
  final FeedbackRecord? feedbackRecord;
  final int? focusCharacteristicId;
  final SpeechStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String originalOutline;
  final String completeManuscript;
  final String initialComment;
  final String finalComment;
  final String sourceMaterials;
  final Map<String, dynamic>? guide;

  const Speech({
    required this.id,
    this.backendId,
    required this.title,
    this.theme = '',
    this.date,
    this.number = '',
    this.song = '',
    required this.type,
    required this.goalType,
    required this.centralObjective,
    this.audienceAnalysis,
    this.outline,
    this.trainingProgress,
    this.executionRecord,
    this.feedbackRecord,
    this.focusCharacteristicId,
    this.status = SpeechStatus.planning,
    required this.createdAt,
    required this.updatedAt,
    this.originalOutline = '',
    this.completeManuscript = '',
    this.initialComment = '',
    this.finalComment = '',
    this.sourceMaterials = '',
    this.guide,
  });

  int get durationMinutes => type == SpeechType.student10min ? 10 : 30;

  int get maxMainPoints => type == SpeechType.student10min ? 3 : 5;

  Speech copyWith({
    String? id,
    int? backendId,
    String? title,
    String? theme,
    DateTime? date,
    String? number,
    String? song,
    SpeechType? type,
    SpeechGoalType? goalType,
    String? centralObjective,
    AudienceAnalysis? audienceAnalysis,
    SpeechOutline? outline,
    TrainingProgress? trainingProgress,
    ExecutionRecord? executionRecord,
    FeedbackRecord? feedbackRecord,
    int? focusCharacteristicId,
    SpeechStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? originalOutline,
    String? completeManuscript,
    String? initialComment,
    String? finalComment,
    String? sourceMaterials,
    Map<String, dynamic>? guide,
  }) {
    return Speech(
      id: id ?? this.id,
      backendId: backendId ?? this.backendId,
      title: title ?? this.title,
      theme: theme ?? this.theme,
      date: date ?? this.date,
      number: number ?? this.number,
      song: song ?? this.song,
      type: type ?? this.type,
      goalType: goalType ?? this.goalType,
      centralObjective: centralObjective ?? this.centralObjective,
      audienceAnalysis: audienceAnalysis ?? this.audienceAnalysis,
      outline: outline ?? this.outline,
      trainingProgress: trainingProgress ?? this.trainingProgress,
      executionRecord: executionRecord ?? this.executionRecord,
      feedbackRecord: feedbackRecord ?? this.feedbackRecord,
      focusCharacteristicId: focusCharacteristicId ?? this.focusCharacteristicId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      originalOutline: originalOutline ?? this.originalOutline,
      completeManuscript: completeManuscript ?? this.completeManuscript,
      initialComment: initialComment ?? this.initialComment,
      finalComment: finalComment ?? this.finalComment,
      sourceMaterials: sourceMaterials ?? this.sourceMaterials,
      guide: guide ?? this.guide,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'backendId': backendId,
      'title': title,
      'theme': theme,
      'date': date?.toIso8601String(),
      'number': number,
      'song': song,
      'type': type.index,
      'goalType': goalType.index,
      'centralObjective': centralObjective,
      'audienceAnalysis': audienceAnalysis?.toJson(),
      'outline': outline?.toJson(),
      'trainingProgress': trainingProgress?.toJson(),
      'executionRecord': executionRecord?.toJson(),
      'feedbackRecord': feedbackRecord?.toJson(),
      'focusCharacteristicId': focusCharacteristicId,
      'status': status.index,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'originalOutline': originalOutline,
      'completeManuscript': completeManuscript,
      'initialComment': initialComment,
      'finalComment': finalComment,
      'sourceMaterials': sourceMaterials,
      'guide': guide,
    };
  }

  factory Speech.fromJson(Map<String, dynamic> json) {
    return Speech(
      id: json['id'],
      backendId: json['backendId'],
      title: json['title'],
      theme: json['theme'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      number: json['number'] ?? '',
      song: json['song'] ?? '',
      type: SpeechType.values[json['type'] ?? 0],
      goalType: SpeechGoalType.values[json['goalType'] ?? 0],
      centralObjective: json['centralObjective'] ?? '',
      audienceAnalysis: json['audienceAnalysis'] != null
          ? AudienceAnalysis.fromJson(json['audienceAnalysis'])
          : null,
      outline: json['outline'] != null
          ? SpeechOutline.fromJson(json['outline'])
          : null,
      trainingProgress: json['trainingProgress'] != null
          ? TrainingProgress.fromJson(json['trainingProgress'])
          : null,
      executionRecord: json['executionRecord'] != null
          ? ExecutionRecord.fromJson(json['executionRecord'])
          : null,
      feedbackRecord: json['feedbackRecord'] != null
          ? FeedbackRecord.fromJson(json['feedbackRecord'])
          : null,
      focusCharacteristicId: json['focusCharacteristicId'],
      status: SpeechStatus.values[json['status'] ?? 0],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      originalOutline: json['originalOutline'] ?? '',
      completeManuscript: json['completeManuscript'] ?? '',
      initialComment: json['initialComment'] ?? '',
      finalComment: json['finalComment'] ?? '',
      sourceMaterials: json['sourceMaterials'] ?? '',
      guide: json['guide'] as Map<String, dynamic>?,
    );
  }
}


@immutable
class AudienceAnalysis {
  final String knowledgeLevel;
  final String immediateNeeds;
  final String expectedAttitude;
  final String desiredTransformation;

  const AudienceAnalysis({
    this.knowledgeLevel = '',
    this.immediateNeeds = '',
    this.expectedAttitude = '',
    this.desiredTransformation = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'knowledgeLevel': knowledgeLevel,
      'immediateNeeds': immediateNeeds,
      'expectedAttitude': expectedAttitude,
      'desiredTransformation': desiredTransformation,
    };
  }

  factory AudienceAnalysis.fromJson(Map<String, dynamic> json) {
    return AudienceAnalysis(
      knowledgeLevel: json['knowledgeLevel'] ?? '',
      immediateNeeds: json['immediateNeeds'] ?? '',
      expectedAttitude: json['expectedAttitude'] ?? '',
      desiredTransformation: json['desiredTransformation'] ?? '',
    );
  }

  AudienceAnalysis copyWith({
    String? knowledgeLevel,
    String? immediateNeeds,
    String? expectedAttitude,
    String? desiredTransformation,
  }) {
    return AudienceAnalysis(
      knowledgeLevel: knowledgeLevel ?? this.knowledgeLevel,
      immediateNeeds: immediateNeeds ?? this.immediateNeeds,
      expectedAttitude: expectedAttitude ?? this.expectedAttitude,
      desiredTransformation: desiredTransformation ?? this.desiredTransformation,
    );
  }
}

@immutable
class SpeechOutline {
  final String introduction;
  final List<MainPoint> mainPoints;
  final String conclusion;
  final List<BiblicalText> biblicalTexts;

  const SpeechOutline({
    this.introduction = '',
    this.mainPoints = const [],
    this.conclusion = '',
    this.biblicalTexts = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'introduction': introduction,
      'mainPoints': mainPoints.map((p) => p.toJson()).toList(),
      'conclusion': conclusion,
      'biblicalTexts': biblicalTexts.map((t) => t.toJson()).toList(),
    };
  }

  factory SpeechOutline.fromJson(Map<String, dynamic> json) {
    return SpeechOutline(
      introduction: json['introduction'] ?? '',
      mainPoints: (json['mainPoints'] as List?)
              ?.map((p) => MainPoint.fromJson(p))
              .toList() ??
          [],
      conclusion: json['conclusion'] ?? '',
      biblicalTexts: (json['biblicalTexts'] as List?)
              ?.map((t) => BiblicalText.fromJson(t))
              .toList() ??
          [],
    );
  }

  SpeechOutline copyWith({
    String? introduction,
    List<MainPoint>? mainPoints,
    String? conclusion,
    List<BiblicalText>? biblicalTexts,
  }) {
    return SpeechOutline(
      introduction: introduction ?? this.introduction,
      mainPoints: mainPoints ?? this.mainPoints,
      conclusion: conclusion ?? this.conclusion,
      biblicalTexts: biblicalTexts ?? this.biblicalTexts,
    );
  }

  double get completionPercentage {
    int total = 3;
    int filled = 0;
    if (introduction.isNotEmpty) filled++;
    if (mainPoints.isNotEmpty) filled++;
    if (conclusion.isNotEmpty) filled++;
    return filled / total;
  }
}

@immutable
class MainPoint {
  final String id;
  final String title;
  final String content;
  final List<String> arguments;
  final List<String> illustrations;
  final String? illustration;
  final int? characteristicTag;

  const MainPoint({
    required this.id,
    required this.title,
    this.content = '',
    this.arguments = const [],
    this.illustrations = const [],
    this.illustration,
    this.characteristicTag,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'arguments': arguments,
      'illustrations': illustrations,
      'illustration': illustration,
      'characteristicTag': characteristicTag,
    };
  }

  factory MainPoint.fromJson(Map<String, dynamic> json) {
    return MainPoint(
      id: json['id'],
      title: json['title'],
      content: json['content'] ?? '',
      arguments: List<String>.from(json['arguments'] ?? []),
      illustrations: List<String>.from(json['illustrations'] ?? []),
      illustration: json['illustration'],
      characteristicTag: json['characteristicTag'],
    );
  }

  MainPoint copyWith({
    String? id,
    String? title,
    String? content,
    List<String>? arguments,
    List<String>? illustrations,
    String? illustration,
    int? characteristicTag,
  }) {
    return MainPoint(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      arguments: arguments ?? this.arguments,
      illustrations: illustrations ?? this.illustrations,
      illustration: illustration ?? this.illustration,
      characteristicTag: characteristicTag ?? this.characteristicTag,
    );
  }
}

@immutable
class BiblicalText {
  final String id;
  final String reference;
  final String read;
  final String explain;
  final String illustrate;
  final String apply;

  const BiblicalText({
    required this.id,
    required this.reference,
    this.read = '',
    this.explain = '',
    this.illustrate = '',
    this.apply = '',
  });

  bool get isLeiaComplete =>
      read.isNotEmpty &&
      explain.isNotEmpty &&
      illustrate.isNotEmpty &&
      apply.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference': reference,
      'read': read,
      'explain': explain,
      'illustrate': illustrate,
      'apply': apply,
    };
  }

  factory BiblicalText.fromJson(Map<String, dynamic> json) {
    return BiblicalText(
      id: json['id'],
      reference: json['reference'],
      read: json['read'] ?? '',
      explain: json['explain'] ?? '',
      illustrate: json['illustrate'] ?? '',
      apply: json['apply'] ?? '',
    );
  }

  BiblicalText copyWith({
    String? id,
    String? reference,
    String? read,
    String? explain,
    String? illustrate,
    String? apply,
  }) {
    return BiblicalText(
      id: id ?? this.id,
      reference: reference ?? this.reference,
      read: read ?? this.read,
      explain: explain ?? this.explain,
      illustrate: illustrate ?? this.illustrate,
      apply: apply ?? this.apply,
    );
  }
}

@immutable
class TrainingProgress {
  final List<TrainingSession> sessions;
  final Map<String, bool> stageChecklist;
  final List<int> focusCharacteristics;
  final double energyLevel;

  const TrainingProgress({
    this.sessions = const [],
    this.stageChecklist = const {},
    this.focusCharacteristics = const [],
    this.energyLevel = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'sessions': sessions.map((s) => s.toJson()).toList(),
      'stageChecklist': stageChecklist,
      'focusCharacteristics': focusCharacteristics,
      'energyLevel': energyLevel,
    };
  }

  factory TrainingProgress.fromJson(Map<String, dynamic> json) {
    return TrainingProgress(
      sessions: (json['sessions'] as List?)
              ?.map((s) => TrainingSession.fromJson(s))
              .toList() ??
          [],
      stageChecklist: Map<String, bool>.from(json['stageChecklist'] ?? {}),
      focusCharacteristics: List<int>.from(json['focusCharacteristics'] ?? []),
      energyLevel: (json['energyLevel'] ?? 0).toDouble(),
    );
  }
}

@immutable
class TrainingSession {
  final String id;
  final DateTime date;
  final int durationSeconds;
  final List<String> notes;
  final double rating;

  const TrainingSession({
    required this.id,
    required this.date,
    required this.durationSeconds,
    this.notes = const [],
    this.rating = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'durationSeconds': durationSeconds,
      'notes': notes,
      'rating': rating,
    };
  }

  factory TrainingSession.fromJson(Map<String, dynamic> json) {
    return TrainingSession(
      id: json['id'],
      date: DateTime.parse(json['date']),
      durationSeconds: json['durationSeconds'],
      notes: List<String>.from(json['notes'] ?? []),
      rating: (json['rating'] ?? 0).toDouble(),
    );
  }
}

@immutable
class ExecutionRecord {
  final DateTime? executionDate;
  final String venue;
  final int audienceSize;
  final int actualDurationSeconds;
  final Map<String, bool> professionalismChecklist;
  final List<String> notes;

  const ExecutionRecord({
    this.executionDate,
    this.venue = '',
    this.audienceSize = 0,
    this.actualDurationSeconds = 0,
    this.professionalismChecklist = const {},
    this.notes = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'executionDate': executionDate?.toIso8601String(),
      'venue': venue,
      'audienceSize': audienceSize,
      'actualDurationSeconds': actualDurationSeconds,
      'professionalismChecklist': professionalismChecklist,
      'notes': notes,
    };
  }

  factory ExecutionRecord.fromJson(Map<String, dynamic> json) {
    return ExecutionRecord(
      executionDate: json['executionDate'] != null
          ? DateTime.parse(json['executionDate'])
          : null,
      venue: json['venue'] ?? '',
      audienceSize: json['audienceSize'] ?? 0,
      actualDurationSeconds: json['actualDurationSeconds'] ?? 0,
      professionalismChecklist:
          Map<String, bool>.from(json['professionalismChecklist'] ?? {}),
      notes: List<String>.from(json['notes'] ?? []),
    );
  }
}

@immutable
class FeedbackRecord {
  final Map<String, int> competencyRatings;
  final List<String> strengths;
  final List<String> improvements;
  final String lessonsLearned;
  final bool objectiveAchieved;
  final int audienceEngagement;

  const FeedbackRecord({
    this.competencyRatings = const {},
    this.strengths = const [],
    this.improvements = const [],
    this.lessonsLearned = '',
    this.objectiveAchieved = false,
    this.audienceEngagement = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'competencyRatings': competencyRatings,
      'strengths': strengths,
      'improvements': improvements,
      'lessonsLearned': lessonsLearned,
      'objectiveAchieved': objectiveAchieved,
      'audienceEngagement': audienceEngagement,
    };
  }

  factory FeedbackRecord.fromJson(Map<String, dynamic> json) {
    return FeedbackRecord(
      competencyRatings: Map<String, int>.from(json['competencyRatings'] ?? {}),
      strengths: List<String>.from(json['strengths'] ?? []),
      improvements: List<String>.from(json['improvements'] ?? []),
      lessonsLearned: json['lessonsLearned'] ?? '',
      objectiveAchieved: json['objectiveAchieved'] ?? false,
      audienceEngagement: json['audienceEngagement'] ?? 0,
    );
  }
}
