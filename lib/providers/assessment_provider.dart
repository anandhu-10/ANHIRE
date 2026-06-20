import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../core/services/cloudinary_service.dart';
import '../core/services/interview_service.dart';
import '../core/services/resume_analyzer_service.dart';
import '../models/assessment_models.dart';
import '../repositories/assessment_repository.dart';
import 'auth_provider.dart';

final assessmentRepositoryProvider = Provider<AssessmentRepository>((ref) {
  return AssessmentRepositoryImpl();
});

// --- Aptitude Test Notifier ---
class AptitudeTestState {
  final List<AptitudeQuestion> questions;
  final int currentQuestionIndex;
  final Map<int, int> selectedOptions; // questionIndex -> optionIndex
  final int timeRemainingSeconds;
  final bool isCompleted;
  final AptitudeResult? result;
  final bool isLoading;

  AptitudeTestState({
    this.questions = const [],
    this.currentQuestionIndex = 0,
    this.selectedOptions = const {},
    this.timeRemainingSeconds = 600, // 10 minutes default
    this.isCompleted = false,
    this.result,
    this.isLoading = false,
  });

  AptitudeTestState copyWith({
    List<AptitudeQuestion>? questions,
    int? currentQuestionIndex,
    Map<int, int>? selectedOptions,
    int? timeRemainingSeconds,
    bool? isCompleted,
    AptitudeResult? result,
    bool? isLoading,
  }) {
    return AptitudeTestState(
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      selectedOptions: selectedOptions ?? this.selectedOptions,
      timeRemainingSeconds: timeRemainingSeconds ?? this.timeRemainingSeconds,
      isCompleted: isCompleted ?? this.isCompleted,
      result: result ?? this.result,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AptitudeTestNotifier extends StateNotifier<AptitudeTestState> {
  final AssessmentRepository _repository;
  Timer? _timer;
  final String _userId;
  final String _category;
  final String _difficulty;

  AptitudeTestNotifier(this._repository, this._userId, this._category, this._difficulty)
      : super(AptitudeTestState()) {
    _loadQuestions();
  }

  void _loadQuestions() async {
    state = state.copyWith(isLoading: true);
    final list = await _repository.getAptitudeQuestions(_category, _difficulty);
    state = AptitudeTestState(
      questions: list,
      timeRemainingSeconds: list.length * 60, // 1 minute per question
      isLoading: false,
    );
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeRemainingSeconds <= 1) {
        timer.cancel();
        submitTest();
      } else {
        state = state.copyWith(timeRemainingSeconds: state.timeRemainingSeconds - 1);
      }
    });
  }

  void selectOption(int questionIndex, int optionIndex) {
    final updated = Map<int, int>.from(state.selectedOptions);
    updated[questionIndex] = optionIndex;
    state = state.copyWith(selectedOptions: updated);
  }

  void nextQuestion() {
    if (state.currentQuestionIndex < state.questions.length - 1) {
      state = state.copyWith(currentQuestionIndex: state.currentQuestionIndex + 1);
    }
  }

  void previousQuestion() {
    if (state.currentQuestionIndex > 0) {
      state = state.copyWith(currentQuestionIndex: state.currentQuestionIndex - 1);
    }
  }

