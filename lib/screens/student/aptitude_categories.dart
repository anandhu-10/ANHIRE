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
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Choose Category & Difficulty",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),

            // Difficulty selector buttons
            Row(
              children: [
                _buildDifficultyChip("easy", "EASY", Colors.green),
                const SizedBox(width: 8),
                _buildDifficultyChip("medium", "MEDIUM", Colors.orange),
                const SizedBox(width: 8),
                _buildDifficultyChip("hard", "HARD", Colors.redAccent),
              ],
            ),
            const SizedBox(height: 20),

            // List of Categories
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 1,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    leading: CircleAvatar(
                      backgroundColor: (cat['color'] as Color).withOpacity(0.12),
                      child: Icon(cat['icon'] as IconData, color: cat['color'] as Color),
                    ),
                    title: Text(
                      cat['title'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        cat['desc'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
                        ),
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
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
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        "No test attempts yet. Select a category above to start your practice!",
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
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected ? activeColor.withOpacity(0.1) : Colors.transparent,
          foregroundColor: isSelected ? activeColor : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          side: BorderSide(
            color: isSelected ? activeColor : Theme.of(context).dividerColor,
            width: isSelected ? 1.5 : 1,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
          minimumSize: const Size(0, 38),
        ),
        onPressed: () {
          setState(() {
            _selectedDifficulty = difficulty;
          });
        },
        child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
