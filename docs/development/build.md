# Build & CI

## Prerequisites

- A [Flutter](https://flutter.dev) SDK. The project targets a pre-null-safety
  Dart (`sdk: ">=2.7.0 <3.0.0"`) and `bonfire: ^2.0.0`, so an older Flutter
  channel is required.
- `flutter pub get` to fetch packages.

## Run locally

```
flutter run            # default device
flutter run -d chrome  # web
flutter run -d windows # Windows desktop
```

## Configuration

Multiplayer reads PubNub keys from a `.env` file at the project root:

```
PUBNUB_SUBSCRIBEKEY=sub-...
PUBNUB_PUBLISHKEY=pub-...
PUBNUB_UUID=your-uuid
```

`.env` is gitignored. Without it, the app falls back to rate-limited demo keys.

## Release pipeline

`.github/workflows/publish.yml` runs on pushes and PRs to `master`:

- **prepare_release** — creates a timestamped GitHub Release.
- **build_web** — `flutter build web`, then assembles the GitHub Pages site
  (landing page + changelog + docs from `.github/pages/`, with the web build
  moved into `game/`) and deploys it to the `gh-pages` branch.
- **build_apk / build_win / build_mac** — build and upload the Android, Windows,
  and macOS release assets (`android-release.apk`, `windows-release.zip`,
  `macos-release.app.zip`).

## Website

The landing site lives in `.github/pages/`:

- `index.html` — hero, download buttons, play-in-browser, features.
- `changelog.html` — renders `CHANGELOG.md`.
- `docs.html` — renders this `docs/` tree.

At deploy time the workflow copies `CHANGELOG.md`, `README.md`, and `docs/` next
to those pages and drops the compiled web app into `game/`.
