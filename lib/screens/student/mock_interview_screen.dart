import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/assessment_provider.dart';

class MockInterviewScreen extends ConsumerStatefulWidget {
  final String type;

  const MockInterviewScreen({
    super.key,
    required this.type,
  });

  @override
  ConsumerState<MockInterviewScreen> createState() => _MockInterviewScreenState();
}

class _MockInterviewScreenState extends ConsumerState<MockInterviewScreen> {
  final _answerController = TextEditingController();
  late String _providerType;

  @override
  void initState() {
    super.initState();
    _providerType = widget.type;
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _saveCurrentAnswer(WidgetRef ref, String questionId) {
    ref.read(interviewProvider(_providerType).notifier).saveAnswer(
          questionId,
          _answerController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final interviewState = ref.watch(interviewProvider(_providerType));
    final notifier = ref.read(interviewProvider(_providerType).notifier);

    // Results Mode
    if (interviewState.isCompleted && interviewState.result != null) {
      final res = interviewState.result!;
      return Scaffold(
        appBar: AppBar(
          title: const Text("Interview Feedback"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              ref.invalidate(interviewProvider(_providerType)); // reset state
              context.pop();
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Summary card
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
                        "Mock Interview Score",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        res.feedback,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.4),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                "Diagnostic Question Breakdown",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 12),

              // Scrollable Solutions
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: res.answers.length,
                itemBuilder: (context, idx) {
                  final eval = res.answers[idx];
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
                                  eval.questionText,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: eval.score >= 70 ? Colors.green.shade50 : Colors.orange.shade50,
                                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                                ),
                                child: Text(
                                  "${eval.score}%",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: eval.score >= 70 ? Colors.green : Colors.orange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // User response
                          const Text("Your Answer:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF64748B))),
                          const SizedBox(height: 2),
                          Text(
                            eval.userAnswer.isNotEmpty ? eval.userAnswer : "No answer provided.",
                            style: const TextStyle(fontSize: 12, color: Color(0xFF334155), fontStyle: FontStyle.italic),
                          ),
                          const SizedBox(height: 12),

                          // Evaluation feedback
                          const Text("ATS Evaluation Log:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF2563EB))),
                          const SizedBox(height: 2),
                          Text(
                            eval.feedback,
                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569), height: 1.4),
                          ),
                          const SizedBox(height: 12),

                          // Recommended reference response
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.all(Radius.circular(6)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Ideal Suggested Answer Reference:",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF16A34A)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  eval.suggestedAnswer,
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF334155), height: 1.4),
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
    if (interviewState.isLoading || interviewState.questions.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentIdx = interviewState.currentQuestionIndex;
    final activeQ = interviewState.questions[currentIdx];
    final savedAns = interviewState.answers[activeQ.id] ?? "";

    // Sync input text controller with state if needed
    if (_answerController.text != savedAns && !_answerController.selection.isValid) {
      _answerController.text = savedAns;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("${_providerType.toUpperCase()} Interview Terminal"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // question progress
            Text(
              "Question ${currentIdx + 1} of ${interviewState.questions.length}",
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: (currentIdx + 1) / interviewState.questions.length,
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
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        activeQ.questionText,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Answer Input
                    TextFormField(
                      controller: _answerController,
                      maxLines: 8,
                      decoration: const InputDecoration(
                        hintText: "Type your detailed answer here... (Use correct technical terminology)",
                        labelText: "Your Response",
                        alignLabelWithHint: true,
                      ),
                      onChanged: (val) {
                        _saveCurrentAnswer(ref, activeQ.id);
                      },
                    ),
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
                  onPressed: currentIdx == 0
                      ? null
                      : () {
                          _saveCurrentAnswer(ref, activeQ.id);
                          notifier.previousQuestion();
                          setState(() {
                            _answerController.text = interviewState.answers[interviewState.questions[currentIdx - 1].id] ?? "";
                          });
                        },
                  child: const Text("PREVIOUS"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(minimumSize: const Size(120, 44)),
                  onPressed: () {
                    _saveCurrentAnswer(ref, activeQ.id);
                    if (currentIdx == interviewState.questions.length - 1) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Finish Interview"),
                          content: const Text("Are you sure you have completed answering all questions?"),
                          actions: [
                            TextButton(onPressed: () => context.pop(), child: const Text("CANCEL")),
                            TextButton(
                              onPressed: () {
                                context.pop();
                                notifier.submitInterview();
                              },
                              child: const Text("FINISH"),
                            ),
                          ],
                        ),
                      );
                    } else {
                      notifier.nextQuestion();
                      setState(() {
                        _answerController.text = interviewState.answers[interviewState.questions[currentIdx + 1].id] ?? "";
                      });
                    }
                  },
                  child: Text(currentIdx == interviewState.questions.length - 1 ? "FINISH" : "NEXT"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
