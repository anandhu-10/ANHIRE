import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hive/hive.dart';
import '../core/services/firebase_service.dart';
import '../core/services/local_cache_service.dart';
import '../models/assessment_models.dart';

abstract class AssessmentRepository {
  Future<List<AptitudeQuestion>> getAptitudeQuestions(String category, String difficulty);
  Future<void> saveAptitudeResult(AptitudeResult result);
  Future<List<AptitudeResult>> getAptitudeResults(String userId);

  Future<List<InterviewQuestion>> getInterviewQuestions(String type);
  Future<void> saveInterviewResult(InterviewResult result);
  Future<List<InterviewResult>> getInterviewResults(String userId);

  Future<void> saveResumeReport(ResumeReport report);
  Future<List<ResumeReport>> getResumeReports(String userId);

  Future<Roadmap> getOrCreateRoadmap(String userId, String targetRole);
  Future<void> updateRoadmap(Roadmap roadmap);

  Future<List<LeaderboardEntry>> getLeaderboard({String? collegeFilter});
  Future<List<AppNotification>> getNotifications(String userId);
}

class AssessmentRepositoryImpl implements AssessmentRepository {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  final LocalCacheService _cacheService = LocalCacheService();

  bool get _useFirebase => FirebaseService.isFirebaseAvailable;

  @override
  Future<List<AptitudeQuestion>> getAptitudeQuestions(String category, String difficulty) async {
    // Standard rule: read from assets for speed and offline stability
    try {
      final String jsonContent = await rootBundle.loadString("assets/aptitude/$category.json");
      final List decoded = jsonDecode(jsonContent);
      final allQuestions = decoded.map((e) => AptitudeQuestion.fromJson(e as Map<String, dynamic>)).toList();
      
      // Filter by difficulty and shuffle/select 10 questions for a test
      final filtered = allQuestions.where((q) => q.difficulty.toLowerCase() == difficulty.toLowerCase()).toList();
      filtered.shuffle();
      return filtered.take(10).toList();
    } catch (e) {
      // Fallback: return mock set
      return List.generate(5, (index) => AptitudeQuestion(
        id: "mock_q_$index",
        category: category,
        topic: "General",
        questionText: "What is the answer to mock question $index?",
        options: ["Option A", "Option B", "Option C", "Option D"],
        correctOptionIndex: 1,
        difficulty: difficulty,
        explanation: "This is a fallback question due to asset reading issues.",
      ));
    }
  }

