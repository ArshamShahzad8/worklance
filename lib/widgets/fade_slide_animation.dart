import 'dart:async';

import 'package:flutter/material.dart';

/// Wraps a child with a subtle fade-in and upward-slide entrance animation.
///
/// Use [index] to create staggered delays across a list of items.  The
/// animation is automatic and plays once when the widget first builds.
///
/// ```dart
/// FadeSlideAnimation(
///   index: index,
///   child: ServiceCard(...),
/// )
/// ```
class FadeSlideAnimation extends StatefulWidget {
  const FadeSlideAnimation({
    super.key,
    required this.child,
    this.index = 0,
    this.duration = const Duration(milliseconds: 350),
    this.delayPerItem = const Duration(milliseconds: 60),
    this.slideOffset = 20.0,
  });

  /// The widget to animate.
  final Widget child;

  /// Position in a list — controls the stagger delay.
  final int index;

  /// Total duration of the fade/slide for a single item.
  final Duration duration;

  /// Extra delay added per index position.
  final Duration delayPerItem;

  /// How far (in logical pixels) the child slides up from.
  final double slideOffset;

  @override
  State<FadeSlideAnimation> createState() => _FadeSlideAnimationState();
}

class _FadeSlideAnimationState extends State<FadeSlideAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _offset = Tween<Offset>(
      begin: Offset(0, widget.slideOffset / 100),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Stagger: each item starts slightly later.
    final delay = widget.delayPerItem * widget.index;
    _timer = Timer(delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}
