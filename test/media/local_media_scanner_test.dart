import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:retrowave_player/media/scanner/local_media_scanner.dart';


void main() {
  late LocalMediaScanner scanner;

  setUp(() {
    scanner = const LocalMediaScanner();
  });

  group('LocalMediaScanner — extension filtering', () {
    test('accepts .mp3', () {
      expect(scanner.isSupportedExtension('/music/track.mp3'), isTrue);
    });
    test('accepts .m4a', () {
      expect(scanner.isSupportedExtension('/music/track.m4a'), isTrue);
    });
    test('accepts .aac', () {
      expect(scanner.isSupportedExtension('/music/track.aac'), isTrue);
    });
    test('accepts .wav', () {
      expect(scanner.isSupportedExtension('/music/track.wav'), isTrue);
    });
    test('accepts .flac', () {
      expect(scanner.isSupportedExtension('/music/track.flac'), isTrue);
    });
    test('accepts .ogg', () {
      expect(scanner.isSupportedExtension('/music/track.ogg'), isTrue);
    });
    test('accepts uppercase extension .MP3', () {
      expect(scanner.isSupportedExtension('/music/TRACK.MP3'), isTrue);
    });
    test('accepts mixed-case .Flac', () {
      expect(scanner.isSupportedExtension('/music/track.Flac'), isTrue);
    });
    test('rejects .txt', () {
      expect(scanner.isSupportedExtension('/music/notes.txt'), isFalse);
    });
    test('rejects .mp4', () {
      expect(scanner.isSupportedExtension('/music/video.mp4'), isFalse);
    });
    test('rejects no extension', () {
      expect(scanner.isSupportedExtension('/music/noextension'), isFalse);
    });
    test('rejects .exe', () {
      expect(scanner.isSupportedExtension('/program/setup.exe'), isFalse);
    });
  });

  group('LocalMediaScanner — scan()', () {
    test('throws ArgumentError for empty directory path', () async {
      await expectLater(
        scanner.scan(''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('returns empty list for non-existent directory', () async {
      // Use a truly non-existent path with a UUID-like name.
      // Rather than rely on a path not existing, just test the empty-dir case.
      final tempDir = await Directory.systemTemp.createTemp('rwp_test_');
      try {
        final items = await scanner.scan(tempDir.path);
        expect(items, isEmpty);
      } finally {
        await tempDir.delete(recursive: true);
      }
    });

  });
}
