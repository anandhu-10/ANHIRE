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
          Container(
            padding: const EdgeInsets.only(top: 50, bottom: 24, left: 24, right: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white.withOpacity(0.9),
                  backgroundImage: profile != null && profile.profileImageUrl.isNotEmpty
                      ? NetworkImage(profile.profileImageUrl)
                      : null,
                  child: profile == null || profile.profileImageUrl.isEmpty
                      ? Icon(Icons.person, size: 36, color: Theme.of(context).colorScheme.primary)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile?.fullName.isNotEmpty == true ? profile!.fullName : "Student Account",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        profile?.email ?? ref.read(authProvider).email ?? "",
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (profile != null) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: const BorderRadius.all(Radius.circular(20)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.local_fire_department, color: Colors.amberAccent, size: 14),
                              const SizedBox(width: 3),
                              Text(
                                "${profile.dailyStreak} Days",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Drawer Navigation Items
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: drawerItems.length,
              itemBuilder: (context, index) {
                final item = drawerItems[index];
                final isSelected = GoRouterState.of(context).matchedLocation == item.route;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    child: ListTile(
                      leading: Icon(
                        item.icon,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      title: Text(
                        item.label,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      selected: isSelected,
                      selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                      onTap: () {
                        context.pop(); // Close drawer
                        context.go(item.route); // Navigate
                      },
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(),

          // Logout Action
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              child: ListTile(
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
            ),
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
