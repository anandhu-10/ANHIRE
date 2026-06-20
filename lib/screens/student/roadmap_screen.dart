import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/assessment_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/app_drawer.dart';

class RoadmapScreen extends ConsumerStatefulWidget {
  const RoadmapScreen({super.key});

  @override
  ConsumerState<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends ConsumerState<RoadmapScreen> {
  bool _initialized = false;

  void _initRoadmap(WidgetRef ref) {
    if (_initialized) return;
    final profile = ref.read(profileProvider).profile;
    if (profile != null) {
      ref.read(roadmapProvider.notifier).loadRoadmap(profile.preferredRole);
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final profile = profileState.profile;

    if (profile != null) {
      _initRoadmap(ref);
    }

    final roadmapState = ref.watch(roadmapProvider);
    final roadmap = roadmapState.roadmap;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Weekly Roadmap"),
      ),
      drawer: const AppDrawer(),
      body: profileState.isLoading || roadmapState.isLoading || roadmap == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Roadmap info header
                  Text(
                    "Syllabus for ${roadmap.targetRole}",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "This structured 4-week plan focuses on key competencies identified as missing or critical for your target role.",
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
                  ),
                  const SizedBox(height: 20),

                  // Progress Card
                  Card(
                    color: const Color(0xFFEFF6FF),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Roadmap Completion",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)),
                              ),
                              Text(
                                "${(roadmap.completionPercentage * 100).toInt()}%",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2563EB)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: roadmap.completionPercentage,
                            color: const Color(0xFF2563EB),
                            backgroundColor: const Color(0xFFDBEAFE),
                            minHeight: 8,
                            borderRadius: const BorderRadius.all(Radius.circular(4)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 4 Weeks list
                  ...roadmap.weeks.map((week) {
                    final int completedCount = week.topics.where((t) => t.isCompleted).length;
                    final int totalCount = week.topics.length;
                    final double weekProgress = totalCount > 0 ? completedCount / totalCount : 0.0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 1,
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: weekProgress == 1.0 ? Colors.green.shade50 : const Color(0xFFF1F5F9),
                          child: Icon(
                            weekProgress == 1.0 ? Icons.check : Icons.lock_open_outlined,
                            color: weekProgress == 1.0 ? Colors.green : const Color(0xFF2563EB),
                          ),
                        ),
                        title: Text(
                          "Week ${week.weekNumber} preparation",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        subtitle: Text(
                          "$completedCount of $totalCount topics completed (${(weekProgress * 100).toInt()}%)",
                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                        children: week.topics.map((topic) {
                          return CheckboxListTile(
                            title: Text(
                              topic.topicName,
                              style: TextStyle(
                                fontSize: 13,
                                decoration: topic.isCompleted ? TextDecoration.lineThrough : null,
                                color: topic.isCompleted ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
                              ),
                            ),
                            value: topic.isCompleted,
                            activeColor: const Color(0xFF2563EB),
                            controlAffinity: ListTileControlAffinity.leading,
                            onChanged: (val) {
                              ref.read(roadmapProvider.notifier).toggleTopic(
                                    week.weekNumber,
                                    topic.topicName,
                                  );
                            },
                          );
                        }).toList(),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}
