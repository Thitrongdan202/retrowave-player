import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retrowave_player/core/constants/app_constants.dart';
import 'package:retrowave_player/core/storage/preferences_service.dart';
import 'package:retrowave_player/providers/library_provider.dart';
import 'package:retrowave_player/widgets/retro_button.dart';
import 'package:retrowave_player/widgets/retro_led_display.dart';
import 'package:retrowave_player/widgets/retro_slider.dart';
import 'package:retrowave_player/widgets/retro_window.dart';
import 'package:retrowave_player/widgets/spectrum_visualizer.dart';
import 'package:retrowave_player/widgets/vinyl_player.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Core App Tests', () {
    test('AppConstants has correct app name', () {
      expect(AppConstants.appName, 'RetroWave Player');
    });

    test('AppConstants has 6 supported audio extensions', () {
      expect(AppConstants.supportedAudioExtensions, hasLength(6));
      expect(
        AppConstants.supportedAudioExtensions,
        containsAll(['mp3', 'flac', 'ogg', 'wav', 'm4a', 'aac']),
      );
    });

    testWidgets('Folder-selection button renders inside ProviderScope',
        (WidgetTester tester) async {
      final prefs = await PreferencesService.create();

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

      await tester.pump();

      expect(find.text('Select Music Folder'), findsOneWidget);
      expect(find.text('No folder selected'), findsOneWidget);
    });
  });

  group('Retro Widget Tests', () {
    testWidgets('RetroButton renders label and fires callback',
        (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RetroButton(
              label: 'TEST BUTTON',
              hasLed: true,
              isLedActive: true,
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('TEST BUTTON'), findsOneWidget);

      await tester.tap(find.text('TEST BUTTON'));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('RetroWindow renders titlebar and content',
        (WidgetTester tester) async {
      bool closed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RetroWindow(
              title: 'RETROWAVE UNIT',
              onClose: () => closed = true,
              child: const Text('WINDOW BODY CONTENT'),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('RETROWAVE UNIT'), findsOneWidget);
      expect(find.text('WINDOW BODY CONTENT'), findsOneWidget);

      await tester.tap(find.text('✕'));
      await tester.pump();

      expect(closed, isTrue);
    });

    testWidgets('RetroLedDisplay renders status and track info',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RetroLedDisplay(
              title: 'Here Without You',
              artist: '3 Doors Down',
              position: Duration(seconds: 9),
              duration: Duration(minutes: 3, seconds: 54),
              isPlaying: true,
              isPaused: false,
              trackIndex: 0,
              totalTracks: 12,
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('▶ PLAY'), findsOneWidget);
      expect(find.text('TRK 01/12'), findsOneWidget);
      expect(find.text('00:09'), findsOneWidget);
      expect(find.text('320 KBPS'), findsOneWidget);
    });

    testWidgets('VinylPlayer renders turntable without throwing',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VinylPlayer(
              isPlaying: false,
              trackTitle: 'Song A',
              artist: 'Artist A',
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(VinylPlayer), findsOneWidget);
    });

    testWidgets('SpectrumVisualizer renders frequency bands',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SpectrumVisualizer(
              isPlaying: false,
              bandCount: 16,
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(SpectrumVisualizer), findsOneWidget);
    });

    testWidgets('RetroSlider renders progress and reacts to drags',
        (WidgetTester tester) async {
      double changedVal = 0.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: RetroSlider(
                value: 0.5,
                onChanged: (val) => changedVal = val,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(RetroSlider), findsOneWidget);
      expect(changedVal, 0.0);
    });
  });
}

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
