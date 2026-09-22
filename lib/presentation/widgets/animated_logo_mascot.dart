import 'dart:async';
import 'package:flutter/material.dart';

/// Animated Mascot for Login Screen:
/// 1. Plays native animated WebP ('assets/images/logo_cat_anim.webp') with buffer to ensure
///    the animation completes 100% of its frames before transitioning.
/// 2. Smoothly fades to static logo ('assets/images/appliq_logo.png') for 4 seconds.
/// 3. Cross-fades back and replays from frame 0 in an infinite loop.
class AnimatedLogoMascot extends StatefulWidget {
  final double size;

  const AnimatedLogoMascot({super.key, this.size = 150});

  @override
  State<AnimatedLogoMascot> createState() => _AnimatedLogoMascotState();
}

enum _MascotPhase { animation, staticLogo }

class _AnimatedLogoMascotState extends State<AnimatedLogoMascot> {
  _MascotPhase _phase = _MascotPhase.animation;
  int _animKeyCounter = 0;
  Timer? _phaseTimer;
  bool _isDisposed = false;

  // 4.27s: Exactly matches the 4.02s WebP playback + Flutter decode buffer
  static const Duration _animDuration = Duration(milliseconds: 4270);
  static const Duration _staticHoldDuration = Duration(seconds: 4);
  static const Duration _fadeTransitionDuration = Duration(milliseconds: 400);

  @override
  void initState() {
    super.initState();
    // Ensure clean start from frame 0
    const AssetImage('assets/images/logo_cat_anim.webp').evict();
    _startAnimationCycle();
  }

  void _startAnimationCycle() {
    if (_isDisposed) return;
    _phaseTimer?.cancel();

    // Play WebP animation until the movement is 100% complete
    _phaseTimer = Timer(_animDuration, () {
      if (_isDisposed || !mounted) return;

      // Smoothly switch to official static logo
      setState(() {
        _phase = _MascotPhase.staticLogo;
      });

      // Clear animated WebP stream from memory cache during the static logo phase
      // so that the next cycle starts freshly from Frame 0 (initial entrance)
      const AssetImage('assets/images/logo_cat_anim.webp').evict();

      // Hold static logo for 4 seconds
      _phaseTimer = Timer(_staticHoldDuration, () {
        if (_isDisposed || !mounted) return;

        // Reset and play WebP animation strictly from beginning (Frame 0)
        setState(() {
          _animKeyCounter++;
          _phase = _MascotPhase.animation;
        });

        _startAnimationCycle();
      });
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _phaseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedSwitcher(
        duration: _fadeTransitionDuration,
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        child: _phase == _MascotPhase.animation
            ? Image.asset(
                'assets/images/logo_cat_anim.webp',
                key: ValueKey('anim_$_animKeyCounter'),
                width: widget.size,
                height: widget.size,
                fit: BoxFit.contain,
              )
            : Image.asset(
                'assets/images/appliq_logo.png',
                key: const ValueKey('appliq_static_logo'),
                width: widget.size,
                height: widget.size,
                fit: BoxFit.contain,
              ),
      ),
    );
  }
}
