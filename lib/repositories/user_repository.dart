import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../core/services/firebase_service.dart';
import '../core/services/local_cache_service.dart';
import '../models/profile_model.dart';

abstract class UserRepository {
  Future<StudentProfile?> getProfile(String uid);
  Future<void> saveProfile(StudentProfile profile);
  Future<void> updateStreak(String uid);
}

class UserRepositoryImpl implements UserRepository {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  final LocalCacheService _cacheService = LocalCacheService();

  bool get _useFirebase => FirebaseService.isFirebaseAvailable;

  @override
  Future<StudentProfile?> getProfile(String uid) async {
    // 1. Try local cache first for instant load (Offline Support)
    final cached = _cacheService.getCachedProfile(uid);
    if (cached != null) {
      return StudentProfile.fromJson(cached);
    }

    if (!_useFirebase) {
      // Return a seeded default profile for demo account offline
      if (uid == "mock_student_uid") {
        final mockProfile = StudentProfile(
          uid: uid,
          fullName: "Anandhu S",
          email: "student@placementpro.com",
          phoneNumber: "+91 9876543210",
          registerNumber: "TVE20CS001",
          collegeName: "College of Engineering, Trivandrum (CET)",
          branch: "Computer Science and Engineering",
          semester: 8,
          cgpa: 8.75,
          skills: ["Dart", "Flutter", "Java", "Python", "SQL"],
          preferredRole: "Flutter Developer",
          linkedinUrl: "https://linkedin.com/in/anandhus",
          githubUrl: "https://github.com/anandhus",
          profileImageUrl: "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80",
          dailyStreak: 3,
          lastActiveDate: DateTime.now().subtract(const Duration(days: 1)),
        );
        await _cacheService.cacheProfile(uid, mockProfile.toJson());
        return mockProfile;
      }
      return StudentProfile.empty(uid, "student@placementpro.com");
    }

    try {
      final doc = await _firestore.collection("profiles").doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final profile = StudentProfile.fromFirestore(doc.data()!);
        // Save to cache
        await _cacheService.cacheProfile(uid, profile.toJson());
        return profile;
      }
    } catch (e) {
      // Suppress error, fallback to empty/cached
    }
    return null;
  }

  @override
  Future<void> saveProfile(StudentProfile profile) async {
    // Save to Hive cache
    await _cacheService.cacheProfile(profile.uid, profile.toJson());

    if (!_useFirebase) {
      // Sync leaderboard offline
      final box = Hive.box("auth_session_box");
      await box.put("profile_${profile.uid}", jsonEncode(profile.toJson()));
      return;
    }

    try {
      // Save to remote Firestore
      await _firestore.collection("profiles").doc(profile.uid).set(profile.toFirestore());
      await _firestore.collection("users").doc(profile.uid).set({
        "uid": profile.uid,
        "email": profile.email,
        "role": profile.uid.contains("admin") ? "admin" : "student",
        "createdAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Sync leaderboard entry
      await _firestore.collection("leaderboard").doc(profile.uid).set({
        "uid": profile.uid,
        "name": profile.fullName,
        "collegeName": profile.collegeName,
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      // If write fails (network issue), enqueue sync task
      await _cacheService.enqueueSyncOperation({
        "type": "saveProfile",
        "uid": profile.uid,
        "data": profile.toJson(),
      });
    }
  }

  @override
  Future<void> updateStreak(String uid) async {
    final profile = await getProfile(uid);
    if (profile == null) return;

    final now = DateTime.now();
    final difference = now.difference(profile.lastActiveDate).inDays;

    StudentProfile updatedProfile;
    if (difference == 1) {
      // Increment streak
      updatedProfile = profile.copyWith(
        dailyStreak: profile.dailyStreak + 1,
        lastActiveDate: now,
      );
    } else if (difference > 1) {
      // Reset streak to 1
      updatedProfile = profile.copyWith(
        dailyStreak: 1,
        lastActiveDate: now,
      );
    } else {
      // Already logged in today, keep streak
      updatedProfile = profile.copyWith(lastActiveDate: now);
    }

    await saveProfile(updatedProfile);
  }
}
