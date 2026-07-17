import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Embeddable in-app webview. This existed before but was never
/// actually wired up anywhere, and had two bugs that would've made it
/// unusable the moment something did use it:
///  1. `onProgress` only `print`ed the value instead of calling
///     `setState`, so `progress` stayed frozen at 0 forever - the
///     loading indicator below never went away.
///  2. A `Positioned.fill(child: Container(color: red@90%))` was
///     stacked as the LAST (i.e. topmost) child, permanently painting
///     the entire page red regardless of what loaded underneath it.
class RedWebView extends StatefulWidget {
  const RedWebView({super.key, required this.url, this.height, this.width});
  final String url;
  final double? height;
  final double? width;

  @override
  State<RedWebView> createState() => _RedWebViewState();
}

class _RedWebViewState extends State<RedWebView> {
  late final WebViewController controller;
  double progress = 0;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int value) {
            if (!mounted) return;
            setState(() => progress = value / 100);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: Stack(
        children: [
          Positioned.fill(child: WebViewWidget(controller: controller)),
          if (progress < 1)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 2,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red[300]!),
              ),
            ),
        ],
      ),
    );
  }
}
