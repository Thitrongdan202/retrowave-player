import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/retro_colors.dart';
import '../../core/theme/retro_metrics.dart';
import '../../desktop/window_manager/desktop_window_manager.dart';
import '../../desktop/window_manager/window_state.dart';
import '../playlist/playlist_window.dart';
import 'main_player_window.dart';

/// Primary shell screen for RetroWave Player.
/// Responsive: renders a floating multi-window workspace on Desktop (Windows),
/// and a cohesive single-column retro console on Mobile (Android / narrow screens).
class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  // Desktop window states
  bool _isPlaylistVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RetroColors.workspaceBg,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWideDesktop = constraints.maxWidth >= 800;

          if (isWideDesktop) {
            return _buildDesktopLayout(constraints);
          } else {
            return _buildMobileLayout(constraints);
          }
        },
      ),
    );
  }

  // ── Desktop Multi-Window Workspace ────────────────────────────────────────
  Widget _buildDesktopLayout(BoxConstraints constraints) {
    const double initialX1 = 40.0;
    const double initialY1 = 40.0;
    const double initialX2 = initialX1 + RetroMetrics.mainPlayerWidth + 24.0;
    const double initialY2 = 40.0;

    final initialWindows = [
      WindowState(
        id: 'main_player',
        title: 'RETROWAVE PLAYER',
        position: const Offset(initialX1, initialY1),
        size: const Size(RetroMetrics.mainPlayerWidth, 530.0),
        zIndex: 2,
        isVisible: true,
      ),
      WindowState(
        id: 'playlist',
        title: 'PLAYLIST EDITOR',
        position: const Offset(initialX2, initialY2),
        size: const Size(RetroMetrics.playlistWidth, 530.0),
        zIndex: 1,
        isVisible: _isPlaylistVisible,
      ),
    ];

    return DesktopWindowManager(
      windows: initialWindows,
      windowBuilders: {
        'main_player': (context, state, onDrag) => MainPlayerWindow(
              width: state.size.width,
              height: state.size.height,
              isFocused: state.zIndex >= 2,
              isPlaylistVisible: _isPlaylistVisible,
              onDrag: onDrag,
              onTogglePlaylist: () {
                setState(() => _isPlaylistVisible = !_isPlaylistVisible);
              },
            ),
        'playlist': (context, state, onDrag) => PlaylistWindow(
              width: state.size.width,
              height: state.size.height,
              isFocused: state.zIndex >= 2,
              onDrag: onDrag,
              onClose: () {
                setState(() => _isPlaylistVisible = false);
              },
            ),
      },
    );
  }

  // ── Mobile Responsive Retro Console ───────────────────────────────────────
  Widget _buildMobileLayout(BoxConstraints constraints) {
    return SafeArea(
      child: Container(
        color: RetroColors.workspaceBg,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Main Player Console
                  MainPlayerWindow(
                    isPlaylistVisible: _isPlaylistVisible,
                    onTogglePlaylist: () {
                      setState(() => _isPlaylistVisible = !_isPlaylistVisible);
                    },
                  ),

                  // Collapsible / Slide-down Playlist Section
                  if (_isPlaylistVisible) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 320.0,
                      child: PlaylistWindow(
                        onClose: () {
                          setState(() => _isPlaylistVisible = false);
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
