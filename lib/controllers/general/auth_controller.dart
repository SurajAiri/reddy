import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:reddy/config/routes/routes.dart';
import 'package:reddy/config/utils/ui_utility.dart';
import 'package:reddy/models/reddit/reddit_info_model.dart';
import 'package:reddy/services/auth/reddit_auth_service.dart';

/// Single source of truth for the user's Reddit login state.
///
/// Responsible for:
/// - loading persisted cookies/UA on app start (so the user doesn't
///   have to log back in every launch)
/// - exposing "last login" time
/// - letting the user re-authenticate / switch accounts on demand
/// - reacting to an expired session (HTTP 401) by clearing state and
///   sending the user back to the login screen
class AuthController extends GetxController {
  Rxn<RedditInfoModel> redditInfo = Rxn<RedditInfoModel>();
  RxBool isInitializing = true.obs;

  bool _handlingSessionExpiry = false;

  bool get isLoggedIn => redditInfo.value != null;
  DateTime? get lastLoginAt => redditInfo.value?.loggedInAt;

  /// Call once, before `runApp`, so the very first frame already
  /// knows whether the user is logged in (avoids a login-screen flash).
  Future<void> init() async {
    try {
      redditInfo.value = await RedditAuthService.load();
    } catch (e) {
      debugPrint('AuthController.init error: $e');
    } finally {
      isInitializing.value = false;
    }
  }

  /// Called by the login WebView once cookies were captured.
  Future<void> saveLogin(RedditInfoModel info) async {
    redditInfo.value = info;
    _handlingSessionExpiry = false;
    await RedditAuthService.save(info);
  }

  /// Called whenever we get a fresh/rotated cookie from a normal API
  /// response, without treating it as a brand-new login.
  Future<void> updateCookie(String cookie) async {
    final current = redditInfo.value;
    if (current == null) return;
    current.cookies = cookie;
    redditInfo.value = current;
    await RedditAuthService.save(current, preserveLoginTimestamp: true);
  }

  /// Wipes stored credentials. Used for logout / before re-authenticating
  /// with a different account.
  Future<void> logout() async {
    redditInfo.value = null;
    await RedditAuthService.clear();
  }

  /// Sends the user to the login screen. If [forceAccountSwitch] is
  /// true, the WebView will first clear its own cookie jar so Reddit
  /// shows the login form instead of silently reusing the previous
  /// session - this is what lets someone "re-authenticate" as a
  /// different account rather than just refreshing the same one.
  void goToLogin({bool forceAccountSwitch = false}) {
    Get.toNamed(
      AllRoutes.redditInfo,
      arguments: {'forceAccountSwitch': forceAccountSwitch},
    );
  }

  /// Central place to react to a 401 from the Reddit API. Clears the
  /// stale session and routes the user back to login, without
  /// spamming multiple toasts/navigations if several requests fail
  /// around the same time.
  void handleSessionExpired() {
    if (_handlingSessionExpiry) return;
    _handlingSessionExpiry = true;
    logout();
    UiUtility.showToast(
      "Your Reddit session expired. Please log in again.",
      isError: true,
    );
    Get.offAllNamed(
      AllRoutes.redditInfo,
      arguments: {'forceAccountSwitch': false},
    );
  }
}
