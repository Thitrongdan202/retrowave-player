import 'dart:io';
import 'package:path/path.dart' as p;
import '../models/local_media_item.dart';
import '../../core/constants/app_constants.dart';

/// Scans a local directory tree and returns supported audio files.
///
/// Supported extensions (Phase 1–6): mp3, m4a, aac, wav, flac, ogg.
/// Title is derived from the filename — no ID3 parsing in this phase.
class LocalMediaScanner {
  const LocalMediaScanner();

  /// Recursively scans [directoryPath] and returns a sorted list of
  /// [LocalMediaItem]s for every supported audio file found.
  ///
  /// Throws [ArgumentError] if [directoryPath] is empty.
  /// Returns an empty list if the directory does not exist or is empty.
  Future<List<LocalMediaItem>> scan(String directoryPath) async {
    if (directoryPath.trim().isEmpty) {
      throw ArgumentError('directoryPath must not be empty');
    }

    final dir = Directory(directoryPath);
    if (!dir.existsSync()) {
      return [];
    }

    final items = <LocalMediaItem>[];

    try {
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File && _isSupported(entity.path)) {
          items.add(LocalMediaItem.fromPath(entity.path));
        }
      }
    } on FileSystemException catch (e) {
      // Permission errors or OS-level failures — return what we have so far.
      // ignore: avoid_print
      print('[LocalMediaScanner] FileSystemException during scan: $e');
    }

    // Sort alphabetically by path for a consistent display order.
    items.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));
    return items;
  }

  /// Returns true if [filePath] has a supported audio file extension.
  bool _isSupported(String filePath) {
    final ext = p.extension(filePath).toLowerCase();
    if (ext.isEmpty) return false;
    // p.extension includes the leading dot — strip it.
    final bare = ext.substring(1);
    return AppConstants.supportedAudioExtensions.contains(bare);
  }

  /// Public helper for unit testing extension filtering.
  bool isSupportedExtension(String filePath) => _isSupported(filePath);
}
