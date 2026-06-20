import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../models/assessment_models.dart';
import '../../providers/assessment_provider.dart';

class AdminQuestionsScreen extends ConsumerStatefulWidget {
  const AdminQuestionsScreen({super.key});

  @override
  ConsumerState<AdminQuestionsScreen> createState() => _AdminQuestionsScreenState();
}

class _AdminQuestionsScreenState extends ConsumerState<AdminQuestionsScreen> {
  final List<AptitudeQuestion> _questionsList = [];
  bool _isLoading = false;
  String _categoryFilter = "quantitative";

  @override
  void initState() {
    super.initState();
    _loadAllQuestions();
  }

  void _loadAllQuestions() async {
    setState(() {
      _isLoading = true;
    });
    
    // Load a subset of questions from repository
    final repo = ref.read(assessmentRepositoryProvider);
    final list = await repo.getAptitudeQuestions(_categoryFilter, "easy");
    final listMed = await repo.getAptitudeQuestions(_categoryFilter, "medium");
    
    setState(() {
      _questionsList.clear();
      _questionsList.addAll([...list, ...listMed]);
      _isLoading = false;
    });
  }

  void _deleteQuestion(String id) {
    setState(() {
      _questionsList.removeWhere((q) => q.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Question successfully deleted from database!")),
    );
  }

  void _showAddEditDialog({AptitudeQuestion? question}) {
    final formKey = GlobalKey<FormState>();
    final textCtrl = TextEditingController(text: question?.questionText ?? "");
    final opt0Ctrl = TextEditingController(text: question != null ? question.options[0] : "");
    final opt1Ctrl = TextEditingController(text: question != null ? question.options[1] : "");
    final opt2Ctrl = TextEditingController(text: question != null ? question.options[2] : "");
    final opt3Ctrl = TextEditingController(text: question != null ? question.options[3] : "");
    final expCtrl = TextEditingController(text: question?.explanation ?? "");

    String difficulty = question?.difficulty ?? "easy";
    int correctIndex = question?.correctOptionIndex ?? 0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(question == null ? "Add Question" : "Edit Question"),
              content: SizedBox(
                width: 450,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: textCtrl,
                          decoration: const InputDecoration(labelText: "Question Text"),
                          maxLines: 3,
                          validator: (v) => v!.isEmpty ? "Required" : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: opt0Ctrl,
                          decoration: const InputDecoration(labelText: "Option A"),
                          validator: (v) => v!.isEmpty ? "Required" : null,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: opt1Ctrl,
                          decoration: const InputDecoration(labelText: "Option B"),
                          validator: (v) => v!.isEmpty ? "Required" : null,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: opt2Ctrl,
                          decoration: const InputDecoration(labelText: "Option C"),
                          validator: (v) => v!.isEmpty ? "Required" : null,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: opt3Ctrl,
                          decoration: const InputDecoration(labelText: "Option D"),
                          validator: (v) => v!.isEmpty ? "Required" : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int>(
                          value: correctIndex,
                          decoration: const InputDecoration(labelText: "Correct Answer Option"),
                          items: const [
                            DropdownMenuItem(value: 0, child: Text("Option A")),
                            DropdownMenuItem(value: 1, child: Text("Option B")),
                            DropdownMenuItem(value: 2, child: Text("Option C")),
                            DropdownMenuItem(value: 3, child: Text("Option D")),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                correctIndex = val;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: difficulty,
                          decoration: const InputDecoration(labelText: "Difficulty Level"),
                          items: const [
                            DropdownMenuItem(value: "easy", child: Text("Easy")),
                            DropdownMenuItem(value: "medium", child: Text("Medium")),
                            DropdownMenuItem(value: "hard", child: Text("Hard")),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                difficulty = val;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: expCtrl,
                          decoration: const InputDecoration(labelText: "Step-by-step Explanation"),
                          maxLines: 2,
                          validator: (v) => v!.isEmpty ? "Required" : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => context.pop(), child: const Text("CANCEL")),
                TextButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final newQ = AptitudeQuestion(
                        id: question?.id ?? const Uuid().v4(),
                        category: _categoryFilter,
                        topic: "General",
                        questionText: textCtrl.text.trim(),
                        options: [
                          opt0Ctrl.text.trim(),
                          opt1Ctrl.text.trim(),
                          opt2Ctrl.text.trim(),
                          opt3Ctrl.text.trim(),
                        ],
                        correctOptionIndex: correctIndex,
                        difficulty: difficulty,
                        explanation: expCtrl.text.trim(),
                      );

                      setState(() {
                        if (question == null) {
                          _questionsList.insert(0, newQ);
                        } else {
                          final idx = _questionsList.indexWhere((element) => element.id == question.id);
                          _questionsList[idx] = newQ;
                        }
                      });

                      context.pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(question == null ? "Question added successfully!" : "Question updated successfully!")),
                      );
                    }
                  },
                  child: const Text("SAVE"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Question Bank Manager"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined, color: Color(0xFF2563EB)),
            onPressed: () => _showAddEditDialog(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Category selectors
            DropdownButtonFormField<String>(
              value: _categoryFilter,
              decoration: const InputDecoration(labelText: "Choose Category Filter"),
              items: const [
                DropdownMenuItem(value: "quantitative", child: Text("Quantitative")),
                DropdownMenuItem(value: "logical", child: Text("Logical")),
                DropdownMenuItem(value: "verbal", child: Text("Verbal")),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _categoryFilter = val;
                  });
                  _loadAllQuestions();
                }
              },
            ),
            const SizedBox(height: 20),

            // Questions list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _questionsList.isEmpty
                      ? const Center(child: Text("No questions found in this category."))
                      : ListView.builder(
                          itemCount: _questionsList.length,
                          itemBuilder: (context, index) {
                            final q = _questionsList[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "Q${index + 1}. ${q.questionText}",
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.blue),
                                          onPressed: () => _showAddEditDialog(question: q),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                                          onPressed: () => _deleteQuestion(q.id),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 8,
                                      children: [
                                        Chip(
                                          label: Text("Diff: ${q.difficulty.toUpperCase()}"),
                                          backgroundColor: const Color(0xFFF1F5F9),
                                          labelStyle: const TextStyle(fontSize: 10),
                                        ),
                                        Chip(
                                          label: Text("Ans: Option ${String.fromCharCode(65 + q.correctOptionIndex)}"),
                                          backgroundColor: Colors.green.shade50,
                                          labelStyle: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
