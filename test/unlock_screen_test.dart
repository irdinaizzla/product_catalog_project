import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/view/screens/unlock_screen.dart';

void main() {
  Widget wrap(VoidCallback onUnlocked) =>
      MaterialApp(home: UnlockScreen(onUnlocked: onUnlocked));

  testWidgets('a short drag snaps back and does not unlock', (tester) async {
    var unlocked = false;
    await tester.pumpWidget(wrap(() => unlocked = true));

    await tester.drag(find.byIcon(Icons.arrow_forward_rounded), const Offset(40, 0));
    await tester.pumpAndSettle();

    expect(unlocked, isFalse);
  });

  testWidgets('dragging to the end unlocks', (tester) async {
    var unlocked = false;
    await tester.pumpWidget(wrap(() => unlocked = true));

    await tester.drag(find.byIcon(Icons.arrow_forward_rounded), const Offset(700, 0));
    await tester.pumpAndSettle();

    expect(unlocked, isTrue);
  });
}