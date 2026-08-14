import 'package:flutter/material.dart';
import '../../core/theme/retro_colors.dart';
import '../../core/theme/retro_typography.dart';
import '../../widgets/retro_button.dart';
import 'window_state.dart';

typedef WindowBuilder = Widget Function(
  BuildContext context,
  WindowState state,
  ValueChanged<Offset> onDrag,
);

/// Workspace manager for draggable floating retro desktop windows on Windows / large screens.
class DesktopWindowManager extends StatefulWidget {
  const DesktopWindowManager({
    super.key,
    required this.windows,
    required this.windowBuilders,
  });

  /// Initial window configurations.
  final List<WindowState> windows;

  /// Builder callback per window ID.
  final Map<String, WindowBuilder> windowBuilders;

  @override
  State<DesktopWindowManager> createState() => _DesktopWindowManagerState();
}

class _DesktopWindowManagerState extends State<DesktopWindowManager> {
  late Map<String, WindowState> _windowMap;
  int _topZIndex = 1;
  String? _focusedWindowId;

  @override
  void initState() {
    super.initState();
    _windowMap = {for (final w in widget.windows) w.id: w};
    if (widget.windows.isNotEmpty) {
      _focusedWindowId = widget.windows.first.id;
    }
  }

  void _bringToFront(String id) {
    if (_windowMap.containsKey(id)) {
      setState(() {
        _topZIndex++;
        _windowMap[id]!.zIndex = _topZIndex;
        _focusedWindowId = id;
      });
    }
  }

  void _moveWindow(String id, Offset delta, Size workspaceSize) {
    if (!_windowMap.containsKey(id)) return;
    setState(() {
      final win = _windowMap[id]!;
      final newX = (win.position.dx + delta.dx).clamp(
        0.0,
        (workspaceSize.width - 100).clamp(0.0, double.infinity),
      );
      final newY = (win.position.dy + delta.dy).clamp(
        0.0,
        (workspaceSize.height - 40).clamp(0.0, double.infinity),
      );
      win.position = Offset(newX, newY);
    });
  }

  void _toggleMinimize(String id) {
    if (_windowMap.containsKey(id)) {
      setState(() {
        _windowMap[id]!.isMinimized = !_windowMap[id]!.isMinimized;
      });
    }
  }

  void _toggleVisibility(String id) {
    if (_windowMap.containsKey(id)) {
      setState(() {
        _windowMap[id]!.isVisible = !_windowMap[id]!.isVisible;
        if (_windowMap[id]!.isVisible) {
          _bringToFront(id);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final workspaceSize = Size(constraints.maxWidth, constraints.maxHeight);

        // Sort windows by z-index for rendering order
        final sortedWindows = _windowMap.values.toList()
          ..sort((a, b) => a.zIndex.compareTo(b.zIndex));

        return Container(
          color: RetroColors.workspaceBg,
          child: Stack(
            children: [
              // ── Background Ambient Texture ────────────────────────────────
              Positioned.fill(
                child: CustomPaint(
                  painter: _WorkspaceGridPainter(),
                ),
              ),

              // ── Floating Windows Layer ────────────────────────────────────
              for (final win in sortedWindows)
                if (win.isVisible && !win.isMinimized && widget.windowBuilders.containsKey(win.id))
                  Positioned(
                    left: win.position.dx,
                    top: win.position.dy,
                    child: GestureDetector(
                      onTapDown: (_) => _bringToFront(win.id),
                      child: SizedBox(
                        width: win.size.width,
                        height: win.size.height,
                        child: widget.windowBuilders[win.id]!(
                          context,
                          win.copyWith(
                            zIndex: win.zIndex,
                            isVisible: win.isVisible,
                            isMinimized: win.isMinimized,
                          ),
                          (delta) => _moveWindow(win.id, delta, workspaceSize),
                        ),
                      ),
                    ),
                  ),

              // ── Bottom Retro Taskbar / Window Dock ────────────────────────
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 32.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                  decoration: const BoxDecoration(
                    color: Color(0xFF141A24),
                    border: Border(
                      top: BorderSide(color: RetroColors.bevelHighlight, width: 1.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Retro Start / App Logo
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                        decoration: const BoxDecoration(
                          color: Color(0xFF1E2838),
                          border: Border(
                            top: BorderSide(color: RetroColors.bevelHighlight, width: 1.0),
                            left: BorderSide(color: RetroColors.bevelHighlight, width: 1.0),
                            right: BorderSide(color: RetroColors.bevelDark, width: 1.0),
                            bottom: BorderSide(color: RetroColors.bevelDark, width: 1.0),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('✦', style: TextStyle(color: RetroColors.vfdGreen, fontSize: 10)),
                            SizedBox(width: 4),
                            Text('RETROWAVE', style: RetroTypography.buttonLabel),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),
                      const VerticalDivider(color: Color(0xFF263245), width: 1, indent: 4, endIndent: 4),
                      const SizedBox(width: 12),

                      // Taskbar Window Tabs
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (final win in _windowMap.values)
                                Padding(
                                  padding: const EdgeInsets.only(right: 6.0),
                                  child: RetroButton(
                                    height: 24.0,
                                    label: win.title,
                                    hasLed: true,
                                    isLedActive: win.isVisible && !win.isMinimized,
                                    isToggled: _focusedWindowId == win.id && win.isVisible && !win.isMinimized,
                                    onPressed: () {
                                      if (!win.isVisible) {
                                        _toggleVisibility(win.id);
                                      } else if (win.isMinimized) {
                                        _toggleMinimize(win.id);
                                        _bringToFront(win.id);
                                      } else if (_focusedWindowId == win.id) {
                                        _toggleMinimize(win.id);
                                      } else {
                                        _bringToFront(win.id);
                                      }
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WorkspaceGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint gridPaint = Paint()
      ..color = const Color(0xFF101722)
      ..strokeWidth = 0.5;

    const double step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
