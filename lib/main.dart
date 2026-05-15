import 'package:flutter/material.dart';

import 'premium/premium_controller.dart';
import 'premium/premium_scope.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const StudyFlowApp());
}

class StudyFlowApp extends StatefulWidget {
  const StudyFlowApp({super.key});

  @override
  State<StudyFlowApp> createState() => _StudyFlowAppState();
}

class _StudyFlowAppState extends State<StudyFlowApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  final PremiumController _premiumController = PremiumController();

  void _changeTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  void dispose() {
    _premiumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScope(
      controller: _premiumController,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'StudyFlow',
        themeMode: _themeMode,
        theme: _lightTheme(),
        darkTheme: _darkTheme(),
        home: HomeScreen(themeMode: _themeMode, onThemeChanged: _changeTheme),
      ),
    );
  }
}

ThemeData _lightTheme() {
  const primary = Color(0xFF7C3AED);

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F7FB),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      foregroundColor: Color(0xFF111827),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
    ),
  );
}

ThemeData _darkTheme() {
  const primary = Color(0xFF8B5CF6);

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF070B17),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      foregroundColor: Colors.white,
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: Color(0xFF0C1224),
      surfaceTintColor: Colors.transparent,
    ),
  );
}
