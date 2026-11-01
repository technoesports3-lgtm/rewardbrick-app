import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ContentWebviewScreen extends StatefulWidget {
  final String url;
  final String title;

  const ContentWebviewScreen(
      {super.key, required this.url, required this.title});

  @override
  State<ContentWebviewScreen> createState() => _ContentWebviewScreenState();
}

class _ContentWebviewScreenState extends State<ContentWebviewScreen> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // ఇది లేటెస్ట్ WebView కోడ్ (ఎర్రర్స్ రావు)
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            setState(() => isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade50,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blue),
        title: Text(widget.title,
            style: const TextStyle(
                color: Colors.blue, fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.blue)),
        ],
      ),
    );
  }
}
