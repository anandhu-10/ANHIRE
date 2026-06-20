import 'dart:math';

class InterviewEvaluationResult {
  final int score;
  final String feedback;
  final String suggestedAnswer;

  InterviewEvaluationResult({
    required this.score,
    required this.feedback,
    required this.suggestedAnswer,
  });
}

class InterviewService {
  /// Evaluates the student's mock interview answer.
  InterviewEvaluationResult evaluateAnswer({
    required String questionText,
    required String userAnswer,
    required List<String> idealKeywords,
    required String suggestedAnswer,
  }) {
    final cleanUserAnswer = userAnswer.trim().toLowerCase();
    final cleanSuggested = suggestedAnswer.toLowerCase();

    if (cleanUserAnswer.isEmpty) {
      return InterviewEvaluationResult(
        score: 0,
        feedback: "No answer was provided. Try expressing your thoughts using standard industry terms.",
        suggestedAnswer: suggestedAnswer,
      );
    }

    // 1. Keyword Matching Score
    int matchedKeywords = 0;
    final List<String> missedKeywords = [];
    for (var kw in idealKeywords) {
      final cleanKw = kw.toLowerCase();
      if (cleanUserAnswer.contains(cleanKw)) {
        matchedKeywords++;
      } else {
        missedKeywords.add(kw);
      }
    }

    double keywordScore = 0.0;
    if (idealKeywords.isNotEmpty) {
      keywordScore = (matchedKeywords / idealKeywords.length) * 50.0; // max 50 points
    } else {
      keywordScore = 50.0; // fallback if no keywords defined
    }

    // 2. Word overlap / Jaccard Similarity Score
    final userTokens = _tokenize(cleanUserAnswer);
    final suggestedTokens = _tokenize(cleanSuggested);

    double similarityScore = 0.0;
    if (userTokens.isNotEmpty && suggestedTokens.isNotEmpty) {
      final intersection = userTokens.intersection(suggestedTokens).length;
      final union = userTokens.union(suggestedTokens).length;
      final jaccard = intersection / union;
      similarityScore = jaccard * 30.0; // max 30 points
    }

    // 3. Length & Detail Check (max 20 points)
    final wordCount = userTokens.length;
    double lengthScore = 0.0;
    if (wordCount >= 30) {
      lengthScore = 20.0;
    } else if (wordCount >= 15) {
      lengthScore = 12.0;
    } else if (wordCount >= 5) {
      lengthScore = 5.0;
    }

    // Total Score Calculation
    int totalScore = (keywordScore + similarityScore + lengthScore).round();
    totalScore = min(max(totalScore, 5), 100);

    // 4. Construct Feedback
    String feedback = "";
    if (totalScore >= 80) {
      feedback = "Excellent response! You explained the concepts clearly, used industry-standard terminology, and provided a detailed answer.";
    } else if (totalScore >= 50) {
      feedback = "Good attempt. Your answer covers some main points, but you could make it stronger by adding more detail and industry terms.";
      if (missedKeywords.isNotEmpty) {
        final samples = missedKeywords.take(3).join(", ");
        feedback += " Try to discuss concepts like: $samples.";
      }
    } else {
      feedback = "Weak response. Your answer is too brief or lacks key technical terms. Study the suggested answer and rewrite using correct technical phrases.";
      if (missedKeywords.isNotEmpty) {
        feedback += " Make sure to cover: ${missedKeywords.join(', ')}.";
      }
    }

    if (wordCount < 15 && totalScore < 80) {
      feedback += " Try to expand on your answer with practical examples to demonstrate deep understanding.";
    }

    return InterviewEvaluationResult(
      score: totalScore,
      feedback: feedback,
      suggestedAnswer: suggestedAnswer,
    );
  }

  /// Helper to tokenize text into a set of words, filtering out common stop words
  Set<String> _tokenize(String text) {
    final stopWords = {
      "a", "an", "the", "and", "or", "but", "is", "are", "was", "were", "of", "to", "in", "on", "at", "for", "with", "by", "that", "this", "it"
    };

    return text
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty && !stopWords.contains(w))
        .toSet();
  }
}
