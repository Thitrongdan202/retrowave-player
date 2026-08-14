import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../media/playback/retro_audio_handler.dart';
import '../media/playback/audio_player_service.dart';

// ── Handler provider ──────────────────────────────────────────────────────────
//
// This provider is populated during app startup in main.dart via
// [audioHandlerProvider.overrideWithValue(handler)].
//
// We declare it as a simple Provider<RetroAudioHandler> so that it can be
// overridden at the ProviderScope level after AudioService.init() completes.

final audioHandlerProvider = Provider<RetroAudioHandler>(
  (ref) => throw UnimplementedError(
    'audioHandlerProvider must be overridden in ProviderScope with the '
    'RetroAudioHandler instance created by AudioService.init().',
  ),
);

// ── AudioPlayerService provider ───────────────────────────────────────────────

final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return AudioPlayerService(handler);
});

// ── Playback state provider ───────────────────────────────────────────────────

/// Reactive [PlaybackState] stream — the UI watches this to update controls.
final playbackStateProvider = StreamProvider<PlaybackState>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.playbackStateStream;
});

/// Reactive current [MediaItem] stream (current track title, art, duration).
final currentMediaItemProvider = StreamProvider<MediaItem?>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.mediaItemStream;
});

/// Reactive playback position stream.
final positionProvider = StreamProvider<Duration>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.positionStream;
});

/// Reactive track duration stream.
final durationProvider = StreamProvider<Duration?>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.durationStream;
});
