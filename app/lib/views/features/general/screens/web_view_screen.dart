import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:reddy/views/features/general/widgets/red_web_view.dart';

/// Reddit's own app keeps outbound links inside the app instead of
/// bouncing you out to the system browser. This is the same idea:
/// a full-screen wrapper around [RedWebView] with a back button and
/// an escape hatch (open in an actual browser) for pages that don't
/// behave inside a WebView (some sites deliberately block embedding).
class WebViewScreen extends StatelessWidget {
  const WebViewScreen({super.key, required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[50],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          Uri.tryParse(url)?.host ?? url,
          style: const TextStyle(color: Colors.black87, fontSize: 15),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser, color: Colors.black87),
            tooltip: 'Open in browser',
            onPressed: () => launchUrl(
              Uri.parse(url),
              mode: LaunchMode.externalApplication,
            ),
          ),
        ],
      ),
      body: RedWebView(url: url, height: double.infinity, width: double.infinity),
    );
  }
}
