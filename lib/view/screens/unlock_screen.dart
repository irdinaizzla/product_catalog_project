import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A "slide to unlock" splash gate: drag the handle to the end of the track to enter the catalog.
/// Presentational app flow
class UnlockScreen extends StatefulWidget {
  const UnlockScreen({super.key, required this.onUnlocked});

  final VoidCallback onUnlocked;

  @override
  State<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends State<UnlockScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
    lowerBound: 0,
    upperBound: 1,
  );

  bool _unlocking = false;
  double _maxDrag = 1;

  static const double _handleSize = 56;
  static const double _trackPadding = 4;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_unlocking || _maxDrag <= 0) return;
    final next =
    (_controller.value + details.delta.dx / _maxDrag).clamp(0.0, 1.0);
    _controller.value = next;
  }

  Future<void> _onDragEnd(DragEndDetails details) async {
    if (_unlocking) return;
    if (_controller.value >= 0.9) {
      setState(() => _unlocking = true);
      await _controller.animateTo(1, curve: Curves.easeOut);
      widget.onUnlocked();
    } else {
      _controller.animateTo(0, curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final accent = colorScheme.tertiary;
    final ink = colorScheme.onPrimary;

    return Scaffold(
      // Pastel sky-blue-to-pink gradient canvas, dark-ink type for contrast.
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFA9DDF3), // pastel sky blue
              Color(0xFFFFE3EC), // pastel pink-white
            ],
          ),
        ),
        child: Stack(
          children: [
            // Water splash background (behind everything).
            const Positioned.fill(
              child: CustomPaint(painter: _SplashBackgroundPainter()),
            ),
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Icon(Icons.storefront_rounded, size: 64, color: ink),
                  ),
                  const SizedBox(height: 20),
                  _EmbossedTitle(ink: ink),
                  SizedBox(height: 10),
                  Text(
                    'Find your glow',
                    style: TextStyle(
                        color: ink.withValues(alpha: 0.6), fontSize: 14),
                  ),
                  const Spacer(flex: 4),
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        _maxDrag = constraints.maxWidth -
                            _handleSize -
                            _trackPadding * 2;

                        return AnimatedBuilder(
                          animation: _controller,
                          builder: (context, _) {
                            final dragX = _controller.value * _maxDrag;
                            return AnimatedOpacity(
                              opacity: _unlocking ? 0 : 1,
                              duration: const Duration(milliseconds: 150),
                              child: Container(
                                height: _handleSize + _trackPadding * 2,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.55),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: Colors.white),
                                ),
                                child: Stack(
                                  alignment: Alignment.centerLeft,
                                  children: [
                                    Center(
                                      child: Opacity(
                                        opacity: 1 - _controller.value,
                                        child: Text(
                                          'Slide to browse',
                                          style: TextStyle(
                                            color: ink.withValues(alpha: 0.7),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                      const EdgeInsets.all(_trackPadding),
                                      child: GestureDetector(
                                        onHorizontalDragUpdate: _onDragUpdate,
                                        onHorizontalDragEnd: _onDragEnd,
                                        child: Transform.translate(
                                          offset: Offset(dragX, 0),
                                          child: _GlassHandle(
                                            size: _handleSize,
                                            accent: accent,
                                            ink: ink,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-screen bubbles background.
class _SplashBackgroundPainter extends CustomPainter {
  const _SplashBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background bubbles only.
    const bubbles = <List<double>>[
      [0.16, 0.44, 9],
      [0.84, 0.30, 8],
      [0.34, 0.70, 6],
      [0.80, 0.72, 10],
      [0.10, 0.86, 7],
      [0.60, 0.56, 6],
    ];
    for (final b in bubbles) {
      _bubble(canvas, Offset(b[0] * w, b[1] * h), b[2]);
    }
  }

  void _bubble(Canvas canvas, Offset c, double r) {
    canvas.drawCircle(
      c,
      r,
      Paint()..color = Colors.white.withValues(alpha: 0.22),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.white.withValues(alpha: 0.9),
    );
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r * 0.7),
      math.pi * 1.1,
      math.pi * 0.4,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round
        ..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _SplashBackgroundPainter oldDelegate) => false;
}


class _GlassHandle extends StatelessWidget {
  const _GlassHandle({
    required this.size,
    required this.accent,
    required this.ink,
  });

  final double size;
  final Color accent;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.70),
                  accent.withValues(alpha: 0.45),
                  Colors.white.withValues(alpha: 0.20),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.9),
                width: 1.5,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glossy highlight across the top.
                Positioned(
                  top: 4,
                  left: 10,
                  right: 10,
                  height: size * 0.34,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(size),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.75),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_rounded, color: ink),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _EmbossedTitle extends StatelessWidget {
  const _EmbossedTitle({required this.ink});

  final Color ink;

  TextStyle get _style => GoogleFonts.lobsterTwo(
    fontSize: 42,
    fontWeight: FontWeight.w700,
    fontStyle: FontStyle.italic,
    height: 1.0,
    letterSpacing: 0.5,
    color: const Color(0xFFFFF4E8), // warm cream
    shadows: [
      // Top-left light edge.
      Shadow(
        color: Colors.white.withValues(alpha: 0.95),
        offset: const Offset(-1.5, -1.5),
        blurRadius: 1,
      ),
      // Bottom-right pink edge for the raised look.
      Shadow(
        color: const Color(0xFFE08AA0).withValues(alpha: 0.85),
        offset: const Offset(2, 3),
        blurRadius: 3,
      ),
      // Soft drop shadow.
      Shadow(
        color: ink.withValues(alpha: 0.25),
        offset: const Offset(3, 6),
        blurRadius: 10,
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Beauty', style: _style),
        Padding(
          padding: const EdgeInsets.only(),
          child: Text('Essentials', style: _style),
        ),
      ],
    );
  }
}