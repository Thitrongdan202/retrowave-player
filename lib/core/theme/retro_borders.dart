import 'package:flutter/material.dart';
import 'retro_colors.dart';

/// 3D Bevel, Inset, and Outset border styles capturing authentic Winamp / Windows XP styling.
class RetroBorders {
  RetroBorders._();

  /// 3D Raised / Outset border (used for buttons, window frames, and physical toggles).
  static BoxDecoration outset({
    Color backgroundColor = RetroColors.panelSurface,
    Color highlightColor = RetroColors.bevelHighlight,
    Color shadowColor = RetroColors.bevelDark,
    double borderWidth = 1.5,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      border: Border(
        top: BorderSide(color: highlightColor, width: borderWidth),
        left: BorderSide(color: highlightColor, width: borderWidth),
        right: BorderSide(color: shadowColor, width: borderWidth),
        bottom: BorderSide(color: shadowColor, width: borderWidth),
      ),
    );
  }

  /// 3D Sunken / Inset border (used for display screens, wells, text boxes, and depressed buttons).
  static BoxDecoration inset({
    Color backgroundColor = RetroColors.wellDark,
    Color highlightColor = RetroColors.bevelHighlight,
    Color shadowColor = RetroColors.bevelDark,
    double borderWidth = 1.5,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      border: Border(
        top: BorderSide(color: shadowColor, width: borderWidth),
        left: BorderSide(color: shadowColor, width: borderWidth),
        right: BorderSide(color: highlightColor, width: borderWidth),
        bottom: BorderSide(color: highlightColor, width: borderWidth),
      ),
    );
  }

  /// Double-beveled frame for complete retro windows and main modules.
  static BoxDecoration windowFrame({
    Color backgroundColor = RetroColors.chassis,
    Color outerHighlight = RetroColors.bevelHighlight,
    Color outerShadow = RetroColors.bevelDark,
    double borderWidth = 1.5,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      border: Border(
        top: BorderSide(color: outerHighlight, width: borderWidth),
        left: BorderSide(color: outerHighlight, width: borderWidth),
        right: BorderSide(color: outerShadow, width: borderWidth),
        bottom: BorderSide(color: outerShadow, width: borderWidth),
      ),
      boxShadow: const [
        BoxShadow(
          color: Colors.black54,
          offset: Offset(4, 6),
          blurRadius: 12,
          spreadRadius: 2,
        ),
      ],
    );
  }

  /// Metallic gradient decoration for window title bars.
  static BoxDecoration titleBar({
    bool isFocused = true,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isFocused
            ? const [
                RetroColors.titleBarHighlight,
                RetroColors.titleBarStart,
                RetroColors.titleBarMid,
                RetroColors.titleBarEnd,
              ]
            : const [
                Color(0xFF333D4F),
                Color(0xFF222834),
                Color(0xFF181D26),
                Color(0xFF10131A),
              ],
        stops: const [0.0, 0.15, 0.85, 1.0],
      ),
      border: const Border(
        bottom: BorderSide(color: RetroColors.bevelDark, width: 1.0),
      ),
    );
  }

  /// VFD dark glass screen container with subtle scanline / CRT glow border.
  static BoxDecoration vfdScreen({
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      color: RetroColors.vfdGlassBg,
      borderRadius: borderRadius ?? BorderRadius.circular(2.0),
      border: Border.all(
        color: RetroColors.vfdGlassBorder,
        width: 1.5,
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x2200E676),
          blurRadius: 6,
          spreadRadius: 1,
        ),
        BoxShadow(
          color: Colors.black87,
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    );
  }
}
