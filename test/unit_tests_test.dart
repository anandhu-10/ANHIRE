import 'package:flutter_test/flutter_test.dart';
import 'package:anhire/core/services/resume_analyzer_service.dart';
import 'package:anhire/core/services/interview_service.dart';

void main() {
  group('ResumeAnalyzerService Unit Tests', () {
    final analyzer = ResumeAnalyzerService();

    test('Should detect missing contact details and give lower score', () {
      const emptyResumeText = "This is a brief resume with no emails or phones.";
      final result = analyzer.analyzeResume(emptyResumeText, "Flutter Developer");

      expect(result.score, lessThan(60));
      expect(result.contactDetailsFound['email'], isFalse);
      expect(result.contactDetailsFound['phone'], isFalse);
      expect(result.contactDetailsFound['linkedin'], isFalse);
      expect(result.missingSections.contains("Education"), isTrue);
    });

    test('Should detect contact details and sections, giving a high score', () {
      const richResumeText = """
      Anandhu S
      Email: student@placementpro.com
      Phone: 9876543210
      LinkedIn: linkedin.com/in/anandhu
      
      Objective
      To build outstanding client experiences using Flutter and Dart.
      
      Education
      B.Tech in Computer Science, College of Engineering Trivandrum (CET).
      
      Skills
      Flutter, Dart, Riverpod, Go Router, Git, Python, Java, SQL
      
      Projects
      ANHIRE: An AI powered platform built using Flutter, Dart, Riverpod and Firebase.
      
      Experience
      Mobile Intern at CET Tech Hub (Flutter/Dart SDK).
      
      Certifications
      Flutter Certified Developer.
      """;

      final result = analyzer.analyzeResume(richResumeText, "Flutter Developer");

      expect(result.score, greaterThan(70));
      expect(result.contactDetailsFound['email'], isTrue);
      expect(result.contactDetailsFound['phone'], isTrue);
      expect(result.contactDetailsFound['linkedin'], isTrue);
      expect(result.missingSections, isEmpty);
    });
  });

  group('InterviewService Evaluation Unit Tests', () {
    final interviewService = InterviewService();

    test('Should score 0 if response is empty', () {
      final result = interviewService.evaluateAnswer(
        questionText: "What is BuildContext?",
        userAnswer: "",
        idealKeywords: ["context", "widget tree", "position"],
        suggestedAnswer: "BuildContext refers to a widget's position in the tree hierarchy.",
      );

      expect(result.score, equals(0));
      expect(result.feedback.contains("No answer was provided"), isTrue);
    });

    test('Should score high if all keywords are matched', () {
      final result = interviewService.evaluateAnswer(
        questionText: "Explain Stateful vs Stateless widgets.",
        userAnswer: "StatelessWidgets have no mutable state and rebuild once. StatefulWidgets maintain state and use setState to trigger rebuilds dynamically.",
        idealKeywords: ["state", "stateless", "stateful", "setstate"],
        suggestedAnswer: "StatelessWidget represents immutable UI, while StatefulWidget represents mutable state that updates via setState.",
      );

      expect(result.score, greaterThanOrEqualTo(50));
      expect(result.feedback.contains("Good attempt"), isTrue);
    });
  });

  group('Readiness Score Formula Unit Tests', () {
    double calculateReadiness(double resume, double aptitude, double interview, double roadmapProgress) {
      // Formula: (Resume*0.30) + (Aptitude*0.30) + (Interview*0.30) + (RoadmapProgress*100*0.10)
      return (resume * 0.3) + (aptitude * 0.3) + (interview * 0.3) + ((roadmapProgress * 100) * 0.1);
    }

    String getLevel(double score) {
      if (score >= 86) return "Placement Ready";
      if (score >= 71) return "Advanced";
      if (score >= 41) return "Intermediate";
      return "Beginner";
    }

    test('Should calculate correct readiness levels', () {
      // 1. Beginner test
      final score1 = calculateReadiness(30, 40, 20, 0.1); // (9) + (12) + (6) + (1) = 28
      expect(score1, equals(28.0));
      expect(getLevel(score1), equals("Beginner"));

      // 2. Intermediate test
      final score2 = calculateReadiness(60, 50, 55, 0.5); // (18) + (15) + (16.5) + (5) = 54.5
      expect(score2, equals(54.5));
      expect(getLevel(score2), equals("Intermediate"));

      // 3. Placement Ready test
      final score3 = calculateReadiness(90, 85, 90, 0.9); // (27) + (25.5) + (27) + (9) = 88.5
      expect(score3, equals(88.5));
      expect(getLevel(score3), equals("Placement Ready"));
    });
  });
}
