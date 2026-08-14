import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/retro_borders.dart';
import '../core/theme/retro_colors.dart';
import '../core/theme/retro_metrics.dart';

/// Animated realistic vinyl turntable with microgrooves, anisotropic lighting reflection,
/// center vintage label, and an articulated tone-arm that tracks playback state.
class VinylPlayer extends StatefulWidget {
  const VinylPlayer({
    super.key,
    required this.isPlaying,
    this.trackTitle,
    this.artist,
    this.diameter = RetroMetrics.vinylDiameter,
  });

  /// Playback state. Starts 60fps rotation & positions tonearm when true.
  final bool isPlaying;

  /// Track title rendered on the center label.
  final String? trackTitle;

  /// Artist name rendered on the center label.
  final String? artist;

  /// Diameter of the vinyl disc.
  final double diameter;

  @override
  State<VinylPlayer> createState() => _VinylPlayerState();
}

class _VinylPlayerState extends State<VinylPlayer> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _tonearmController;
  late Animation<double> _tonearmAnimation;

  @override
  void initState() {
    super.initState();

    // Vinyl rotation controller (33 1/3 RPM simulated = ~1.8 seconds per turn)
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // Tonearm swing animation (0.0 = resting on armrest, 1.0 = on record groove)
    _tonearmController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _tonearmAnimation = CurvedAnimation(
      parent: _tonearmController,
      curve: Curves.easeInOutCubic,
    );

    if (widget.isPlaying) {
      _rotationController.repeat();
      _tonearmController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant VinylPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_rotationController.isAnimating) {
      _rotationController.repeat();
      _tonearmController.forward();
    } else if (!widget.isPlaying && _rotationController.isAnimating) {
      _rotationController.stop();
      _tonearmController.reverse();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _tonearmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: RetroBorders.inset(
        backgroundColor: const Color(0xFF0A0D13),
        highlightColor: RetroColors.bevelHighlight,
        shadowColor: RetroColors.bevelDark,
      ),
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: SizedBox(
          width: widget.diameter + 40,
          height: widget.diameter + 10,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ── Turntable Platter Base ────────────────────────────────────
              Container(
                width: widget.diameter + 8,
                height: widget.diameter + 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF141820),
                  border: Border.all(
                    color: const Color(0xFF2C3545),
                    width: 1.5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black87,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),

              // ── Rotating Vinyl Disc ───────────────────────────────────────
              AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationController.value * 2 * math.pi,
                    child: CustomPaint(
                      size: Size(widget.diameter, widget.diameter),
                      painter: _VinylDiscPainter(
                        trackTitle: widget.trackTitle ?? 'RETROWAVE',
                        artist: widget.artist ?? 'HI-FI STEREO',
                      ),
                    ),
                  );
                },
              ),

              // ── Articulated Tonearm (Pivots over the record) ───────────────
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: 60,
                child: AnimatedBuilder(
                  animation: _tonearmAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      size: Size(60, widget.diameter + 10),
                      painter: _TonearmPainter(
                        progress: _tonearmAnimation.value,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VinylDiscPainter extends CustomPainter {
  _VinylDiscPainter({
    required this.trackTitle,
    required this.artist,
  });

  final String trackTitle;
  final String artist;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2;

    // 1. Vinyl Body (Deep Jet Black)
    final Paint bodyPaint = Paint()
      ..color = RetroColors.vinylBody
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bodyPaint);

    // 2. Concentric Microgrooves
    final Paint groovePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (double r = radius * 0.42; r < radius - 2; r += 2.2) {
      final double opacity = 0.12 + (math.sin(r * 1.5) * 0.08);
      groovePaint.color = Colors.white.withValues(alpha: opacity);
      canvas.drawCircle(center, r, groovePaint);
    }

    // Lead-in & Lead-out Run-out Grooves
    final Paint leadGroovePaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius - 2, leadGroovePaint);
    canvas.drawCircle(center, radius * 0.40, leadGroovePaint);

    // 3. Anisotropic Specular Light Sheen (Two opposing radial sheen cones)
    final Paint sheenPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    final Path sheenCone1 = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 4,
        math.pi / 3,
        false,
      )
      ..close();

    final Path sheenCone2 = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        3 * math.pi / 4,
        math.pi / 3,
        false,
      )
      ..close();

    canvas.drawPath(sheenCone1, sheenPaint);
    canvas.drawPath(sheenCone2, sheenPaint);

    // 4. Center Vintage Label
    final double labelRadius = radius * 0.38;
    final Paint labelPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFF8B1515),
          Color(0xFF5A0B0B),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: labelRadius));
    canvas.drawCircle(center, labelRadius, labelPaint);

    // Label Gold Ring
    final Paint labelRing = Paint()
      ..color = RetroColors.amberAccent.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, labelRadius - 1.5, labelRing);
    canvas.drawCircle(center, labelRadius * 0.75, labelRing);

    // Label Text
    final TextPainter textPainter = TextPainter(
      text: const TextSpan(
        text: 'RETROWAVE\n33 RPM',
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 6.5,
          fontWeight: FontWeight.w900,
          color: RetroColors.amberAccent,
          letterSpacing: 0.8,
          height: 1.1,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: labelRadius * 1.5);

    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - labelRadius * 0.65),
    );

    // 5. Center Spindle Hole & Brass Ring
    final Paint brassRing = Paint()
      ..color = const Color(0xFFC8A550)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 7.0, brassRing);

    final Paint spindleHole = Paint()
      ..color = const Color(0xFF05070A)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4.0, spindleHole);
  }

  @override
  bool shouldRepaint(covariant _VinylDiscPainter oldDelegate) => true;
}

class _TonearmPainter extends CustomPainter {
  _TonearmPainter({required this.progress});

  /// 0.0 = resting on armrest, 1.0 = resting on outer vinyl groove.
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    // Pivot Base at Top-Right
    final Offset pivot = Offset(size.width - 16, 16);

    // Swing angle: idle ~ 0 deg (straight down), active ~ -28 deg (swept onto record)
    final double angle = -0.15 - (progress * 0.42);

    canvas.save();
    canvas.translate(pivot.dx, pivot.dy);
    canvas.rotate(angle);

    // Metallic Base Gimbal
    final Paint basePaint = Paint()
      ..color = const Color(0xFF4C586B)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, 11, basePaint);

    final Paint pivotHighlight = Paint()
      ..color = const Color(0xFF8A99B0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset.zero, 10, pivotHighlight);

    // Arm Rod (Curved S-shape metallic tube)
    final Paint armPaint = Paint()
      ..color = const Color(0xFFB0BDD1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final Path armPath = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height * 0.65)
      ..quadraticBezierTo(
        -8,
        size.height * 0.78,
        -18,
        size.height * 0.85,
      );

    canvas.drawPath(armPath, armPaint);

    // Headshell Cartridge & Stylus
    final Offset headPos = Offset(-18, size.height * 0.85);
    final Paint headPaint = Paint()
      ..color = const Color(0xFF1E2430)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: headPos, width: 10, height: 16),
        const Radius.circular(1.5),
      ),
      headPaint,
    );

    // Stylus Tip Highlight
    final Paint stylusPaint = Paint()
      ..color = RetroColors.vfdGreen
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(headPos.dx, headPos.dy + 7), 1.5, stylusPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _TonearmPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
