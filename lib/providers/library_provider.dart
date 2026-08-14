import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage/preferences_service.dart';
import '../media/models/local_media_item.dart';
import '../media/scanner/local_media_scanner.dart';


// ── PreferencesService provider ───────────────────────────────────────────────
//
// Overridden at startup in main.dart after await PreferencesService.create().

final preferencesServiceProvider = Provider<PreferencesService>(
  (ref) => throw UnimplementedError(
    'preferencesServiceProvider must be overridden in ProviderScope.',
  ),
);

// ── Selected folder provider ──────────────────────────────────────────────────

/// Holds the currently selected music folder path, persisted across restarts.
final selectedFolderProvider =
    StateNotifierProvider<SelectedFolderNotifier, String?>(
  (ref) {
    final prefs = ref.watch(preferencesServiceProvider);
    return SelectedFolderNotifier(prefs);
  },
);

class SelectedFolderNotifier extends StateNotifier<String?> {
  SelectedFolderNotifier(this._prefs) : super(_prefs.musicFolderPath);

  final PreferencesService _prefs;

  /// Open the OS folder picker and save the selection.
  /// Returns [true] if a folder was selected, [false] if cancelled.
  Future<bool> pickFolder() async {
    try {
      final result = await FilePickerPlatform.instance.getDirectoryPath(
        dialogTitle: 'Select Music Folder',
      );
      if (result == null) return false;
      await _prefs.setMusicFolderPath(result);
      state = result;
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('[SelectedFolderNotifier] pickFolder error: $e');
      return false;
    }
  }

  /// Clear the saved folder selection.
  Future<void> clearFolder() async {
    await _prefs.clearMusicFolderPath();
    state = null;
  }
}

// ── Music library provider ────────────────────────────────────────────────────

/// Holds the scanned list of [LocalMediaItem]s for the selected folder.
final musicLibraryProvider =
    StateNotifierProvider<MusicLibraryNotifier, MusicLibraryState>(
  (ref) {
    final notifier = MusicLibraryNotifier();
    // Automatically rescan when the selected folder changes.
    ref.listen<String?>(selectedFolderProvider, (_, folder) {
      if (folder != null) {
        notifier.scanFolder(folder);
      } else {
        notifier.clear();
      }
    });
    return notifier;
  },
);

/// State of the music library scan.
sealed class MusicLibraryState {
  const MusicLibraryState();
}

class MusicLibraryIdle extends MusicLibraryState {
  const MusicLibraryIdle();
}

class MusicLibraryLoading extends MusicLibraryState {
  const MusicLibraryLoading();
}

class MusicLibraryLoaded extends MusicLibraryState {
  const MusicLibraryLoaded(this.items);
  final List<LocalMediaItem> items;
}

class MusicLibraryError extends MusicLibraryState {
  const MusicLibraryError(this.message);
  final String message;
}

class MusicLibraryNotifier extends StateNotifier<MusicLibraryState> {
  MusicLibraryNotifier() : super(const MusicLibraryIdle());

  final _scanner = const LocalMediaScanner();

  /// Scan [folderPath] and update state.
  Future<void> scanFolder(String folderPath) async {
    state = const MusicLibraryLoading();
    try {
      final items = await _scanner.scan(folderPath);
      state = MusicLibraryLoaded(items);
    } catch (e) {
      state = MusicLibraryError('Failed to scan folder: $e');
    }
  }

  /// Clear the library.
  void clear() => state = const MusicLibraryIdle();

  /// Rescan the given folder (e.g., refresh button).
  Future<void> rescan(String folderPath) => scanFolder(folderPath);
}
