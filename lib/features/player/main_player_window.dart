import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/retro_borders.dart';
import '../../core/theme/retro_colors.dart';
import '../../core/theme/retro_typography.dart';
import '../../media/models/local_media_item.dart';
import '../../providers/audio_provider.dart';
import '../../providers/library_provider.dart';
import '../../widgets/retro_button.dart';
import '../../widgets/retro_led_display.dart';
import '../../widgets/retro_slider.dart';
import '../../widgets/retro_window.dart';
import '../../widgets/spectrum_visualizer.dart';
import '../../widgets/vinyl_player.dart';

/// Main RetroWave Player master console window containing the VFD LED display,
/// 20-band spectrum visualizer, vinyl turntable, seekbar, and transport controls.
class MainPlayerWindow extends ConsumerStatefulWidget {
  const MainPlayerWindow({
    super.key,
    this.width,
    this.height,
    this.isFocused = true,
    this.isPlaylistVisible = true,
    this.onTogglePlaylist,
    this.onClose,
    this.onMinimize,
    this.onFocus,
    this.onDrag,
  });

  final double? width;
  final double? height;
  final bool isFocused;
  final bool isPlaylistVisible;
  final VoidCallback? onTogglePlaylist;
  final VoidCallback? onClose;
  final VoidCallback? onMinimize;
  final VoidCallback? onFocus;
  final ValueChanged<Offset>? onDrag;

  @override
  ConsumerState<MainPlayerWindow> createState() => _MainPlayerWindowState();
}

class _MainPlayerWindowState extends ConsumerState<MainPlayerWindow> {
  double _volume = 1.0;

  @override
  Widget build(BuildContext context) {
    final playbackState = ref.watch(playbackStateProvider).valueOrNull;
    final mediaItem = ref.watch(currentMediaItemProvider).valueOrNull;
    final position = ref.watch(positionProvider).valueOrNull ?? Duration.zero;
    final duration = ref.watch(durationProvider).valueOrNull ?? Duration.zero;
    final libraryState = ref.watch(musicLibraryProvider);
    final audioService = ref.read(audioPlayerServiceProvider);

    final isPlaying = playbackState?.playing ?? false;
    final isPaused = (playbackState?.processingState == AudioProcessingState.ready ||
            playbackState?.processingState == AudioProcessingState.buffering) &&
        !isPlaying;

    final List<LocalMediaItem> tracks = switch (libraryState) {
      MusicLibraryLoaded(:final items) => items,
      _ => const [],
    };

    final int currentIndex = audioService.currentIndex;

    final double totalMs = duration.inMilliseconds.toDouble();
    final double posMs = position.inMilliseconds.toDouble();
    final double seekProgress = totalMs > 0 ? (posMs / totalMs).clamp(0.0, 1.0) : 0.0;

    final String trackTitle = mediaItem?.title ?? 'RETROWAVE PLAYER';
    final String trackArtist = mediaItem?.artist ?? 'READY';
    final String extension = mediaItem?.extras?['path']?.toString().split('.').last.toUpperCase() ?? 'MP3';

    return RetroWindow(
      title: 'RETROWAVE PLAYER',
      width: widget.width,
      height: widget.height,
      isFocused: widget.isFocused,
      onClose: widget.onClose,
      onMinimize: widget.onMinimize,
      onFocus: widget.onFocus,
      onDrag: widget.onDrag,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Top Module: VFD LED Screen ──────────────────────────────────
            RetroLedDisplay(
              title: trackTitle,
              artist: trackArtist,
              position: position,
              duration: duration,
              isPlaying: isPlaying,
              isPaused: isPaused,
              trackIndex: currentIndex >= 0 ? currentIndex : 0,
              totalTracks: tracks.length,
              audioFormat: extension,
            ),

            const SizedBox(height: 6),

            // ── Frequency Visualizer ────────────────────────────────────────
            SpectrumVisualizer(
              isPlaying: isPlaying,
              height: 32.0,
              bandCount: 22,
            ),

            const SizedBox(height: 6),

            // ── Turntable / Vinyl Record Chamber ────────────────────────────
            VinylPlayer(
              isPlaying: isPlaying,
              trackTitle: trackTitle,
              artist: trackArtist,
              diameter: 155.0,
            ),

            const SizedBox(height: 6),

            // ── Seek Progress Bar ───────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
              decoration: RetroBorders.inset(
                backgroundColor: const Color(0xFF101622),
              ),
              child: Column(
                children: [
                  RetroSlider(
                    value: seekProgress,
                    onChanged: (val) {
                      if (totalMs > 0) {
                        final targetMs = (val * totalMs).round();
                        audioService.seek(Duration(milliseconds: targetMs));
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // ── Bottom Control Deck (Transport, Volume, Window Toggles) ──────
            Container(
              padding: const EdgeInsets.all(6.0),
              decoration: RetroBorders.outset(
                backgroundColor: const Color(0xFF18202E),
              ),
              child: Column(
                children: [
                  // Primary Transport Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Previous Track
                      RetroButton(
                        width: 38,
                        height: 28,
                        icon: const Icon(Icons.skip_previous, size: 14, color: RetroColors.textPrimary),
                        tooltip: 'Previous track',
                        onPressed: audioService.previous,
                      ),

                      // Play
                      RetroButton(
                        width: 44,
                        height: 28,
                        icon: const Icon(Icons.play_arrow, size: 16, color: RetroColors.vfdGreen),
                        tooltip: 'Play',
                        isToggled: isPlaying,
                        onPressed: audioService.play,
                      ),

                      // Pause
                      RetroButton(
                        width: 38,
                        height: 28,
                        icon: const Icon(Icons.pause, size: 14, color: RetroColors.amberAccent),
                        tooltip: 'Pause',
                        isToggled: isPaused,
                        onPressed: audioService.pause,
                      ),

                      // Stop
                      RetroButton(
                        width: 38,
                        height: 28,
                        icon: const Icon(Icons.stop, size: 14, color: RetroColors.textPrimary),
                        tooltip: 'Stop',
                        onPressed: audioService.stop,
                      ),

                      // Next Track
                      RetroButton(
                        width: 38,
                        height: 28,
                        icon: const Icon(Icons.skip_next, size: 14, color: RetroColors.textPrimary),
                        tooltip: 'Next track',
                        onPressed: audioService.next,
                      ),

                      // Eject / Open Folder
                      RetroButton(
                        width: 44,
                        height: 28,
                        icon: const Icon(Icons.folder_open, size: 14, color: RetroColors.cyanAccent),
                        tooltip: 'Select Music Folder',
                        onPressed: () {
                          ref.read(selectedFolderProvider.notifier).pickFolder();
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Secondary Controls: Volume Slider & Playlist Toggle
                  Row(
                    children: [
                      // Volume Label & Slider
                      const Text(
                        'VOL',
                        style: RetroTypography.buttonLabel,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: RetroSlider(
                          value: _volume,
                          activeColor: RetroColors.cyanAccent,
                          onChanged: (val) {
                            setState(() => _volume = val);
                            audioService.setVolume(val);
                          },
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${(_volume * 100).round()}%',
                        style: RetroTypography.ledBadgeActive.copyWith(
                          color: RetroColors.cyanAccent,
                          fontSize: 9.0,
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Sub-window toggles: [PL] Playlist
                      RetroButton(
                        width: 36,
                        height: 22,
                        label: 'PL',
                        hasLed: true,
                        isLedActive: widget.isPlaylistVisible,
                        isToggled: widget.isPlaylistVisible,
                        tooltip: 'Toggle Playlist Window',
                        onPressed: widget.onTogglePlaylist,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
