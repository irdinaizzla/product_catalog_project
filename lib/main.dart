import 'package:flutter/material.dart';

import 'unlock_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Catalog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AppGate(),
    );
  }
}

/// Shows the slide-to-unlock splash first, then swaps in the product
/// catalog. Kept as its own tiny widget so main.dart stays a clean entry
/// point and the "unlock" step can be changed independently later.
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