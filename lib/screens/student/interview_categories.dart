import 'dart:ui' show PathMetric;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/assessment_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/responsive_scaffold.dart';

class InterviewCategoriesScreen extends ConsumerWidget {
  const InterviewCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(assessmentRepositoryProvider);
    final auth = ref.watch(authProvider);

    final streams = [
      {"id": "hr", "title": "HR Interview", "desc": "Tell me about yourself, career goals, conflicts, teamwork.", "icon": Icons.account_box_outlined, "color": Colors.blue},
      {"id": "flutter", "title": "Flutter Developer Technical", "desc": "Widgets lifecycle, state management, context, keys.", "icon": Icons.phone_android_outlined, "color": Colors.cyan},
      {"id": "python", "title": "Python Developer Technical", "desc": "List comprehensions, decorators, generators, GIL, memory.", "icon": Icons.terminal_outlined, "color": Colors.indigo},
      {"id": "java", "title": "Java Developer Technical", "desc": "JVM structures, multithreading, collections, OOP, interfaces.", "icon": Icons.coffee_outlined, "color": Colors.brown},
      {"id": "dbms", "title": "DBMS Technical Interview", "desc": "ACID properties, B-Tree indices, SQL normalization, Joins.", "icon": Icons.storage_outlined, "color": Colors.teal},
    ];

    return ResponsiveScaffold(
      title: "Mock Interviews",
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Mock Interviews",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Select a topic to start your mock interview session.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 24),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: streams.length,
                  itemBuilder: (context, index) {
                    final str = streams[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: (str['color'] as Color).withOpacity(0.15),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (str['color'] as Color).withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        leading: CircleAvatar(
                          radius: 22,
                          backgroundColor: (str['color'] as Color).withOpacity(0.12),
                          child: Icon(str['icon'] as IconData, color: str['color'] as Color, size: 22),
                        ),
                        title: Text(
                          str['title'] as String,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                            str['desc'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                              height: 1.3,
                            ),
                          ),
                        ),
                        trailing: CircleAvatar(
                          radius: 16,
                          backgroundColor: (str['color'] as Color).withOpacity(0.1),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 11,
                            color: str['color'] as Color,
                          ),
                        ),
                        onTap: () {
                          context.push('/mock-interview-session/${str['id']}');
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                Text(
                  "Interview History",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),

                // Load historical interview reports
                FutureBuilder(
                  future: repo.getInterviewResults(auth.uid ?? "temp_user"),
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
                                "No mock interviews taken yet.",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Select a stream above to practice your viva answers!",
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
                      itemCount: list.length > 5 ? 5 : list.length,
                      itemBuilder: (context, index) {
                        final item = list[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: 0.5,
                          child: ListTile(
                            title: Text(
                              "${item.interviewType.toUpperCase()} Interview",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            subtitle: Text(
                              "Date: ${DateFormat('dd-MMM-yyyy kk:mm').format(item.attemptedAt)}\nFeedback: ${item.feedback}",
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
                                height: 1.3,
                              ),
                            ),
                            trailing: CircleAvatar(
                              backgroundColor: item.score >= 80 ? Colors.green.shade50 : Colors.orange.shade50,
                              radius: 20,
                              child: Text(
                                "${item.score}%",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: item.score >= 80 ? Colors.green : Colors.orange,
                                ),
                              ),
                            ),
                            isThreeLine: true,
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
