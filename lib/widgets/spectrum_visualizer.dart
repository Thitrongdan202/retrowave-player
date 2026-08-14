import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/retro_colors.dart';

/// Winamp-style 20-band spectrum visualizer with segmented LED bars (green->yellow->red)
/// and gravity-decaying peak hold needles.
class SpectrumVisualizer extends StatefulWidget {
  const SpectrumVisualizer({
    super.key,
    required this.isPlaying,
    this.height = 36.0,
    this.bandCount = 20,
    this.audioAmplitude = 0.8,
  });

  /// True when audio is actively playing; animates bars and peak drops.
  final bool isPlaying;

  /// Height of the visualizer module.
  final double height;

  /// Number of frequency equalizer bands.
  final int bandCount;

  /// Overall amplitude scale factor.
  final double audioAmplitude;

  @override
  State<SpectrumVisualizer> createState() => _SpectrumVisualizerState();
}

class _SpectrumVisualizerState extends State<SpectrumVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late List<double> _bandHeights;
  late List<double> _peakHeights;
  late List<double> _peakVelocities;
  final math.Random _random = math.Random();
  double _phase = 0.0;

  @override
  void initState() {
    super.initState();
    _bandHeights = List.filled(widget.bandCount, 0.0);
    _peakHeights = List.filled(widget.bandCount, 0.0);
    _peakVelocities = List.filled(widget.bandCount, 0.0);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..addListener(_updateBands);

    if (widget.isPlaying) {
      _animController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant SpectrumVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_animController.isAnimating) {
      _animController.repeat();
    } else if (!widget.isPlaying && _animController.isAnimating) {
      _animController.stop();
      _decayToZero();
    }
  }

  void _decayToZero() {
    setState(() {
      for (int i = 0; i < widget.bandCount; i++) {
        _bandHeights[i] = 0.0;
        _peakHeights[i] = 0.0;
      }
    });
  }

  void _updateBands() {
    if (!widget.isPlaying) return;

    _phase += 0.08;
    setState(() {
      for (int i = 0; i < widget.bandCount; i++) {
        // Multi-frequency simulated harmonics for natural Winamp audio pulse
        final double harmonic1 = math.sin(_phase * 2.5 + i * 0.4);
        final double harmonic2 = math.cos(_phase * 4.1 - i * 0.7);
        final double harmonic3 = math.sin(_phase * 1.2 + i * 0.15);
        final double noise = _random.nextDouble() * 0.35;

        // Low bands have higher baseline energy (bass curve)
        final double bassBias = (1.0 - (i / widget.bandCount) * 0.45);
        double rawLevel = ((harmonic1 + harmonic2 + harmonic3) / 3.0 + 0.5) * bassBias + noise;
        rawLevel = (rawLevel * widget.audioAmplitude).clamp(0.05, 1.0);

        _bandHeights[i] = rawLevel;

        // Peak hold physics
        if (rawLevel >= _peakHeights[i]) {
          _peakHeights[i] = rawLevel;
          _peakVelocities[i] = 0.0;
        } else {
          // Gravity acceleration
          _peakVelocities[i] += 0.003;
          _peakHeights[i] = (_peakHeights[i] - _peakVelocities[i]).clamp(0.0, 1.0);
        }
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: const Color(0xFF030704),
        borderRadius: BorderRadius.circular(1.0),
        border: Border.all(
          color: const Color(0xFF0C2414),
          width: 0.8,
        ),
      ),
      child: CustomPaint(
        size: Size(double.infinity, widget.height),
        painter: _SpectrumPainter(
          bandHeights: _bandHeights,
          peakHeights: _peakHeights,
          bandCount: widget.bandCount,
        ),
      ),
    );
  }
}

class _SpectrumPainter extends CustomPainter {
  _SpectrumPainter({
    required this.bandHeights,
    required this.peakHeights,
    required this.bandCount,
  });

  final List<double> bandHeights;
  final List<double> peakHeights;
  final int bandCount;

  static const int segmentCount = 12; // vertical blocks per bar

  @override
  void paint(Canvas canvas, Size size) {
    if (bandCount == 0) return;

    const double barGap = 2.0;
    final double barWidth = (size.width - (bandCount - 1) * barGap) / bandCount;
    final double segmentHeight = (size.height - (segmentCount - 1) * 1.5) / segmentCount;

    final Paint segmentPaint = Paint()..style = PaintingStyle.fill;
    final Paint peakPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < bandCount; i++) {
      final double x = i * (barWidth + barGap);
      final double level = bandHeights[i];
      final int activeSegments = (level * segmentCount).round();

      // Render vertical LED blocks
      for (int s = 0; s < segmentCount; s++) {
        final double y = size.height - (s + 1) * (segmentHeight + 1.5);
        final bool isLit = s < activeSegments;

        Color blockColor;
        if (s >= 10) {
          // Top 2 segments: Red
          blockColor = isLit ? RetroColors.redPeak : const Color(0xFF26050C);
        } else if (s >= 7) {
          // Middle 3 segments: Yellow / Amber
          blockColor = isLit ? RetroColors.amberAccent : const Color(0xFF2B1F00);
        } else {
          // Bottom 7 segments: Phosphor Green
          blockColor = isLit ? RetroColors.vfdGreen : const Color(0xFF0A2412);
        }

        segmentPaint.color = blockColor;
        canvas.drawRect(
          Rect.fromLTWH(x, y, barWidth, segmentHeight),
          segmentPaint,
        );
      }

      // Render Peak Hold Cap (Floating needle)
      final double peakLevel = peakHeights[i];
      if (peakLevel > 0.05) {
        final int peakSegment = (peakLevel * segmentCount).clamp(1, segmentCount).round();
        final double peakY = size.height - peakSegment * (segmentHeight + 1.5);

        peakPaint.color = peakSegment >= 10
            ? RetroColors.redPeak
            : (peakSegment >= 7 ? RetroColors.amberAccent : RetroColors.vfdGreen);

        canvas.drawRect(
          Rect.fromLTWH(x, peakY, barWidth, 1.8),
          peakPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SpectrumPainter oldDelegate) => true;
}
