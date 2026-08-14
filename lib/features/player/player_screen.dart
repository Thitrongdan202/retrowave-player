import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/audio_provider.dart';
import '../../providers/library_provider.dart';
import '../../core/constants/app_constants.dart';

/// Primary player screen for RetroWave Player (Phase 1–6 functional UI).
///
/// Contains:
///  - Folder selection button
///  - Scanned audio file list
///  - Current track / playback controls
///  - Seek bar
class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          AppConstants.appName,
          style: TextStyle(
            color: Color(0xFFE0E0E0),
            fontFamily: 'monospace',
            fontSize: 18,
            letterSpacing: 2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF9E9E9E)),
            tooltip: 'Rescan folder',
            onPressed: () {
              final folder = ref.read(selectedFolderProvider);
              if (folder != null) {
                ref.read(musicLibraryProvider.notifier).rescan(folder);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _FolderSection(),
          const Divider(color: Color(0xFF333333), height: 1),
          Expanded(child: _LibrarySection()),
          const Divider(color: Color(0xFF333333), height: 1),
          _PlayerControls(),
        ],
      ),
    );
  }
}

// ── Folder picker section ─────────────────────────────────────────────────────

class _FolderSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folder = ref.watch(selectedFolderProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D2D2D),
              foregroundColor: const Color(0xFFB0B0B0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            icon: const Icon(Icons.folder_open, size: 18),
            label: const Text('Select Music Folder'),
            onPressed: () {
              ref.read(selectedFolderProvider.notifier).pickFolder();
            },
          ),
          const SizedBox(width: 12),
          if (folder != null)
            Expanded(
              child: Text(
                folder,
                style: const TextStyle(
                  color: Color(0xFF757575),
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
                overflow: TextOverflow.ellipsis,
              ),
            )
          else
            const Text(
              'No folder selected',
              style: TextStyle(color: Color(0xFF444444), fontSize: 12),
            ),
        ],
      ),
    );
  }
}

// ── Library list section ──────────────────────────────────────────────────────

class _LibrarySection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryState = ref.watch(musicLibraryProvider);
    final playbackState = ref.watch(playbackStateProvider);
    final currentIndex =
        ref.watch(audioHandlerProvider).currentIndex;

    return switch (libraryState) {
      MusicLibraryIdle() => const Center(
          child: Text(
            'Select a music folder to begin.',
            style: TextStyle(color: Color(0xFF555555)),
          ),
        ),
      MusicLibraryLoading() => const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF757575),
            strokeWidth: 2,
          ),
        ),
      MusicLibraryError(:final message) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    color: Color(0xFFCF6679), size: 36),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: const TextStyle(color: Color(0xFFCF6679)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      MusicLibraryLoaded(:final items) => items.isEmpty
          ? const Center(
              child: Text(
                'No supported audio files found in this folder.',
                style: TextStyle(color: Color(0xFF555555)),
              ),
            )
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isPlaying =
                    currentIndex == index &&
                    (playbackState.value?.playing ?? false);

                return ListTile(
                  dense: true,
                  leading: Text(
                    (index + 1).toString().padLeft(2, '0'),
                    style: TextStyle(
                      color: isPlaying
                          ? const Color(0xFF90CAF9)
                          : const Color(0xFF555555),
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                  ),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      color: isPlaying
                          ? const Color(0xFF90CAF9)
                          : const Color(0xFFCCCCCC),
                      fontSize: 14,
                      fontWeight:
                          isPlaying ? FontWeight.w600 : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    item.path.split(RegExp(r'[/\\]')).last,
                    style: const TextStyle(
                      color: Color(0xFF444444),
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    final service =
                        ref.read(audioPlayerServiceProvider);
                    service.playTrack(items, index);
                  },
                );
              },
            ),
    };
  }
}

// ── Playback controls section ─────────────────────────────────────────────────

