import 'package:flutter/material.dart';
import '../core/theme/retro_borders.dart';
import '../core/theme/retro_colors.dart';
import '../core/theme/retro_metrics.dart';
import '../core/theme/retro_typography.dart';

/// Winamp / Windows XP-style retro application window frame.
/// Features a metallic title bar with bevels, title icon, close/minimize/maximize buttons,
/// and support for title-bar dragging in a desktop window manager.
class RetroWindow extends StatelessWidget {
  const RetroWindow({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.width,
    this.height,
    this.isFocused = true,
    this.isClosable = true,
    this.isMinimizable = true,
    this.onClose,
    this.onMinimize,
    this.onFocus,
    this.onDrag,
    this.backgroundColor = RetroColors.chassis,
    this.padding = RetroMetrics.windowPadding,
  });

  /// Window title text (e.g. `✦ RETROWAVE PLAYER`).
  final String title;

  /// Main window content.
  final Widget child;

  /// Optional icon placed left of the title.
  final Widget? icon;

  /// Explicit width. If null, sizes to constraints.
  final double? width;

  /// Explicit height. If null, sizes to content.
  final double? height;

  /// Whether this window currently has desktop focus.
  final bool isFocused;

  /// Whether the close button is visible.
  final bool isClosable;

  /// Whether the minimize button is visible.
  final bool isMinimizable;

  /// Callback when close button is clicked.
  final VoidCallback? onClose;

  /// Callback when minimize button is clicked.
  final VoidCallback? onMinimize;

  /// Callback when the window is clicked to gain focus.
  final VoidCallback? onFocus;

  /// Callback for dragging via the title bar.
  final ValueChanged<Offset>? onDrag;

  final Color backgroundColor;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onFocus?.call(),
      child: Container(
        width: width,
        height: height,
        decoration: RetroBorders.windowFrame(backgroundColor: backgroundColor),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Metallic Title Bar ──────────────────────────────────────────
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (details) => onDrag?.call(details.delta),
              child: Container(
                height: RetroMetrics.titleBarHeight,
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                decoration: RetroBorders.titleBar(isFocused: isFocused),
                child: Row(
                  children: [
                    if (icon != null) ...[
                      icon!,
                      const SizedBox(width: 6),
                    ] else ...[
                      const Text(
                        '✦',
                        style: TextStyle(
                          color: RetroColors.amberAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Expanded(
                      child: Text(
                        title.toUpperCase(),
                        style: RetroTypography.windowTitle.copyWith(
                          color: isFocused
                              ? RetroColors.textPrimary
                              : RetroColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Title Bar Action Controls
                    if (isMinimizable) ...[
                      _TitleBarButton(
                        label: '_',
                        tooltip: 'Minimize',
                        onPressed: onMinimize,
                      ),
                      const SizedBox(width: 2),
                    ],
                    if (isClosable) ...[
                      _TitleBarButton(
                        label: '✕',
                        tooltip: 'Close',
                        isClose: true,
                        onPressed: onClose,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ── Sunken Main Window Body ─────────────────────────────────────
            Flexible(
              fit: height != null ? FlexFit.tight : FlexFit.loose,
              child: Container(
                padding: padding,
                decoration: const BoxDecoration(
                  color: RetroColors.chassis,
                ),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TitleBarButton extends StatefulWidget {
  const _TitleBarButton({
    required this.label,
    required this.tooltip,
    this.isClose = false,
    this.onPressed,
  });

  final String label;
  final String tooltip;
  final bool isClose;
  final VoidCallback? onPressed;

  @override
  State<_TitleBarButton> createState() => _TitleBarButtonState();
}

class _TitleBarButtonState extends State<_TitleBarButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    Color bg = const Color(0xFF263042);
    if (_isHovered) {
      bg = widget.isClose ? const Color(0xFFC42B1C) : const Color(0xFF38465F);
    }
    if (_isPressed) {
      bg = widget.isClose ? const Color(0xFF8F1E13) : const Color(0xFF1B222E);
    }

    final decoration = _isPressed
        ? RetroBorders.inset(
            backgroundColor: bg,
            highlightColor: RetroColors.bevelHighlight,
            shadowColor: RetroColors.bevelDark,
          )
        : RetroBorders.outset(
            backgroundColor: bg,
            highlightColor: _isHovered ? const Color(0xFF7B8DA8) : RetroColors.bevelHighlight,
            shadowColor: RetroColors.bevelDark,
          );

    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() {
          _isHovered = false;
          _isPressed = false;
        }),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            widget.onPressed?.call();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: Container(
            width: RetroMetrics.titleBarButtonSize,
            height: RetroMetrics.titleBarButtonSize,
            decoration: decoration,
            alignment: Alignment.center,
            child: Text(
              widget.label,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 9.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
