import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../../media/models/local_media_item.dart';

/// The RetroWave audio handler.
///
/// Extends [BaseAudioHandler] so that `audio_service` can bridge this handler
/// to the Android MediaSession / foreground service and lock-screen controls.
///
/// On Windows the handler is used directly as a playback abstraction —
/// no OS-level audio service registration is needed.
///
/// Architecture:
/// ```
/// Flutter UI
///      ↓
/// RetroAudioHandler (this class)
///      ↓
/// just_audio  AudioPlayer
///      ↓
/// Local audio file
/// ```
class RetroAudioHandler extends BaseAudioHandler with SeekHandler {
  RetroAudioHandler() {
    _init();
  }

  final AudioPlayer _player = AudioPlayer();

  /// Ordered list of tracks in the current session.
  final List<LocalMediaItem> _tracks = [];

  /// Index of the currently selected track.
  int _currentIndex = -1;

  // ── Initialisation ────────────────────────────────────────────────────────

  void _init() {
    // Forward just_audio player state into audio_service's playbackState stream.
    _player.playerStateStream.listen(_onPlayerStateChanged);
    _player.positionStream.listen(_onPositionChanged);
    _player.durationStream.listen(_onDurationChanged);

    // Forward just_audio errors to playbackState as error state.
    _player.playbackEventStream.listen(
      (_) {},
      onError: _onPlaybackError,
    );
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Load [tracks] into the queue and immediately play [startIndex].
  Future<void> loadAndPlay(List<LocalMediaItem> tracks, int startIndex) async {
    if (tracks.isEmpty) return;
    if (startIndex < 0 || startIndex >= tracks.length) return;

    _tracks
      ..clear()
      ..addAll(tracks);

    // Publish the full queue to audio_service.
    queue.add(_tracks.map(_toMediaItem).toList());

    await _playIndex(startIndex);
  }

  // ── BaseAudioHandler overrides ────────────────────────────────────────────

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    playbackState.add(playbackState.value.copyWith(
      processingState: AudioProcessingState.idle,
    ));
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    if (_currentIndex + 1 < _tracks.length) {
      await _playIndex(_currentIndex + 1);
    }
  }

  @override
  Future<void> skipToPrevious() async {
    // If we're more than 3 s in, restart current track; otherwise go back.
    final pos = _player.position;
    if (pos.inSeconds > 3 || _currentIndex == 0) {
      await _player.seek(Duration.zero);
      if (!_player.playing) await _player.play();
    } else if (_currentIndex > 0) {
      await _playIndex(_currentIndex - 1);
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= _tracks.length) return;
    await _playIndex(index);
  }

  @override
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  // setVolume is not part of BaseAudioHandler — it's a custom method.
  Future<void> setVolume(double volume) => _player.setVolume(volume);

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<void> _playIndex(int index) async {
    _currentIndex = index;
    final item = _tracks[index];

    // Announce the current media item to audio_service (→ notification art etc.)
    mediaItem.add(_toMediaItem(item));

    // Connect the file to just_audio and begin playback.
    try {
      await _player.setAudioSource(
        AudioSource.file(item.path, tag: _toMediaItem(item)),
      );
      await _player.play();
    } on PlayerException catch (e) {
      playbackState.add(playbackState.value.copyWith(
        processingState: AudioProcessingState.error,
        errorCode: e.code,
        errorMessage: e.message ?? 'Playback error',
      ));
    } on Exception catch (e) {
      playbackState.add(playbackState.value.copyWith(
        processingState: AudioProcessingState.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onPlayerStateChanged(PlayerState state) {
    final processingState = _mapProcessingState(state.processingState);
    final playing = state.playing;

    playbackState.add(playbackState.value.copyWith(
      controls: _buildControls(playing),
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: processingState,
      playing: playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: _currentIndex,
    ));

    // Auto-advance to next track when current finishes.
    if (processingState == AudioProcessingState.completed) {
      skipToNext();
    }
  }

  void _onPositionChanged(Duration position) {
    playbackState.add(playbackState.value.copyWith(
      updatePosition: position,
    ));
  }

  void _onDurationChanged(Duration? duration) {
    if (duration != null && mediaItem.valueOrNull != null) {
      mediaItem.add(mediaItem.value!.copyWith(duration: duration));
    }
  }

  void _onPlaybackError(Object error, StackTrace stack) {
    // ignore: avoid_print
    print('[RetroAudioHandler] Playback error: $error');
    playbackState.add(playbackState.value.copyWith(
      processingState: AudioProcessingState.error,
      errorMessage: error.toString(),
    ));
  }

  List<MediaControl> _buildControls(bool playing) => [
        MediaControl.skipToPrevious,
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
        MediaControl.stop,
      ];

  AudioProcessingState _mapProcessingState(ProcessingState state) {
    switch (state) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

  MediaItem _toMediaItem(LocalMediaItem item) => MediaItem(
        id: item.id,
        title: item.title,
        playable: true,
        extras: {'path': item.path},
      );

  // ── Convenience getters for UI ────────────────────────────────────────────

  /// The current queue of tracks.
  List<LocalMediaItem> get tracks => List.unmodifiable(_tracks);

  /// Index of the currently playing (or selected) track.
  int get currentIndex => _currentIndex;

  /// Expose the raw just_audio position stream for the seek bar.
  Stream<Duration> get positionStream => _player.positionStream;

  /// Expose the raw just_audio duration stream for the seek bar.
  Stream<Duration?> get durationStream => _player.durationStream;

  /// Whether the player is currently playing.
  bool get isPlaying => _player.playing;

  // ── Disposal ──────────────────────────────────────────────────────────────

  /// Dispose resources. Call when the application exits.
  Future<void> dispose() async {
    await _player.dispose();
  }
}
