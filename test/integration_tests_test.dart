import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:anhire/screens/auth/login_screen.dart';
import 'package:anhire/screens/student/resume_analyzer.dart';
import 'package:anhire/screens/student/aptitude_categories.dart';

void main() {
  setUpAll(() async {
    final tempDir = Directory.systemTemp.createTempSync();
    Hive.init(tempDir.path);
    await Hive.openBox("profile_box");
    await Hive.openBox("dashboard_box");
    await Hive.openBox("roadmaps_box");
    await Hive.openBox("resume_box");
    await Hive.openBox("aptitude_box");
    await Hive.openBox("interview_box");
    await Hive.openBox("auth_session_box");
    SharedPreferences.setMockInitialValues({});
  });

  // Helper to wrap test widgets with standard parent bindings
  Widget createTestWidget(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        home: child,
      ),
    );
  }

  group('UI & Integration Widget Tests', () {
    testWidgets('Login Screen input validation test', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const LoginScreen()));
      await tester.pumpAndSettle();

      // Transition to Login Form
      final loginTransitionFinder = find.text("Login");
      expect(loginTransitionFinder, findsOneWidget);
      await tester.ensureVisible(loginTransitionFinder);
      await tester.tap(loginTransitionFinder);
      await tester.pumpAndSettle();

      // 1. Trigger login without inputs -> expect validation errors
      final loginBtnFinder = find.text("LOGIN");
      expect(loginBtnFinder, findsOneWidget);

      await tester.ensureVisible(loginBtnFinder);
      await tester.tap(loginBtnFinder);
      await tester.pumpAndSettle();

      expect(find.text("Enter your email address"), findsOneWidget);
      expect(find.text("Enter your password"), findsOneWidget);

      // 2. Input invalid email formatting -> expect format error
      final emailFieldFinder = find.widgetWithText(TextFormField, "Email Address");
      await tester.ensureVisible(emailFieldFinder);
      await tester.enterText(emailFieldFinder, "invalid_email_no_at");
      await tester.ensureVisible(loginBtnFinder);
      await tester.tap(loginBtnFinder);
      await tester.pumpAndSettle();

      expect(find.text("Enter a valid email address"), findsOneWidget);
    });

    testWidgets('Resume Analyzer screen rendering test', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const ResumeAnalyzerScreen()));
      await tester.pumpAndSettle();

      // Verify page details load
      expect(find.text("Resume Audit Engine"), findsOneWidget);
      expect(find.text("Choose PDF / DOCX"), findsOneWidget);
      expect(find.text("ANALYZE RESUME"), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('Aptitude selector chips rendering test', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const AptitudeCategoriesScreen()));
      await tester.pumpAndSettle();

      // Verify categories load
      expect(find.text("Quantitative Aptitude"), findsOneWidget);
      expect(find.text("Logical Reasoning"), findsOneWidget);
      expect(find.text("Verbal Ability"), findsOneWidget);

      // Verify difficulty chips load
      expect(find.text("EASY"), findsOneWidget);
      expect(find.text("MEDIUM"), findsOneWidget);
      expect(find.text("HARD"), findsOneWidget);
    });
  });
}
