# Reddy — Fixes & Improvements

## 1. No infinite scroll (fixed)
- **Before:** feed used a "Load More…" button, and worse — each "next page" fetch **replaced** the entire post list instead of appending to it, so scrolling further actually *lost* earlier posts.
- **Now:** `HomeController` keeps a growing `RxList<RedditPostModel> posts`, appends new pages (de-duped by post id), and a scroll listener on `postScrollController` auto-fetches the next page ~800px before the bottom. `home_screen.dart` was switched from a `ListView` nested inside a `CustomScrollView` to a real `SliverList.builder`, so posts are also genuinely lazy-built now (better scroll performance). Added a footer spinner / "end of feed" indicator and pull-to-refresh (`RefreshIndicator`).

## 2. No re-authentication option (fixed)
- **Before:** login only ever happened once, on first launch; there was no way to log in again or switch accounts, and no persistence at all — cookies lived only in memory, so **every app restart required logging in again**.
- **Now:**
  - Added `AuthController` + `RedditAuthService` (SharedPreferences-backed) that saves cookies, user agent, and login timestamp, and reloads them before the first frame on startup — so the app skips straight to the feed on return visits.
  - Added **"Re-authenticate"** in the drawer and in Settings ("Account" section), which reopens the login WebView and clears its cookie jar first so Reddit shows the login form again (lets you switch accounts, not just refresh the same session).
  - Session-expiry (HTTP 401) is now handled centrally: `AuthController.handleSessionExpired()` clears the stale session, shows a toast, and routes back to login automatically instead of leaving the app in a broken state.

## 3. Last login time not stored (fixed)
- `RedditInfoModel` now carries `loggedInAt`, persisted alongside the cookies. Settings screen shows "Last logged in: YYYY-MM-DD HH:mm".
- Cookie rotation (`Set-Cookie` from Reddit) updates the stored cookie **without** resetting this timestamp, since that's a session refresh, not a new login.

## 4. Gallery posts (`reddit.com/gallery/<id>`) didn't render (fixed)
- **Before:** the code never looked at `is_gallery` / `media_metadata` at all. When `preview.images` happened to be missing (common for gallery posts), the feed fell back to a plain text button showing the raw gallery URL — no image.
- **Now:** `RedditPostModel` parses `media_metadata` + `gallery_data.items` (in the order Reddit specifies) into a `galleryImages` list. `PostField` renders a swipeable carousel (`PageView`) with a "1/N" counter for multi-image gallery posts, using cached network images.

## 5. Other issues found & fixed

| Issue | Fix |
|---|---|
| **N+1 network requests**: every single post fired an extra, un-awaited HTTP request for its author's profile *while parsing the feed JSON* — 25 posts = 25 extra requests upfront, a common cause of Reddit rate-limiting and battery/data waste. | Removed the eager fetch from the model constructor. Author avatars are now fetched **lazily** (only once a post actually scrolls into view) and are cached in-memory by username, with in-flight de-duplication so the same author is never fetched twice concurrently. |
| **Rotated session cookies were silently dropped.** The code checked `response.headers['Cookie']`, but `Cookie` is a *request* header — the response header is `set-cookie`. Rotated cookies were never actually saved. | Fixed to read `set-cookie` and merge it into the stored cookie string, now wired through `AuthController.updateCookie`. |
| **No image caching.** Every image used `Image.network`, which never caches to disk and re-downloads on every rebuild/scroll — expensive on mobile data and causes jank. `cached_network_image` was already a dependency but unused. | Swapped all post images and avatars to `CachedNetworkImage` / `CachedNetworkImageProvider`. |
| **Settings not persisted** (`shared_preferences` was a dependency but unused) — Safe Mode, sound, autoplay, image quality, playback speed all reset on every app restart. | `SettingsController` now loads/saves all of these via `SharedPreferences` automatically on change. |
| **Inefficient list rendering**: a non-lazy `ListView` was nested inside a `CustomScrollView`'s `SliverList`, defeating lazy building. | Replaced with a direct `SliverList.builder`. |
| **Crash-prone / noisy error handling**: `handleApiResponse` called `jsonDecode` unconditionally on error bodies, which throws on Reddit's HTML error pages (5xx/ratelimit); full response bodies and cookies were `print`ed to the console (perf + leaks session cookies into logs). | Guarded JSON decoding with try/catch, removed cookie/body logging. |
| **Dead code with a real security issue**: an unused test screen posted the WebView's raw session cookies to a public `beeceptor.com` webhook. It wasn't wired into any route, but was still shipping in the app. | Deleted (`lib/views/features/test_screen.dart`). |
| Double-slash bug in the user-details API URL (`.../user//username/about.json`). | Fixed. |

## Not changed (flagged for awareness)
- `lib/views/test/test_screen.dart` and `lib/services/subranking/*` appear to be unused/experimental (not wired into `routes.dart`). Left alone since they're inert, but worth a cleanup pass.
- The `release/` folder (prebuilt APKs) was excluded from this delivered zip to keep the download small — regenerate with `flutter build apk` as needed.

## Suggested next steps
- Consider adding refresh-token style silent re-auth (headless WebView ping) before a session fully expires, instead of only reacting to 401s.
- Gallery carousel currently always loads the full-resolution image per item; could add per-image quality-tier selection like single-image posts already have.

## New: site-wide reddit search + sort-by (Best/Hot/New/Top/Rising)

- **Search box now understands two kinds of input:**
  - `r/<name>` (spaces are stripped, e.g. `r/ mild lyinteresting` → `mildlyinteresting`) jumps straight to that subreddit, exactly like before — all the existing local/API subreddit suggestion lists still work unchanged (tapping a suggestion always goes straight to that subreddit, regardless of prefix).
  - Anything else is run as a normal, site-wide reddit search (`/search.json`) and shown as a feed, the same way a subreddit's feed is — infinite scroll, pull-to-refresh, and post cards all work identically. Each post still shows which subreddit it came from since search results span many subreddits.
- **Sort-by menu** added to the home app bar (next to the search icon): **Best, Hot, New, Top, Rising**. Applies to whichever feed is active (a subreddit or a search) and re-fetches from the top when changed.
  - Reddit doesn't actually expose a `best` listing for individual subreddits (only the aggregated home/all feed) or a `rising`/`best` option on `/search.json`, so those are transparently mapped to their closest equivalent (`hot` / `relevance` / `new`) per-endpoint under the hood — the UI options stay the same either way.
- The app bar title and the "no posts found" empty state now reflect whatever's actually being browsed (`r/subreddit` or `"search query"`).
