import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OfficeWebViewWidget extends StatefulWidget {
  const OfficeWebViewWidget({Key? key}) : super(key: key);

  @override
  State<OfficeWebViewWidget> createState() => _OfficeWebViewWidgetState();
}

class _OfficeWebViewWidgetState extends State<OfficeWebViewWidget> {
  @override
  void initState() {
    super.initState();
    // Enable virtual display.
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return WebView(
      initialUrl: 'https://www.awigntest.com/',
    );
  }
}
