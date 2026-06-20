import 'package:cloud_firestore/cloud_firestore.dart';

// Helper for parsing dates
DateTime _parseDate(dynamic val) {
  if (val is Timestamp) return val.toDate();
  if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
  return DateTime.now();
}

// --- Resume Model & Report ---
class ResumeReport {
  final String id;
  final String userId;
  final String resumeId;
  final int score;
  final List<String> missingSections;
  final List<String> improvementSuggestions;
  final String atsCompatibilityReport;
  final Map<String, bool> contactDetailsFound;
  final DateTime analyzedAt;

  ResumeReport({
    required this.id,
    required this.userId,
    required this.resumeId,
    required this.score,
    required this.missingSections,
    required this.improvementSuggestions,
    required this.atsCompatibilityReport,
    required this.contactDetailsFound,
    required this.analyzedAt,
  });

  factory ResumeReport.fromJson(Map<String, dynamic> json) {
    return ResumeReport(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      resumeId: json['resumeId'] ?? '',
      score: json['score'] ?? 0,
      missingSections: List<String>.from(json['missingSections'] ?? []),
      improvementSuggestions: List<String>.from(json['improvementSuggestions'] ?? []),
      atsCompatibilityReport: json['atsCompatibilityReport'] ?? '',
      contactDetailsFound: Map<String, bool>.from(json['contactDetailsFound'] ?? {}),
      analyzedAt: _parseDate(json['analyzedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "userId": userId,
        "resumeId": resumeId,
        "score": score,
        "missingSections": missingSections,
        "improvementSuggestions": improvementSuggestions,
        "atsCompatibilityReport": atsCompatibilityReport,
        "contactDetailsFound": contactDetailsFound,
        "analyzedAt": analyzedAt.toIso8601String(),
      };
}

// --- Aptitude Questions & Results ---
class AptitudeQuestion {
  final String id;
  final String category; // quantitative | logical | verbal
  final String topic;
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;
  final String difficulty; // easy | medium | hard
  final String explanation;

  AptitudeQuestion({
    required this.id,
    required this.category,
    required this.topic,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    required this.difficulty,
    required this.explanation,
  });

  factory AptitudeQuestion.fromJson(Map<String, dynamic> json) {
    return AptitudeQuestion(
      id: json['id'] ?? '',
      category: json['category'] ?? '',
      topic: json['topic'] ?? '',
      questionText: json['questionText'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctOptionIndex: json['correctOptionIndex'] ?? 0,
      difficulty: json['difficulty'] ?? 'easy',
      explanation: json['explanation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "category": category,
        "topic": topic,
        "questionText": questionText,
        "options": options,
        "correctOptionIndex": correctOptionIndex,
        "difficulty": difficulty,
        "explanation": explanation,
      };
}

class AptitudeResult {
  final String id;
  final String userId;
  final String category;
  final String difficulty;
  final int score;
  final int totalQuestions;
  final double accuracy;
  final int timeTakenSeconds;
  final DateTime attemptedAt;

  AptitudeResult({
    required this.id,
    required this.userId,
    required this.category,
    required this.difficulty,
    required this.score,
    required this.totalQuestions,
    required this.accuracy,
    required this.timeTakenSeconds,
    required this.attemptedAt,
  });

  factory AptitudeResult.fromJson(Map<String, dynamic> json) {
    return AptitudeResult(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      category: json['category'] ?? '',
      difficulty: json['difficulty'] ?? 'medium',
      score: json['score'] ?? 0,
      totalQuestions: json['totalQuestions'] ?? 0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
      timeTakenSeconds: json['timeTakenSeconds'] ?? 0,
      attemptedAt: _parseDate(json['attemptedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "userId": userId,
        "category": category,
        "difficulty": difficulty,
        "score": score,
        "totalQuestions": totalQuestions,
        "accuracy": accuracy,
        "timeTakenSeconds": timeTakenSeconds,
        "attemptedAt": attemptedAt.toIso8601String(),
      };
}

// --- Mock Interviews ---
class InterviewQuestion {
  final String id;
  final String type; // hr | technical | behavioral
  final String role;
  final String questionText;
  final List<String> idealKeywords;
  final String suggestedAnswer;

  InterviewQuestion({
    required this.id,
    required this.type,
    required this.role,
    required this.questionText,
    required this.idealKeywords,
    required this.suggestedAnswer,
  });

  factory InterviewQuestion.fromJson(Map<String, dynamic> json) {
    return InterviewQuestion(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      role: json['role'] ?? '',
      questionText: json['questionText'] ?? '',
      idealKeywords: List<String>.from(json['idealKeywords'] ?? []),
      suggestedAnswer: json['suggestedAnswer'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "role": role,
        "questionText": questionText,
        "idealKeywords": idealKeywords,
        "suggestedAnswer": suggestedAnswer,
      };
}

class AnswerEvaluation {
  final String questionId;
  final String questionText;
  final String userAnswer;
  final int score;
  final String feedback;
  final String suggestedAnswer;

  AnswerEvaluation({
    required this.questionId,
    required this.questionText,
    required this.userAnswer,
    required this.score,
    required this.feedback,
    required this.suggestedAnswer,
  });

  factory AnswerEvaluation.fromJson(Map<String, dynamic> json) {
    return AnswerEvaluation(
      questionId: json['questionId'] ?? '',
      questionText: json['questionText'] ?? '',
      userAnswer: json['userAnswer'] ?? '',
      score: json['score'] ?? 0,
      feedback: json['feedback'] ?? '',
      suggestedAnswer: json['suggestedAnswer'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        "questionId": questionId,
        "questionText": questionText,
        "userAnswer": userAnswer,
        "score": score,
        "feedback": feedback,
        "suggestedAnswer": suggestedAnswer,
      };
}

class InterviewResult {
  final String id;
  final String userId;
  final String interviewType;
  final int score;
  final String feedback;
  final List<AnswerEvaluation> answers;
  final DateTime attemptedAt;

  InterviewResult({
    required this.id,
    required this.userId,
    required this.interviewType,
    required this.score,
    required this.feedback,
    required this.answers,
    required this.attemptedAt,
  });

  factory InterviewResult.fromJson(Map<String, dynamic> json) {
    var rawList = json['answers'] as List? ?? [];
    List<AnswerEvaluation> parsedAnswers =
        rawList.map((e) => AnswerEvaluation.fromJson(e as Map<String, dynamic>)).toList();

    return InterviewResult(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      interviewType: json['interviewType'] ?? '',
      score: json['score'] ?? 0,
      feedback: json['feedback'] ?? '',
      answers: parsedAnswers,
      attemptedAt: _parseDate(json['attemptedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "userId": userId,
        "interviewType": interviewType,
        "score": score,
        "feedback": feedback,
        "answers": answers.map((e) => e.toJson()).toList(),
        "attemptedAt": attemptedAt.toIso8601String(),
      };
}

// --- Roadmap & Skill Gap ---
class RoadmapTopic {
  final String topicName;
  bool isCompleted;

  RoadmapTopic({
    required this.topicName,
    required this.isCompleted,
  });

  factory RoadmapTopic.fromJson(Map<String, dynamic> json) {
    return RoadmapTopic(
      topicName: json['topicName'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        "topicName": topicName,
        "isCompleted": isCompleted,
      };
}

class RoadmapWeek {
  final int weekNumber;
  final List<RoadmapTopic> topics;

  RoadmapWeek({
    required this.weekNumber,
    required this.topics,
  });

  factory RoadmapWeek.fromJson(Map<String, dynamic> json) {
    var rawList = json['topics'] as List? ?? [];
    return RoadmapWeek(
      weekNumber: json['weekNumber'] ?? 1,
      topics: rawList.map((e) => RoadmapTopic.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        "weekNumber": weekNumber,
        "topics": topics.map((e) => e.toJson()).toList(),
      };
}

class Roadmap {
  final String id;
  final String userId;
  final String targetRole;
  final List<RoadmapWeek> weeks;
  final double completionPercentage;
  final DateTime updatedAt;

  Roadmap({
    required this.id,
    required this.userId,
    required this.targetRole,
    required this.weeks,
    required this.completionPercentage,
    required this.updatedAt,
  });

  factory Roadmap.fromJson(Map<String, dynamic> json) {
    var rawWeeks = json['weeks'] as List? ?? [];
    return Roadmap(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      targetRole: json['targetRole'] ?? 'Software Developer',
      weeks: rawWeeks.map((e) => RoadmapWeek.fromJson(e as Map<String, dynamic>)).toList(),
      completionPercentage: (json['completionPercentage'] as num?)?.toDouble() ?? 0.0,
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "userId": userId,
        "targetRole": targetRole,
        "weeks": weeks.map((e) => e.toJson()).toList(),
        "completionPercentage": completionPercentage,
        "updatedAt": updatedAt.toIso8601String(),
      };
}

class SkillGapAnalysis {
  final String id;
  final String userId;
  final String targetRole;
  final List<String> missingSkills;
  final List<String> recommendations;
  final int estimatedLearningTimeHours;
  final DateTime analyzedAt;

  SkillGapAnalysis({
    required this.id,
    required this.userId,
    required this.targetRole,
    required this.missingSkills,
    required this.recommendations,
    required this.estimatedLearningTimeHours,
    required this.analyzedAt,
  });

  factory SkillGapAnalysis.fromJson(Map<String, dynamic> json) {
    return SkillGapAnalysis(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      targetRole: json['targetRole'] ?? '',
      missingSkills: List<String>.from(json['missingSkills'] ?? []),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      estimatedLearningTimeHours: json['estimatedLearningTimeHours'] ?? 0,
      analyzedAt: _parseDate(json['analyzedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "userId": userId,
        "targetRole": targetRole,
        "missingSkills": missingSkills,
        "recommendations": recommendations,
        "estimatedLearningTimeHours": estimatedLearningTimeHours,
        "analyzedAt": analyzedAt.toIso8601String(),
      };
}

// --- Leaderboard ---
class LeaderboardEntry {
  final String uid;
  final String name;
  final String collegeName;
  final double readinessScore;
  final double aptitudeScore;
  final DateTime updatedAt;

  LeaderboardEntry({
    required this.uid,
    required this.name,
    required this.collegeName,
    required this.readinessScore,
    required this.aptitudeScore,
    required this.updatedAt,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      collegeName: json['collegeName'] ?? '',
      readinessScore: (json['readinessScore'] as num?)?.toDouble() ?? 0.0,
      aptitudeScore: (json['aptitudeScore'] as num?)?.toDouble() ?? 0.0,
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "name": name,
        "collegeName": collegeName,
        "readinessScore": readinessScore,
        "aptitudeScore": aptitudeScore,
        "updatedAt": updatedAt.toIso8601String(),
      };
}

// --- Notifications ---
class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final bool read;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    this.read = false,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      read: json['read'] ?? false,
      createdAt: _parseDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "userId": userId,
        "title": title,
        "body": body,
        "read": read,
        "createdAt": createdAt.toIso8601String(),
      };
}
