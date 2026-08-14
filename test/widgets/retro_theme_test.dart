import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retrowave_player/core/theme/retro_borders.dart';
import 'package:retrowave_player/core/theme/retro_colors.dart';
import 'package:retrowave_player/core/theme/retro_metrics.dart';
import 'package:retrowave_player/core/theme/retro_typography.dart';

void main() {
  group('RetroColors tests', () {
    test('defines required retro palette values', () {
      expect(RetroColors.vfdGreen, isA<Color>());
      expect(RetroColors.amberAccent, isA<Color>());
      expect(RetroColors.cyanAccent, isA<Color>());
      expect(RetroColors.chassis, isA<Color>());
      expect(RetroColors.workspaceBg, isA<Color>());
    });
  });

  group('RetroTypography tests', () {
    test('uses monospace font family for all retro styles', () {
      expect(RetroTypography.ledTimer.fontFamily, 'monospace');
      expect(RetroTypography.ledMarquee.fontFamily, 'monospace');
      expect(RetroTypography.windowTitle.fontFamily, 'monospace');
      expect(RetroTypography.buttonLabel.fontFamily, 'monospace');
    });
  });

  group('RetroBorders tests', () {
    test('creates outset and inset bevel decorations', () {
      final outset = RetroBorders.outset();
      expect(outset.border, isNotNull);
      expect(outset.border!.top.color, RetroColors.bevelHighlight);
      expect(outset.border!.bottom.color, RetroColors.bevelDark);

      final inset = RetroBorders.inset();
      expect(inset.border, isNotNull);
      expect(inset.border!.top.color, RetroColors.bevelDark);
      expect(inset.border!.bottom.color, RetroColors.bevelHighlight);
    });

    test('creates titleBar decoration with gradient', () {
      final titleBarDeco = RetroBorders.titleBar(isFocused: true);
      expect(titleBarDeco.gradient, isA<LinearGradient>());
    });
  });

  group('RetroMetrics tests', () {
    test('verifies standard desktop and button dimensions', () {
      expect(RetroMetrics.titleBarHeight, 26.0);
      expect(RetroMetrics.mainPlayerWidth, 380.0);
      expect(RetroMetrics.playlistWidth, 380.0);
      expect(RetroMetrics.transportButtonHeight, 28.0);
    });
  });
}
