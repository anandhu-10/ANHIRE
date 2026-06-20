import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/assessment_models.dart';
import '../repositories/assessment_repository.dart';
import '../core/services/local_cache_service.dart';
import 'auth_provider.dart';
import 'assessment_provider.dart';

class DashboardData {
  final int resumeScore;
  final int aptitudeScore;
  final int interviewScore;
  final double roadmapCompletion; // 0.0 to 1.0
  final int readinessScore;
  final String readinessLevel; // Beginner, Intermediate, Advanced, Placement Ready
  final int dailyStreak;
  final List<String> recentActivity;
  final List<String> recommendedActions;
  final Map<String, List<double>> trends; // resume, aptitude, interview, readiness lists
  final bool isLoading;

  DashboardData({
    this.resumeScore = 0,
    this.aptitudeScore = 0,
    this.interviewScore = 0,
    this.roadmapCompletion = 0.0,
    this.readinessScore = 0,
    this.readinessLevel = "Beginner",
    this.dailyStreak = 0,
    this.recentActivity = const [],
    this.recommendedActions = const [],
    this.trends = const {},
    this.isLoading = false,
  });

  DashboardData copyWith({
    int? resumeScore,
    int? aptitudeScore,
    int? interviewScore,
    double? roadmapCompletion,
    int? readinessScore,
    String? readinessLevel,
    int? dailyStreak,
    List<String>? recentActivity,
    List<String>? recommendedActions,
    Map<String, List<double>>? trends,
    bool? isLoading,
  }) {
    return DashboardData(
      resumeScore: resumeScore ?? this.resumeScore,
      aptitudeScore: aptitudeScore ?? this.aptitudeScore,
      interviewScore: interviewScore ?? this.interviewScore,
      roadmapCompletion: roadmapCompletion ?? this.roadmapCompletion,
      readinessScore: readinessScore ?? this.readinessScore,
      readinessLevel: readinessLevel ?? this.readinessLevel,
      dailyStreak: dailyStreak ?? this.dailyStreak,
      recentActivity: recentActivity ?? this.recentActivity,
      recommendedActions: recommendedActions ?? this.recommendedActions,
      trends: trends ?? this.trends,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  Map<String, dynamic> toJson() => {
        "resumeScore": resumeScore,
        "aptitudeScore": aptitudeScore,
        "interviewScore": interviewScore,
        "roadmapCompletion": roadmapCompletion,
        "readinessScore": readinessScore,
        "readinessLevel": readinessLevel,
        "dailyStreak": dailyStreak,
        "recentActivity": recentActivity,
        "recommendedActions": recommendedActions,
        "trends": trends,
      };

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    // Helper to parse trends
    final rawTrends = json['trends'] as Map? ?? {};
    final Map<String, List<double>> parsedTrends = {};
    rawTrends.forEach((key, val) {
      if (val is List) {
        parsedTrends[key.toString()] = val.map((e) => (e as num).toDouble()).toList();
      }
    });

    return DashboardData(
      resumeScore: json['resumeScore'] ?? 0,
      aptitudeScore: json['aptitudeScore'] ?? 0,
      interviewScore: json['interviewScore'] ?? 0,
      roadmapCompletion: (json['roadmapCompletion'] as num?)?.toDouble() ?? 0.0,
      readinessScore: json['readinessScore'] ?? 0,
      readinessLevel: json['readinessLevel'] ?? "Beginner",
      dailyStreak: json['dailyStreak'] ?? 0,
      recentActivity: List<String>.from(json['recentActivity'] ?? []),
      recommendedActions: List<String>.from(json['recommendedActions'] ?? []),
      trends: parsedTrends,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardData> {
  final AssessmentRepository _repository;
  final LocalCacheService _cacheService = LocalCacheService();
  final String _userId;

  DashboardNotifier(this._repository, this._userId) : super(DashboardData()) {
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true);

    // 1. Try local cache first for instant load
    final cached = _cacheService.getCachedDashboard(_userId);
    if (cached != null) {
      state = DashboardData.fromJson(cached).copyWith(isLoading: false);
    }

    try {
      // 2. Fetch history from DB / repositories
      final resumeReports = await _repository.getResumeReports(_userId);
      final aptitudeResults = await _repository.getAptitudeResults(_userId);
      final interviewResults = await _repository.getInterviewResults(_userId);

      // Latest target role
      final String targetRole = "Flutter Developer"; // default, updated from profile later
      final roadmap = await _repository.getOrCreateRoadmap(_userId, targetRole);

      // Scores
      final int resume = resumeReports.isNotEmpty ? resumeReports.first.score : 0;
      final int aptitude = aptitudeResults.isNotEmpty ? aptitudeResults.first.score : 0;
      final int interview = interviewResults.isNotEmpty ? interviewResults.first.score : 0;
      final double roadmapProg = roadmap.completionPercentage;

      // Formula: (Resume*0.30) + (Aptitude*0.30) + (Interview*0.30) + (Roadmap*0.10)
      final double overall = (resume * 0.3) + (aptitude * 0.3) + (interview * 0.3) + ((roadmapProg * 100) * 0.1);
      final int readiness = overall.round();

      // Levels
      String level = "Beginner";
      if (readiness >= 86) {
        level = "Placement Ready";
      } else if (readiness >= 71) {
        level = "Advanced";
      } else if (readiness >= 41) {
        level = "Intermediate";
      }

      // Streaks (pull from profile cache or mock)
      final profileJson = _cacheService.getCachedProfile(_userId);
      final int streak = profileJson != null ? (profileJson['dailyStreak'] ?? 0) as int : 3;

      // Recommended Actions
      final List<String> actions = [];
      if (resume == 0) actions.add("Upload your resume text to receive your ATS Compatibility Score.");
      if (aptitude == 0) actions.add("Take your first Quantitative Aptitude Test to check problem-solving speed.");
      if (interview == 0) actions.add("Attempt a Mock Technical Interview to evaluate conceptual terminology.");
      if (roadmapProg < 0.25) actions.add("Start tracking your Weekly Learning Roadmap to fill critical skill gaps.");
      if (actions.isEmpty) actions.add("Practice more questions on logical reasoning to boost your rank!");

      // Recent Activity Feed
      final List<String> activity = [];
      if (resumeReports.isNotEmpty) {
        activity.add("Resume analyzed: ATS Score ${resumeReports.first.score}%");
      }
      if (aptitudeResults.isNotEmpty) {
        activity.add("Aptitude test completed: Score ${aptitudeResults.first.score}% (${aptitudeResults.first.category})");
      }
      if (interviewResults.isNotEmpty) {
        activity.add("Mock interview completed: Score ${interviewResults.first.score}% (${interviewResults.first.interviewType.toUpperCase()})");
      }
      if (activity.isEmpty) {
        activity.add("Account created successfully. Welcome to ANHIRE!");
      }

      // Trends mapping (last 5 scores)
      final List<double> resTrend = resumeReports.reversed.map((e) => e.score.toDouble()).toList();
      final List<double> aptTrend = aptitudeResults.reversed.map((e) => e.score.toDouble()).toList();
      final List<double> intTrend = interviewResults.reversed.map((e) => e.score.toDouble()).toList();
      
      // Pad with zeroes/defaults if history length is less than 5 to make charts look good
      List<double> padTrend(List<double> list, double defaultVal) {
        if (list.length >= 5) return list.sublist(list.length - 5);
        final padding = List.filled(5 - list.length, defaultVal);
        return [...padding, ...list];
      }

      final paddedResume = padTrend(resTrend, 40.0);
      final paddedAptitude = padTrend(aptTrend, 50.0);
      final paddedInterview = padTrend(intTrend, 30.0);

      final List<double> readTrend = [];
      for (int i = 0; i < 5; i++) {
        final rScore = (paddedResume[i] * 0.3) + (paddedAptitude[i] * 0.3) + (paddedInterview[i] * 0.3) + ((roadmapProg * 100) * 0.1);
        readTrend.add(rScore);
      }

      final trends = {
        "resume": paddedResume,
        "aptitude": paddedAptitude,
        "interview": paddedInterview,
        "readiness": readTrend,
      };

      final data = DashboardData(
        resumeScore: resume,
        aptitudeScore: aptitude,
        interviewScore: interview,
        roadmapCompletion: roadmapProg,
        readinessScore: readiness,
        readinessLevel: level,
        dailyStreak: streak,
        recentActivity: activity,
        recommendedActions: actions,
        trends: trends,
        isLoading: false,
      );

      // Save to Hive cache
      await _cacheService.cacheDashboard(_userId, data.toJson());
      state = data;
    } catch (e) {
      // Keep cached state on fail, set isLoading false
      state = state.copyWith(isLoading: false);
    }
  }
}

final StateNotifierProvider<DashboardNotifier, DashboardData> dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardData>((ref) {
  final repo = ref.watch(assessmentRepositoryProvider);
  final auth = ref.watch(authProvider);
  
  // Refresh dashboard whenever specific features submit results
  ref.listen(resumeReportProvider, (previous, next) {
    if (auth.uid != null) {
      ref.read(dashboardProvider.notifier).loadDashboard();
    }
  });
  
  return DashboardNotifier(repo, auth.uid ?? "temp_user");
});
