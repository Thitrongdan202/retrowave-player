import 'package:path/path.dart' as p;

/// Represents a single local audio file discovered by [LocalMediaScanner].
class LocalMediaItem {
  const LocalMediaItem({
    required this.id,
    required this.path,
    required this.title,
    this.type = 'audio',
  });

  /// Unique identifier — the absolute file path is stable enough for Phase 1–6.
  final String id;

  /// Absolute path to the audio file on the local filesystem.
  final String path;

  /// Human-readable title derived from the filename (without extension).
  final String title;

  /// Media type — always 'audio' for Phase 1–6.
  final String type;

  /// Derive a [LocalMediaItem] from a raw file path.
  factory LocalMediaItem.fromPath(String filePath) {
    final filename = p.basenameWithoutExtension(filePath);
    // Clean up common filename artefacts: leading numbers, underscores, dashes.
    final title = filename
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .trim();
    return LocalMediaItem(
      id: filePath,
      path: filePath,
      title: title.isEmpty ? p.basename(filePath) : title,
    );
  }

  @override
  String toString() => 'LocalMediaItem(title: $title, path: $path)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalMediaItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
