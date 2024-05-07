import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RedWebView extends StatefulWidget {
  const RedWebView({super.key, required this.url, this.height, this.width});
  final String url;
  final double? height;
  final double? width;

  @override
  State<RedWebView> createState() => _RedWebViewState();
}

class _RedWebViewState extends State<RedWebView> {
  late WebViewController controller;
  double progress = 0;
  @override
  void initState() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            print(progress);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: Stack(
        children: [
          Positioned.fill(
            child: WebViewWidget(
              controller: controller,
            ),
          ),
          if (progress < 1)
            Positioned.fill(
              child: Center(
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.black,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          Positioned.fill(child: Container(color: Colors.red.withOpacity(0.9))),
        ],
      ),
    );
  }
}
