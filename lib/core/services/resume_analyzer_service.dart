import 'dart:math';

class ResumeAnalysisResult {
  final int score;
  final List<String> missingSections;
  final List<String> improvementSuggestions;
  final String atsCompatibilityReport;
  final Map<String, bool> contactDetailsFound;

  ResumeAnalysisResult({
    required this.score,
    required this.missingSections,
    required this.improvementSuggestions,
    required this.atsCompatibilityReport,
    required this.contactDetailsFound,
  });

  Map<String, dynamic> toJson() => {
        "score": score,
        "missingSections": missingSections,
        "improvementSuggestions": improvementSuggestions,
        "atsCompatibilityReport": atsCompatibilityReport,
        "contactDetailsFound": contactDetailsFound,
      };
}

class ResumeAnalyzerService {
  // Predefined role keywords for ATS checks
  static final Map<String, List<String>> roleKeywords = {
    "software developer": [
      "java", "python", "c++", "data structures", "algorithms", "oop",
      "git", "sql", "testing", "software engineering", "sdlc"
    ],
    "flutter developer": [
      "dart", "flutter", "state management", "riverpod", "provider", "bloc",
      "widgets", "api integration", "git", "material design", "ios", "android"
    ],
    "backend developer": [
      "python", "node.js", "databases", "sql", "nosql", "mongodb", "postgresql",
      "docker", "rest api", "microservices", "redis", "aws", "gcp"
    ],
    "full stack developer": [
      "javascript", "html", "css", "react", "node.js", "express", "mongodb",
      "rest apis", "git", "web development", "angular", "vue"
    ],
    "data analyst": [
      "sql", "python", "r", "pandas", "excel", "tableau", "power bi",
      "statistics", "data visualization", "data cleaning", "machine learning"
    ]
  };

  ResumeAnalysisResult analyzeResume(String text, String targetRole) {
    final textLower = text.toLowerCase();
    final role = targetRole.toLowerCase();

    // 1. Check Contact Details
    final hasEmail = RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}').hasMatch(text);
    final hasPhone = RegExp(r'(?:\+?\d{1,3}[- ]?)?\(?\d{3}\)?[- ]?\d{3}[- ]?\d{4}').hasMatch(text);
    final hasLinkedIn = textLower.contains("linkedin.com") || textLower.contains("li/in/");

    final contacts = {
      "email": hasEmail,
      "phone": hasPhone,
      "linkedin": hasLinkedIn,
    };

    // 2. Check Standard Sections
    final sections = {
      "Objective": ["objective", "summary", "profile"],
      "Education": ["education", "academic", "university", "college", "degree"],
      "Skills": ["skills", "technical skills", "technologies", "expertise"],
      "Projects": ["projects", "personal projects", "academic projects"],
      "Experience": ["experience", "work experience", "employment", "internship"],
      "Certifications": ["certifications", "certs", "achievements", "courses"]
    };

    final List<String> missingSections = [];
    final List<String> foundSections = [];

    sections.forEach((sectionName, keywords) {
      bool found = false;
      for (var kw in keywords) {
        if (textLower.contains(kw)) {
          found = true;
          break;
        }
      }
      if (found) {
        foundSections.add(sectionName);
      } else {
        missingSections.add(sectionName);
      }
    });

    // 3. Keyword Density Checks
    final keywords = roleKeywords[role] ?? roleKeywords["software developer"]!;
    int matchedKeywordsCount = 0;
    final List<String> missingKeywords = [];

    for (var kw in keywords) {
      if (textLower.contains(kw)) {
        matchedKeywordsCount++;
      } else {
        missingKeywords.add(kw);
      }
    }

    // 4. Formatting and Length Checks
    final wordCount = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    final List<String> suggestions = [];

    if (wordCount < 100) {
      suggestions.add("The resume is too short. Add more details about your projects and skills.");
    } else if (wordCount > 600) {
      suggestions.add("The resume is too wordy. Keep it concise, preferably under 1-2 pages.");
    }

    // Accumulate scoring details
    int score = 0;

    // Contact Details = 25 pts (8.3 pts each)
    if (hasEmail) score += 9;
    if (hasPhone) score += 8;
    if (hasLinkedIn) score += 8;

    // Sections = 45 pts (7.5 pts each found section)
    score += (foundSections.length * 7.5).round();

    // Keywords = 30 pts (proportion of matched keywords)
    if (keywords.isNotEmpty) {
      score += ((matchedKeywordsCount / keywords.length) * 30).round();
    }

    // Clamp score to 100 max, 10 min
    score = min(max(score, 10), 100);

    // Generate suggestions based on findings
    if (!hasEmail) suggestions.add("Add a professional email address.");
    if (!hasPhone) suggestions.add("Add a valid phone number for recruiters.");
    if (!hasLinkedIn) suggestions.add("Add your LinkedIn profile link to improve credibility.");

    for (var sec in missingSections) {
      suggestions.add("Add a dedicated '$sec' section to structure your resume better.");
    }

    if (missingKeywords.isNotEmpty) {
      final sampleSize = min(3, missingKeywords.length);
      final suggestionsKeywords = missingKeywords.sublist(0, sampleSize).join(", ");
      suggestions.add(
        "Incorporate targeted keywords for $targetRole: e.g., $suggestionsKeywords.",
      );
    }

    if (score < 50) {
      suggestions.add("Review formatting to make sure standard fonts and layout headers are used.");
    }

    // 5. Generate Compatibility summary
    String atsCompatibility = "";
    if (score >= 85) {
      atsCompatibility = "High ATS Compatibility: The resume is exceptionally structured, includes important contact links, has key section titles, and contains dense keywords for the targeted job role.";
    } else if (score >= 60) {
      atsCompatibility = "Moderate ATS Compatibility: The resume is readable by parser engines but lacks crucial keywords or sections. Add missing keywords and ensure contact links are clickable.";
    } else {
      atsCompatibility = "Low ATS Compatibility: Major sections are missing, contact details are incomplete, or keyword density is low. Revise according to suggestions.";
    }

    return ResumeAnalysisResult(
      score: score,
      missingSections: missingSections,
      improvementSuggestions: suggestions,
      atsCompatibilityReport: atsCompatibility,
      contactDetailsFound: contacts,
    );
  }
}
