# RetroWave Player

An offline-first personal media player built with Flutter.

## Current Status: Phases 1–6

| Phase | Description | Status |
|-------|-------------|--------|
| 1 | Flutter project + Riverpod foundation | ✅ |
| 2 | Local persistence (SharedPreferences) | ✅ |
| 3 | Local filesystem media scanner | ✅ |
| 4 | Local audio playback (just_audio) | ✅ |
| 5 | Android background audio architecture | ✅ |
| 6 | Android notification / lock-screen / BT controls | ✅ |
| 7+ | Retro visual theme (Winamp-style), advanced features | 🔜 |

---

## Architecture

```
Flutter UI (PlayerScreen)
       ↓
Riverpod Providers
  ├── audioHandlerProvider
  ├── audioPlayerServiceProvider
  ├── selectedFolderProvider
  └── musicLibraryProvider
       ↓
Services
  ├── AudioPlayerService   — playback control façade
  ├── RetroAudioHandler    — extends BaseAudioHandler (audio_service)
  ├── LocalMediaScanner    — recursive filesystem scanner
  └── PreferencesService   — SharedPreferences wrapper
       ↓
Platform / Playback
  ├── just_audio           — cross-platform audio engine
  └── audio_service        — Android MediaSession / foreground service
```

### Key Decisions

- **No Drift**: Phase 1–6 uses `SharedPreferences` for lightweight state only. SQLite arrives in Phase 13+.
- **No broad storage permissions**: Modern `file_picker` API handles folder access without `READ_EXTERNAL_STORAGE`.
- **`audio_service` on Windows**: `AudioService.init()` is a no-op at the OS level on Windows; `RetroAudioHandler` acts as a clean playback abstraction on all platforms.
- **`RetroAudioHandler` extends `BaseAudioHandler with SeekHandler`**: Automatically provides seek-bar delta operations.

---

## Project Structure

```
lib/
├── core/
│   ├── constants/app_constants.dart     # supported extensions, pref keys
│   └── storage/preferences_service.dart # SharedPreferences wrapper
├── media/
│   ├── models/local_media_item.dart     # immutable audio file model
│   ├── scanner/local_media_scanner.dart # recursive FS scanner
│   └── playback/
│       ├── audio_player_service.dart    # façade over RetroAudioHandler
│       └── retro_audio_handler.dart     # BaseAudioHandler implementation
├── providers/
│   ├── audio_provider.dart              # audio + playback state providers
│   └── library_provider.dart           # folder selection + library scan
├── features/player/
│   └── player_screen.dart              # functional dark-theme player UI
└── main.dart
```

---

## Supported Platforms

| Platform | Background audio | Lock-screen controls | Bluetooth/headset |
|----------|:----------------:|:--------------------:|:-----------------:|
| Windows  | ✅ (app stays open) | — | — |
| Android  | ✅ | ✅ | ✅ |

---

## Supported Audio Formats

`mp3` · `m4a` · `aac` · `wav` · `flac` · `ogg`

---

## Installation & Run

### Prerequisites

- Flutter 3.47.0 or later
- Dart 3.13.0 or later
- Windows: Visual Studio 2022 with "Desktop development with C++" workload
- Android: Android SDK, NDK

### Get dependencies

```bash
flutter pub get
```

### Run on Windows

```bash
flutter run -d windows
```

### Run on Android

```bash
flutter run -d <device-id>
```

List connected devices:

```bash
flutter devices
```

---

## Windows Testing Checklist

1. Launch app, window opens
2. Click **Select Music Folder**, OS folder picker opens
3. Choose a folder containing MP3s
4. Track list appears
5. Click a track, audio plays through speakers
6. Click pause, audio pauses
7. Click play, audio resumes
8. Click next, skip to next track
9. Click previous, restart or go back
10. Drag seek bar, position jumps
11. Minimize window, audio continues

---

## Android Testing Checklist

1. Launch and select a folder containing audio files
2. Tap a track, playback begins
3. Press Home, audio continues in background
4. Lock screen, lock-screen controls appear (Previous / Play-Pause / Next)
5. Bluetooth headset button events control playback
6. Notification Previous / Play-Pause / Next buttons work
7. Swipe away notification, audio stops (foreground service ends)

---

## Known Limitations (Phase 1–6)

- No ID3 metadata parsing — titles are derived from filenames
- No album art
- No playlist persistence — queue resets on app restart
- No shuffle or repeat modes
- No Windows-specific lock-screen / OS media key integration (SMTC)
- No retro visual theme (Winamp-style UI comes in Phase 7+)
- Android folder picker scope may vary by device/OS version

---

## Running Tests

```bash
flutter analyze
flutter test
```

---

## Initial Git Commit

```bash
git init
git add .
git commit -m "feat: bootstrap retrowave player audio foundation"
```
