import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// Thin wrapper around [SharedPreferences] for typed access to
/// lightweight persisted state (selected folder, last played path, etc.).
///
/// This is intentionally minimal for Phases 1–6. Phase 13+ will migrate
/// heavier persistence to Drift/SQLite.
class PreferencesService {
  PreferencesService._(this._prefs);

  final SharedPreferences _prefs;

  /// Factory constructor — call once at startup via [create].
  static Future<PreferencesService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferencesService._(prefs);
  }

  // ── Music Folder ──────────────────────────────────────────────────────────

  String? get musicFolderPath =>
      _prefs.getString(AppConstants.prefKeyMusicFolder);

  Future<void> setMusicFolderPath(String path) =>
      _prefs.setString(AppConstants.prefKeyMusicFolder, path);

  Future<void> clearMusicFolderPath() =>
      _prefs.remove(AppConstants.prefKeyMusicFolder);

  // ── Last Played ───────────────────────────────────────────────────────────

  String? get lastPlayedPath =>
      _prefs.getString(AppConstants.prefKeyLastPlayedPath);

  Future<void> setLastPlayedPath(String path) =>
      _prefs.setString(AppConstants.prefKeyLastPlayedPath, path);

  Future<void> clearLastPlayedPath() =>
      _prefs.remove(AppConstants.prefKeyLastPlayedPath);
}
