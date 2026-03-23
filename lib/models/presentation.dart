import 'package:flutter/foundation.dart';

enum WorkflowType {
  objetivoProprio,
  objetivoCliente,
}

enum PresentationStatus {
  draft,
  planning,
  preparing,
  training,
  ready,
  executed,
  archived,
}

@immutable
class Presentation {
  final String id;
  final String title;
  final WorkflowType workflowType;
  final String kpiGoal;
  final PresentationStatus status;
  final MessageArchitecture? messageArchitecture;
  final TrainingData? trainingData;
  final ExecutionData? executionData;
  final PerformanceMetrics? performanceMetrics;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Presentation({
    required this.id,
    required this.title,
    required this.workflowType,
    required this.kpiGoal,
    this.status = PresentationStatus.draft,
    this.messageArchitecture,
    this.trainingData,
    this.executionData,
    this.performanceMetrics,
    required this.createdAt,
    required this.updatedAt,
  });

  Presentation copyWith({
    String? id,
    String? title,
    WorkflowType? workflowType,
    String? kpiGoal,
    PresentationStatus? status,
    MessageArchitecture? messageArchitecture,
    TrainingData? trainingData,
    ExecutionData? executionData,
    PerformanceMetrics? performanceMetrics,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Presentation(
      id: id ?? this.id,
      title: title ?? this.title,
      workflowType: workflowType ?? this.workflowType,
      kpiGoal: kpiGoal ?? this.kpiGoal,
      status: status ?? this.status,
      messageArchitecture: messageArchitecture ?? this.messageArchitecture,
      trainingData: trainingData ?? this.trainingData,
      executionData: executionData ?? this.executionData,
      performanceMetrics: performanceMetrics ?? this.performanceMetrics,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'workflowType': workflowType.index,
      'kpiGoal': kpiGoal,
      'status': status.index,
      'messageArchitecture': messageArchitecture?.toJson(),
      'trainingData': trainingData?.toJson(),
      'executionData': executionData?.toJson(),
      'performanceMetrics': performanceMetrics?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Presentation.fromJson(Map<String, dynamic> json) {
    return Presentation(
      id: json['id'],
      title: json['title'],
      workflowType: WorkflowType.values[json['workflowType']],
      kpiGoal: json['kpiGoal'],
      status: PresentationStatus.values[json['status']],
      messageArchitecture: json['messageArchitecture'] != null
          ? MessageArchitecture.fromJson(json['messageArchitecture'])
          : null,
      trainingData: json['trainingData'] != null
          ? TrainingData.fromJson(json['trainingData'])
          : null,
      executionData: json['executionData'] != null
          ? ExecutionData.fromJson(json['executionData'])
          : null,
      performanceMetrics: json['performanceMetrics'] != null
          ? PerformanceMetrics.fromJson(json['performanceMetrics'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

@immutable
class MessageArchitecture {
  final String centralIdea;
  final String problem;
  final String audienceIdentification;
  final String problemCause;
  final String solutionAndMethod;
  final String motivationSelfConfidence;
  final String motivationOvercoming;
  final String motivationAction;
  final String requestedAction;
  final String celebration;

  const MessageArchitecture({
    this.centralIdea = '',
    this.problem = '',
    this.audienceIdentification = '',
    this.problemCause = '',
    this.solutionAndMethod = '',
    this.motivationSelfConfidence = '',
    this.motivationOvercoming = '',
    this.motivationAction = '',
    this.requestedAction = '',
    this.celebration = '',
  });

  MessageArchitecture copyWith({
    String? centralIdea,
    String? problem,
    String? audienceIdentification,
    String? problemCause,
    String? solutionAndMethod,
    String? motivationSelfConfidence,
    String? motivationOvercoming,
    String? motivationAction,
    String? requestedAction,
    String? celebration,
  }) {
    return MessageArchitecture(
      centralIdea: centralIdea ?? this.centralIdea,
      problem: problem ?? this.problem,
      audienceIdentification: audienceIdentification ?? this.audienceIdentification,
      problemCause: problemCause ?? this.problemCause,
      solutionAndMethod: solutionAndMethod ?? this.solutionAndMethod,
      motivationSelfConfidence: motivationSelfConfidence ?? this.motivationSelfConfidence,
      motivationOvercoming: motivationOvercoming ?? this.motivationOvercoming,
      motivationAction: motivationAction ?? this.motivationAction,
      requestedAction: requestedAction ?? this.requestedAction,
      celebration: celebration ?? this.celebration,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'centralIdea': centralIdea,
      'problem': problem,
      'audienceIdentification': audienceIdentification,
      'problemCause': problemCause,
      'solutionAndMethod': solutionAndMethod,
      'motivationSelfConfidence': motivationSelfConfidence,
      'motivationOvercoming': motivationOvercoming,
      'motivationAction': motivationAction,
      'requestedAction': requestedAction,
      'celebration': celebration,
    };
  }

  factory MessageArchitecture.fromJson(Map<String, dynamic> json) {
    return MessageArchitecture(
      centralIdea: json['centralIdea'] ?? '',
      problem: json['problem'] ?? '',
      audienceIdentification: json['audienceIdentification'] ?? '',
      problemCause: json['problemCause'] ?? '',
      solutionAndMethod: json['solutionAndMethod'] ?? '',
      motivationSelfConfidence: json['motivationSelfConfidence'] ?? '',
      motivationOvercoming: json['motivationOvercoming'] ?? '',
      motivationAction: json['motivationAction'] ?? '',
      requestedAction: json['requestedAction'] ?? '',
      celebration: json['celebration'] ?? '',
    );
  }

  double get completionPercentage {
    int filledFields = 0;
    if (centralIdea.isNotEmpty) filledFields++;
    if (problem.isNotEmpty) filledFields++;
    if (audienceIdentification.isNotEmpty) filledFields++;
    if (problemCause.isNotEmpty) filledFields++;
    if (solutionAndMethod.isNotEmpty) filledFields++;
    if (motivationSelfConfidence.isNotEmpty) filledFields++;
    if (motivationOvercoming.isNotEmpty) filledFields++;
    if (motivationAction.isNotEmpty) filledFields++;
    if (requestedAction.isNotEmpty) filledFields++;
    if (celebration.isNotEmpty) filledFields++;
    return filledFields / 10;
  }
}

@immutable
class TrainingData {
  final List<TrainingSession> sessions;
  final Map<String, bool> stageChecklist;
  final List<String> notes;

  const TrainingData({
    this.sessions = const [],
    this.stageChecklist = const {},
    this.notes = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'sessions': sessions.map((s) => s.toJson()).toList(),
      'stageChecklist': stageChecklist,
      'notes': notes,
    };
  }

  factory TrainingData.fromJson(Map<String, dynamic> json) {
    return TrainingData(
      sessions: (json['sessions'] as List?)
              ?.map((s) => TrainingSession.fromJson(s))
              .toList() ??
          [],
      stageChecklist: Map<String, bool>.from(json['stageChecklist'] ?? {}),
      notes: List<String>.from(json['notes'] ?? []),
    );
  }
}

@immutable
class TrainingSession {
  final String id;
  final DateTime date;
  final int durationSeconds;
  final String? videoPath;
  final List<TimestampNote> timestampNotes;
  final double energyRating;
  final String feedback;

  const TrainingSession({
    required this.id,
    required this.date,
    required this.durationSeconds,
    this.videoPath,
    this.timestampNotes = const [],
    this.energyRating = 0,
    this.feedback = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'durationSeconds': durationSeconds,
      'videoPath': videoPath,
      'timestampNotes': timestampNotes.map((n) => n.toJson()).toList(),
      'energyRating': energyRating,
      'feedback': feedback,
    };
  }

  factory TrainingSession.fromJson(Map<String, dynamic> json) {
    return TrainingSession(
      id: json['id'],
      date: DateTime.parse(json['date']),
      durationSeconds: json['durationSeconds'],
      videoPath: json['videoPath'],
      timestampNotes: (json['timestampNotes'] as List?)
              ?.map((n) => TimestampNote.fromJson(n))
              .toList() ??
          [],
      energyRating: json['energyRating']?.toDouble() ?? 0,
      feedback: json['feedback'] ?? '',
    );
  }
}

@immutable
class TimestampNote {
  final int seconds;
  final String note;
  final String type;

  const TimestampNote({
    required this.seconds,
    required this.note,
    this.type = 'general',
  });

  Map<String, dynamic> toJson() {
    return {
      'seconds': seconds,
      'note': note,
      'type': type,
    };
  }

  factory TimestampNote.fromJson(Map<String, dynamic> json) {
    return TimestampNote(
      seconds: json['seconds'],
      note: json['note'],
      type: json['type'] ?? 'general',
    );
  }
}

@immutable
class ExecutionData {
  final DateTime? executionDate;
  final String venue;
  final int audienceSize;
  final Map<String, bool> professionalismChecklist;
  final List<String> executionNotes;

  const ExecutionData({
    this.executionDate,
    this.venue = '',
    this.audienceSize = 0,
    this.professionalismChecklist = const {},
    this.executionNotes = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'executionDate': executionDate?.toIso8601String(),
      'venue': venue,
      'audienceSize': audienceSize,
      'professionalismChecklist': professionalismChecklist,
      'executionNotes': executionNotes,
    };
  }

  factory ExecutionData.fromJson(Map<String, dynamic> json) {
    return ExecutionData(
      executionDate: json['executionDate'] != null
          ? DateTime.parse(json['executionDate'])
          : null,
      venue: json['venue'] ?? '',
      audienceSize: json['audienceSize'] ?? 0,
      professionalismChecklist:
          Map<String, bool>.from(json['professionalismChecklist'] ?? {}),
      executionNotes: List<String>.from(json['executionNotes'] ?? []),
    );
  }
}

@immutable
class PerformanceMetrics {
  final int businessClosed;
  final int contractsSigned;
  final int leadsGenerated;
  final double conversionRate;
  final List<String> feedback;
  final List<String> lessonsLearned;
  final DateTime? followUpDate;

  const PerformanceMetrics({
    this.businessClosed = 0,
    this.contractsSigned = 0,
    this.leadsGenerated = 0,
    this.conversionRate = 0,
    this.feedback = const [],
    this.lessonsLearned = const [],
    this.followUpDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'businessClosed': businessClosed,
      'contractsSigned': contractsSigned,
      'leadsGenerated': leadsGenerated,
      'conversionRate': conversionRate,
      'feedback': feedback,
      'lessonsLearned': lessonsLearned,
      'followUpDate': followUpDate?.toIso8601String(),
    };
  }

  factory PerformanceMetrics.fromJson(Map<String, dynamic> json) {
    return PerformanceMetrics(
      businessClosed: json['businessClosed'] ?? 0,
      contractsSigned: json['contractsSigned'] ?? 0,
      leadsGenerated: json['leadsGenerated'] ?? 0,
      conversionRate: json['conversionRate']?.toDouble() ?? 0,
      feedback: List<String>.from(json['feedback'] ?? []),
      lessonsLearned: List<String>.from(json['lessonsLearned'] ?? []),
      followUpDate: json['followUpDate'] != null
          ? DateTime.parse(json['followUpDate'])
          : null,
    );
  }
}
