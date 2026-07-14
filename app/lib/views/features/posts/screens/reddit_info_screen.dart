import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reddy/config/routes/routes.dart';
import 'package:reddy/controllers/general/auth_controller.dart';
import 'package:reddy/models/reddit/reddit_info_model.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RedditInfoScreen extends StatefulWidget {
  const RedditInfoScreen({super.key});

  @override
  State<RedditInfoScreen> createState() => _RedditInfoScreenState();
}

class _RedditInfoScreenState extends State<RedditInfoScreen> {
  late final WebViewController controller;
  bool _handled = false;

  /// True when the user explicitly asked to re-authenticate / switch
  /// accounts (as opposed to this being the very first launch login).
  bool get _forceAccountSwitch {
    final args = Get.arguments;
    if (args is Map && args['forceAccountSwitch'] == true) return true;
    return false;
  }

  @override
  void initState() {
    super.initState();
    // Build the controller synchronously (before the first build()
    // call runs) so the `late final` field is always initialized in
    // time - any async setup (like clearing cookies) happens after,
    // and only delays when loadRequest actually fires.
    controller = WebViewController();
    _initWebView();
  }

  Future<void> _initWebView() async {
    if (_forceAccountSwitch) {
      // Clear the WebView's own cookie jar first so Reddit shows the
      // login form again instead of silently re-using whichever
      // account was previously signed in inside the WebView - this is
      // what makes "re-authenticate" actually let you switch accounts.
      await WebViewCookieManager().clearCookies();
    }

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) async {
            if (_handled) return;
            // Extract the cookies
            final cookies = await controller
                .runJavaScriptReturningResult('document.cookie') as String?;
            final ua = await controller.getUserAgent();

            final cleanedCookies =
                cookies is String ? _unquote(cookies) : cookies?.toString();

            // Only treat this as "logged in" once Reddit actually set a
            // session cookie - on the bare login page `document.cookie`
            // can still be non-empty (analytics cookies etc.), so we
            // check for reddit's known session cookie names.
            if (cleanedCookies != null &&
                cleanedCookies.isNotEmpty &&
                _looksAuthenticated(cleanedCookies)) {
              _handled = true;
              final info = RedditInfoModel(Uri.parse(url), cleanedCookies, ua);
              await Get.find<AuthController>().saveLogin(info);

              if (Get.isRegistered<AuthController>() &&
                  Get.previousRoute.isNotEmpty &&
                  Get.previousRoute != AllRoutes.redditInfo) {
                // Came here mid-session (re-auth) - just go back.
                Get.back();
              } else {
                // First launch - replace the whole stack with Home.
                Get.offAllNamed(AllRoutes.homeScreen);
              }
            }
          },
        ),
      )
      ..loadRequest(Uri.parse('https://www.reddit.com/login'));

    if (mounted) setState(() {});
  }

  bool _looksAuthenticated(String cookieString) {
    const sessionCookieNames = ['reddit_session', 'token_v2', 'loid'];
    return sessionCookieNames.any((name) => cookieString.contains(name));
  }

  String _unquote(String raw) {
    if (raw.length >= 2 && raw.startsWith('"') && raw.endsWith('"')) {
      return raw.substring(1, raw.length - 1);
    }
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final canCancel = Get.previousRoute.isNotEmpty;
    return Scaffold(
      appBar: canCancel
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.black87),
                onPressed: () => Get.back(),
              ),
            )
          : null,
      body: Stack(
        children: [
          // 1. The Visible Loading UI
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text(
                  _forceAccountSwitch
                      ? "Re-authenticating..."
                      : "Authenticating...",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // 2. The Hidden WebView
          // Offstage keeps the WebView active in the tree but completely invisible.
          Offstage(
            offstage: true,
            child: SizedBox(
              width: 1,
              height: 1,
              child: WebViewWidget(controller: controller),
            ),
          ),
        ],
      ),
    );
  }
}
