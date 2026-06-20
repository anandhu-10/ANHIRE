import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/trend_chart.dart';
import '../../core/services/pdf_report_service.dart';

class StudentDashboardScreen extends ConsumerWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardProvider);
    final profileState = ref.watch(profileProvider);
    final profile = profileState.profile;

    final double progressPercent = dashboard.readinessScore / 100.0;

    void _exportPdfReport() async {
      if (profile == null) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Generating PDF report on-device...")),
      );

      final pdfService = PdfReportService();
      try {
        final pdfBytes = await pdfService.generateCompleteReport(
          studentName: profile.fullName.isNotEmpty ? profile.fullName : "Student Demo",
          registerNumber: profile.registerNumber.isNotEmpty ? profile.registerNumber : "TVE20CS000",
          collegeName: profile.collegeName.isNotEmpty ? profile.collegeName : "Engineering College",
          branch: profile.branch.isNotEmpty ? profile.branch : "CSE",
          preferredRole: profile.preferredRole,
          cgpa: profile.cgpa,
          resumeScore: dashboard.resumeScore,
          aptitudeScore: dashboard.aptitudeScore,
          interviewScore: dashboard.interviewScore,
          roadmapProgress: dashboard.roadmapCompletion,
          readinessScore: dashboard.readinessScore,
          readinessLevel: dashboard.readinessLevel,
          missingSkills: profile.skills.length > 2 ? [] : ["Data Structures", "SQL Normalization"],
          recommendations: dashboard.recommendedActions,
        );

        await pdfService.printReport(pdfBytes, "ANHIRE_Readiness_Report.pdf");
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to generate PDF: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("ANHIRE"),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined, color: Color(0xFF2563EB)),
            tooltip: "Export Portfolio Report",
            onPressed: _exportPdfReport,
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: dashboard.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(dashboardProvider.notifier).loadDashboard(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Welcome Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Hello, ${profile?.fullName.split(' ').first ?? 'Student'}!",
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const Text(
                                "Here is your preparation progress summary.",
                                style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        // Streak Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                "${dashboard.dailyStreak} Days",
                                style: const TextStyle(
                                  color: Color(0xFFB45309),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Overall Placement Readiness Score Card
                    Card(
                      color: const Color(0xFFEFF6FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(16)),
                        side: BorderSide(color: const Color(0xFF2563EB).withOpacity(0.15), width: 1.5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            // Circular Progress
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  CircularProgressIndicator(
                                    value: progressPercent,
                                    strokeWidth: 8,
                                    backgroundColor: const Color(0xFFDBEAFE),
                                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                                  ),
                                  Center(
                                    child: Text(
                                      "${dashboard.readinessScore}",
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            // Score text info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Placement Readiness Score",
                                    style: TextStyle(
                                      color: Color(0xFF1E293B),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getLevelBadgeColor(dashboard.readinessLevel),
                                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                                    ),
                                    child: Text(
                                      dashboard.readinessLevel.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    "Target: 86+ to be Placement Ready",
                                    style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Grid of module scores
                    const Text(
                      "Preparation Modules",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 10),
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.35,
                      children: [
                        _buildModuleCard(
                          context: context,
                          title: "Resume Score",
                          value: "${dashboard.resumeScore}",
                          subtitle: "ATS Compatibility",
                          icon: Icons.description_outlined,
                          color: Colors.blue,
                          route: "/resume-analyzer",
                        ),
                        _buildModuleCard(
                          context: context,
                          title: "Aptitude Score",
                          value: "${dashboard.aptitudeScore}",
                          subtitle: "Mock Tests",
                          icon: Icons.quiz_outlined,
                          color: Colors.green,
                          route: "/aptitude",
                        ),
                        _buildModuleCard(
                          context: context,
                          title: "Interview Score",
                          value: "${dashboard.interviewScore}",
                          subtitle: "Evaluation",
                          icon: Icons.forum_outlined,
                          color: Colors.purple,
                          route: "/mock-interview",
                        ),
                        _buildModuleCard(
                          context: context,
                          title: "Roadmap Done",
                          value: "${(dashboard.roadmapCompletion * 100).toInt()}%",
                          subtitle: "4-Week Tracker",
                          icon: Icons.map_outlined,
                          color: Colors.orange,
                          route: "/roadmap",
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Trend Line Graph Section (Viva Wow Factor)
                    if (dashboard.trends.isNotEmpty) ...[
                      const Text(
                        "Performance History & Trends",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                      const SizedBox(height: 10),
                      TrendChart(
                        title: "Placement Readiness Growth Trend",
                        dataPoints: dashboard.trends['readiness'] ?? [0, 0, 0, 0, 0],
                        lineColor: const Color(0xFF2563EB),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Recommended Action List
                    Card(
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.orangeAccent),
                                const SizedBox(width: 8),
                                const Text(
                                  "Recommended Actions",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...dashboard.recommendedActions.map((action) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("• ", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                                    Expanded(
                                      child: Text(
                                        action,
                                        style: const TextStyle(fontSize: 12.5, color: Color(0xFF475569), height: 1.4),
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
                    const SizedBox(height: 16),

                    // Recent Activity Log
                    Card(
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Recent Activity Log",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...dashboard.recentActivity.map((activity) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.history, size: 16, color: Color(0xFF64748B)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        activity,
                                        style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
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
                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),
    );
  }

  Color _getLevelBadgeColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return Colors.redAccent;
      case 'intermediate':
        return Colors.orangeAccent;
      case 'advanced':
        return Colors.blueAccent;
      case 'placement ready':
        return Colors.green;
      default:
        return Colors.blueAccent;
    }
  }

  Widget _buildModuleCard({
    required BuildContext context,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return Card(
      elevation: 1,
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        onTap: () => context.go(route),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: color.withOpacity(0.12),
                    child: Icon(icon, size: 18, color: color),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 9.5,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
