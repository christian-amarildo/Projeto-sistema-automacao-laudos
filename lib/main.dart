import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/mobile/login_page.dart';
import 'features/desktop/inspection_page.dart';

void main() {
  runApp(const ProviderScope(child: ForensiChainApp()));
}

class ForensiChainApp extends StatelessWidget {
  const ForensiChainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: _getHomeWidget(),
    );
  }

  Widget _getHomeWidget() {
    if (kIsWeb) return const LoginPage(); // Web defaults to mobile view for now
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return const InspectionPage();
    } else {
      return const LoginPage();
    }
  }
}
