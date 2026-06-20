import 'dart:ui' show PathMetric;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/assessment_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/responsive_scaffold.dart';

class AptitudeCategoriesScreen extends ConsumerStatefulWidget {
  const AptitudeCategoriesScreen({super.key});

  @override
  ConsumerState<AptitudeCategoriesScreen> createState() => _AptitudeCategoriesScreenState();
}

class _AptitudeCategoriesScreenState extends ConsumerState<AptitudeCategoriesScreen> {
  String _selectedDifficulty = "easy";

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(assessmentRepositoryProvider);
    final auth = ref.watch(authProvider);

    final categories = [
      {
        "id": "quantitative",
        "title": "Quantitative Aptitude",
        "desc": "Percentage, Ratios, Time & Work, Probability, Profit & Loss",
        "icon": Icons.calculate_outlined,
        "color": Colors.green,
      },
      {
        "id": "logical",
        "title": "Logical Reasoning",
        "desc": "Coding-Decoding, Blood Relations, Seating Arrangements, Pattern Sequences",
        "icon": Icons.psychology_outlined,
        "color": Colors.blue,
      },
      {
        "id": "verbal",
        "title": "Verbal Ability",
        "desc": "Subject-Verb Agreement, Vocab Synonyms, Reading Comprehension",
        "icon": Icons.translate_outlined,
        "color": Colors.orange,
      },
    ];

    return ResponsiveScaffold(
      title: "Aptitude Preparation",
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Aptitude Preparation",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Choose a category and difficulty level to start practicing.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 24),

                // Difficulty selector buttons
                Row(
                  children: [
                    _buildDifficultyChip("easy", "EASY", Colors.green),
                    const SizedBox(width: 12),
                    _buildDifficultyChip("medium", "MEDIUM", Colors.orange),
                    const SizedBox(width: 12),
                    _buildDifficultyChip("hard", "HARD", Colors.redAccent),
                  ],
                ),
                const SizedBox(height: 24),

                // List of Categories
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: (cat['color'] as Color).withOpacity(0.15),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (cat['color'] as Color).withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        leading: CircleAvatar(
                          radius: 22,
                          backgroundColor: (cat['color'] as Color).withOpacity(0.12),
                          child: Icon(cat['icon'] as IconData, color: cat['color'] as Color, size: 22),
                        ),
                        title: Text(
                          cat['title'] as String,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                            cat['desc'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                              height: 1.3,
                            ),
                          ),
                        ),
                        trailing: CircleAvatar(
                          radius: 16,
                          backgroundColor: (cat['color'] as Color).withOpacity(0.1),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 11,
                            color: cat['color'] as Color,
                          ),
                        ),
                        onTap: () {
                          context.push(
                            '/aptitude-test/${cat['id']}/${_selectedDifficulty}',
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                Text(
                  "Attempt History",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),

                // Attempt History List Loader
                FutureBuilder(
                  future: repo.getAptitudeResults(auth.uid ?? "temp_user"),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final list = snapshot.data ?? [];
                    if (list.isEmpty) {
                      return CustomPaint(
                        painter: DashedBorderPainter(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          borderRadius: 16,
                          strokeWidth: 1.5,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardTheme.color?.withOpacity(0.4) ?? Theme.of(context).colorScheme.surface.withOpacity(0.4),
                            borderRadius: const BorderRadius.all(Radius.circular(16)),
                          ),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                child: Icon(
                                  Icons.assignment_turned_in_outlined,
                                  size: 22,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                "No test attempts yet.",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Select a category above to start your practice!",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: list.length > 5 ? 5 : list.length, // Show last 5
                      itemBuilder: (context, index) {
                        final item = list[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: 0.5,
                          child: ListTile(
                            title: Text(
                              "${item.category.substring(0, 1).toUpperCase()}${item.category.substring(1)} (${item.difficulty.toUpperCase()})",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            subtitle: Text(
                              "Date: ${DateFormat('dd-MMM-yyyy kk:mm').format(item.attemptedAt)} | Time: ${item.timeTakenSeconds}s",
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
                              ),
                            ),
                            trailing: CircleAvatar(
                              backgroundColor: item.score >= 70 ? Colors.green.shade50 : Colors.orange.shade50,
                              radius: 20,
                              child: Text(
                                "${item.score}%",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: item.score >= 70 ? Colors.green : Colors.orange,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyChip(String difficulty, String label, Color activeColor) {
    final isSelected = _selectedDifficulty == difficulty;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedDifficulty = difficulty;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected 
                ? activeColor 
                : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B).withOpacity(0.5) : const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? activeColor : Colors.transparent,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dash;
  final double borderRadius;

  DashedBorderPainter({
    this.color = const Color(0xFF6366F1),
    this.strokeWidth = 1.5,
    this.gap = 5.0,
    this.dash = 5.0,
    this.borderRadius = 16.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    final Path path = Path()..addRRect(rrect);
    final Path dashPath = Path();

    double distance = 0.0;
    // Simple custom metric-free dashing logic for web safety
    final double circumference = 2 * (size.width + size.height);
    bool draw = true;
    double current = 0.0;
    
    // We can use a simpler custom dash line painting logic since PathMetric is supported
    // but this custom pathmetric logic is 100% fine on web and native as proven before
    // import 'dart:ui' show PathMetric is supported.
    // Let's import dart:ui at the top of aptitude_categories.dart to be perfectly safe.
    try {
      for (var measurePath in path.computeMetrics()) {
        double d = 0.0;
        while (d < measurePath.length) {
          dashPath.addPath(
            measurePath.extractPath(d, d + dash),
            Offset.zero,
          );
          d += dash + gap;
        }
      }
      canvas.drawPath(dashPath, paint);
    } catch (_) {
      canvas.drawRRect(rrect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
