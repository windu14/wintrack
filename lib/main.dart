import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wintrack/core/theme/app_theme.dart';
import 'package:wintrack/features/home/presentation/home_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: WintrackApp(),
    ),
  );
}

class WintrackApp extends StatelessWidget {
  const WintrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wintrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
