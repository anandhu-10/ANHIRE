import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/trend_chart.dart';
import '../../widgets/responsive_scaffold.dart';
import '../../widgets/semi_circular_progress.dart';
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

    return ResponsiveScaffold(
      title: "ANHIRE",
      actions: [
        IconButton(
          icon: Icon(Icons.picture_as_pdf_outlined, color: Theme.of(context).colorScheme.primary),
          tooltip: "Export Portfolio Report",
          onPressed: _exportPdfReport,
        ),
      ],
      body: dashboard.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(dashboardProvider.notifier).loadDashboard(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
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
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF2E26D9), // Royal Indigo
                            Color(0xFF7C3AED), // Violet Purple
                            Color(0xFFDB2777), // Hot Pink
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.all(Radius.circular(20)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7C3AED).withOpacity(0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 28.0),
                        child: Row(
                          children: [
                            // Glowing gauge indicator
                            SemiCircularProgress(
                              percentage: dashboard.readinessScore.toDouble(),
                              size: 130,
                            ),
                            const SizedBox(width: 32),
                            // Score text info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "${profile?.fullName.split(' ').first ?? 'Student'}, You're ${dashboard.readinessScore}% Career Ready!",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Based on your ATS resume score, mock aptitude tests, and roadmap tasks. Boost your odds!",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.85),
                                      fontSize: 13.5,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  Row(
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: Colors.black,
                                          minimumSize: const Size(165, 42),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                        ),
                                        onPressed: () => context.go("/roadmap"),
                                        child: const Text(
                                          "Review Weak Areas",
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          side: const BorderSide(color: Colors.white, width: 1.5),
                                          minimumSize: const Size(140, 42),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                        ),
                                        onPressed: () => context.go("/mock-interview"),
                                        child: const Text(
                                          "Practice Mock",
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                      ),
                                    ],
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
                    Text(
                      "Preparation Modules",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 280,
                        mainAxisExtent: 165,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      children: [
                        _buildModuleCard(
                          context: context,
                          title: "Resume",
                          value: "${dashboard.resumeScore}%",
                          subtitle: dashboard.resumeScore >= 80 
                              ? "Strong, High Impact" 
                              : (dashboard.resumeScore >= 50 ? "Good, Minor Edits" : "Needs Revision"),
                          icon: Icons.description_outlined,
                          color: const Color(0xFF00F2FE), // Bright Cyan
                          route: "/resume-analyzer",
                          progress: dashboard.resumeScore / 100.0,
                        ),
                        _buildModuleCard(
                          context: context,
                          title: "Aptitude",
                          value: "${dashboard.aptitudeScore}%",
                          subtitle: dashboard.aptitudeScore >= 80 
                              ? "Excellent Analytics" 
                              : (dashboard.aptitudeScore >= 50 ? "Good Progress" : "Practice More"),
                          icon: Icons.quiz_outlined,
                          color: const Color(0xFF10B981), // Emerald Green
                          route: "/aptitude",
                          progress: dashboard.aptitudeScore / 100.0,
                        ),
                        _buildModuleCard(
                          context: context,
                          title: "Interview",
                          value: "${dashboard.interviewScore}%",
                          subtitle: dashboard.interviewScore >= 80 
                              ? "Strong Performance" 
                              : (dashboard.interviewScore >= 60 ? "Good Potential" : "Needs Practice"),
                          icon: Icons.forum_outlined,
                          color: const Color(0xFF8B5CF6), // Royal Purple
                          route: "/mock-interview",
                          progress: dashboard.interviewScore / 100.0,
                        ),
                        _buildModuleCard(
                          context: context,
                          title: "Roadmap",
                          value: "${(dashboard.roadmapCompletion * 100).toInt()}%",
                          subtitle: dashboard.roadmapCompletion == 1.0 
                              ? "Ready to Apply" 
                              : "${(4 - dashboard.roadmapCompletion * 4).round()} Weeks Pending",
                          icon: Icons.map_outlined,
                          color: const Color(0xFFF59E0B), // Amber Accent
                          route: "/roadmap",
                          progress: dashboard.roadmapCompletion,
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
    required double progress,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161922) : Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          hoverColor: color.withOpacity(0.04),
          onTap: () => context.go(route),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Row: Icon container & uppercase title side-by-side
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, size: 18, color: color),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: color,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                // Middle: Score percentage
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                // Linear Progress Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(
                      value: progress,
                      color: color,
                      backgroundColor: color.withOpacity(0.12),
                      minHeight: 4,
                      borderRadius: const BorderRadius.all(Radius.circular(2)),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark ? color.withOpacity(0.85) : color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
