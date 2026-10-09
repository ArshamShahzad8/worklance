import 'package:flutter/material.dart';

/// Reusable search input with a clear button.
///
/// The parent owns the [controller] and receives every change through
/// [onChanged], so filtering stays in the screen's state.
class AppSearchBar extends StatefulWidget {
  const AppSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hintText = 'Search for services...',
    this.onOpenFullSearch,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hintText;

  /// When provided, a trailing "open full search" icon appears that hands
  /// the current query to the dedicated marketplace search screen
  /// (Week 7) — used on the Home tab so users can search freelancers,
  /// jobs and categories too, not just services.
  final ValueChanged<String>? onOpenFullSearch;

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(AppSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() => setState(() {});

  void _clear() {
    widget.controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      onChanged: widget.onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: widget.controller.text.isEmpty &&
                widget.onOpenFullSearch == null
            ? null
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.controller.text.isNotEmpty)
                    IconButton(
                      onPressed: _clear,
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.close_rounded),
                    ),
                  if (widget.onOpenFullSearch != null)
                    IconButton(
                      onPressed: () =>
                          widget.onOpenFullSearch!(widget.controller.text),
                      tooltip: 'Search everything',
                      icon: const Icon(Icons.arrow_forward_rounded),
                    ),
                ],
              ),
      ),
    );
  }
}