  Future<void> submitTest() async {
    _timer?.cancel();
    if (state.isCompleted) return;

    state = state.copyWith(isLoading: true);
    
    // Evaluate answers
    int score = 0;
    for (int i = 0; i < state.questions.length; i++) {
      final selected = state.selectedOptions[i];
      if (selected != null && selected == state.questions[i].correctOptionIndex) {
        score++;
      }
    }

    final int totalQ = state.questions.length;
    final double accuracy = totalQ > 0 ? (score / totalQ) * 100.0 : 0.0;
    final int timeTaken = (totalQ * 60) - state.timeRemainingSeconds;

    final result = AptitudeResult(
      id: const Uuid().v4(),
      userId: _userId,
      category: _category,
      difficulty: _difficulty,
      score: (accuracy).round(), // Convert to 0-100 scale
      totalQuestions: totalQ,
      accuracy: accuracy,
      timeTakenSeconds: timeTaken,
      attemptedAt: DateTime.now(),
    );

    await _repository.saveAptitudeResult(result);
    state = state.copyWith(
      isCompleted: true,
      result: result,
      isLoading: false,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// Params class to pass data to family provider
class AptitudeTestParams {
  final String category;
  final String difficulty;
  AptitudeTestParams(this.category, this.difficulty);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AptitudeTestParams &&
          runtimeType == other.runtimeType &&
          category == other.category &&
          difficulty == other.difficulty;

  @override
  int get hashCode => category.hashCode ^ difficulty.hashCode;
}

final aptitudeTestProvider = StateNotifierProvider.family<AptitudeTestNotifier, AptitudeTestState, AptitudeTestParams>((ref, params) {
  final repo = ref.watch(assessmentRepositoryProvider);
  final auth = ref.watch(authProvider);
  return AptitudeTestNotifier(repo, auth.uid ?? "temp_user", params.category, params.difficulty);
});

// --- Mock Interview Notifier ---
class InterviewState {
  final List<InterviewQuestion> questions;
  final int currentQuestionIndex;
  final Map<String, String> answers; // questionId -> userAnswerText
  final bool isCompleted;
  final InterviewResult? result;
  final bool isLoading;

  InterviewState({
    this.questions = const [],
    this.currentQuestionIndex = 0,
    this.answers = const {},
    this.isCompleted = false,
    this.result,
    this.isLoading = false,
  });

  InterviewState copyWith({
    List<InterviewQuestion>? questions,
    int? currentQuestionIndex,
    Map<String, String>? answers,
    bool? isCompleted,
    InterviewResult? result,
    bool? isLoading,
  }) {
    return InterviewState(
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      answers: answers ?? this.answers,
      isCompleted: isCompleted ?? this.isCompleted,
      result: result ?? this.result,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class InterviewNotifier extends StateNotifier<InterviewState> {
  final AssessmentRepository _repository;
  final InterviewService _evaluationService = InterviewService();
  final String _userId;
  final String _type;

  InterviewNotifier(this._repository, this._userId, this._type) : super(InterviewState()) {
    _loadQuestions();
  }

  void _loadQuestions() async {
    state = state.copyWith(isLoading: true);
    final list = await _repository.getInterviewQuestions(_type);
    state = InterviewState(questions: list, isLoading: false);
  }

  void saveAnswer(String questionId, String text) {
    final updated = Map<String, String>.from(state.answers);
    updated[questionId] = text;
    state = state.copyWith(answers: updated);
  }

  void nextQuestion() {
    if (state.currentQuestionIndex < state.questions.length - 1) {
      state = state.copyWith(currentQuestionIndex: state.currentQuestionIndex + 1);
    }
  }

  void previousQuestion() {
    if (state.currentQuestionIndex > 0) {
      state = state.copyWith(currentQuestionIndex: state.currentQuestionIndex - 1);
    }
  }

  Future<void> submitInterview() async {
    if (state.isCompleted) return;
    state = state.copyWith(isLoading: true);

    final List<AnswerEvaluation> evaluations = [];
    int totalScoreAccumulator = 0;

    for (var q in state.questions) {
      final ans = state.answers[q.id] ?? "";
      final evaluation = _evaluationService.evaluateAnswer(
        questionText: q.questionText,
        userAnswer: ans,
        idealKeywords: q.idealKeywords,
        suggestedAnswer: q.suggestedAnswer,
      );
      evaluations.add(AnswerEvaluation(
        questionId: q.id,
        questionText: q.questionText,
        userAnswer: ans,
        score: evaluation.score,
        feedback: evaluation.feedback,
        suggestedAnswer: evaluation.suggestedAnswer,
      ));
      totalScoreAccumulator += evaluation.score;
    }

    final int avgScore = state.questions.isNotEmpty
        ? (totalScoreAccumulator / state.questions.length).round()
        : 0;

    String finalFeedback = "";
    if (avgScore >= 80) {
      finalFeedback = "Strong Candidate! Excellent vocabulary, conceptual grasp, and detailed explanations.";
    } else if (avgScore >= 55) {
      finalFeedback = "Competent Candidate. Good primary grasp, but needs to expand on key definitions and practical application.";
    } else {
      finalFeedback = "Needs Improvement. Prepare keywords, core architecture elements, and elaborate answers with examples.";
    }

    final result = InterviewResult(
      id: const Uuid().v4(),
      userId: _userId,
      interviewType: _type,
      score: avgScore,
      feedback: finalFeedback,
      answers: evaluations,
      attemptedAt: DateTime.now(),
    );

    await _repository.saveInterviewResult(result);
    state = state.copyWith(
      isCompleted: true,
      result: result,
      isLoading: false,
    );
  }
}

final interviewProvider = StateNotifierProvider.family<InterviewNotifier, InterviewState, String>((ref, type) {
  final repo = ref.watch(assessmentRepositoryProvider);
  final auth = ref.watch(authProvider);
  return InterviewNotifier(repo, auth.uid ?? "temp_user", type);
});

// --- Resume Analyzer Notifier ---
class ResumeState {
  final ResumeReport? latestReport;
  final bool isLoading;
  final String? errorMessage;

  ResumeState({
    this.latestReport,
    this.isLoading = false,
    this.errorMessage,
  });
}

class ResumeNotifier extends StateNotifier<ResumeState> {
  final AssessmentRepository _repository;
  final ResumeAnalyzerService _analyzerService = ResumeAnalyzerService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final String _userId;

  ResumeNotifier(this._repository, this._userId) : super(ResumeState()) {
    _loadLatestReport();
  }

  void _loadLatestReport() async {
    state = ResumeState(isLoading: true);
    final list = await _repository.getResumeReports(_userId);
    if (list.isNotEmpty) {
      state = ResumeState(latestReport: list.first);
    } else {
      state = ResumeState();
    }
  }

  Future<void> analyzeResumeText({
    required String text,
    required String targetRole,
    File? pdfFile,
  }) async {
    state = ResumeState(isLoading: true);
    try {
      String fileUrl = "";
      if (pdfFile != null) {
        // Upload file to Cloudinary for storage
        fileUrl = await _cloudinaryService.uploadFile(
          file: pdfFile,
          folder: "resumes",
          isImage: false,
        );
      }

      // Run local ATS rules
      final result = _analyzerService.analyzeResume(text, targetRole);
      
      final report = ResumeReport(
        id: const Uuid().v4(),
        userId: _userId,
        resumeId: fileUrl.isNotEmpty ? fileUrl : "text_only",
        score: result.score,
        missingSections: result.missingSections,
        improvementSuggestions: result.improvementSuggestions,
        atsCompatibilityReport: result.atsCompatibilityReport,
        contactDetailsFound: result.contactDetailsFound,
        analyzedAt: DateTime.now(),
      );

      await _repository.saveResumeReport(report);
      state = ResumeState(latestReport: report);
    } catch (e) {
      state = ResumeState(errorMessage: e.toString());
    }
  }
}

final resumeReportProvider = StateNotifierProvider<ResumeNotifier, ResumeState>((ref) {
  final repo = ref.watch(assessmentRepositoryProvider);
  final auth = ref.watch(authProvider);
  return ResumeNotifier(repo, auth.uid ?? "temp_user");
});

// --- Roadmap Notifier ---
class RoadmapState {
  final Roadmap? roadmap;
  final bool isLoading;

  RoadmapState({this.roadmap, this.isLoading = false});
}

class RoadmapNotifier extends StateNotifier<RoadmapState> {
  final AssessmentRepository _repository;
  final String _userId;

  RoadmapNotifier(this._repository, this._userId) : super(RoadmapState());

  Future<void> loadRoadmap(String targetRole) async {
    state = RoadmapState(isLoading: true);
    final roadmap = await _repository.getOrCreateRoadmap(_userId, targetRole);
    state = RoadmapState(roadmap: roadmap);
  }

  Future<void> toggleTopic(int weekNumber, String topicName) async {
    if (state.roadmap == null) return;
    
    final updatedWeeks = state.roadmap!.weeks.map((w) {
      if (w.weekNumber == weekNumber) {
        final updatedTopics = w.topics.map((t) {
          if (t.topicName == topicName) {
            t.isCompleted = !t.isCompleted;
          }
          return t;
        }).toList();
        return RoadmapWeek(weekNumber: w.weekNumber, topics: updatedTopics);
      }
      return w;
    }).toList();

    // Re-calculate completion percentage
    int totalTopics = 0;
    int completedTopics = 0;
    for (var w in updatedWeeks) {
      for (var t in w.topics) {
        totalTopics++;
        if (t.isCompleted) completedTopics++;
      }
    }

    final double completion = totalTopics > 0 ? completedTopics / totalTopics : 0.0;

    final updatedRoadmap = Roadmap(
      id: state.roadmap!.id,
      userId: state.roadmap!.userId,
      targetRole: state.roadmap!.targetRole,
      weeks: updatedWeeks,
      completionPercentage: completion,
      updatedAt: DateTime.now(),
    );

    await _repository.updateRoadmap(updatedRoadmap);
    state = RoadmapState(roadmap: updatedRoadmap);
  }
}

final roadmapProvider = StateNotifierProvider<RoadmapNotifier, RoadmapState>((ref) {
  final repo = ref.watch(assessmentRepositoryProvider);
  final auth = ref.watch(authProvider);
  return RoadmapNotifier(repo, auth.uid ?? "temp_user");
});
