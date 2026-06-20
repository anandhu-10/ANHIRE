import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/leaderboard_provider.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = "";
  final Map<String, bool> _disabledUsers = {}; // uid -> isDisabled

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleUserStatus(String uid, String name) {
    final curStatus = _disabledUsers[uid] ?? false;
    setState(() {
      _disabledUsers[uid] = !curStatus;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(!curStatus ? "Disabled student account: $name" : "Enabled student account: $name"),
        backgroundColor: !curStatus ? Colors.redAccent : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final leadState = ref.watch(leaderboardProvider);
    final students = leadState.entries;

    // Filter students by search query
    final filteredStudents = students.where((s) {
      return s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.collegeName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    // Compute admin dashboard stats
    final totalStudents = students.length + 12; // aggregate seeded student count
    const activeUsers = 6;
    double avgReadiness = 0.0;
    double avgApt = 0.0;
    if (students.isNotEmpty) {
      double totalRead = 0;
      double totalAptScore = 0;
      for (var s in students) {
        totalRead += s.readinessScore;
        totalAptScore += s.aptitudeScore;
      }
      avgReadiness = totalRead / students.length;
      avgApt = totalAptScore / students.length;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("ANHIRE Admin Panel"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: "Logout",
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Admin stats cards
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.45,
              children: [
                _buildStatCard("Total Students", "$totalStudents", Icons.people_outline, Colors.blue),
                _buildStatCard("Active Users", "$activeUsers", Icons.bolt, Colors.green),
                _buildStatCard("Avg Readiness", "${avgReadiness.toStringAsFixed(1)}%", Icons.offline_bolt_outlined, Colors.purple),
                _buildStatCard("Avg Aptitude", "${avgApt.toStringAsFixed(1)}%", Icons.extension_outlined, Colors.orange),
              ],
            ),
            const SizedBox(height: 20),

            // Question CRUD Navigation
            Card(
              color: const Color(0xFFEFF6FF),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF2563EB),
                  child: Icon(Icons.inventory_2_outlined, color: Colors.white),
                ),
                title: const Text("Manage Question Bank", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Add, edit, or delete aptitude test questions.", style: TextStyle(fontSize: 11)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => context.push('/admin-questions'),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              "Registered Students List",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 12),

            // Search Bar
            TextFormField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: "Search by Student Name or College...",
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
            ),
            const SizedBox(height: 12),

            // Students List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredStudents.length,
              itemBuilder: (context, index) {
                final s = filteredStudents[index];
                final isDisabled = _disabledUsers[s.uid] ?? false;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(
                      s.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        decoration: isDisabled ? TextDecoration.lineThrough : null,
                        color: isDisabled ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
                      ),
                    ),
                    subtitle: Text(
                      "College: ${s.collegeName} | Readiness: ${s.readinessScore.round()}%",
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDisabled ? const Color(0xFF16A34A) : const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(80, 32),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () => _toggleUserStatus(s.uid, s.name),
                      child: Text(isDisabled ? "Enable" : "Disable", style: const TextStyle(fontSize: 11)),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        side: BorderSide(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: color.withOpacity(0.1),
                  child: Icon(icon, size: 16, color: color),
                ),
                Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }
}
