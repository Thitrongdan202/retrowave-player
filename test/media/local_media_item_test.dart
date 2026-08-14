import 'package:flutter_test/flutter_test.dart';
import 'package:retrowave_player/media/models/local_media_item.dart';

void main() {
  group('LocalMediaItem', () {
    test('fromPath derives title from filename without extension', () {
      final item = LocalMediaItem.fromPath('/music/My Great Song.mp3');
      expect(item.title, 'My Great Song');
    });

    test('fromPath replaces underscores and dashes with spaces', () {
      final item = LocalMediaItem.fromPath('/music/my_great-song.flac');
      expect(item.title, 'my great song');
    });

    test('fromPath sets id equal to path', () {
      const path = '/music/song.mp3';
      final item = LocalMediaItem.fromPath(path);
      expect(item.id, path);
      expect(item.path, path);
    });

    test('fromPath sets type to audio', () {
      final item = LocalMediaItem.fromPath('/music/track.wav');
      expect(item.type, 'audio');
    });

    test('equality is based on id (path)', () {
      final a = LocalMediaItem.fromPath('/music/song.mp3');
      final b = LocalMediaItem.fromPath('/music/song.mp3');
      final c = LocalMediaItem.fromPath('/music/other.mp3');
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('fromPath replaces underscores in filename', () {
      final item = LocalMediaItem.fromPath('/music/track_name_here.mp3');
      expect(item.title, 'track name here');
    });



    test('const constructor sets fields correctly', () {
      const item = LocalMediaItem(
        id: 'abc',
        path: '/path/to/file.mp3',
        title: 'Custom Title',
        type: 'audio',
      );
      expect(item.id, 'abc');
      expect(item.title, 'Custom Title');
      expect(item.type, 'audio');
    });
  });
}
