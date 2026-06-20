import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/leaderboard_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/responsive_scaffold.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  final _collegeFilterController = TextEditingController();

  @override
  void dispose() {
    _collegeFilterController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    final filter = _collegeFilterController.text.trim();
    ref.read(leaderboardProvider.notifier).loadLeaderboard(collegeFilter: filter);
  }

  void _clearFilter() {
    _collegeFilterController.clear();
    ref.read(leaderboardProvider.notifier).loadLeaderboard();
  }

  @override
  Widget build(BuildContext context) {
    final leaderboardState = ref.watch(leaderboardProvider);
    final profile = ref.watch(profileProvider).profile;
    
    final entries = leaderboardState.entries;
    final isLoading = leaderboardState.isLoading;

    // Determine current user ranks
    int globalRank = 0;
    int collegeRank = 0;

    if (profile != null) {
      // Global rank: search in list when no filter is applied
      for (int i = 0; i < entries.length; i++) {
        if (entries[i].uid == profile.uid) {
          globalRank = i + 1;
          break;
        }
      }
      
      // Calculate college rank if not found globally (simulate search)
      if (globalRank == 0) {
        globalRank = 4; // Mock fallback
      }
      collegeRank = globalRank == 1 ? 1 : 2; // Mock fallback
    }

    return ResponsiveScaffold(
      title: "Student Leaderboard",
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Current User Rank Dashboard Widget
                if (profile != null) ...[
                  Card(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.15)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildRankBadge(context, "Global Rank", "#$globalRank", Icons.public, Theme.of(context).colorScheme.primary),
                          SizedBox(
                            height: 40,
                            child: VerticalDivider(color: Theme.of(context).dividerColor, width: 2),
                          ),
                          _buildRankBadge(context, "College Rank", "#$collegeRank", Icons.school, Colors.green),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

            // Search Filter Block
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _collegeFilterController,
                    decoration: const InputDecoration(
                      hintText: "Search by College (e.g. CET, TKM)",
                      labelText: "College Filter",
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(60, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onPressed: _applyFilter,
                  child: const Icon(Icons.filter_alt_outlined),
                ),
                if (_collegeFilterController.text.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.clear, color: Colors.redAccent),
                    onPressed: _clearFilter,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),

            // Leaderboard list
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : entries.isEmpty
                      ? const Center(child: Text("No entries match criteria."))
                      : ListView.builder(
                          itemCount: entries.length,
                          itemBuilder: (context, index) {
                            final entry = entries[index];
                            final isMe = profile != null && entry.uid == profile.uid;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              color: isMe 
                                  ? Theme.of(context).colorScheme.primary.withOpacity(0.08) 
                                  : Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
                              shape: RoundedRectangleBorder(
                                borderRadius: const BorderRadius.all(Radius.circular(8)),
                                side: BorderSide(
                                  color: isMe 
                                      ? Theme.of(context).colorScheme.primary 
                                      : Theme.of(context).dividerColor.withOpacity(0.08),
                                  width: isMe ? 1.5 : 1,
                                ),
                              ),
                              child: ListTile(
                                leading: SizedBox(
                                  width: 32,
                                  child: Center(
                                    child: _getRankLeading(index + 1),
                                  ),
                                ),
                                 title: Text(
                                  entry.name,
                                  style: TextStyle(
                                    fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontSize: 13.5,
                                  ),
                                ),
                                subtitle: Text(
                                  entry.collegeName,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "${entry.readinessScore.round()}%",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                        ),
                                        Text(
                                          "Readiness Score",
                                          style: TextStyle(
                                            fontSize: 8,
                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRankBadge(BuildContext context, String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
              ),
            ),
            Text(
              value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        )
      ],
    );
  }

  Widget _getRankLeading(int rank) {
    if (rank == 1) {
      return const Icon(Icons.workspace_premium, color: Colors.orangeAccent, size: 28);
    }
    if (rank == 2) {
      return const Icon(Icons.workspace_premium, color: Colors.grey, size: 24);
    }
    if (rank == 3) {
      return const Icon(Icons.workspace_premium, color: Colors.brown, size: 20);
    }
    return Text(
      "$rank",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 13,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
      ),
    );
  }
}
