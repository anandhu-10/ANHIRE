import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/firebase_service.dart';
import 'core/services/local_cache_service.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize local cache boxes (Hive offline database)
  await LocalCacheService.init();

  // 2. Initialize Firebase service (handles setup exceptions gracefully)
  await FirebaseService.initialize();

  runApp(
    const ProviderScope(
      child: AnhireApp(),
    ),
  );
}

class AnhireApp extends ConsumerWidget {
  const AnhireApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'ANHIRE',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Auto detect system theme mode (light/dark)
      routerConfig: router,
    );
  }
}
