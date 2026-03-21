// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

Widget buildDesignerView({
  required String url,
  required Function(String) onMessage,
}) {
  return _WebIframeView(url: url, onMessage: onMessage);
}

class _WebIframeView extends StatefulWidget {
  final String url;
  final Function(String) onMessage;

  const _WebIframeView({required this.url, required this.onMessage});

  @override
  State<_WebIframeView> createState() => _WebIframeViewState();
}

class _WebIframeViewState extends State<_WebIframeView> {
  late final String _viewType;

  @override
  void initState() {
    super.initState();
    _viewType = 'room-designer-iframe-${DateTime.now().millisecondsSinceEpoch}';

    // Register the iframe view
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final iframe = html.IFrameElement()
        ..src = widget.url
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allow = 'autoplay; fullscreen';

      // Listen for messages from the iframe
      html.window.onMessage.listen((event) {
        if (event.data is String) {
          widget.onMessage(event.data as String);
        }
      });

      return iframe;
    });
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewType);
  }
}
