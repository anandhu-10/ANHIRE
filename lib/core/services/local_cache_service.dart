import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalCacheService {
  static const String _profileBox = "profile_box";
  static const String _dashboardBox = "dashboard_box";
  static const String _roadmapsBox = "roadmaps_box";
  static const String _resumeBox = "resume_box";
  static const String _aptitudeBox = "aptitude_box";
  static const String _interviewBox = "interview_box";
  static const String _syncQueueKey = "offline_sync_queue";

  /// Initializes Hive database for offline usage.
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_profileBox);
    await Hive.openBox(_dashboardBox);
    await Hive.openBox(_roadmapsBox);
    await Hive.openBox(_resumeBox);
    await Hive.openBox(_aptitudeBox);
    await Hive.openBox(_interviewBox);
  }

  // --- Profile Cache ---
  Future<void> cacheProfile(String uid, Map<String, dynamic> data) async {
    final box = Hive.box(_profileBox);
    await box.put(uid, jsonEncode(data));
  }

  Map<String, dynamic>? getCachedProfile(String uid) {
    final box = Hive.box(_profileBox);
    final raw = box.get(uid) as String?;
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  // --- Dashboard Cache ---
  Future<void> cacheDashboard(String uid, Map<String, dynamic> data) async {
    final box = Hive.box(_dashboardBox);
    await box.put(uid, jsonEncode(data));
  }

  Map<String, dynamic>? getCachedDashboard(String uid) {
    final box = Hive.box(_dashboardBox);
    final raw = box.get(uid) as String?;
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  // --- Roadmaps Cache ---
  Future<void> cacheRoadmap(String uid, Map<String, dynamic> data) async {
    final box = Hive.box(_roadmapsBox);
    await box.put(uid, jsonEncode(data));
  }

  Map<String, dynamic>? getCachedRoadmap(String uid) {
    final box = Hive.box(_roadmapsBox);
    final raw = box.get(uid) as String?;
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  // --- Resume Reports Cache ---
  Future<void> cacheResumeReports(String uid, List<Map<String, dynamic>> reports) async {
    final box = Hive.box(_resumeBox);
    await box.put(uid, jsonEncode(reports));
  }

  List<Map<String, dynamic>>? getCachedResumeReports(String uid) {
    final box = Hive.box(_resumeBox);
    final raw = box.get(uid) as String?;
    if (raw == null) return null;
    final decoded = jsonDecode(raw) as List;
    return decoded.map((e) => e as Map<String, dynamic>).toList();
  }

  // --- Aptitude Cache ---
  Future<void> cacheAptitudeResults(String uid, List<Map<String, dynamic>> results) async {
    final box = Hive.box(_aptitudeBox);
    await box.put(uid, jsonEncode(results));
  }

  List<Map<String, dynamic>>? getCachedAptitudeResults(String uid) {
    final box = Hive.box(_aptitudeBox);
    final raw = box.get(uid) as String?;
    if (raw == null) return null;
    final decoded = jsonDecode(raw) as List;
    return decoded.map((e) => e as Map<String, dynamic>).toList();
  }

  // --- Interview Cache ---
  Future<void> cacheInterviewResults(String uid, List<Map<String, dynamic>> results) async {
    final box = Hive.box(_interviewBox);
    await box.put(uid, jsonEncode(results));
  }

  List<Map<String, dynamic>>? getCachedInterviewResults(String uid) {
    final box = Hive.box(_interviewBox);
    final raw = box.get(uid) as String?;
    if (raw == null) return null;
    final decoded = jsonDecode(raw) as List;
    return decoded.map((e) => e as Map<String, dynamic>).toList();
  }

  // --- Offline Sync Queue ---
  /// Adds a Firestore operation to the queue to execute when online.
  Future<void> enqueueSyncOperation(Map<String, dynamic> operation) async {
    final prefs = await SharedPreferences.getInstance();
    final queueRaw = prefs.getStringList(_syncQueueKey) ?? [];
    queueRaw.add(jsonEncode(operation));
    await prefs.setStringList(_syncQueueKey, queueRaw);
  }

  /// Fetches all queued operations.
  Future<List<Map<String, dynamic>>> getSyncQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final queueRaw = prefs.getStringList(_syncQueueKey) ?? [];
    return queueRaw.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  /// Clears the queue once synchronized.
  Future<void> clearSyncQueue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_syncQueueKey);
  }
}
