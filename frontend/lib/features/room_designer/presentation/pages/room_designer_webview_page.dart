import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../../../core/services/token_service.dart';
import '../../../../core/theme/app_colors.dart';

// Conditionally import webview_flutter only on mobile
import 'room_designer_webview_mobile.dart' if (dart.library.html) 'room_designer_webview_web.dart';

class RoomDesignerWebViewPage extends StatefulWidget {
  final String? designId;
  final String? roomType;
  final String? showroomId;

  const RoomDesignerWebViewPage({
    super.key,
    this.designId,
    this.roomType,
    this.showroomId,
  });

  @override
  State<RoomDesignerWebViewPage> createState() => _RoomDesignerWebViewPageState();
}

class _RoomDesignerWebViewPageState extends State<RoomDesignerWebViewPage> {
  String? _url;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _buildUrl();
  }

  Future<void> _buildUrl() async {
    final token = await TokenService.getToken();

    final params = <String, String>{};
    if (token != null) params['token'] = token;
    if (widget.designId != null) params['designId'] = widget.designId!;
    if (widget.roomType != null) params['roomType'] = widget.roomType!;
    if (widget.showroomId != null) params['showroomId'] = widget.showroomId!;

    final queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    setState(() {
      _url = 'https://sanzen-new-demo.onrender.com/room-designer/index.html?$queryString';
      _isLoading = false;
    });
  }

  void _handleMessage(String message) {
    try {
      final data = jsonDecode(message);
      final type = data['type']?.toString() ?? message;
      _processMessageType(type);
    } catch (_) {
      _processMessageType(message);
    }
  }

  void _processMessageType(String type) {
    switch (type) {
      case 'design-saved':
        _showSnackbar('Design saved!', AppColors.primaryGreen);
        break;
      case 'back-pressed':
        Navigator.pop(context);
        break;
      case 'wishlist-created':
        _showSnackbar('Wishlist saved!', AppColors.primaryGreen);
        break;
    }
  }

  void _showSnackbar(String text, Color bgColor) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text, style: const TextStyle(color: AppColors.white)),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          'Room Designer',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading || _url == null
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.primaryGreen),
                  SizedBox(height: 16),
                  Text('Loading Room Designer...', style: TextStyle(color: AppColors.grey, fontSize: 14)),
                ],
              ),
            )
          : buildDesignerView(
              url: _url!,
              onMessage: _handleMessage,
            ),
    );
  }
}
