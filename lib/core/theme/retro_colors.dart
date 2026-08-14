import 'package:flutter/material.dart';

/// Palette of colors for the RetroWave XP/Winamp aesthetic.
/// Combines deep space/chassis navy-blacks, metallic gradients, and phosphor VFD green/amber accents.
class RetroColors {
  RetroColors._();

  // ── Chassis & Deep Surfaces ────────────────────────────────────────────────
  /// Deep space black / window workspace background.
  static const Color spaceBlack = Color(0xFF070A0F);
  
  /// Desktop workspace / backdrop grid surface.
  static const Color workspaceBg = Color(0xFF0C1017);
  
  /// Outer hardware chassis / window frame base.
  static const Color chassis = Color(0xFF151B26);
  
  /// Panel / inner module surface (dark blue-gray).
  static const Color panelSurface = Color(0xFF1A2130);
  
  /// Recessed tray / sunken well background.
  static const Color wellDark = Color(0xFF0F141E);

  // ── Metallic Bevels & 3D Shading ──────────────────────────────────────────
  /// Bright top-left specular highlight for 3D raised bevels.
  static const Color bevelHighlight = Color(0xFF5A6982);
  
  /// Soft upper highlight.
  static const Color bevelLight = Color(0xFF3B4659);
  
  /// Neutral body tone for metallic surfaces.
  static const Color bevelMid = Color(0xFF242C3D);
  
  /// Deep bottom-right drop shadow for 3D bevels.
  static const Color bevelShadow = Color(0xFF0A0E15);
  
  /// Jet black inner shadow / cutout edge.
  static const Color bevelDark = Color(0xFF040609);

  // ── Title Bar Metallic Gradient ───────────────────────────────────────────
  static const Color titleBarStart = Color(0xFF2D384D);
  static const Color titleBarMid = Color(0xFF1F2736);
  static const Color titleBarEnd = Color(0xFF161C27);
  static const Color titleBarHighlight = Color(0xFF6B7B96);

  // ── VFD / LED Phosphor Green (Display & Meters) ───────────────────────────
  /// Primary active VFD phosphor green (bright neon).
  static const Color vfdGreen = Color(0xFF39FF14);
  
  /// Secondary bright emerald glow.
  static const Color vfdGreenGlow = Color(0xFF00E676);
  
  /// Muted / inactive LED phosphor green (unlit segments/ghosting).
  static const Color vfdGreenDim = Color(0xFF103A1C);
  
  /// Deep background tint for LED glass window.
  static const Color vfdGlassBg = Color(0xFF030905);
  
  /// Border of the LED screen glass.
  static const Color vfdGlassBorder = Color(0xFF0E2E18);

  // ── Accents & Secondary Colors ────────────────────────────────────────────
  /// Retro amber / gold indicator.
  static const Color amberAccent = Color(0xFFFFB300);
  static const Color amberDim = Color(0xFF4A3400);
  
  /// Cyber cyan / stereo indicator.
  static const Color cyanAccent = Color(0xFF00E5FF);
  static const Color cyanDim = Color(0xFF003840);
  
  /// Spectrum peak red / clipping alert.
  static const Color redPeak = Color(0xFFFF2E56);
  static const Color redDim = Color(0xFF400A15);

  // ── Text & Iconography ────────────────────────────────────────────────────
  /// Crisp primary text (pale silver-blue).
  static const Color textPrimary = Color(0xFFE8EEF5);
  
  /// Secondary text (cool steel gray).
  static const Color textSecondary = Color(0xFF8B98AD);
  
  /// Muted labels / disabled items.
  static const Color textMuted = Color(0xFF4C586B);
  
  /// Text rendered in glowing VFD green.
  static const Color textLed = Color(0xFF39FF14);

  // ── Vinyl Record Specific ─────────────────────────────────────────────────
  static const Color vinylBody = Color(0xFF0D0F13);
  static const Color vinylGroove = Color(0xFF191D24);
  static const Color vinylSheen = Color(0xFF343D4D);
  static const Color vinylLabelBg = Color(0xFF8B0000);
  static const Color vinylSpindle = Color(0xFFC0C8D6);
  static const Color tonearmMetallic = Color(0xFF9EA9BA);
}
