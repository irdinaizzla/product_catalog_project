import 'package:flutter/material.dart';

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
    // Pastel raspberry accent on the drag handle so the soft,
    // mostly pastel-blue screen still has a clear focal point.
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
        child: SafeArea(
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
              Text(
                'Product Catalog',
                style: TextStyle(
                  color: ink,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Slide to browse the catalog',
                style: TextStyle(color: ink.withValues(alpha: 0.6), fontSize: 14),
              ),
              const Spacer(flex: 4),
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    _maxDrag =
                        constraints.maxWidth - _handleSize - _trackPadding * 2;

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
                                      'Slide to unlock',
                                      style: TextStyle(
                                        color: ink.withValues(alpha: 0.7),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(_trackPadding),
                                  child: GestureDetector(
                                    onHorizontalDragUpdate: _onDragUpdate,
                                    onHorizontalDragEnd: _onDragEnd,
                                    child: Transform.translate(
                                      offset: Offset(dragX, 0),
                                      child: Container(
                                        width: _handleSize,
                                        height: _handleSize,
                                        decoration: BoxDecoration(
                                          color: accent,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: accent.withValues(
                                                  alpha: 0.45),
                                              blurRadius: 16,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.arrow_forward_rounded,
                                          color: ink,
                                        ),
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
      ),
    );
  }
}