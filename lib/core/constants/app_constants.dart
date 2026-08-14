/// Application-wide constants for RetroWave Player.
library;

class AppConstants {
  AppConstants._();

  /// Audio file extensions supported by Phase 1–6.
  static const List<String> supportedAudioExtensions = [
    'mp3',
    'm4a',
    'aac',
    'wav',
    'flac',
    'ogg',
  ];

  /// Key used to persist the selected music folder path.
  static const String prefKeyMusicFolder = 'music_folder_path';

  /// Key used to persist the last-played track path.
  static const String prefKeyLastPlayedPath = 'last_played_path';

  /// Application name.
  static const String appName = 'RetroWave Player';
}
