import 'package:flutter/material.dart';

/// Layout dimensions, spacing, and sizing metrics for the retro UI.
class RetroMetrics {
  RetroMetrics._();

  // ── Window Metrics ────────────────────────────────────────────────────────
  /// Standard height of retro window title bars.
  static const double titleBarHeight = 26.0;
  
  /// Close/minimize titlebar button dimension.
  static const double titleBarButtonSize = 16.0;

  /// Default compact width for the Main Player window on Desktop.
  static const double mainPlayerWidth = 380.0;
  
  /// Default compact height for the Main Player window on Desktop.
  static const double mainPlayerHeight = 490.0;

  /// Default width for the Playlist window on Desktop.
  static const double playlistWidth = 380.0;
  
  /// Default height for the Playlist window on Desktop.
  static const double playlistHeight = 360.0;

  // ── Button Sizes ──────────────────────────────────────────────────────────
  /// Standard transport button width (Play, Pause, Next, Prev, Stop).
  static const double transportButtonWidth = 44.0;
  static const double transportButtonHeight = 28.0;

  /// Small mode / compact toggle button dimensions.
  static const double miniButtonSize = 22.0;

  // ── Turntable / Vinyl Record ──────────────────────────────────────────────
  static const double vinylDiameter = 170.0;
  static const double vinylLabelDiameter = 62.0;
  static const double vinylSpindleDiameter = 12.0;

  // ── Padding & Spacing ─────────────────────────────────────────────────────
  static const double padXSmall = 4.0;
  static const double padSmall = 8.0;
  static const double padMedium = 12.0;
  static const double padLarge = 16.0;

  static const EdgeInsets windowPadding = EdgeInsets.all(8.0);
  static const EdgeInsets panelPadding = EdgeInsets.all(6.0);
}
