import 'package:flutter/material.dart';

import 'view/screens/product_list_screen.dart';
import 'view/screens/unlock_screen.dart';

void main() {
  runApp(const MyApp());
}

// Pastel Paddle Pop palette
const Color _paddlepopBlue = Color(0xFFA9DDF3);   // pastel sky blue
const Color _paddlepopPink = Color(0xFFFFB5C2);   // pastel raspberry
const Color _paddlepopOrange = Color(0xFFFFD3A5); // pastel citrus
const Color _inkNavy = Color(0xFF2B3A67);         // soft navy for text/contrast

final ColorScheme _catalogColorScheme = const ColorScheme.light(
  primary: _paddlepopBlue,
  onPrimary: _inkNavy,
  primaryContainer: _paddlepopBlue,
  onPrimaryContainer: _inkNavy,
  secondary: Color(0xFFFFF3D6), // pastel yellow-cream
  onSecondary: _inkNavy,
  secondaryContainer: Color(0xFFFFF8E8),
  onSecondaryContainer: _inkNavy,
  tertiary: _paddlepopPink,
  onTertiary: _inkNavy,
  surface: Colors.white,
  onSurface: _inkNavy,
  surfaceContainerHighest: Color(0xFFFDF6EC),
  outline: Color(0xFFE0D7C6),
  error: Color(0xFFE58B8B),
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
        appBarTheme: const AppBarTheme(
          backgroundColor: _paddlepopBlue,
          foregroundColor: _inkNavy,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: _paddlepopOrange,
          foregroundColor: _inkNavy,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _paddlepopBlue,
            foregroundColor: _inkNavy,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textButtonTheme: const TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: WidgetStatePropertyAll(_paddlepopPink),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFFFDF6EC),
          labelStyle: const TextStyle(color: _inkNavy),
          selectedColor: _paddlepopOrange,
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
      child: _unlocked
          ? const ProductListScreen(key: ValueKey('catalog'))
          : UnlockScreen(
        key: const ValueKey('unlock'),
        onUnlocked: () => setState(() => _unlocked = true),
      ),
    );
  }
}