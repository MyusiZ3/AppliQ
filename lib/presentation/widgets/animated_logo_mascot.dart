import 'dart:async';
import 'package:flutter/material.dart';

/// Animated Mascot for Login Screen:
/// 1. Plays native animated WebP ('assets/images/logo_cat_anim.webp') once upon screen entry.
/// 2. Smoothly fades into the official static logo ('assets/images/appliq_logo.png') with pulsing element.
/// 3. Stays permanently on the static logo without looping back.
class AnimatedLogoMascot extends StatefulWidget {
  final double size;

  const AnimatedLogoMascot({super.key, this.size = 150});

  @override
  State<AnimatedLogoMascot> createState() => _AnimatedLogoMascotState();
}

enum _MascotPhase { animation, staticLogo }

class _AnimatedLogoMascotState extends State<AnimatedLogoMascot> {
  _MascotPhase _phase = _MascotPhase.animation;
  Timer? _phaseTimer;
  bool _isDisposed = false;
  double _entryOpacity = 0.0;

  // 4.27s: Matches the WebP playback + Flutter decode buffer
  static const Duration _animDuration = Duration(milliseconds: 4270);
  static const Duration _fadeTransitionDuration = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    const AssetImage('assets/images/logo_cat_anim.webp').evict();

    // Smooth initial Fade In when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _entryOpacity = 1.0;
        });
      }
    });

    // Play intro animation once, then permanently transition to static logo
    _phaseTimer = Timer(_animDuration, () {
      if (_isDisposed || !mounted) return;
      setState(() {
        _phase = _MascotPhase.staticLogo;
      });
      const AssetImage('assets/images/logo_cat_anim.webp').evict();
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedOpacity(
          opacity: _entryOpacity,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeIn,
          child: AnimatedSwitcher(
            duration: _fadeTransitionDuration,
            reverseDuration: const Duration(milliseconds: 400),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: _phase == _MascotPhase.animation
                ? Image.asset(
                    'assets/images/logo_cat_anim.webp',
                    key: const ValueKey('mascot_intro_anim'),
                    width: widget.size,
                    height: widget.size,
                    fit: BoxFit.contain,
                  )
                : Stack(
                    key: const ValueKey('appliq_static_logo'),
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/images/appliq_logo.png',
                        width: widget.size,
                        height: widget.size,
                        fit: BoxFit.contain,
                      ),
                      _PulsingElement(size: widget.size),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Floating UI elements layer with a breathing/blinking fade animation
class _PulsingElement extends StatefulWidget {
  final double size;
  const _PulsingElement({required this.size});

  @override
  State<_PulsingElement> createState() => _PulsingElementState();
}

class _PulsingElementState extends State<_PulsingElement>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.25, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _pulseAnimation.value,
          child: child,
        );
      },
      child: Image.asset(
        'assets/images/appliq_element.png',
        width: widget.size,
        height: widget.size,
        fit: BoxFit.contain,
      ),
    );
  }
}