  @override
  Future<void> saveAptitudeResult(AptitudeResult result) async {
    // Write to Hive cache
    final List<Map<String, dynamic>> results = _cacheService.getCachedAptitudeResults(result.userId) ?? [];
    results.insert(0, result.toJson());
    await _cacheService.cacheAptitudeResults(result.userId, results);

    // Update readiness score in leaderboard local copy
    await _updateLocalLeaderboard(result.userId, aptitudeScore: result.score.toDouble());

    if (!_useFirebase) return;

    try {
      await _firestore.collection("aptitude_results").doc(result.id).set(result.toJson());
      // Update global leaderboard collection in Firestore
      await _firestore.collection("leaderboard").doc(result.userId).set({
        "aptitudeScore": result.score,
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      await _cacheService.enqueueSyncOperation({
        "type": "saveAptitudeResult",
        "data": result.toJson(),
      });
    }
  }

  @override
  Future<List<AptitudeResult>> getAptitudeResults(String userId) async {
    final cached = _cacheService.getCachedAptitudeResults(userId);
    if (cached != null) {
      return cached.map((e) => AptitudeResult.fromJson(e)).toList();
    }

    if (!_useFirebase) return [];

    try {
      final query = await _firestore
          .collection("aptitude_results")
          .where("userId", isEqualTo: userId)
          .orderBy("attemptedAt", descending: true)
          .get();

      final results = query.docs.map((d) => AptitudeResult.fromJson(d.data())).toList();
      await _cacheService.cacheAptitudeResults(userId, results.map((e) => e.toJson()).toList());
      return results;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<InterviewQuestion>> getInterviewQuestions(String type) async {
    try {
      final String jsonContent = await rootBundle.loadString("assets/interview/$type.json");
      final List decoded = jsonDecode(jsonContent);
      final allQuestions = decoded.map((e) => InterviewQuestion.fromJson(e as Map<String, dynamic>)).toList();
      allQuestions.shuffle();
      return allQuestions.take(5).toList(); // Return 5 questions for mock interview
    } catch (e) {
      return List.generate(3, (index) => InterviewQuestion(
        id: "mock_int_$index",
        type: type,
        role: "Software Developer",
        questionText: "Tell me your thoughts on mock scenario $index.",
        idealKeywords: ["test", "mock", "practice"],
        suggestedAnswer: "An ideal response covers practicing and testing software modules thoroughly.",
      ));
    }
  }

  @override
  Future<void> saveInterviewResult(InterviewResult result) async {
    final List<Map<String, dynamic>> results = _cacheService.getCachedInterviewResults(result.userId) ?? [];
    results.insert(0, result.toJson());
    await _cacheService.cacheInterviewResults(result.userId, results);

    // Update readiness score in leaderboard local copy
    await _updateLocalLeaderboard(result.userId, interviewScore: result.score.toDouble());

    if (!_useFirebase) return;

    try {
      await _firestore.collection("interview_results").doc(result.id).set(result.toJson());
    } catch (e) {
      await _cacheService.enqueueSyncOperation({
        "type": "saveInterviewResult",
        "data": result.toJson(),
      });
    }
  }

  @override
  Future<List<InterviewResult>> getInterviewResults(String userId) async {
    final cached = _cacheService.getCachedInterviewResults(userId);
    if (cached != null) {
      return cached.map((e) => InterviewResult.fromJson(e)).toList();
    }

    if (!_useFirebase) return [];

    try {
      final query = await _firestore
          .collection("interview_results")
          .where("userId", isEqualTo: userId)
          .orderBy("attemptedAt", descending: true)
          .get();

      final results = query.docs.map((d) => InterviewResult.fromJson(d.data())).toList();
      await _cacheService.cacheInterviewResults(userId, results.map((e) => e.toJson()).toList());
      return results;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveResumeReport(ResumeReport report) async {
    final List<Map<String, dynamic>> reports = _cacheService.getCachedResumeReports(report.userId) ?? [];
    reports.insert(0, report.toJson());
    await _cacheService.cacheResumeReports(report.userId, reports);

    // Update readiness score in leaderboard local copy
    await _updateLocalLeaderboard(report.userId, resumeScore: report.score.toDouble());

    if (!_useFirebase) return;

    try {
      await _firestore.collection("resume_reports").doc(report.id).set(report.toJson());
    } catch (e) {
      await _cacheService.enqueueSyncOperation({
        "type": "saveResumeReport",
        "data": report.toJson(),
      });
    }
  }

  @override
  Future<List<ResumeReport>> getResumeReports(String userId) async {
    final cached = _cacheService.getCachedResumeReports(userId);
    if (cached != null) {
      return cached.map((e) => ResumeReport.fromJson(e)).toList();
    }

    if (!_useFirebase) return [];

    try {
      final query = await _firestore
          .collection("resume_reports")
          .where("userId", isEqualTo: userId)
          .orderBy("analyzedAt", descending: true)
          .get();

      final reports = query.docs.map((d) => ResumeReport.fromJson(d.data())).toList();
      await _cacheService.cacheResumeReports(userId, reports.map((e) => e.toJson()).toList());
      return reports;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Roadmap> getOrCreateRoadmap(String userId, String targetRole) async {
    final cached = _cacheService.getCachedRoadmap(userId);
    if (cached != null) {
      final roadmap = Roadmap.fromJson(cached);
      if (roadmap.targetRole.toLowerCase() == targetRole.toLowerCase()) {
        return roadmap;
      }
    }

    // Load from skills assets
    final roleFile = targetRole.toLowerCase().replaceAll(' ', '_');
    try {
      final jsonContent = await rootBundle.loadString("assets/skills/$roleFile.json");
      final data = jsonDecode(jsonContent);

      final List<String> requiredSkills = List<String>.from(data['requiredSkills'] ?? []);
      final List<String> missingSkills = List<String>.from(data['missingSkills'] ?? []);
      
      // Split missing skills into 4 weeks
      final List<RoadmapWeek> weeks = [];
      for (int w = 1; w <= 4; w++) {
        final List<RoadmapTopic> topics = [];
        if (missingSkills.isNotEmpty) {
          // distribute topics
          int itemsPerWeek = (missingSkills.length / 4.0).ceil();
          int start = (w - 1) * itemsPerWeek;
          int end = start + itemsPerWeek;
          if (start < missingSkills.length) {
            final sub = missingSkills.sublist(start, end > missingSkills.length ? missingSkills.length : end);
            for (var item in sub) {
              topics.add(RoadmapTopic(topicName: item, isCompleted: false));
            }
          }
        }
        
        // Add a generic prep topic if week is empty
        if (topics.isEmpty) {
          topics.add(RoadmapTopic(topicName: "Aptitude & HR Mock Practice", isCompleted: false));
        }
        weeks.add(RoadmapWeek(weekNumber: w, topics: topics));
      }

      final roadmap = Roadmap(
        id: "roadmap_$userId",
        userId: userId,
        targetRole: targetRole,
        weeks: weeks,
        completionPercentage: 0.0,
        updatedAt: DateTime.now(),
      );

      await _cacheService.cacheRoadmap(userId, roadmap.toJson());
      
      // Firestore upload
      if (_useFirebase) {
        await _firestore.collection("roadmaps").doc(roadmap.id).set(roadmap.toJson());
      }
      return roadmap;
    } catch (e) {
      // Fallback roadmap
      final roadmap = Roadmap(
        id: "roadmap_$userId",
        userId: userId,
        targetRole: targetRole,
        weeks: List.generate(4, (w) => RoadmapWeek(
          weekNumber: w + 1,
          topics: [RoadmapTopic(topicName: "Mock Aptitude practice", isCompleted: false)],
        )),
        completionPercentage: 0.0,
        updatedAt: DateTime.now(),
      );
      await _cacheService.cacheRoadmap(userId, roadmap.toJson());
      return roadmap;
    }
  }

  @override
  Future<void> updateRoadmap(Roadmap roadmap) async {
    await _cacheService.cacheRoadmap(roadmap.userId, roadmap.toJson());

    // Update readiness score in leaderboard local copy
    await _updateLocalLeaderboard(roadmap.userId, roadmapCompletion: roadmap.completionPercentage);

    if (!_useFirebase) return;

    try {
      await _firestore.collection("roadmaps").doc(roadmap.id).set(roadmap.toJson());
    } catch (e) {
      await _cacheService.enqueueSyncOperation({
        "type": "updateRoadmap",
        "data": roadmap.toJson(),
      });
    }
  }

  @override
  Future<List<LeaderboardEntry>> getLeaderboard({String? collegeFilter}) async {
    if (!_useFirebase) {
      // Mock leaderboard lists combining cached entries and defaults
      final List<LeaderboardEntry> list = [
        LeaderboardEntry(uid: "mock_student_uid", name: "Anandhu S", collegeName: "CET", readinessScore: 84.0, aptitudeScore: 80.0, updatedAt: DateTime.now()),
        LeaderboardEntry(uid: "uid2", name: "Abhiram K", collegeName: "CET", readinessScore: 92.0, aptitudeScore: 90.0, updatedAt: DateTime.now()),
        LeaderboardEntry(uid: "uid3", name: "Sandra Philip", collegeName: "TKM", readinessScore: 78.0, aptitudeScore: 75.0, updatedAt: DateTime.now()),
        LeaderboardEntry(uid: "uid4", name: "Rithvik Raju", collegeName: "CET", readinessScore: 68.0, aptitudeScore: 70.0, updatedAt: DateTime.now()),
        LeaderboardEntry(uid: "uid5", name: "Fathima N", collegeName: "GECB", readinessScore: 86.0, aptitudeScore: 82.0, updatedAt: DateTime.now()),
        LeaderboardEntry(uid: "uid6", name: "Rahul Das", collegeName: "TKM", readinessScore: 45.0, aptitudeScore: 50.0, updatedAt: DateTime.now()),
      ];
      
      // Update with current cached student if available
      final currentProfileJson = _cacheService.getCachedProfile("mock_student_uid");
      if (currentProfileJson != null) {
        final box = Hive.box("auth_session_box");
        double localReadiness = box.get("lead_readiness_mock_student_uid", defaultValue: 84.0) as double;
        double localApt = box.get("lead_aptitude_mock_student_uid", defaultValue: 80.0) as double;
        
        list[0] = LeaderboardEntry(
          uid: "mock_student_uid",
          name: currentProfileJson['fullName'] ?? "Anandhu S",
          collegeName: currentProfileJson['collegeName'] ?? "CET",
          readinessScore: localReadiness,
          aptitudeScore: localApt,
          updatedAt: DateTime.now(),
        );
      }

      list.sort((a, b) => b.readinessScore.compareTo(a.readinessScore));

      if (collegeFilter != null && collegeFilter.isNotEmpty) {
        return list.where((e) => e.collegeName.toLowerCase() == collegeFilter.toLowerCase()).toList();
      }
      return list;
    }

    try {
      Query query = _firestore.collection("leaderboard");
      if (collegeFilter != null && collegeFilter.isNotEmpty) {
        query = query.where("collegeName", isEqualTo: collegeFilter);
      }
      
      final result = await query.get();
      final list = result.docs.map((d) {
        final data = d.data() as Map<String, dynamic>;
        // Calculate dynamic readiness score if needed, or read stored
        return LeaderboardEntry.fromJson(data);
      }).toList();
      
      list.sort((a, b) => b.readinessScore.compareTo(a.readinessScore));
      return list;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<AppNotification>> getNotifications(String userId) async {
    if (!_useFirebase) {
      return [
        AppNotification(id: "n1", userId: userId, title: "Welcome to ANHIRE", body: "Complete your profile, upload your resume text and start preparing for interviews!", createdAt: DateTime.now().subtract(const Duration(hours: 4))),
        AppNotification(id: "n2", userId: userId, title: "Daily Practice Reminder", body: "Practice makes perfect! Take a 10-minute quantitative test now.", createdAt: DateTime.now().subtract(const Duration(days: 1))),
      ];
    }

    try {
      final res = await _firestore
          .collection("notifications")
          .where("userId", isEqualTo: userId)
          .orderBy("createdAt", descending: true)
          .get();
      return res.docs.map((d) => AppNotification.fromJson(d.data())).toList();
    } catch (e) {
      return [];
    }
  }

  // --- Helper to update local leaderboard details for offline score calculations ---
  Future<void> _updateLocalLeaderboard(
    String uid, {
    double? resumeScore,
    double? aptitudeScore,
    double? interviewScore,
    double? roadmapCompletion,
  }) async {
    final box = Hive.box("auth_session_box");
    
    double curResume = box.get("lead_resume_$uid", defaultValue: 70.0) as double;
    double curApt = box.get("lead_aptitude_$uid", defaultValue: 60.0) as double;
    double curInt = box.get("lead_interview_$uid", defaultValue: 65.0) as double;
    double curRoad = box.get("lead_roadmap_$uid", defaultValue: 0.0) as double;

    if (resumeScore != null) {
      curResume = resumeScore;
      await box.put("lead_resume_$uid", resumeScore);
    }
    if (aptitudeScore != null) {
      curApt = aptitudeScore;
      await box.put("lead_aptitude_$uid", aptitudeScore);
    }
    if (interviewScore != null) {
      curInt = interviewScore;
      await box.put("lead_interview_$uid", interviewScore);
    }
    if (roadmapCompletion != null) {
      curRoad = roadmapCompletion;
      await box.put("lead_roadmap_$uid", roadmapCompletion);
    }

    // Formula: (Resume*0.30) + (Aptitude*0.30) + (Interview*0.30) + (Roadmap*0.10)
    final double overall = (curResume * 0.3) + (curApt * 0.3) + (curInt * 0.3) + ((curRoad * 100) * 0.1);
    await box.put("lead_readiness_$uid", overall);
    await box.put("lead_aptitude_$uid", curApt);
  }
}
