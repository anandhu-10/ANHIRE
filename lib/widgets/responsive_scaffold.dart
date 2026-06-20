import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import 'app_drawer.dart';

class ResponsiveScaffold extends ConsumerWidget {
  final Widget body;
  final String title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const ResponsiveScaffold({
    super.key,
    required this.body,
    required this.title,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 900;

    if (!isDesktop) {
      // Mobile & Tablet: Standard Scaffold with Drawer
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: actions,
        ),
        drawer: const AppDrawer(),
        body: SafeArea(child: body),
        floatingActionButton: floatingActionButton,
      );
    }

    // Desktop/Web View: Persistent Sidebar Layout
    final profileState = ref.watch(profileProvider);
    final profile = profileState.profile;
    final authState = ref.watch(authProvider);

    final currentPath = GoRouterState.of(context).matchedLocation;

    final navItems = [
      _NavRouteItem(
        label: "Dashboard",
        route: "/student-dashboard",
        icon: Icons.grid_view_outlined,
        activeIcon: Icons.grid_view_rounded,
      ),
      _NavRouteItem(
        label: "My Profile",
        route: "/profile",
        icon: Icons.person_outline,
        activeIcon: Icons.person,
      ),
      _NavRouteItem(
        label: "Resume Analyzer",
        route: "/resume-analyzer",
        icon: Icons.description_outlined,
        activeIcon: Icons.description,
      ),
      _NavRouteItem(
        label: "Aptitude Tests",
        route: "/aptitude",
        icon: Icons.quiz_outlined,
        activeIcon: Icons.quiz,
      ),
      _NavRouteItem(
        label: "Mock Interviews",
        route: "/mock-interview",
        icon: Icons.chat_bubble_outline_outlined,
        activeIcon: Icons.chat_bubble,
      ),
      _NavRouteItem(
        label: "Learning Roadmap",
        route: "/roadmap",
        icon: Icons.map_outlined,
        activeIcon: Icons.map,
      ),
      _NavRouteItem(
        label: "Leaderboard",
        route: "/leaderboard",
        icon: Icons.emoji_events_outlined,
        activeIcon: Icons.emoji_events,
      ),
    ];

    final primaryColor = Theme.of(context).colorScheme.primary;
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    final sidebarBgColor = Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface;

    return Scaffold(
      body: Row(
        children: [
          // Sleek Sidebar (Fixed width)
          Container(
            width: 270,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF111217) : sidebarBgColor,
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.08),
                  width: 1.5,
                ),
              ),
            ),
            child: Column(
              children: [
                // Header / Brand
                Padding(
                  padding: const EdgeInsets.only(top: 24.0, bottom: 12.0, left: 24.0, right: 24.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryColor, Theme.of(context).colorScheme.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.radar_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [primaryColor, Theme.of(context).colorScheme.secondary],
                          ).createShader(bounds),
                          child: const Text(
                            'ANHIRE',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // User Snapshot Card (Under logo)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF4F46E5), // Indigo
                        Color(0xFF7C3AED), // Purple
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          backgroundImage: profile != null && profile.profileImageUrl.isNotEmpty
                              ? NetworkImage(profile.profileImageUrl)
                              : null,
                          child: profile == null || profile.profileImageUrl.isEmpty
                              ? const Icon(Icons.person, size: 24, color: Colors.white)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        profile?.fullName.isNotEmpty == true ? profile!.fullName : "Alex Johnson",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Beginner Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFFBBF24),
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: 10,
                              color: Color(0xFFFBBF24),
                            ),
                            SizedBox(width: 4),
                            Text(
                              "Beginner",
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFBBF24),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),

                // Navigation Items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: navItems.length,
                    itemBuilder: (context, index) {
                      final item = navItems[index];
                      // Highlight if current path matches or starts with the navigation item's route
                      final isSelected = currentPath == item.route || 
                          (item.route != '/student-dashboard' && currentPath.startsWith(item.route));

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: ListTile(
                            dense: true,
                            leading: Icon(
                              isSelected ? item.activeIcon : item.icon,
                              color: isSelected 
                                  ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : primaryColor)
                                  : onSurfaceColor.withOpacity(0.55),
                              size: 20,
                            ),
                            title: Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected 
                                    ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : primaryColor)
                                    : onSurfaceColor.withOpacity(0.7),
                              ),
                            ),
                            selected: isSelected,
                            selectedTileColor: Theme.of(context).brightness == Brightness.dark 
                                ? const Color(0xFF20222B) 
                                : primaryColor.withOpacity(0.08),
                            onTap: () => context.go(item.route),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const Divider(height: 1),

                // Settings & Logout at the bottom (pinned)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: ListTile(
                          dense: true,
                          leading: Icon(
                            Icons.settings_outlined,
                            size: 20,
                            color: onSurfaceColor.withOpacity(0.55),
                          ),
                          title: Text(
                            "Settings",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: onSurfaceColor.withOpacity(0.7),
                            ),
                          ),
                          onTap: () => context.go("/profile"),
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: ListTile(
                          dense: true,
                          leading: const Icon(
                            Icons.logout,
                            size: 20,
                            color: Colors.redAccent,
                          ),
                          title: const Text(
                            "Logout",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.redAccent,
                            ),
                          ),
                          onTap: () async {
                            await ref.read(authProvider.notifier).logout();
                            if (context.mounted) {
                              context.go("/login");
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Screen Pane (Takes up rest of width)
          Expanded(
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Column(
                children: [
                  // Sleek Top Header Bar
                  Container(
                    height: 70,
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).appBarTheme.backgroundColor,
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).dividerColor.withOpacity(0.04),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).appBarTheme.titleTextStyle?.color ?? onSurfaceColor,
                          ),
                        ),
                        const Spacer(),
                        if (actions != null && actions!.isNotEmpty) ...actions!,
                        if (actions == null || actions!.isEmpty) ...[
                          IconButton(
                            icon: const Icon(Icons.search, size: 20),
                            tooltip: "Search",
                            onPressed: () {},
                          ),
                          const SizedBox(width: 4),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.notifications_none_outlined, size: 22),
                                tooltip: "Notifications",
                                onPressed: () {},
                              ),
                              Positioned(
                                right: 12,
                                top: 12,
                                child: Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: Colors.redAccent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: primaryColor.withOpacity(0.1),
                            backgroundImage: profile != null && profile.profileImageUrl.isNotEmpty
                                ? NetworkImage(profile.profileImageUrl)
                                : null,
                            child: profile == null || profile.profileImageUrl.isEmpty
                                ? Icon(Icons.person, size: 16, color: primaryColor)
                                : null,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Actual Body Content
                  Expanded(
                    child: SafeArea(
                      child: body,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavRouteItem {
  final String label;
  final String route;
  final IconData icon;
  final IconData activeIcon;

  _NavRouteItem({
    required this.label,
    required this.route,
    required this.icon,
    required this.activeIcon,
  });
}
