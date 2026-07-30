# Reddy

A Flutter Reddit client with a fast, infinite-scrolling feed, cookie-based login (no API keys/OAuth app registration needed), gallery and video support, and a locally cached browsing history.

Built with Flutter + [GetX](https://pub.dev/packages/get) for state management, [Hive](https://pub.dev/packages/hive) for local storage, and a WebView-based login flow.

## Features

- **Infinite-scroll feed** — subreddit and search results load in pages and append as you scroll, with pull-to-refresh and an "end of feed" indicator.
- **Cookie-based login** — log in through an embedded WebView (no Reddit developer app / OAuth client needed); the session is saved and restored automatically on the next launch.
- **Re-authentication** — switch accounts or refresh a stale session from the drawer or Settings without losing your saved history.
- **Site-wide search** — type a plain query to search all of Reddit, or `r/<subreddit>` to jump straight to a subreddit; sort by Best, Hot, New, Top, or Rising.
- **Gallery posts** — multi-image `reddit.com/gallery/...` posts render as a swipeable carousel instead of a broken link.
- **Video playback** — HLS/video posts play inline via `video_player` and `chewie`.
- **Cached images** — post images and avatars are disk-cached and decoded at display size, keeping the feed light on memory and mobile data.
- **Persisted settings** — Safe Mode, sound, autoplay, image quality, and playback speed are saved with `shared_preferences` and survive app restarts.
- **Local history** — recently viewed posts/subreddits are stored on-device with Hive.

## Screens

| Screen | Purpose |
|---|---|
| Reddit Info / Login | WebView login flow; entry point for logged-out users |
| Home | Subreddit feed with quick-subreddit chips, sort menu, and search |
| Search | Site-wide search or subreddit jump, with an SFW/NSFW and `r/` toggle |
| Post Detail | Full post view with comments |
| Settings | Account info, re-authentication, playback and display preferences |

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart `>=3.3.0 <4.0.0`, per `pubspec.yaml`)
- A configured platform toolchain for whichever target you're building (Android Studio/SDK, Xcode, etc.)

### Setup

```bash
# Install dependencies
flutter pub get

# Generate Hive adapter code (required after model changes)
dart run build_runner build --delete-conflicting-outputs

# Run on a connected device or emulator
flutter run
```

### Building a release

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web / Windows / macOS / Linux
flutter build web
flutter build windows
flutter build macos
flutter build linux
```

## Project Structure

```
lib/
├── config/           # Routes, constants, enums, shared utilities
├── controllers/      # GetX controllers (home, auth, settings, search, post detail)
├── models/           # Data models (Reddit posts, comments, users, history)
├── services/         # Reddit API client, auth service, caching, Hive storage
└── views/
    ├── features/     # Screens and widgets grouped by feature (general, posts, player)
    └── widgets/      # Shared/reusable widgets
```

Platform folders (`android/`, `ios/`, `macos/`, `windows/`, `linux/`, `web/`) contain the standard Flutter platform runners and are generally not edited by hand.

## Configuration Notes

- **App ID**: `com.codykas.reddy` (Android `applicationId` / `namespace`).
- **Auth**: no `client_id`/`client_secret` or `.env` file is required — login happens via an in-app WebView against reddit.com, and the resulting session cookie + user agent are persisted locally via `shared_preferences`.
- **Local data**: browsing history is stored with Hive in a local box; clearing app data/storage will reset it.

## Known Limitations / Not Yet Wired Up

- `lib/views/test/` and `lib/services/subranking/` contain experimental code that isn't linked into the app's routes — safe to ignore or remove.
- Reddit's `/search.json` endpoint doesn't support every sort option the UI exposes (e.g. no true "Best" or "Rising" for search); these are mapped to the closest supported equivalent under the hood.

## Contributing

Issues and pull requests are welcome. Please run `flutter analyze` and `flutter test` before submitting a PR.

## License

Add a license here (e.g. MIT) if you intend to distribute this project publicly.