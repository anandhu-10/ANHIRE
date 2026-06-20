import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:anhire/main.dart';

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

  testWidgets('App compiles and loads login page test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: AnhireApp(),
      ),
    );

    // Allow asynchronous Riverpod setup and session checks to settle
    await tester.pumpAndSettle();

    // Verify that the login page title "ANHIRE" is rendered
    expect(find.text('ANHIRE'), findsWidgets);
  });
}
