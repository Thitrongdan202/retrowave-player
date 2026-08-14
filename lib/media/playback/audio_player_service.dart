import 'package:audio_service/audio_service.dart';
import '../playback/retro_audio_handler.dart';
import '../models/local_media_item.dart';

/// High-level audio service facade used by Riverpod providers and the UI.
///
/// Wraps [RetroAudioHandler] and exposes a clean API for playing a track
/// from a list, controlling playback, and seeking.
///
/// This service does NOT contain state — state is held by [RetroAudioHandler]
/// which broadcasts via [audio_service] streams.
class AudioPlayerService {
  AudioPlayerService(this._handler);

  final RetroAudioHandler _handler;

  // ── Playback control ──────────────────────────────────────────────────────

  /// Load [tracks] and start playing the track at [index].
  Future<void> playTrack(List<LocalMediaItem> tracks, int index) =>
      _handler.loadAndPlay(tracks, index);

  Future<void> play() => _handler.play();
  Future<void> pause() => _handler.pause();
  Future<void> stop() => _handler.stop();
  Future<void> next() => _handler.skipToNext();
  Future<void> previous() => _handler.skipToPrevious();

  Future<void> seek(Duration position) => _handler.seek(position);

  Future<void> setVolume(double volume) => _handler.setVolume(volume);
  Future<void> setSpeed(double speed) => _handler.setSpeed(speed);

  // ── State streams ─────────────────────────────────────────────────────────

  /// Broadcast stream of [PlaybackState] from audio_service.
  Stream<PlaybackState> get playbackStateStream =>
      _handler.playbackState.stream;

  /// Current snapshot of playback state.
  PlaybackState get playbackState => _handler.playbackState.value;

  /// Stream of the currently playing [MediaItem].
  Stream<MediaItem?> get mediaItemStream => _handler.mediaItem.stream;

  /// Stream of current playback position.
  Stream<Duration> get positionStream => _handler.positionStream;

  /// Stream of total track duration.
  Stream<Duration?> get durationStream => _handler.durationStream;

  // ── Queue info ────────────────────────────────────────────────────────────

  List<LocalMediaItem> get tracks => _handler.tracks;
  int get currentIndex => _handler.currentIndex;
  bool get isPlaying => _handler.isPlaying;
}
