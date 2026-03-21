import 'package:flutter/material.dart';

class BeforeAfterSlider extends StatefulWidget {
  final String beforeUrl;
  final String afterUrl;

  const BeforeAfterSlider({
    super.key,
    required this.beforeUrl,
    required this.afterUrl,
  });

  @override
  State<BeforeAfterSlider> createState() => _BeforeAfterSliderState();
}

class _BeforeAfterSliderState extends State<BeforeAfterSlider> {
  double _sliderPosition = 0.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Before / After', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  _sliderPosition = (details.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
                });
              },
              child: Stack(
                children: [
                  // After image (full width)
                  SizedBox(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    child: Image.network(
                      widget.afterUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.broken_image, color: Colors.grey, size: 48),
                      ),
                    ),
                  ),
                  // Before image (clipped)
                  ClipRect(
                    clipper: _LeftClipper(_sliderPosition * constraints.maxWidth),
                    child: SizedBox(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      child: Image.network(
                        widget.beforeUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.broken_image, color: Colors.grey, size: 48),
                        ),
                      ),
                    ),
                  ),
                  // Divider line
                  Positioned(
                    left: _sliderPosition * constraints.maxWidth - 1.5,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 3,
                      color: Colors.white,
                    ),
                  ),
                  // Handle
                  Positioned(
                    left: _sliderPosition * constraints.maxWidth - 18,
                    top: constraints.maxHeight / 2 - 18,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 6),
                        ],
                      ),
                      child: const Icon(Icons.swap_horiz, size: 20, color: Colors.black87),
                    ),
                  ),
                  // Labels
                  Positioned(
                    left: 12,
                    top: 12,
                    child: _buildLabel('BEFORE'),
                  ),
                  Positioned(
                    right: 12,
                    top: 12,
                    child: _buildLabel('AFTER'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _LeftClipper extends CustomClipper<Rect> {
  final double width;
  _LeftClipper(this.width);

  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, width, size.height);

  @override
  bool shouldReclip(covariant _LeftClipper oldClipper) => oldClipper.width != width;
}
