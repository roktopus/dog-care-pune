# Dog Help Pune

A Flutter self-help app for reporting stray-dog issues anywhere in Pune through the citizen’s own PMC CARE account.

Dog Help Pune is an independent civic app. It is not an official Pune Municipal Corporation product, and it does not offer an in-app support desk.

## Features

- PMC CARE sign-in with the citizen’s mobile number and the 4-digit OTP PMC sends
- Three-step report: photo, details (location, ward, prabhag), review and send
- Camera or gallery photo kept on the phone (PMC receives description and location; attachment is empty because this app has no image host)
- Device location or a pin anywhere in Pune, with automatic ward/prabhag suggestion from PMC prabhag boundaries
- My Reports and My Map for reports filed from this phone only (no shared community feed)
- Local SQLite history and secure session storage; status refresh from PMC while signed in

## PMC CARE account

A PMC CARE account is required. This app does not create accounts.

1. Welcome → **I don’t have a PMC CARE account** opens [PMC registration](https://www.pmccare.in/Login/enter-mobile-number/register).
2. An unknown number stays locked and opens the same page.
3. After registering, use **I’ve registered — check again**, then enter the 4-digit OTP.

## Requirements

- Flutter stable / Dart `^3.13.2` (`pubspec.yaml`)
- Xcode + signing team (iOS), CocoaPods (`cd ios && pod install`)
- Android SDK for Android builds
- Network for PMC CARE and map tiles

```bash
flutter doctor
```

## Getting started (production)

Default builds talk to live PMC CARE (`https://api.pmccare.in`). Do not pass `FAKE_PMC` for real use.

```bash
git clone <repository-url>
cd dog-care-pune
flutter pub get
cd ios && pod install && cd ..
flutter devices
flutter run --release
```

Open `ios/Runner.xcworkspace` in Xcode, not `Runner.xcodeproj`. iOS deployment target is 15.5 (ML Kit).

Release packages:

```bash
flutter build ios --release
flutter build apk --release
```

On iOS 14+, a debug build opened from the home screen can show a black screen. Prefer `flutter run` for debug, or install a release build for home-screen launches.

## Tests (no live PMC)

```bash
flutter analyze
flutter test
```

Tests use an in-memory `FakePmcGateway`. Optional simulator smoke without live traffic:

```bash
flutter run -d "iPhone 16 Pro" --dart-define=FAKE_PMC=true
```

Fake OTP is always `1234`. Leave `FAKE_PMC` unset for production.

## Project structure

```text
lib/
  main.dart                 Entry, AppScope (HttpPmcGateway by default)
  src/
    models.dart             Reports, issues, status
    store.dart              Session, drafts, submit
    persistence.dart        SQLite + secure session + durable photos
    photo_check.dart        Sharpness + dog detection
    pmc/                    CARE client, mapping, area index
    screens/                Welcome through report flow, map, help
assets/data/                PMC prabhag boundary GeoJSON (name matching only)
assets/images/              Logo and placeholders
test/                       Widget, PMC, and photo persistence tests
```

## Permissions

| Platform | Permission | Why |
| --- | --- | --- |
| iOS / Android | Camera, photos | Report photo |
| iOS / Android | Location when in use | Pin and ward suggestion |
| Android | Internet | PMC CARE + map tiles |

## Map tiles

OpenStreetMap tiles via `https://tile.openstreetmap.org` with the app package as user agent. For heavy production traffic, use a permitted tile provider or self-host.

## App identity

| | |
| --- | --- |
| Display name | Dog Help Pune |
| iOS bundle id | `in.pune.doghelp.dogHelpPune` |
| Android application id | `in.pune.doghelp.dog_help_pune` |
| Version | `1.0.0+1` |

## PMC CARE notes

Verified against `https://api.pmccare.in` (same surface as [pmc-care-cli](https://github.com/ForceGT/pmc-care-cli)):

- Lookup, categories, wards, and prabhags work without filing
- OTP and `addGrievanceDirectly` need the citizen’s own account
- Photos stay on device; PMC attachment is empty (no hosting backend)
- This app does not invent reference numbers

## Not in this build

- Push notifications
- In-app PMC registration or support chat
- Uploading photos into PMC object storage

## License

[MIT](LICENSE)
