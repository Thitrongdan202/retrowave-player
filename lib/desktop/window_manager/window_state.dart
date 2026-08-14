import 'package:flutter/material.dart';

/// Represents the geometry and state of a desktop sub-window.
class WindowState {
  WindowState({
    required this.id,
    required this.title,
    required this.position,
    required this.size,
    this.zIndex = 0,
    this.isVisible = true,
    this.isMinimized = false,
  });

  final String id;
  final String title;
  Offset position;
  Size size;
  int zIndex;
  bool isVisible;
  bool isMinimized;

  WindowState copyWith({
    String? id,
    String? title,
    Offset? position,
    Size? size,
    int? zIndex,
    bool? isVisible,
    bool? isMinimized,
  }) {
    return WindowState(
      id: id ?? this.id,
      title: title ?? this.title,
      position: position ?? this.position,
      size: size ?? this.size,
      zIndex: zIndex ?? this.zIndex,
      isVisible: isVisible ?? this.isVisible,
      isMinimized: isMinimized ?? this.isMinimized,
    );
  }
}
