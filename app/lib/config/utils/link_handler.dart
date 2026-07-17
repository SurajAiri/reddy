import 'package:get/get.dart';
import 'package:reddy/config/routes/routes.dart';
import 'package:reddy/config/utils/utility.dart';
import 'package:reddy/controllers/general/home_controller.dart';
import 'package:reddy/views/features/general/screens/web_view_screen.dart';

/// Single place deciding what happens when a link gets tapped, no
/// matter where it came from - a post's outbound URL button, a link
/// inside a post's selftext markdown, or a link inside a comment.
/// Reddit's own app never dumps you out to the system browser for
/// this: an `r/subreddit` link switches the feed in place, everything
/// else opens in an in-app browser.
class LinkHandler {
  static void open(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return;

    final subreddit = Utility.parseSubredditFromUrl(trimmed);
    if (subreddit.isNotEmpty) {
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().updateSubreddit(subreddit);
      }
      Get.until((route) =>
          route.settings.name == AllRoutes.homeScreen || route.isFirst);
      return;
    }

    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      // Relative link (e.g. "/u/someone", "/message/compose") or bare
      // text a markdown parser mistook for a link target - nothing
      // sane to open in a webview.
      return;
    }

    Get.to(WebViewScreen(url: trimmed));
  }
}
