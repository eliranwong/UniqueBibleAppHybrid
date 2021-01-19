// Packages
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:webview_flutter/webview_flutter.dart';
// The following three imports work with webview.
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'dart:convert';
// My libraries
import 'config.dart';
import 'html_elements.dart';

class LookupContent extends StatelessWidget {

  final Function callBack;
  //WebViewController _webViewController;
  LookupContent(this.callBack);

  @override
  Widget build(BuildContext context) {
    return _buildLookupContent(context);
  }

  Widget _buildLookupContent(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      final String lookupContent = watch(lookupContentP).state;
      final Map<String, Color> myColors = watch(myColorsP).state;
      final Map<String, TextStyle> myTextStyle = watch(myTextStyleP).state;
      final double fontSize = watch(fontSizeP).state;
      return WebView(
        initialUrl: _buildHtmlContent(context, lookupContent, myColors, myTextStyle, fontSize),
        javascriptMode: JavascriptMode.unrestricted,
        javascriptChannels: <JavascriptChannel>[
          HtmlElements.ubaJsChannel(),
        ].toSet(),
        //onWebViewCreated: (WebViewController webViewController) => _webViewController = webViewController,
        gestureRecognizers: Set()
          ..addAll({
            Factory<VerticalDragGestureRecognizer>(() => VerticalDragGestureRecognizer()),
            Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
            Factory<LongPressGestureRecognizer>(() => LongPressGestureRecognizer()),
          }),
      );
    });
  }

  String _buildHtmlContent(BuildContext context, String content, Map<String, Color> myColors, Map<String, TextStyle> myTextStyle, double fontSize) {

    final String backgroundColor = myColors["background"].toHex();
    final String fontColor = myColors["black"].toHex();

    final List<int> bcvList = context.read(historyActiveVerseP).state.first;
    final String activeBcvSettings = "var activeText = 'KJV'; var activeB = ${bcvList.first}; var activeC = ${bcvList[1]}; var activeV = ${bcvList[2]};";

    final fullContent = """
<!DOCTYPE html><html>
<head><title>UniqueBible.app</title>
<style>body { font-size: ${fontSize}px; background-color: $backgroundColor; color: $fontColor; }</style>
<style>${HtmlElements.defaultCss()}</style>
<script src='js/common.js'></script>
<script src='w3.js'></script>
<script>$activeBcvSettings</script>
<script>
var versionList = []; 
var compareList = []; 
var parallelList = []; 
var diffList = []; 
var searchList = [];
</script>
</head>
<body>
<span id='v0.0.0'></span>
$content
</body>
</html>
    """;

    return Uri.dataFromString(fullContent, mimeType: 'text/html', encoding: utf8).toString();
  }

}