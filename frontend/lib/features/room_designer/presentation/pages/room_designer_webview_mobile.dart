import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/theme/app_colors.dart';

Widget buildDesignerView({
  required String url,
  required Function(String) onMessage,
}) {
  return _MobileWebView(url: url, onMessage: onMessage);
}

class _MobileWebView extends StatefulWidget {
  final String url;
  final Function(String) onMessage;

  const _MobileWebView({required this.url, required this.onMessage});

  @override
  State<_MobileWebView> createState() => _MobileWebViewState();
}

class _MobileWebViewState extends State<_MobileWebView> {
  late final WebViewController _controller;
  bool _isPageLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isPageLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isPageLoading = false);
          },
        ),
      )
      ..addJavaScriptChannel(
        'FlutterBridge',
        onMessageReceived: (JavaScriptMessage message) {
          widget.onMessage(message.message);
        },
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isPageLoading)
          Container(
            color: AppColors.white,
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            ),
          ),
      ],
    );
  }
}
