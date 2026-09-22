import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Animated Mascot for Login Screen:
/// Plays video animation (logo_cat_anim.webm), smoothly fades to static logo for 4s,
/// and repeats smoothly.
class AnimatedLogoMascot extends StatefulWidget {
  final double size;

  const AnimatedLogoMascot({super.key, this.size = 150});

  @override
  State<AnimatedLogoMascot> createState() => _AnimatedLogoMascotState();
}

class _AnimatedLogoMascotState extends State<AnimatedLogoMascot> {
  VideoPlayerController? _videoController;
  bool _showVideo = true;
  bool _isVideoInitialized = false;
  Timer? _staticTimer;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      final controller =
          VideoPlayerController.asset('assets/videos/logo_cat_anim.webm');
      _videoController = controller;

      await controller.initialize();
      if (_isDisposed) {
        controller.dispose();
        return;
      }

      controller.setVolume(0.0);
      controller.setLooping(false);

      controller.addListener(_videoListener);

      setState(() {
        _isVideoInitialized = true;
        _showVideo = true;
      });

      await controller.play();
    } catch (_) {
      // Fallback to static logo if video fails to load
      if (!_isDisposed && mounted) {
        setState(() {
          _isVideoInitialized = false;
          _showVideo = false;
        });
      }
    }
  }

  void _videoListener() {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) return;

    // Check if video reached its end
    if (controller.value.position >= controller.value.duration &&
        !controller.value.isPlaying &&
        _showVideo) {
      _handleVideoEnded();
    }
  }

  void _handleVideoEnded() {
    if (_isDisposed || !mounted) return;

    // Fade to static logo
    setState(() {
      _showVideo = false;
    });

    // Hold static logo for 4 seconds, then fade back to video and replay
    _staticTimer?.cancel();
    _staticTimer = Timer(const Duration(seconds: 4), () async {
      if (_isDisposed || !mounted) return;

      final controller = _videoController;
      if (controller != null && controller.value.isInitialized) {
        await controller.seekTo(Duration.zero);
        if (_isDisposed || !mounted) return;

        setState(() {
          _showVideo = true;
        });

        await controller.play();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _staticTimer?.cancel();
    _videoController?.removeListener(_videoListener);
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        child: (_isVideoInitialized && _showVideo && _videoController != null)
            ? KeyedSubtree(
                key: const ValueKey('video_mascot'),
                child: SizedBox(
                  width: widget.size,
                  height: widget.size,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(
                      width: _videoController!.value.size.width > 0
                          ? _videoController!.value.size.width
                          : widget.size,
                      height: _videoController!.value.size.height > 0
                          ? _videoController!.value.size.height
                          : widget.size,
                      child: VideoPlayer(_videoController!),
                    ),
                  ),
                ),
              )
            : KeyedSubtree(
                key: const ValueKey('static_mascot'),
                child: Image.asset(
                  'assets/images/appliq_logo.png',
                  width: widget.size,
                  height: widget.size,
                  fit: BoxFit.contain,
                ),
              ),
      ),
    );
  }
}
