import 'package:cloud_firestore/cloud_firestore.dart';

class StudentProfile {
  final String uid;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String registerNumber;
  final String collegeName;
  final String branch;
  final int semester;
  final double cgpa;
  final List<String> skills;
  final String preferredRole;
  final String linkedinUrl;
  final String githubUrl;
  final String profileImageUrl;
  final int dailyStreak;
  final DateTime lastActiveDate;

  StudentProfile({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.registerNumber,
    required this.collegeName,
    required this.branch,
    required this.semester,
    required this.cgpa,
    required this.skills,
    required this.preferredRole,
    required this.linkedinUrl,
    required this.githubUrl,
    required this.profileImageUrl,
    this.dailyStreak = 0,
    required this.lastActiveDate,
  });

  factory StudentProfile.empty(String uid, String email) {
    return StudentProfile(
      uid: uid,
      fullName: "",
      email: email,
      phoneNumber: "",
      registerNumber: "",
      collegeName: "",
      branch: "",
      semester: 1,
      cgpa: 0.0,
      skills: [],
      preferredRole: "Software Developer",
      linkedinUrl: "",
      githubUrl: "",
      profileImageUrl: "",
      dailyStreak: 0,
      lastActiveDate: DateTime.now(),
    );
  }

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      uid: json['uid'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      registerNumber: json['registerNumber'] ?? '',
      collegeName: json['collegeName'] ?? '',
      branch: json['branch'] ?? '',
      semester: json['semester'] ?? 1,
      cgpa: (json['cgpa'] as num?)?.toDouble() ?? 0.0,
      skills: List<String>.from(json['skills'] ?? []),
      preferredRole: json['preferredRole'] ?? 'Software Developer',
      linkedinUrl: json['linkedinUrl'] ?? '',
      githubUrl: json['githubUrl'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
      dailyStreak: json['dailyStreak'] ?? 0,
      lastActiveDate: json['lastActiveDate'] != null
          ? DateTime.tryParse(json['lastActiveDate']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  factory StudentProfile.fromFirestore(Map<String, dynamic> map) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return StudentProfile(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      registerNumber: map['registerNumber'] ?? '',
      collegeName: map['collegeName'] ?? '',
      branch: map['branch'] ?? '',
      semester: map['semester'] ?? 1,
      cgpa: (map['cgpa'] as num?)?.toDouble() ?? 0.0,
      skills: List<String>.from(map['skills'] ?? []),
      preferredRole: map['preferredRole'] ?? 'Software Developer',
      linkedinUrl: map['linkedinUrl'] ?? '',
      githubUrl: map['githubUrl'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      dailyStreak: map['dailyStreak'] ?? 0,
      lastActiveDate: parseDate(map['lastActiveDate']),
    );
  }

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "fullName": fullName,
        "email": email,
        "phoneNumber": phoneNumber,
        "registerNumber": registerNumber,
        "collegeName": collegeName,
        "branch": branch,
        "semester": semester,
        "cgpa": cgpa,
        "skills": skills,
        "preferredRole": preferredRole,
        "linkedinUrl": linkedinUrl,
        "githubUrl": githubUrl,
        "profileImageUrl": profileImageUrl,
        "dailyStreak": dailyStreak,
        "lastActiveDate": lastActiveDate.toIso8601String(),
      };

  Map<String, dynamic> toFirestore() => {
        "uid": uid,
        "fullName": fullName,
        "email": email,
        "phoneNumber": phoneNumber,
        "registerNumber": registerNumber,
        "collegeName": collegeName,
        "branch": branch,
        "semester": semester,
        "cgpa": cgpa,
        "skills": skills,
        "preferredRole": preferredRole,
        "linkedinUrl": linkedinUrl,
        "githubUrl": githubUrl,
        "profileImageUrl": profileImageUrl,
        "dailyStreak": dailyStreak,
        "lastActiveDate": Timestamp.fromDate(lastActiveDate),
      };

  StudentProfile copyWith({
    String? fullName,
    String? phoneNumber,
    String? registerNumber,
    String? collegeName,
    String? branch,
    int? semester,
    double? cgpa,
    List<String>? skills,
    String? preferredRole,
    String? linkedinUrl,
    String? githubUrl,
    String? profileImageUrl,
    int? dailyStreak,
    DateTime? lastActiveDate,
  }) {
    return StudentProfile(
      uid: uid,
      email: email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      registerNumber: registerNumber ?? this.registerNumber,
      collegeName: collegeName ?? this.collegeName,
      branch: branch ?? this.branch,
      semester: semester ?? this.semester,
      cgpa: cgpa ?? this.cgpa,
      skills: skills ?? this.skills,
      preferredRole: preferredRole ?? this.preferredRole,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      githubUrl: githubUrl ?? this.githubUrl,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      dailyStreak: dailyStreak ?? this.dailyStreak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
    );
  }
}
