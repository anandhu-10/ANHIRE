import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/assessment_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/responsive_scaffold.dart';

class ResumeAnalyzerScreen extends ConsumerStatefulWidget {
  const ResumeAnalyzerScreen({super.key});

  @override
  ConsumerState<ResumeAnalyzerScreen> createState() => _ResumeAnalyzerScreenState();
}

class _ResumeAnalyzerScreenState extends ConsumerState<ResumeAnalyzerScreen> {
  final _textController = TextEditingController();
  File? _pickedFile;
  String _fileName = "";

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _pickResumeFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx'],
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final sizeMb = file.lengthSync() / (1024 * 1024);
      if (sizeMb > 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("File size exceeds 5 MB limit. Please compress!"),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
      setState(() {
        _pickedFile = file;
        _fileName = result.files.single.name;
      });
    }
  }

  void _triggerAnalysis() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please paste your resume text to execute the ATS evaluation."),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    final profile = ref.read(profileProvider).profile;
    final role = profile?.preferredRole ?? "Software Developer";

    await ref.read(resumeReportProvider.notifier).analyzeResumeText(
          text: text,
          targetRole: role,
          pdfFile: _pickedFile,
        );

    final state = ref.read(resumeReportProvider);
    if (state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Analysis failed: ${state.errorMessage}"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("ATS Audit successfully completed!"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final resumeState = ref.watch(resumeReportProvider);
    final report = resumeState.latestReport;
    final isLoading = resumeState.isLoading;

    return ResponsiveScaffold(
      title: "ATS Resume Analyzer",
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Resume Audit Engine",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Upload your resume PDF to Cloudinary and paste the text contents below to compute your recruiter matching index.",
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // File Picker Block
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color?.withOpacity(0.5) ?? Theme.of(context).colorScheme.surface.withOpacity(0.5),
                          borderRadius: const BorderRadius.all(Radius.circular(16)),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.cloud_upload_outlined,
                              size: 36,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                foregroundColor: Theme.of(context).colorScheme.primary,
                                minimumSize: const Size(180, 40),
                                elevation: 0,
                              ),
                              icon: const Icon(Icons.attach_file, size: 16),
                              label: const Text("Choose PDF / DOCX", style: TextStyle(fontSize: 13)),
                              onPressed: _pickResumeFile,
                            ),
                            if (_fileName.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                "Selected: $_fileName",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ]
                          ],
                        ),
                      ),
                  const SizedBox(height: 20),

                  // Paste Text Area
                  TextFormField(
                    controller: _textController,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      hintText: "Paste your resume plain text here to run rule check...",
                      labelText: "Resume Plain Text",
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: _triggerAnalysis,
                    child: const Text("ANALYZE RESUME"),
                  ),
                  const SizedBox(height: 28),

                  if (report != null) ...[
                    const Divider(),
                    const SizedBox(height: 20),
                    Text(
                      "ATS Audit Findings",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Audit score card
                    Builder(
                      builder: (context) {
                        final isDark = Theme.of(context).brightness == Brightness.dark;
                        final greenBg = isDark ? const Color(0xFF064E3B) : const Color(0xFFF0FDF4);
                        final greenBorder = isDark ? const Color(0xFF059669) : const Color(0xFF86EFAC);
                        final greenText = isDark ? const Color(0xFF34D399) : const Color(0xFF16A34A);

                        return Card(
                          color: greenBg,
                          shape: RoundedRectangleBorder(
                            borderRadius: const BorderRadius.all(Radius.circular(16)),
                            side: BorderSide(color: greenBorder, width: 1.5),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  "${report.score}",
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: greenText,
                                  ),
                                ),
                                Text(
                                  "ATS Compatibility Score",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: greenText,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  report.atsCompatibilityReport,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: Theme.of(context).colorScheme.onSurface,
                                    height: 1.4,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    ),
                    const SizedBox(height: 20),

                    // Contact checklist card
                    Card(
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Recruiter Contact Links",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(height: 12),
                            _buildContactRow(context, "Email Address", report.contactDetailsFound['email'] ?? false),
                            _buildContactRow(context, "Phone Number", report.contactDetailsFound['phone'] ?? false),
                            _buildContactRow(context, "LinkedIn Profile Link", report.contactDetailsFound['linkedin'] ?? false),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Sections & improvements
                    Card(
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "ATS Formatting Recommendations",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(height: 12),
                            ...report.improvementSuggestions.map((suggestion) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 16,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        suggestion,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ],
              ),
            ),
          ),
      ),
    );
  }

  Widget _buildContactRow(BuildContext context, String label, bool found) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            found ? Icons.check_circle : Icons.cancel,
            color: found ? Colors.green : Colors.redAccent,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: found ? FontWeight.bold : FontWeight.normal,
              color: found 
                  ? Theme.of(context).colorScheme.onSurface 
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          )
        ],
      ),
    );
  }
}
