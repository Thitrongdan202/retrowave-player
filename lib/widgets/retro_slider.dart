import 'package:flutter/material.dart';
import '../core/theme/retro_colors.dart';

/// Grooved retro hardware slider with a sunken track, glowing LED trail, and metallic beveled thumb.
class RetroSlider extends StatefulWidget {
  const RetroSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 1.0,
    this.height = 14.0,
    this.thumbWidth = 10.0,
    this.activeColor = RetroColors.vfdGreen,
    this.inactiveColor = const Color(0xFF0D121B),
  });

  /// Current progress value (between [min] and [max]).
  final double value;

  /// Callback while dragging.
  final ValueChanged<double> onChanged;

  /// Callback when drag concludes.
  final ValueChanged<double>? onChangeEnd;

  final double min;
  final double max;
  final double height;
  final double thumbWidth;
  final Color activeColor;
  final Color inactiveColor;

  @override
  State<RetroSlider> createState() => _RetroSliderState();
}

class _RetroSliderState extends State<RetroSlider> {
  bool _isDragging = false;
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final double range = widget.max - widget.min;
    final double currentVal = _dragValue ?? widget.value;
    final double fraction = range > 0
        ? ((currentVal - widget.min) / range).clamp(0.0, 1.0)
        : 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double trackWidth = constraints.maxWidth;
        final double usableWidth = (trackWidth - widget.thumbWidth).clamp(0.0, double.infinity);
        final double thumbOffset = fraction * usableWidth;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: (details) {
            setState(() {
              _isDragging = true;
              _updateValueFromOffset(details.localPosition.dx, trackWidth);
            });
          },
          onHorizontalDragUpdate: (details) {
            setState(() {
              _updateValueFromOffset(details.localPosition.dx, trackWidth);
            });
          },
          onHorizontalDragEnd: (details) {
            final double finalVal = _dragValue ?? widget.value;
            setState(() {
              _isDragging = false;
              _dragValue = null;
            });
            widget.onChangeEnd?.call(finalVal);
          },
          onTapDown: (details) {
            _updateValueFromOffset(details.localPosition.dx, trackWidth);
            widget.onChangeEnd?.call(_dragValue ?? widget.value);
            setState(() => _dragValue = null);
          },
          child: SizedBox(
            width: trackWidth,
            height: widget.height,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // ── Sunken Track Trough ──────────────────────────────────────
                Container(
                  width: trackWidth,
                  height: 6.0,
                  decoration: BoxDecoration(
                    color: widget.inactiveColor,
                    border: const Border(
                      top: BorderSide(color: RetroColors.bevelDark, width: 1.0),
                      left: BorderSide(color: RetroColors.bevelDark, width: 1.0),
                      right: BorderSide(color: RetroColors.bevelHighlight, width: 0.5),
                      bottom: BorderSide(color: RetroColors.bevelHighlight, width: 0.5),
                    ),
                  ),
                  child: Stack(
                    children: [
                      // LED Illuminated Progress Fill
                      FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: fraction,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                widget.activeColor.withValues(alpha: 0.6),
                                widget.activeColor,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: widget.activeColor.withValues(alpha: 0.5),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Beveled Metallic Thumb ───────────────────────────────────
                Positioned(
                  left: thumbOffset,
                  child: Container(
                    width: widget.thumbWidth,
                    height: widget.height,
                    decoration: BoxDecoration(
                      color: _isDragging
                          ? const Color(0xFF6B7E9C)
                          : const Color(0xFF3F4B5E),
                      border: const Border(
                        top: BorderSide(color: RetroColors.bevelHighlight, width: 1.5),
                        left: BorderSide(color: RetroColors.bevelHighlight, width: 1.5),
                        right: BorderSide(color: RetroColors.bevelDark, width: 1.5),
                        bottom: BorderSide(color: RetroColors.bevelDark, width: 1.5),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black54,
                          offset: Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      // Subtle center line groove on the thumb
                      child: Container(
                        width: 1.5,
                        height: widget.height - 6,
                        color: Colors.black45,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _updateValueFromOffset(double localDx, double trackWidth) {
    final double usableWidth = trackWidth - widget.thumbWidth;
    if (usableWidth <= 0) return;
    final double fraction = (localDx / trackWidth).clamp(0.0, 1.0);
    final double newVal = widget.min + fraction * (widget.max - widget.min);
    _dragValue = newVal;
    widget.onChanged(newVal);
  }
}
