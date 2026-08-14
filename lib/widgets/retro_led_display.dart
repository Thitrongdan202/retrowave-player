import 'dart:async';
import 'package:flutter/material.dart';
import '../core/theme/retro_borders.dart';
import '../core/theme/retro_colors.dart';
import '../core/theme/retro_typography.dart';

/// Recessed VFD (Vacuum Fluorescent Display) dark glass screen with glowing phosphor green/amber
/// readouts, animated horizontal marquee for overflowing song titles, and audio technical badges.
class RetroLedDisplay extends StatefulWidget {
  const RetroLedDisplay({
    super.key,
    required this.title,
    this.artist,
    required this.position,
    required this.duration,
    required this.isPlaying,
    required this.isPaused,
    this.trackIndex = 0,
    this.totalTracks = 0,
    this.bitrate = '320 KBPS',
    this.sampleRate = '44.1 KHZ',
    this.audioFormat = 'STEREO',
  });

  final String title;
  final String? artist;
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final bool isPaused;
  final int trackIndex;
  final int totalTracks;
  final String bitrate;
  final String sampleRate;
  final String audioFormat;

  @override
  State<RetroLedDisplay> createState() => _RetroLedDisplayState();
}

class _RetroLedDisplayState extends State<RetroLedDisplay> {
  late ScrollController _marqueeController;
  Timer? _marqueeTimer;

  @override
  void initState() {
    super.initState();
    _marqueeController = ScrollController();
    _startMarqueeIfNeeded();
  }

  @override
  void didUpdateWidget(covariant RetroLedDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.title != widget.title || oldWidget.artist != widget.artist) {
      _resetMarquee();
    }
  }

  void _resetMarquee() {
    _marqueeTimer?.cancel();
    if (_marqueeController.hasClients) {
      _marqueeController.jumpTo(0.0);
    }
    _startMarqueeIfNeeded();
  }

  void _startMarqueeIfNeeded() {
    _marqueeTimer?.cancel();
    _marqueeTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!_marqueeController.hasClients) return;
      final maxScroll = _marqueeController.position.maxScrollExtent;
      if (maxScroll > 10) {
        final nextOffset = _marqueeController.offset + 1.2;
        if (nextOffset >= maxScroll) {
          _marqueeController.jumpTo(0.0);
        } else {
          _marqueeController.jumpTo(nextOffset);
        }
      }
    });
  }

  @override
  void dispose() {
    _marqueeTimer?.cancel();
    _marqueeController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final String trackNumberStr = widget.totalTracks > 0
        ? 'TRK ${(widget.trackIndex + 1).toString().padLeft(2, '0')}/${widget.totalTracks.toString().padLeft(2, '0')}'
        : 'TRK --/--';

    final String statusStr = widget.isPlaying
        ? '▶ PLAY'
        : (widget.isPaused ? 'Ⅱ PAUSE' : '■ STOP');

    final Color statusColor = widget.isPlaying
        ? RetroColors.vfdGreen
        : (widget.isPaused ? RetroColors.amberAccent : RetroColors.textMuted);

    final String displayTitle = widget.artist != null && widget.artist!.isNotEmpty
        ? '${widget.artist!.toUpperCase()} - ${widget.title.toUpperCase()}'
        : widget.title.toUpperCase();

    return Container(
      decoration: RetroBorders.vfdScreen(),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Top Row: Status, Track Index, Time Elapsed & Total ────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Playback Status Indicator
              Row(
                children: [
                  Text(
                    statusStr,
                    style: RetroTypography.ledBadgeActive.copyWith(
                      color: statusColor,
                      fontSize: 10.0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    trackNumberStr,
                    style: RetroTypography.ledBadgeActive.copyWith(
                      color: RetroColors.cyanAccent,
                      fontSize: 10.0,
                    ),
                  ),
                ],
              ),

              // Digital Timer Elapsed / Total
              Row(
                children: [
                  Text(
                    _formatDuration(widget.position),
                    style: RetroTypography.ledTimer.copyWith(fontSize: 18.0),
                  ),
                  Text(
                    ' / ${_formatDuration(widget.duration)}',
                    style: RetroTypography.ledBadgeDim.copyWith(
                      fontSize: 11.0,
                      color: RetroColors.vfdGreen.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 6),

          // ── Center Row: Marquee Text (Auto-scrolling track info) ───────────
          Container(
            height: 22.0,
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: const Color(0xFF020603),
              borderRadius: BorderRadius.circular(1.0),
              border: Border.all(
                color: const Color(0xFF081C10),
                width: 0.5,
              ),
            ),
            child: SingleChildScrollView(
              controller: _marqueeController,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(
                children: [
                  Text(
                    displayTitle.isEmpty ? 'RETROWAVE PLAYER READY' : displayTitle,
                    style: RetroTypography.ledMarquee,
                  ),
                  // Extra spacer for smooth loop
                  const SizedBox(width: 60),
                  if (displayTitle.isNotEmpty)
                    Text(
                      displayTitle,
                      style: RetroTypography.ledMarquee,
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 6),

          // ── Bottom Row: Audio Technical Badges ────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SpecBadge(label: widget.bitrate, isActive: widget.isPlaying),
              _SpecBadge(label: widget.sampleRate, isActive: widget.isPlaying),
              _SpecBadge(label: widget.audioFormat, isActive: widget.isPlaying),
              _SpecBadge(
                label: 'HI-FI',
                isActive: widget.isPlaying,
                activeColor: RetroColors.amberAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpecBadge extends StatelessWidget {
  const _SpecBadge({
    required this.label,
    required this.isActive,
    this.activeColor = RetroColors.vfdGreen,
  });

  final String label;
  final bool isActive;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.5),
      decoration: BoxDecoration(
        color: isActive
            ? activeColor.withValues(alpha: 0.08)
            : const Color(0xFF040A06),
        borderRadius: BorderRadius.circular(1.0),
        border: Border.all(
          color: isActive
              ? activeColor.withValues(alpha: 0.3)
              : const Color(0xFF0A1F10),
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: isActive
            ? RetroTypography.ledBadgeActive.copyWith(
                color: activeColor,
                shadows: [
                  Shadow(color: activeColor.withValues(alpha: 0.8), blurRadius: 3),
                ],
              )
            : RetroTypography.ledBadgeDim,
      ),
    );
  }
}
