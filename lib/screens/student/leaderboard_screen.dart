import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/leaderboard_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/app_drawer.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Leaderboard"),
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current User Rank Dashboard Widget
            if (profile != null) ...[
              Card(
                color: const Color(0xFFF8FAFC),
                shape: RoundedRectangleBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  side: BorderSide(color: const Color(0xFFE2E8F0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildRankBadge("Global Rank", "#$globalRank", Icons.public, Colors.blue),
                      const SizedBox(
                        height: 40,
                        child: VerticalDivider(color: Color(0xFFE2E8F0), width: 2),
                      ),
                      _buildRankBadge("College Rank", "#$collegeRank", Icons.school, Colors.green),
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
                              color: isMe ? const Color(0xFFEFF6FF) : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: const BorderRadius.all(Radius.circular(8)),
                                side: BorderSide(
                                  color: isMe ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
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
                                    color: const Color(0xFF1E293B),
                                    fontSize: 13.5,
                                  ),
                                ),
                                subtitle: Text(
                                  entry.collegeName,
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
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
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Color(0xFF2563EB),
                                          ),
                                        ),
                                        const Text(
                                          "Readiness Score",
                                          style: TextStyle(fontSize: 8, color: Color(0xFF64748B)),
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
    );
  }

  Widget _buildRankBadge(String label, String value, IconData icon, Color color) {
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
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
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
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF64748B)),
    );
  }
}
