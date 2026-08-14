import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/retro_borders.dart';
import '../../core/theme/retro_colors.dart';
import '../../core/theme/retro_typography.dart';
import '../../media/models/local_media_item.dart';
import '../../providers/audio_provider.dart';
import '../../providers/library_provider.dart';
import '../../widgets/retro_button.dart';
import '../../widgets/retro_window.dart';

/// Winamp-style playlist editor window with compact track listing,
/// active track neon LED highlighting, double-tap/click to play, and bottom status summary.
class PlaylistWindow extends ConsumerWidget {
  const PlaylistWindow({
    super.key,
    this.width,
    this.height,
    this.isFocused = true,
    this.onClose,
    this.onMinimize,
    this.onFocus,
    this.onDrag,
  });

  final double? width;
  final double? height;
  final bool isFocused;
  final VoidCallback? onClose;
  final VoidCallback? onMinimize;
  final VoidCallback? onFocus;
  final ValueChanged<Offset>? onDrag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryState = ref.watch(musicLibraryProvider);
    final playbackState = ref.watch(playbackStateProvider).valueOrNull;
    final currentItem = ref.watch(currentMediaItemProvider).valueOrNull;
    final audioService = ref.read(audioPlayerServiceProvider);

    final List<LocalMediaItem> tracks = switch (libraryState) {
      MusicLibraryLoaded(:final items) => items,
      _ => const [],
    };

    final isPlaying = playbackState?.playing ?? false;

    return RetroWindow(
      title: 'PLAYLIST EDITOR',
      width: width,
      height: height,
      isFocused: isFocused,
      onClose: onClose,
      onMinimize: onMinimize,
      onFocus: onFocus,
      onDrag: onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Playlist Track Table ──────────────────────────────────────────
          Expanded(
            child: Container(
              decoration: RetroBorders.inset(
                backgroundColor: const Color(0xFF070B10),
                highlightColor: RetroColors.bevelHighlight,
                shadowColor: RetroColors.bevelDark,
              ),
              child: tracks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.queue_music,
                            color: Color(0xFF2C3B4E),
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'NO TRACKS LOADED',
                            style: RetroTypography.playlistSubtext.copyWith(
                              color: RetroColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 8),
                          RetroButton(
                            height: 24.0,
                            label: 'SELECT FOLDER',
                            onPressed: () {
                              ref.read(selectedFolderProvider.notifier).pickFolder();
                            },
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: tracks.length,
                      itemBuilder: (context, index) {
                        final track = tracks[index];
                        final bool isCurrent = currentItem?.id == track.id;

                        return _PlaylistItemRow(
                          index: index + 1,
                          track: track,
                          isActive: isCurrent,
                          isPlaying: isCurrent && isPlaying,
                          onTap: () {
                            audioService.playTrack(tracks, index);
                          },
                        );
                      },
                    ),
            ),
          ),

          const SizedBox(height: 6),

          // ── Bottom Action & Status Bar ────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
            decoration: RetroBorders.outset(
              backgroundColor: const Color(0xFF161E2C),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Action Buttons
                Row(
                  children: [
                    RetroButton(
                      height: 22.0,
                      label: '+ FOLDER',
                      tooltip: 'Select and scan music folder',
                      onPressed: () {
                        ref.read(selectedFolderProvider.notifier).pickFolder();
                      },
                    ),
                    const SizedBox(width: 4),
                    RetroButton(
                      height: 22.0,
                      label: 'RESCAN',
                      tooltip: 'Rescan current folder',
                      onPressed: () {
                        final folder = ref.read(selectedFolderProvider);
                        if (folder != null) {
                          ref.read(musicLibraryProvider.notifier).rescan(folder);
                        }
                      },
                    ),
                    const SizedBox(width: 4),
                    RetroButton(
                      height: 22.0,
                      label: 'CLEAR',
                      tooltip: 'Clear playlist',
                      onPressed: () {
                        ref.read(selectedFolderProvider.notifier).clearFolder();
                      },
                    ),
                  ],
                ),

                // Track Count & Format Label
                Text(
                  '${tracks.length.toString().padLeft(2, '0')} TRACKS',
                  style: RetroTypography.ledBadgeActive.copyWith(
                    color: RetroColors.cyanAccent,
                    fontSize: 10.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaylistItemRow extends StatefulWidget {
  const _PlaylistItemRow({
    required this.index,
    required this.track,
    required this.isActive,
    required this.isPlaying,
    required this.onTap,
  });

  final int index;
  final LocalMediaItem track;
  final bool isActive;
  final bool isPlaying;
  final VoidCallback onTap;

  @override
  State<_PlaylistItemRow> createState() => _PlaylistItemRowState();
}

class _PlaylistItemRowState extends State<_PlaylistItemRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final String extension = widget.track.path.split('.').last.toUpperCase();

    Color bgColor = Colors.transparent;
    if (widget.isActive) {
      bgColor = const Color(0xFF0D2415);
    } else if (_isHovered) {
      bgColor = const Color(0xFF141C28);
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          color: bgColor,
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.5),
          child: Row(
            children: [
              // Track Number / Play Indicator
              SizedBox(
                width: 28,
                child: Row(
                  children: [
                    if (widget.isActive)
                      Icon(
                        widget.isPlaying ? Icons.play_arrow : Icons.pause,
                        color: RetroColors.vfdGreen,
                        size: 11,
                      )
                    else
                      const SizedBox(width: 11),
                    const SizedBox(width: 2),
                    Text(
                      widget.index.toString().padLeft(2, '0'),
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: widget.isActive
                            ? RetroColors.vfdGreen
                            : RetroColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 4),

              // Track Title
              Expanded(
                child: Text(
                  widget.track.title,
                  style: widget.isActive
                      ? RetroTypography.playlistItemActive
                      : RetroTypography.playlistItem.copyWith(
                          color: _isHovered ? Colors.white : RetroColors.textPrimary,
                        ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(width: 6),

              // Audio Format Badge (MP3, FLAC, WAV, etc.)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 1.0),
                decoration: BoxDecoration(
                  color: widget.isActive
                      ? RetroColors.vfdGreenDim
                      : const Color(0xFF161E2A),
                  borderRadius: BorderRadius.circular(1.0),
                  border: Border.all(
                    color: widget.isActive
                        ? RetroColors.vfdGreen.withValues(alpha: 0.4)
                        : const Color(0xFF263345),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  extension,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: widget.isActive
                        ? RetroColors.vfdGreen
                        : RetroColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
