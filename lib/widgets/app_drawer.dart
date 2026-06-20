import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final profile = profileState.profile;

    final List<_DrawerItem> drawerItems = [
      _DrawerItem(icon: Icons.dashboard_outlined, label: "Dashboard", route: "/student-dashboard"),
      _DrawerItem(icon: Icons.person_outline, label: "My Profile", route: "/profile"),
      _DrawerItem(icon: Icons.description_outlined, label: "Resume Analyzer", route: "/resume-analyzer"),
      _DrawerItem(icon: Icons.quiz_outlined, label: "Aptitude Tests", route: "/aptitude"),
      _DrawerItem(icon: Icons.forum_outlined, label: "Mock Interviews", route: "/mock-interview"),
      _DrawerItem(icon: Icons.map_outlined, label: "Learning Roadmap", route: "/roadmap"),
      _DrawerItem(icon: Icons.leaderboard_outlined, label: "Leaderboard", route: "/leaderboard"),
    ];

    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF2563EB),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: profile != null && profile.profileImageUrl.isNotEmpty
                  ? NetworkImage(profile.profileImageUrl)
                  : null,
              child: profile == null || profile.profileImageUrl.isEmpty
                  ? const Icon(Icons.person, size: 40, color: Color(0xFF2563EB))
                  : null,
            ),
            accountName: Text(
              profile?.fullName.isNotEmpty == true ? profile!.fullName : "Student Account",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            accountEmail: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile?.email ?? ref.read(authProvider).email ?? ""),
                const SizedBox(height: 4),
                if (profile != null)
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department, color: Colors.orange, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        "${profile.dailyStreak} Day Streak",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Drawer Navigation Items
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: drawerItems.length,
              itemBuilder: (context, index) {
                final item = drawerItems[index];
                final isSelected = GoRouterState.of(context).matchedLocation == item.route;

                return ListTile(
                  leading: Icon(
                    item.icon,
                    color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                  ),
                  title: Text(
                    item.label,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF1E293B),
                    ),
                  ),
                  selected: isSelected,
                  selectedTileColor: const Color(0xFFEFF6FF),
                  onTap: () {
                    context.pop(); // Close drawer
                    context.go(item.route); // Navigate
                  },
                );
              },
            ),
          ),

          const Divider(),

          // Logout Action
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              context.pop(); // Close drawer
              await ref.read(authProvider.notifier).logout();
              context.go("/login"); // Redirect
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _DrawerItem {
  final IconData icon;
  final String label;
  final String route;

  _DrawerItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}
