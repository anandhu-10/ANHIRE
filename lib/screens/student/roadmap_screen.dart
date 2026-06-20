import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/assessment_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/responsive_scaffold.dart';

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

    return ResponsiveScaffold(
      title: "Weekly Roadmap",
      body: profileState.isLoading || roadmapState.isLoading || roadmap == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Roadmap info header
                      Text(
                        "Syllabus for ${roadmap.targetRole}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "This structured 4-week plan focuses on key competencies identified as missing or critical for your target role.",
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),

                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                            width: 1.5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Roadmap Completion",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    "${(roadmap.completionPercentage * 100).toInt()}%",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: roadmap.completionPercentage,
                                color: Theme.of(context).colorScheme.primary,
                                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
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
                          backgroundColor: weekProgress == 1.0 ? Colors.green.withOpacity(0.12) : Theme.of(context).dividerColor.withOpacity(0.08),
                          child: Icon(
                            weekProgress == 1.0 ? Icons.check : Icons.lock_open_outlined,
                            color: weekProgress == 1.0 ? Colors.green : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        title: Text(
                          "Week ${week.weekNumber} preparation",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        subtitle: Text(
                          "$completedCount of $totalCount topics completed (${(weekProgress * 100).toInt()}%)",
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
                          ),
                        ),
                        children: week.topics.map((topic) {
                          return CheckboxListTile(
                            title: Text(
                              topic.topicName,
                              style: TextStyle(
                                fontSize: 13,
                                decoration: topic.isCompleted ? TextDecoration.lineThrough : null,
                                color: topic.isCompleted 
                                    ? Theme.of(context).colorScheme.onSurface.withOpacity(0.4) 
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            value: topic.isCompleted,
                            activeColor: Theme.of(context).colorScheme.primary,
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
              ),
            ),
    );
  }
}
