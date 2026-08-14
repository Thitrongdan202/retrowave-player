import 'package:flutter/material.dart';
import 'retro_colors.dart';

/// Typography styles tailored for the retro XP/Winamp UI.
/// Employs monospace metrics, digital VFD display styles, and compact desktop system labels.
class RetroTypography {
  RetroTypography._();

  /// Large digital clock / time counter in VFD phosphor green with glow.
  static const TextStyle ledTimer = TextStyle(
    fontFamily: 'monospace',
    fontSize: 26,
    fontWeight: FontWeight.w800,
    letterSpacing: 2.0,
    color: RetroColors.vfdGreen,
    shadows: [
      Shadow(color: RetroColors.vfdGreenGlow, blurRadius: 8),
      Shadow(color: RetroColors.vfdGreenDim, blurRadius: 16),
    ],
  );

  /// Medium digital text for track position and song index.
  static const TextStyle ledMedium = TextStyle(
    fontFamily: 'monospace',
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.5,
    color: RetroColors.vfdGreen,
    shadows: [
      Shadow(color: RetroColors.vfdGreenGlow, blurRadius: 4),
    ],
  );

  /// Marquee title & artist text on the main VFD display screen.
  static const TextStyle ledMarquee = TextStyle(
    fontFamily: 'monospace',
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    color: RetroColors.vfdGreen,
    shadows: [
      Shadow(color: RetroColors.vfdGreenGlow, blurRadius: 5),
    ],
  );

  /// Small technical badge indicators (e.g. 320 KBPS, 44.1 KHZ, STEREO).
  static const TextStyle ledBadgeActive = TextStyle(
    fontFamily: 'monospace',
    fontSize: 9.5,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.8,
    color: RetroColors.vfdGreen,
    shadows: [
      Shadow(color: RetroColors.vfdGreenGlow, blurRadius: 4),
    ],
  );

  /// Dim/inactive badge state (ghosted LCD/VFD segment).
  static const TextStyle ledBadgeDim = TextStyle(
    fontFamily: 'monospace',
    fontSize: 9.5,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    color: RetroColors.vfdGreenDim,
  );

  /// Amber / gold LED badge text (e.g., PAUSE, MUTE, EQ).
  static const TextStyle ledAmber = TextStyle(
    fontFamily: 'monospace',
    fontSize: 10,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.0,
    color: RetroColors.amberAccent,
    shadows: [
      Shadow(color: RetroColors.amberAccent, blurRadius: 4),
    ],
  );

  /// Window title bar text (bold, metallic contrast, compact).
  static const TextStyle windowTitle = TextStyle(
    fontFamily: 'monospace',
    fontSize: 11,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.5,
    color: RetroColors.textPrimary,
    shadows: [
      Shadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 1),
    ],
  );

  /// Tactile button micro-label (e.g. [PL], [EQ], [EJECT]).
  static const TextStyle buttonLabel = TextStyle(
    fontFamily: 'monospace',
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    color: RetroColors.textPrimary,
  );

  /// Playlist row title text.
  static const TextStyle playlistItem = TextStyle(
    fontFamily: 'monospace',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    color: RetroColors.textPrimary,
  );

  /// Active currently playing playlist item (highlighted).
  static const TextStyle playlistItemActive = TextStyle(
    fontFamily: 'monospace',
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    color: RetroColors.vfdGreen,
    shadows: [
      Shadow(color: RetroColors.vfdGreenGlow, blurRadius: 4),
    ],
  );

  /// Playlist index & duration labels.
  static const TextStyle playlistSubtext = TextStyle(
    fontFamily: 'monospace',
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: RetroColors.textSecondary,
  );
}
