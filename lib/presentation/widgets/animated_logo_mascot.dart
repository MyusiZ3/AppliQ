import 'dart:async';
import 'package:flutter/material.dart';
import 'package:appliq/core/constants/app_colors.dart';

/// Animated Mascot for Login Screen:
/// 1. Plays native animated WebP ('assets/images/logo_cat_anim.webp') with buffer to ensure
///    the animation completes 100% of its frames before transitioning.
/// 2. Smoothly fades to static logo ('assets/images/appliq_logo.png') and pulsing elements for 4 seconds.
/// 3. Transitions back to animation with a sleek right-to-left gradient swipe matching theme background.
class AnimatedLogoMascot extends StatefulWidget {
  final double size;

  const AnimatedLogoMascot({super.key, this.size = 150});

  @override
  State<AnimatedLogoMascot> createState() => _AnimatedLogoMascotState();
}

enum _MascotPhase { animation, staticLogo }

class _AnimatedLogoMascotState extends State<AnimatedLogoMascot>
    with SingleTickerProviderStateMixin {
  _MascotPhase _phase = _MascotPhase.animation;
  int _animKeyCounter = 0;
  Timer? _phaseTimer;
  bool _isDisposed = false;
  double _entryOpacity = 0.0;

  late final AnimationController _swipeController;
  late final Animation<double> _swipeProgress;
  bool _isSwiping = false;

  // 4.27s: Exactly matches the 4.02s WebP playback + Flutter decode buffer
  static const Duration _animDuration = Duration(milliseconds: 4270);
  static const Duration _staticHoldDuration = Duration(seconds: 4);
  static const Duration _fadeTransitionDuration = Duration(milliseconds: 400);
  static const Duration _swipeDuration = Duration(milliseconds: 750);

  @override
  void initState() {
    super.initState();
    const AssetImage('assets/images/logo_cat_anim.webp').evict();

    // Right-to-Left Gradient Swipe Curtain Controller
    _swipeController = AnimationController(
      vsync: this,
      duration: _swipeDuration,
    );

    _swipeProgress = CurvedAnimation(
      parent: _swipeController,
      curve: Curves.easeInOutCubic,
    );

    _swipeController.addListener(() {
      // Exactly at midpoint (when curtain 100% covers the mascot), switch to animation from frame 0
      if (_swipeController.value >= 0.5 && _isSwiping && _phase == _MascotPhase.staticLogo) {
        if (mounted && !_isDisposed) {
          setState(() {
            _phase = _MascotPhase.animation;
            _animKeyCounter++;
          });
          const AssetImage('assets/images/logo_cat_anim.webp').evict();
        }
      }
    });

    _swipeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted && !_isDisposed) {
          setState(() {
            _isSwiping = false;
          });
          _swipeController.reset();
        }
      }
    });

    // Smooth initial Fade In on video when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _entryOpacity = 1.0;
        });
      }
    });

    _startAnimationCycle();
  }

  void _startAnimationCycle() {
    if (_isDisposed) return;
    _phaseTimer?.cancel();

    // 1. Play WebP animation until movement is 100% complete
    _phaseTimer = Timer(_animDuration, () {
      if (_isDisposed || !mounted) return;

      // 2. Smoothly switch to official static logo + pulsing elements
      setState(() {
        _phase = _MascotPhase.staticLogo;
      });

      const AssetImage('assets/images/logo_cat_anim.webp').evict();

      // 3. Hold static logo for 4 seconds
      _phaseTimer = Timer(_staticHoldDuration, () {
        if (_isDisposed || !mounted) return;

        // 4. Trigger Right-to-Left Gradient Swipe transition
        setState(() {
          _isSwiping = true;
        });
        _swipeController.forward(from: 0.0);

        _startAnimationCycle();
      });
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _phaseTimer?.cancel();
    _swipeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.background;
    final curtainWidth = widget.size * 2.2;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.hardEdge,
          children: [
            // Mascot / Logo Container
            AnimatedOpacity(
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
                        key: ValueKey('anim_$_animKeyCounter'),
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

            // High-Visibility Gradient Swipe Curtain (Right to Left)
            if (_isSwiping)
              AnimatedBuilder(
                animation: _swipeProgress,
                builder: (context, _) {
                  // Interpolate from right (outside) to left (outside)
                  final leftPos = widget.size - _swipeProgress.value * (widget.size + curtainWidth);

                  return Positioned(
                    left: leftPos,
                    top: -10,
                    bottom: -10,
                    width: curtainWidth,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                          colors: [
                            bgColor.withOpacity(0.0),
                            bgColor.withOpacity(0.6),
                            bgColor,
                            bgColor,
                            bgColor.withOpacity(0.6),
                            bgColor.withOpacity(0.0),
                          ],
                          stops: const [0.0, 0.15, 0.35, 0.65, 0.85, 1.0],
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
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
