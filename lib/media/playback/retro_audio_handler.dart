import 'dart:io';
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
  Future<void> play() async {
    // ignore: avoid_print
    print('[RetroWave] Action: play()');
    try {
      await _player.play();
    } catch (e, stack) {
      // ignore: avoid_print
      print('[RetroWave] play() error: $e\n$stack');
    }
  }

  @override
  Future<void> pause() async {
    // ignore: avoid_print
    print('[RetroWave] Action: pause()');
    await _player.pause();
  }

  @override
  Future<void> stop() async {
    // ignore: avoid_print
    print('[RetroWave] Action: stop()');
    await _player.stop();
    playbackState.add(playbackState.value.copyWith(
      processingState: AudioProcessingState.idle,
      playing: false,
    ));
  }

  @override
  Future<void> seek(Duration position) async {
    // ignore: avoid_print
    print('[RetroWave] Action: seek($position)');
    await _player.seek(position);
  }

  @override
  Future<void> skipToNext() async {
    // ignore: avoid_print
    print('[RetroWave] Action: skipToNext()');
    if (_currentIndex + 1 < _tracks.length) {
      await _playIndex(_currentIndex + 1);
    }
  }

  @override
  Future<void> skipToPrevious() async {
    // ignore: avoid_print
    print('[RetroWave] Action: skipToPrevious()');
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

    // Announce current media item immediately
    mediaItem.add(_toMediaItem(item));

    final file = File(item.path);
    final exists = file.existsSync();
    final size = exists ? file.lengthSync() : 0;

    // Diagnostic logging per specification
    // ignore: avoid_print
    print('[RetroWave] Selected:\n${item.path}');
    // ignore: avoid_print
    print('[RetroWave] Exists: $exists');
    // ignore: avoid_print
    print('[RetroWave] Size: $size bytes');
    // ignore: avoid_print
    print('[RetroWave] Loading audio source...');

    if (!exists || size == 0) {
      final errorMsg = !exists ? 'File does not exist' : 'File is empty (0 bytes)';
      // ignore: avoid_print
      print('[RetroWave] Error: $errorMsg');
      playbackState.add(playbackState.value.copyWith(
        processingState: AudioProcessingState.error,
        errorMessage: errorMsg,
      ));
      return;
    }

    try {
      final duration = await _player.setFilePath(item.path);
      // ignore: avoid_print
      print('[RetroWave] Duration: $duration');
      if (duration != null) {
        mediaItem.add(_toMediaItem(item).copyWith(duration: duration));
      }

      // ignore: avoid_print
      print('[RetroWave] Starting playback...');
      await _player.play();
      // ignore: avoid_print
      print('[RetroWave] Playing: ${_player.playing}');
    } on PlayerException catch (e, stack) {
      // ignore: avoid_print
      print('[RetroWave] PlayerException (${e.code}): ${e.message}\n$stack');
      playbackState.add(playbackState.value.copyWith(
        processingState: AudioProcessingState.error,
        errorCode: e.code,
        errorMessage: e.message ?? 'Unable to decode audio file',
      ));
    } catch (e, stack) {
      // ignore: avoid_print
      print('[RetroWave] Playback error: $e\n$stack');
      playbackState.add(playbackState.value.copyWith(
        processingState: AudioProcessingState.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onPlayerStateChanged(PlayerState state) {
    final processingState = _mapProcessingState(state.processingState);
    final playing = state.playing;

    // ignore: avoid_print
    print('[RetroWave] PlayerState: playing=$playing, state=${state.processingState}');

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
      // ignore: avoid_print
      print('[RetroWave] Track completed. Auto-advancing...');
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
    print('[RetroWave] Stream playback error: $error\n$stack');
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
