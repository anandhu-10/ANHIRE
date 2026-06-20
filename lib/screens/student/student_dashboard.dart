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
            icon: Icon(Icons.picture_as_pdf_outlined, color: Theme.of(context).colorScheme.primary),
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
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onBackground,
                                ),
                              ),
                              Text(
                                "Here is your preparation progress summary.",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Streak Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.12),
                            borderRadius: const BorderRadius.all(Radius.circular(20)),
                            border: Border.all(color: Colors.orange.withOpacity(0.24)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                "${dashboard.dailyStreak} Days",
                                style: const TextStyle(
                                  color: Colors.orange,
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
                      elevation: 4,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.secondary,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.all(Radius.circular(16)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(22.0),
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
                                      backgroundColor: Colors.white.withOpacity(0.2),
                                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                    Center(
                                      child: Text(
                                        "${dashboard.readinessScore}",
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
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
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.24),
                                        borderRadius: const BorderRadius.all(Radius.circular(6)),
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
                                    const SizedBox(height: 8),
                                    Text(
                                      "Target: 86+ to be Placement Ready",
                                      style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Grid of module scores
                    Text(
                      "Preparation Modules",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.3,
                      children: [
                        _buildModuleCard(
                          context: context,
                          title: "Resume Score",
                          value: "${dashboard.resumeScore}",
                          subtitle: "ATS Compatibility",
                          icon: Icons.description_outlined,
                          color: Theme.of(context).colorScheme.primary,
                          route: "/resume-analyzer",
                        ),
                        _buildModuleCard(
                          context: context,
                          title: "Aptitude Score",
                          value: "${dashboard.aptitudeScore}",
                          subtitle: "Mock Tests",
                          icon: Icons.quiz_outlined,
                          color: Colors.teal,
                          route: "/aptitude",
                        ),
                        _buildModuleCard(
                          context: context,
                          title: "Interview Score",
                          value: "${dashboard.interviewScore}",
                          subtitle: "Evaluation",
                          icon: Icons.forum_outlined,
                          color: Theme.of(context).colorScheme.secondary,
                          route: "/mock-interview",
                        ),
                        _buildModuleCard(
                          context: context,
                          title: "Roadmap Done",
                          value: "${(dashboard.roadmapCompletion * 100).toInt()}%",
                          subtitle: "4-Week Tracker",
                          icon: Icons.map_outlined,
                          color: Theme.of(context).colorScheme.tertiary,
                          route: "/roadmap",
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Trend Line Graph Section (Viva Wow Factor)
                    if (dashboard.trends.isNotEmpty) ...[
                      Text(
                        "Performance History & Trends",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TrendChart(
                        title: "Placement Readiness Growth Trend",
                        dataPoints: dashboard.trends['readiness'] ?? [0, 0, 0, 0, 0],
                        lineColor: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Recommended Action List
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.star, color: Theme.of(context).colorScheme.tertiary),
                                const SizedBox(width: 8),
                                Text(
                                  "Recommended Actions",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSurface,
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
                                    Text("• ", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                                    Expanded(
                                      child: Text(
                                        action,
                                        style: TextStyle(
                                          fontSize: 13,
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
                    const SizedBox(height: 16),

                    // Recent Activity Log
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Recent Activity Log",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...dashboard.recentActivity.map((activity) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: [
                                    Icon(Icons.history, size: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        activity,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
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
                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),
    );
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
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        onTap: () => context.go(route),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: color.withOpacity(0.12),
                    child: Icon(icon, size: 20, color: color),
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
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
