import 'dart:convert';

import 'api_callback_listener.dart';
import 'package:http/http.dart' as http;
import 'ui_utility.dart';

class ApiCallHandler {
  /// error handled and returns whether success or not
  /// `true` success
  /// `false` failure
  static bool handleApiResponse(
    http.Response response, {
    ApiCallListener? listener,
  }) {
    if (response.statusCode < 400) {
      // success
      _call(listener);
      return true;
    }

    if (response.statusCode == 401) {
      // Session expired - handled centrally by AuthController before
      // we ever get here, so just report failure quietly.
      _call(listener, error: "Token expired");
      return false;
    }

    // Error bodies aren't guaranteed to be valid JSON (Reddit can
    // return HTML error pages, e.g. for 5xx/ratelimit responses), so
    // guard the decode instead of letting it throw.
    String? message;
    try {
      final json = jsonDecode(response.body);
      message = json is Map ? json['message']?.toString() : null;
    } catch (_) {
      // not JSON - fall through with a generic message below
    }
    _call(listener,
        error: message ?? "Request failed (${response.statusCode})");
    return false;
  }

  static void _call(ApiCallListener? listener, {String? error}) {
    if (error == null) {
      listener?.onSuccess?.call();
    } else {
      listener?.onError?.call(error);
      UiUtility.showToast(error, isError: true);
      print("error: $error");
    }
    listener?.onCompleted?.call();
  }
}
