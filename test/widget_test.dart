// Widget smoke test — verifies the app renders its core structure.
//
// Does NOT create a real RetroAudioHandler or AudioPlayer — both require
// platform audio initialization which hangs in headless test environments.
// The unit tests (local_media_item_test, local_media_scanner_test) cover
// the core business logic. This file just verifies the widget layer compiles
// and the Riverpod provider scope works for non-audio providers.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retrowave_player/core/constants/app_constants.dart';
import 'package:retrowave_player/core/storage/preferences_service.dart';
import 'package:retrowave_player/providers/library_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('AppConstants has correct app name', () {
    expect(AppConstants.appName, 'RetroWave Player');
  });

  test('AppConstants has 6 supported audio extensions', () {
    expect(AppConstants.supportedAudioExtensions, hasLength(6));
    expect(AppConstants.supportedAudioExtensions, containsAll(['mp3', 'flac', 'ogg', 'wav', 'm4a', 'aac']));
  });

  testWidgets('Folder-selection button renders inside ProviderScope',
      (WidgetTester tester) async {
    final prefs = await PreferencesService.create();

    // _FolderButtonStub only reads selectedFolderProvider which depends only
    // on preferencesServiceProvider — no audio subsystem is needed.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          preferencesServiceProvider.overrideWithValue(prefs),
        ],
        child: const MaterialApp(
          home: Scaffold(body: _FolderButtonStub()),
        ),
      ),
    );

    // One pump is sufficient — no async audio initialization involved.
    await tester.pump();

    expect(find.text('Select Music Folder'), findsOneWidget);
    expect(find.text('No folder selected'), findsOneWidget);
  });
}

/// Minimal widget that exercises [selectedFolderProvider] without
/// touching any audio providers.
class _FolderButtonStub extends ConsumerWidget {
  const _FolderButtonStub();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folder = ref.watch(selectedFolderProvider);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: () {},
          child: const Text('Select Music Folder'),
        ),
        Text(folder ?? 'No folder selected'),
      ],
    );
  }
}
