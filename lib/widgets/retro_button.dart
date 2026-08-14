import 'package:flutter/material.dart';
import '../core/theme/retro_borders.dart';
import '../core/theme/retro_colors.dart';
import '../core/theme/retro_typography.dart';

/// Tactile 3D push button styled like classic Winamp and Windows 98/2000/XP hardware keys.
/// Depresses when pressed (flips from outset to inset bevel and shifts child 1px).
class RetroButton extends StatefulWidget {
  const RetroButton({
    super.key,
    required this.onPressed,
    this.label,
    this.icon,
    this.tooltip,
    this.width,
    this.height = 28.0,
    this.isToggled = false,
    this.hasLed = false,
    this.isLedActive = false,
    this.ledColor = RetroColors.vfdGreen,
    this.fontSize = 10.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
  });

  /// Action callback. If null, the button renders as disabled.
  final VoidCallback? onPressed;

  /// Optional text label inside the button.
  final String? label;

  /// Optional icon inside the button.
  final Widget? icon;

  /// Tooltip text on hover.
  final String? tooltip;

  /// Explicit width. If null, sizes to fit content.
  final double? width;

  /// Explicit height. Defaults to 28px.
  final double height;

  /// Whether the button is currently in a toggled/held-down state.
  final bool isToggled;

  /// If true, renders a miniature illuminated status LED dot in the corner or beside label.
  final bool hasLed;

  /// Status of the LED indicator dot.
  final bool isLedActive;

  /// Color of the LED indicator dot.
  final Color ledColor;

  /// Font size for text label.
  final double fontSize;

  /// Inner padding.
  final EdgeInsets padding;

  @override
  State<RetroButton> createState() => _RetroButtonState();
}

class _RetroButtonState extends State<RetroButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null;
    final bool isDepressed = (widget.isToggled || _isPressed) && isEnabled;

    final BoxDecoration decoration = isDepressed
        ? RetroBorders.inset(
            backgroundColor: const Color(0xFF131924),
            highlightColor: RetroColors.bevelHighlight,
            shadowColor: RetroColors.bevelDark,
          )
        : RetroBorders.outset(
            backgroundColor: _isHovered && isEnabled
                ? const Color(0xFF283245)
                : RetroColors.panelSurface,
            highlightColor: _isHovered && isEnabled
                ? const Color(0xFF7A8BA8)
                : RetroColors.bevelHighlight,
            shadowColor: RetroColors.bevelDark,
          );

    Widget content = FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.icon != null) ...[
            widget.icon!,
            if (widget.label != null || widget.hasLed) const SizedBox(width: 4),
          ],
          if (widget.label != null)
            Text(
              widget.label!,
              style: RetroTypography.buttonLabel.copyWith(
                fontSize: widget.fontSize,
                color: isEnabled
                    ? (_isHovered
                        ? Colors.white
                        : RetroColors.textPrimary)
                    : RetroColors.textMuted,
              ),
            ),
          if (widget.hasLed) ...[
            const SizedBox(width: 4),
            _LedDot(isActive: widget.isLedActive, color: widget.ledColor),
          ],
        ],
      ),
    );

    // Apply 1px physical nudge when depressed to simulate real 3D travel
    if (isDepressed) {
      content = Transform.translate(
        offset: const Offset(1, 1),
        child: content,
      );
    }

    Widget button = MouseRegion(
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() {
        _isHovered = false;
        _isPressed = false;
      }),
      child: GestureDetector(
        onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: isEnabled
            ? (_) {
                setState(() => _isPressed = false);
                widget.onPressed?.call();
              }
            : null,
        onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 60),
          width: widget.width,
          height: widget.height,
          padding: widget.padding,
          decoration: decoration,
          alignment: Alignment.center,
          child: content,
        ),
      ),
    );

    if (widget.tooltip != null && widget.tooltip!.isNotEmpty) {
      button = Tooltip(
        message: widget.tooltip!,
        waitDuration: const Duration(milliseconds: 400),
        child: button,
      );
    }

    return button;
  }
}

class _LedDot extends StatelessWidget {
  const _LedDot({
    required this.isActive,
    required this.color,
  });

  final bool isActive;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5.0,
      height: 5.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? color : const Color(0xFF0F2617),
        border: Border.all(
          color: Colors.black87,
          width: 0.5,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.8),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );
  }
}
