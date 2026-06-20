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
        label: "Modules",
        route: "/roadmap",
        icon: Icons.view_module_outlined,
        activeIcon: Icons.view_module,
      ),
      _NavRouteItem(
        label: "Profile",
        route: "/profile",
        icon: Icons.person_outline,
        activeIcon: Icons.person,
      ),
      _NavRouteItem(
        label: "Mentors",
        route: "/mock-interview",
        icon: Icons.people_outline,
        activeIcon: Icons.people,
      ),
      _NavRouteItem(
        label: "Job Alerts",
        route: "/resume-analyzer",
        icon: Icons.notifications_none_outlined,
        activeIcon: Icons.notifications,
      ),
      _NavRouteItem(
        label: "Settings",
        route: "/profile",
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
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
                  padding: const EdgeInsets.only(top: 36.0, bottom: 28.0, left: 24.0, right: 24.0),
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
                          Icons.school,
                          color: Colors.white,
                          size: 24,
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
                              fontSize: 22,
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

                const Divider(height: 1),
                const SizedBox(height: 16),

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
                        padding: const EdgeInsets.symmetric(vertical: 3.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: ListTile(
                            leading: Icon(
                              isSelected ? item.activeIcon : item.icon,
                              color: isSelected 
                                  ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : primaryColor)
                                  : onSurfaceColor.withOpacity(0.55),
                              size: 22,
                            ),
                            title: Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 13.5,
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

                // Profile card & Logout at the bottom
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: primaryColor.withOpacity(0.1),
                        backgroundImage: profile != null && profile.profileImageUrl.isNotEmpty
                            ? NetworkImage(profile.profileImageUrl)
                            : null,
                        child: profile == null || profile.profileImageUrl.isEmpty
                            ? Icon(Icons.person, size: 20, color: primaryColor)
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              profile?.fullName.isNotEmpty == true ? profile!.fullName : "Student",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: onSurfaceColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              profile?.email ?? authState.email ?? "",
                              style: TextStyle(
                                fontSize: 10,
                                color: onSurfaceColor.withOpacity(0.5),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.redAccent, size: 20),
                        tooltip: "Logout",
                        onPressed: () async {
                          await ref.read(authProvider.notifier).logout();
                          if (context.mounted) {
                            context.go("/login");
                          }
                        },
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
