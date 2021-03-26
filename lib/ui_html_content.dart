import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
//import 'config.dart';
import 'package:webview_flutter/webview_flutter.dart';


class TestWebView extends StatelessWidget {
  WebViewController _webViewController1;

  @override
  Widget build(BuildContext context) {
    return getWebView();
  }

  Widget getWebView() {
    return WebView(
      initialUrl: 'https://marvel.bible/',
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (WebViewController webViewController) {
        _webViewController1 = webViewController;
      },
      gestureRecognizers: Set()
        ..addAll({
          Factory<VerticalDragGestureRecognizer>(
              () => VerticalDragGestureRecognizer()),
          Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
          Factory<LongPressGestureRecognizer>(() => LongPressGestureRecognizer()),
        }),
    );
  }
}
