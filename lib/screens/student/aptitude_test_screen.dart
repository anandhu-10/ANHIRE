import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/assessment_provider.dart';

class AptitudeTestScreen extends ConsumerWidget {
  final String category;
  final String difficulty;

  const AptitudeTestScreen({
    super.key,
    required this.category,
    required this.difficulty,
  });

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return "${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = AptitudeTestParams(category, difficulty);
    final testState = ref.watch(aptitudeTestProvider(params));
    final notifier = ref.read(aptitudeTestProvider(params).notifier);

    final String title = "${category.substring(0, 1).toUpperCase()}${category.substring(1)} Test";

    // Handle completed state -> Show results
    if (testState.isCompleted && testState.result != null) {
      final res = testState.result!;
      return Scaffold(
        appBar: AppBar(
          title: const Text("Test Results"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              ref.invalidate(aptitudeTestProvider(params)); // reset state
              context.pop();
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Result Card
              Card(
                color: const Color(0xFFEFF6FF),
                shape: RoundedRectangleBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  side: BorderSide(color: const Color(0xFF2563EB).withOpacity(0.2), width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text(
                        "${res.score}%",
                        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                      ),
                      const Text(
                        "Test Score (Accuracy)",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem("Time Taken", "${res.timeTakenSeconds}s"),
                          _buildStatItem("Difficulty", difficulty.toUpperCase()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                "Review Questions & Solutions",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 12),

              // Question Solutions Checklist
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: testState.questions.length,
                itemBuilder: (context, idx) {
                  final q = testState.questions[idx];
                  final userSel = testState.selectedOptions[idx];
                  final isCorrect = userSel != null && userSel == q.correctOptionIndex;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Q${idx + 1}. ",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              Expanded(
                                child: Text(
                                  q.questionText,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)),
                                ),
                              ),
                              Icon(
                                isCorrect ? Icons.check_circle : Icons.cancel,
                                color: isCorrect ? Colors.green : Colors.redAccent,
                                size: 20,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Display options
                          ...List.generate(q.options.length, (optIdx) {
                            final isUserSelected = userSel == optIdx;
                            final isCorrectOpt = q.correctOptionIndex == optIdx;

                            Color optColor = const Color(0xFF1E293B);
                            FontWeight optWeight = FontWeight.normal;
                            if (isCorrectOpt) {
                              optColor = Colors.green;
                              optWeight = FontWeight.bold;
                            } else if (isUserSelected && !isCorrectOpt) {
                              optColor = Colors.redAccent;
                            }

                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isCorrectOpt
                                    ? Colors.green.shade50
                                    : (isUserSelected ? Colors.red.shade50 : Colors.transparent),
                                borderRadius: const BorderRadius.all(Radius.circular(4)),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    "${String.fromCharCode(65 + optIdx)}) ",
                                    style: TextStyle(color: optColor, fontWeight: optWeight, fontSize: 12),
                                  ),
                                  Expanded(
                                    child: Text(
                                      q.options[optIdx],
                                      style: TextStyle(color: optColor, fontWeight: optWeight, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 12),

                          // Explanation Block
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.all(Radius.circular(6)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Explanation:",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF2563EB)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  q.explanation,
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF475569), height: 1.4),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      );
    }

    // Active Test Mode
    if (testState.isLoading || testState.questions.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentIdx = testState.currentQuestionIndex;
    final activeQuestion = testState.questions[currentIdx];
    final selectedOpt = testState.selectedOptions[currentIdx];

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                _formatTime(testState.timeRemainingSeconds),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.redAccent,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Question count indicator
            Text(
              "Question ${currentIdx + 1} of ${testState.questions.length}",
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: (currentIdx + 1) / testState.questions.length,
              color: const Color(0xFF2563EB),
              backgroundColor: const Color(0xFFE2E8F0),
            ),
            const SizedBox(height: 24),

            // Question Card
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      activeQuestion.questionText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Options list
                    ...List.generate(activeQuestion.options.length, (optIdx) {
                      final isSelected = selectedOpt == optIdx;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                          borderRadius: const BorderRadius.all(Radius.circular(8)),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: RadioListTile<int>(
                          value: optIdx,
                          groupValue: selectedOpt,
                          activeColor: const Color(0xFF2563EB),
                          title: Text(
                            activeQuestion.options[optIdx],
                            style: TextStyle(
                              fontSize: 13,
                              color: isSelected ? const Color(0xFF1E293B) : const Color(0xFF475569),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          onChanged: (val) {
                            if (val != null) {
                              notifier.selectOption(currentIdx, val);
                            }
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Navigation panel
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(minimumSize: const Size(100, 44)),
                  onPressed: currentIdx == 0 ? null : () => notifier.previousQuestion(),
                  child: const Text("PREVIOUS"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(minimumSize: const Size(120, 44)),
                  onPressed: () {
                    if (currentIdx == testState.questions.length - 1) {
                      // Confirm dialog before submit
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Submit Test"),
                          content: const Text("Are you sure you want to finish and submit your answers?"),
                          actions: [
                            TextButton(onPressed: () => context.pop(), child: const Text("CANCEL")),
                            TextButton(
                              onPressed: () {
                                context.pop();
                                notifier.submitTest();
                              },
                              child: const Text("SUBMIT"),
                            ),
                          ],
                        ),
                      );
                    } else {
                      notifier.nextQuestion();
                    }
                  },
                  child: Text(currentIdx == testState.questions.length - 1 ? "FINISH" : "NEXT"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
      ],
    );
  }
}
