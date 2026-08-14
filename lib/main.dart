import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'core/storage/preferences_service.dart';
import 'features/player/player_screen.dart';
import 'media/playback/retro_audio_handler.dart';
import 'providers/audio_provider.dart';
import 'providers/library_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Initialise shared preferences ──────────────────────────────────────────
  final prefs = await PreferencesService.create();

  // ── Initialise audio service ───────────────────────────────────────────────
  //
  // On Android:  AudioService.init() registers the RetroAudioHandler with the
  //              Android MediaSession and starts the foreground service.
  //
  // On Windows:  AudioService.init() is a lightweight no-op at the OS level;
  //              the handler is still created and used as the playback abstraction.
  //
  final handler = await AudioService.init<RetroAudioHandler>(
    builder: RetroAudioHandler.new,
    config: AudioServiceConfig(
      androidNotificationChannelId: 'com.retrowave.player.channel',
      androidNotificationChannelName: 'RetroWave Player',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: false,
      androidNotificationIcon: 'mipmap/ic_launcher',
      notificationColor: const Color(0xFF1A1A2E),
    ),
  );

  runApp(
    ProviderScope(
      overrides: [
        // Provide the audio handler singleton to the Riverpod graph.
        audioHandlerProvider.overrideWithValue(handler),
        // Provide the preferences singleton.
        preferencesServiceProvider.overrideWithValue(prefs),
      ],
      child: const RetroWaveApp(),
    ),
  );
}

class RetroWaveApp extends StatelessWidget {
  const RetroWaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF5C8FD6),
          secondary: Color(0xFF90CAF9),
          surface: Color(0xFF1E1E1E),
          error: Color(0xFFCF6679),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Color(0xFFE0E0E0),
          elevation: 0,
        ),
        listTileTheme: const ListTileThemeData(
          tileColor: Color(0xFF121212),
          selectedTileColor: Color(0xFF1A2A3A),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        ),
      ),
      home: _AppShell(),
    );
  }
}

/// Wraps [PlayerScreen] and handles the initial folder-restore scan.
class _AppShell extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<_AppShell> {
  @override
  void initState() {
    super.initState();
    // Trigger a scan of the previously selected folder (if any) on startup.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final folder = ref.read(selectedFolderProvider);
      if (folder != null) {
        ref.read(musicLibraryProvider.notifier).scanFolder(folder);
      }
    });
  }

  @override
  Widget build(BuildContext context) => const PlayerScreen();
}
