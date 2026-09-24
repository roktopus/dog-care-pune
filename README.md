# Dog Help Pune

A Flutter app for reporting stray-dog issues in Pune and following those reports on a map.

Dog Help Pune is an independent civic app. It is not an official Pune Municipal Corporation application, and it does not submit complaints to PMC CARE yet.

## Features

- Welcome screen and a home dashboard with open and resolved counts
- A three-step report: photo, issue details, and review
- Camera or gallery photo via `image_picker`
- Live OpenStreetMap view via `flutter_map`, with pan, zoom, and report pins around Kondhwa
- Tap or **Change** on the report screen to drop a location pin
- My Reports with All, Open, and Resolved filters
- Report timeline, nearby map, notifications, profile, and help

## Current test behavior

Mobile verification is bypassed so the app can be tried without a one-time password.

- **Get Started** and **I already have an account** open Home directly.
- Reports shown on first launch are sample data stored in memory for that session.
- A new report gets a local reference number. It is not an official PMC reference.
- Closing the app clears reports added during the session. Nothing is written to a database yet.

## Requirements

- [Flutter](https://docs.flutter.dev/install) stable with Dart `3.13` or later (`sdk: ^3.13.2` in `pubspec.yaml`)
- Xcode with a signing team, for an iPhone
- Android Studio or the Android SDK, for an Android device or emulator
- A network connection so map tiles can load

Check the toolchain:

```bash
flutter doctor
```

## Getting started

```bash
git clone <repository-url>
cd dog-care-pune
flutter pub get
```

Run on a connected device or emulator:

```bash
flutter devices
flutter run
```

Run on a specific device:

```bash
flutter run -d <device-id>
```

On iOS 14 and later, a debug build launched from the home screen shows a black screen. Start debug builds with `flutter run`, or install a release build when you want to open the app from the home screen:

```bash
flutter build ios --release
flutter build apk --release
```

Static analysis and tests:

```bash
flutter analyze
flutter test
```

## Project structure

```text
lib/
  main.dart                 App entry, theme, and AppScope
  src/
    models.dart             Reports, issue types, and status
    store.dart              In-memory session state and sample reports
    theme.dart              Colors and ThemeData
    widgets.dart            Shared UI and the OpenStreetMap view
    screens/                Welcome, home, report flow, list, detail, map, help
assets/images/              Logo, hero art, and report photos
test/widget_test.dart       Welcome-screen widget test
```

State is a `ChangeNotifier` (`AppStore`) exposed with `InheritedNotifier`. Screens read it through `AppScope.of(context)`.

## Permissions

| Platform | Permission | Why |
| --- | --- | --- |
| iOS | Camera | Take a report photo |
| iOS | Photo library | Choose a report photo |
| iOS | Location when in use | Declared for a future device-location fix |
| Android | Camera, photos, location | Same reasons |

The map itself does not request location. The blue dot is a fixed Kondhwa point until device location is wired in.

## Map tiles

Map imagery comes from [OpenStreetMap](https://www.openstreetmap.org/copyright) through `https://tile.openstreetmap.org`. Tile requests send the app package name as the user agent, which is required by the [OSM tile usage policy](https://operations.osmfoundation.org/policies/tiles/).

Do not point production traffic at the public tile server. For a wider release, use a tile provider that allows your traffic, or host tiles yourself.

## App identity

| | |
| --- | --- |
| Display name | Dog Help Pune |
| Package | `dog_help_pune` |
| iOS bundle id | `in.pune.doghelp.dogHelpPune` |
| Android application id | `in.pune.doghelp.dog_help_pune` |
| Version | `1.0.0+1` |

`publish_to: none` in `pubspec.yaml` keeps this app off pub.dev.

## Not in this build

- PMC CARE sign-in, complaint submission, or official status
- Persistent local storage
- Device GPS for “your location”
- Push notifications

## License

[MIT](LICENSE)
