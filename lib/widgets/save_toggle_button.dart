import 'package:flutter/material.dart';

import '../core/state/app_store.dart';
import '../core/theme/app_colors.dart';

/// Reusable animated save/favorite toggle button.
///
/// Works with [FavoritesController], which tracks a generic set of string
/// ids — so it can back "saved" state for services, jobs, or any future
/// item type without a dedicated controller per feature.
class SaveToggleButton extends StatefulWidget {
  const SaveToggleButton({
    super.key,
    required this.favorites,
    required this.itemId,
    this.savedTooltip = 'Remove from saved',
    this.unsavedTooltip = 'Save',
  });

  final FavoritesController favorites;
  final String itemId;
  final String savedTooltip;
  final String unsavedTooltip;

  @override
  State<SaveToggleButton> createState() => _SaveToggleButtonState();
}

class _SaveToggleButtonState extends State<SaveToggleButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 0.9), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    widget.favorites.toggle(widget.itemId);
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.favorites,
      builder: (context, _) {
        final isSaved = widget.favorites.isFavorite(widget.itemId);
        return ScaleTransition(
          scale: _scaleAnimation,
          child: IconButton(
            onPressed: _toggle,
            tooltip: isSaved ? widget.savedTooltip : widget.unsavedTooltip,
            icon: Icon(
              isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: isSaved ? AppColors.primary : AppColors.textMuted,
            ),
          ),
        );
      },
    );
  }
}