class _PlayerControls extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playbackStateAsync = ref.watch(playbackStateProvider);
    final mediaItemAsync = ref.watch(currentMediaItemProvider);
    final positionAsync = ref.watch(positionProvider);
    final durationAsync = ref.watch(durationProvider);

    final playbackState = playbackStateAsync.valueOrNull;
    final mediaItem = mediaItemAsync.valueOrNull;
    final position = positionAsync.valueOrNull ?? Duration.zero;
    final duration = durationAsync.valueOrNull ?? Duration.zero;
    final isPlaying = playbackState?.playing ?? false;
    final processingState =
        playbackState?.processingState ?? AudioProcessingState.idle;

    final service = ref.read(audioPlayerServiceProvider);

    return Container(
      color: const Color(0xFF1A1A1A),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current track title
          Text(
            mediaItem?.title ?? '—',
            style: const TextStyle(
              color: Color(0xFFE0E0E0),
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // Error state indicator
          if (processingState == AudioProcessingState.error)
            const Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Text(
                'Playback error — file may be missing or unsupported.',
                style:
                    TextStyle(color: Color(0xFFCF6679), fontSize: 12),
              ),
            ),

          // Seek bar
          _SeekBar(
            position: position,
            duration: duration,
            onSeek: service.seek,
          ),

          // Time labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(position),
                style: const TextStyle(
                  color: Color(0xFF757575),
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
              Text(
                _formatDuration(duration),
                style: const TextStyle(
                  color: Color(0xFF757575),
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Transport buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ControlButton(
                icon: Icons.skip_previous,
                onPressed: service.previous,
                tooltip: 'Previous',
              ),
              const SizedBox(width: 8),
              _PlayPauseButton(
                isPlaying: isPlaying,
                isLoading: processingState == AudioProcessingState.loading ||
                    processingState == AudioProcessingState.buffering,
                onPlay: service.play,
                onPause: service.pause,
              ),
              const SizedBox(width: 8),
              _ControlButton(
                icon: Icons.skip_next,
                onPressed: service.next,
                tooltip: 'Next',
              ),
              const SizedBox(width: 16),
              _ControlButton(
                icon: Icons.stop,
                onPressed: service.stop,
                tooltip: 'Stop',
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _SeekBar extends StatefulWidget {
  const _SeekBar({
    required this.position,
    required this.duration,
    required this.onSeek,
  });

  final Duration position;
  final Duration duration;
  final void Function(Duration) onSeek;

  @override
  State<_SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<_SeekBar> {
  double? _draggingValue;

  @override
  Widget build(BuildContext context) {
    final total = widget.duration.inMilliseconds.toDouble();
    final current =
        _draggingValue ?? widget.position.inMilliseconds.toDouble();
    final value = (total > 0) ? (current / total).clamp(0.0, 1.0) : 0.0;

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: const Color(0xFF5C8FD6),
        inactiveTrackColor: const Color(0xFF333333),
        thumbColor: const Color(0xFF90CAF9),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
        trackHeight: 3,
      ),
      child: Slider(
        value: value,
        onChanged: total > 0
            ? (v) => setState(
                () => _draggingValue = v * total)
            : null,
        onChangeEnd: total > 0
            ? (v) {
                final target =
                    Duration(milliseconds: (v * total).round());
                widget.onSeek(target);
                setState(() => _draggingValue = null);
              }
            : null,
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFFB0B0B0), size: 28),
        onPressed: onPressed,
        splashRadius: 20,
      ),
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({
    required this.isPlaying,
    required this.isLoading,
    required this.onPlay,
    required this.onPause,
  });

  final bool isPlaying;
  final bool isLoading;
  final VoidCallback onPlay;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        width: 48,
        height: 48,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: Color(0xFF90CAF9),
              strokeWidth: 2.5,
            ),
          ),
        ),
      );
    }

    return IconButton(
      iconSize: 42,
      icon: Icon(
        isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
        color: const Color(0xFF90CAF9),
      ),
      onPressed: isPlaying ? onPause : onPlay,
      tooltip: isPlaying ? 'Pause' : 'Play',
    );
  }
}
