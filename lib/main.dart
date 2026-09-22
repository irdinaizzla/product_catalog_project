import 'package:flutter/material.dart';

import 'unlock_screen.dart';

void main() {
  runApp(const MyApp());
}

const Color _accent = Color(0xFFFF5A36);

final ColorScheme _catalogColorScheme = const ColorScheme.light(
  primary: Color(0xFF081549),
  onPrimary: Colors.white,
  primaryContainer: Color(0xFF081549),
  onPrimaryContainer: Colors.white,
  secondary: Color(0xFFEDEDED),
  onSecondary: Color(0xFF081549),
  secondaryContainer: Color(0xFFF5F5F5),
  onSecondaryContainer: Color(0xFF081549),
  tertiary: _accent,
  onTertiary: Colors.white,
  surface: Colors.white,
  onSurface: Color(0xFF081549),
  surfaceContainerHighest: Color(0xFFF2F2F2),
  outline: Color(0xFFBDBDBD),
  error: Color(0xFFE53935),
  onError: Colors.white,
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Catalog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: _catalogColorScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: _catalogColorScheme.surface,
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF081549),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: _accent,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF081549),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: _accent),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFFF2F2F2),
          labelStyle: const TextStyle(color: Color(0xFF081549)),
          selectedColor: _accent,
          side: BorderSide.none,
        ),
      ),
      home: const AppGate(),
    );
  }
}

/// Shows the slide-to-unlock splash first, then swaps in the product catalog.
class AppGate extends StatefulWidget {
  const AppGate({super.key});

  @override
  State<AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<AppGate> {
  bool _unlocked = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: UnlockScreen(
        key: const ValueKey('unlock'),
        onUnlocked: () => setState(() => _unlocked = true),
      ),
    );
  }
}