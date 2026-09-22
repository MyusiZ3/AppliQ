import 'dart:async';
import 'package:flutter/material.dart';

/// Animated Mascot for Login Screen:
/// 1. Plays frame sequence precisely from frame 000 -> frame 097 (never starts from end).
/// 2. Bounces in/out smoothly using Curves.easeOutBack.
/// 3. Switches to static logo (appliq_logo.png) for 4 seconds.
/// 4. Bounces back into frame 000 in an infinite clean loop.
class AnimatedLogoMascot extends StatefulWidget {
  final double size;

  const AnimatedLogoMascot({super.key, this.size = 150});

  @override
  State<AnimatedLogoMascot> createState() => _AnimatedLogoMascotState();
}

enum _MascotPhase { animation, staticLogo }

class _AnimatedLogoMascotState extends State<AnimatedLogoMascot>
    with TickerProviderStateMixin {
  late final AnimationController _frameController;
  late final AnimationController _transitionController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  _MascotPhase _phase = _MascotPhase.animation;
  Timer? _holdTimer;
  bool _isDisposed = false;

  static const int _totalFrames = 98;
  static const Duration _animDuration = Duration(milliseconds: 3920); // ~25 fps
  static const Duration _staticHoldDuration = Duration(seconds: 4);
  static const Duration _transitionDuration = Duration(milliseconds: 450);

  @override
  void initState() {
    super.initState();
    _transitionController = AnimationController(
      vsync: this,
      duration: _transitionDuration,
      value: 1.0,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeInOut,
    );

    // Spring Bounce scale curve
    _scaleAnimation = Tween<double>(begin: 0.86, end: 1.0).animate(
      CurvedAnimation(
        parent: _transitionController,
        curve: Curves.easeOutBack,
      ),
    );

    _frameController = AnimationController(
      vsync: this,
      duration: _animDuration,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _handleAnimationCompleted();
        }
      });

    // Start playing from Frame 0 immediately
    _frameController.forward(from: 0.0);
  }

  void _handleAnimationCompleted() async {
    if (_isDisposed || !mounted) return;

    // 1. Smooth bounce-out / fade-out
    await _transitionController.reverse();
    if (_isDisposed || !mounted) return;

    // 2. Switch to static logo
    setState(() {
      _phase = _MascotPhase.staticLogo;
    });

    // 3. Bounce-in / fade-in static logo
    _transitionController.forward();

    // 4. Hold static logo for 4 seconds
    _holdTimer?.cancel();
    _holdTimer = Timer(_staticHoldDuration, () async {
      if (_isDisposed || !mounted) return;

      // 5. Smooth bounce-out / fade-out static logo
      await _transitionController.reverse();
      if (_isDisposed || !mounted) return;

      // 6. Switch back to animation and explicitly reset to Frame 0
      setState(() {
        _phase = _MascotPhase.animation;
      });
      _frameController.reset();

      // 7. Bounce-in / fade-in animation and play forward from Frame 0
      _transitionController.forward();
      _frameController.forward(from: 0.0);
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _holdTimer?.cancel();
    _frameController.dispose();
    _transitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _transitionController,
        builder: (context, _) {
          return Opacity(
            opacity: _fadeAnimation.value.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: _phase == _MascotPhase.staticLogo
                  ? Image.asset(
                      'assets/images/appliq_logo.png',
                      width: widget.size,
                      height: widget.size,
                      fit: BoxFit.contain,
                    )
                  : AnimatedBuilder(
                      animation: _frameController,
                      builder: (context, _) {
                        final frameIndex = (_frameController.value * (_totalFrames - 1))
                            .round()
                            .clamp(0, _totalFrames - 1);
                        final framePadded = frameIndex.toString().padLeft(3, '0');

                        return Image.asset(
                          'assets/images/cat_frames/frame_$framePadded.png',
                          width: widget.size,
                          height: widget.size,
                          fit: BoxFit.contain,
                          gaplessPlayback: true,
                        );
                      },
                    ),
            ),
          );
        },
      ),
    );
  }
}
