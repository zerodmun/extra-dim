import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'services/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style for immersive dark look
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0A0E21),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Initialize settings
  final settingsService = SettingsService();
  await settingsService.init();

  runApp(ExtraDimApp(settingsService: settingsService));
}

class ExtraDimApp extends StatelessWidget {
  final SettingsService settingsService;

  const ExtraDimApp({super.key, required this.settingsService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Extra Dim',
      debugShowCheckedModeBanner: false,
      theme: _buildDarkTheme(),
      home: HomeScreen(settingsService: settingsService),
    );
  }

  ThemeData _buildDarkTheme() {
    final textTheme = GoogleFonts.interTextTheme(
      ThemeData.dark().textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0A0E21),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFFF6B35),
        secondary: Color(0xFFFFB347),
        surface: Color(0xFF1A1F36),
        error: Color(0xFFFF4757),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF0A0E21),
        elevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1A1F36).withValues(alpha: 0.7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return const Color(0xFF8B95A2);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFFFF6B35);
          }
          return const Color(0xFF252A40);
        }),
      ),
    );
  }
}
