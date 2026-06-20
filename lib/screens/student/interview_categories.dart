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
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Select Interview Topic",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: streams.length,
              itemBuilder: (context, index) {
                final str = streams[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 1,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    leading: CircleAvatar(
                      backgroundColor: (str['color'] as Color).withOpacity(0.1),
                      child: Icon(str['icon'] as IconData, color: str['color'] as Color),
                    ),
                    title: Text(
                      str['title'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        str['desc'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
                        ),
                      ),
                    ),
                    trailing: Icon(
                      Icons.play_circle_outline,
                      size: 24,
                      color: Theme.of(context).colorScheme.primary,
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
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        "No mock interviews taken yet. Select a stream above to practice your viva answers!",
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                        textAlign: TextAlign.center,
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
