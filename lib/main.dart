import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/mobile/home_mobile.dart';
import 'features/desktop/home_desktop.dart';

void main() {
  runApp(const ProviderScope(child: ForensiChainApp()));
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          // Use defaultTargetPlatform to allow testing with debugDefaultTargetPlatformOverride
          final platform = defaultTargetPlatform;
          if (platform == TargetPlatform.windows ||
              platform == TargetPlatform.linux ||
              platform == TargetPlatform.macOS) {
            return const HomeDesktop();
          } else {
            return const HomeMobile();
          }
        },
      ),
    ],
  );
});

class ForensiChainApp extends ConsumerWidget {
  const ForensiChainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'ForensiChain',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00FF00), // Success/Integrity
          error: Color(0xFFFF0000), // Error/Violation
          surface: Color(0xFF1E1E1E),
          background: Color(0xFF1E1E1E),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
        ),
      ),
      routerConfig: router,
    );
  }
}
