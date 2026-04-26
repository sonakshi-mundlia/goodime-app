import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './providers/auth_provider.dart';
import './screens/home_screen.dart';
import './screens/dashboard_screen.dart';
import './providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsProvider = SettingsProvider();
  await settingsProvider.init();

  final authProvider = AuthProvider();
  await authProvider.init();

  runApp(MyApp(
    settingsProvider: settingsProvider,
    authProvider: authProvider,
  ));
}

// ================= APP =================
class MyApp extends StatelessWidget {
  final SettingsProvider settingsProvider;
  final AuthProvider authProvider;

  const MyApp({
    super.key,
    required this.settingsProvider,
    required this.authProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider.value(value: authProvider),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          final size = MediaQuery.of(context).size;

          // ================= RESPONSIVE SCALE =================
          final isSmall = size.width < 360;
          final isLarge = size.width >= 700;

          final scale = isSmall
              ? 0.90
              : isLarge
              ? 1.15
              : 1.0;

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Goodime AI',
            themeMode: settings.themeMode,
            theme: _lightTheme(scale),
            darkTheme: _darkTheme(scale),
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }

  // ================= LIGHT THEME =================
  ThemeData _lightTheme(double scale) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      textTheme: TextTheme(
        bodyMedium: TextStyle(fontSize: 14 * scale),
        titleMedium: TextStyle(fontSize: 16 * scale),
        titleLarge: TextStyle(fontSize: 20 * scale),
      ),

      colorScheme: const ColorScheme.light(
        primary: Color(0xFF0D47A1),
        secondary: Color(0xFF4A148C),
        surface: Colors.white,
        surfaceContainerHighest: Color(0xFFF1F3F4),
        onSurface: Color(0xFF111827),
      ),

      scaffoldBackgroundColor: const Color(0xFFF8FAFC),

      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 60 * scale,
        titleTextStyle: TextStyle(
          fontSize: 18 * scale,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),

      iconTheme: IconThemeData(size: 22 * scale),
    );
  }

  // ================= DARK THEME =================
  ThemeData _darkTheme(double scale) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      textTheme: TextTheme(
        bodyMedium: TextStyle(fontSize: 14 * scale),
        titleMedium: TextStyle(fontSize: 16 * scale),
        titleLarge: TextStyle(fontSize: 20 * scale),
      ),

      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF90CAF9),
        secondary: Color(0xFFCE93D8),
        surface: Color(0xFF121212),
        surfaceContainerHighest: Color(0xFF1E1E1E),
        onSurface: Colors.white,
      ),

      scaffoldBackgroundColor: const Color(0xFF0F1115),

      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 60 * scale,
        titleTextStyle: TextStyle(
          fontSize: 18 * scale,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      iconTheme: IconThemeData(size: 22 * scale),
    );
  }
}

// ================= AUTH WRAPPER =================
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (auth.isLoggedIn) {
      return const DashboardScreen();
    }

    return const HomeScreen();
  }
}