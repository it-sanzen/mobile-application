import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import '../../../../core/services/api_service.dart';

class AiRedesignSimulatorPage extends StatefulWidget {
  final XFile? imageFile;
  const AiRedesignSimulatorPage({super.key, this.imageFile});

  @override
  State<AiRedesignSimulatorPage> createState() => _AiRedesignSimulatorPageState();
}

class PlacedItem {
  final String name;
  final String imageAsset;
  Offset position;
  double scale;
  double rotation;

  PlacedItem({
    required this.name, 
    required this.imageAsset, 
    required this.position,
    this.scale = 1.0,
    this.rotation = 0.0,
  });
}

class _AiRedesignSimulatorPageState extends State<AiRedesignSimulatorPage> {
  bool _showOriginal = false;
  final List<PlacedItem> _placedItems = [];
  final GlobalKey _imageKey = GlobalKey();
  bool _isGenerating = false;
  String? _generatedImageUrl;

  Future<void> _captureAndUploadImage() async {
    setState(() => _isGenerating = true);
    try {
      final boundary = _imageKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      // Show processing dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: AppColors.primaryGreen),
                const SizedBox(height: 16),
                const Text('AI is processing your design...'),
                const SizedBox(height: 8),
                Text(
                  'This may take a few seconds',
                  style: TextStyle(fontSize: 12, color: AppColors.grey),
                ),
              ],
            ),
          ),
        );
      }

      final response = await ApiService.postMultipart(
        '/ai-designer/generate',
        fileBytes: bytes,
        filename: 'composition.png',
        fields: {
          'roomType': 'Living Room',
          'designStyle': 'Modern Minimalist',
          'shouldMock': 'true',
        },
      );

      // Close dialog
      if (mounted) {
        Navigator.pop(context);
      }

      if (response['success'] == true) {
        final savedDesign = response['data']['savedDesign'];
        setState(() {
          _generatedImageUrl = savedDesign['imageUrl'];
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('AI Design Generated & Saved!')),
          );
          // Assuming original caller expects an image path or URL
          Navigator.pop(context, _generatedImageUrl);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response['error']}')),
          );
        }
      }
    } catch (e) {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context); // Close dialog
      }
      print('Capture error: $e');
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text(
          'AI Redesign Result',
          style: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.black),
        actions: [
          TextButton(
            onPressed: () {
              // Just save the manual staging without AI
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Manual Design Saved!')),
              );
              Navigator.pop(context, widget.imageFile);
            },
            child: const Text(
              'Save Layout',
              style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      floatingActionButton: _placedItems.isNotEmpty && !_isGenerating
          ? FloatingActionButton.extended(
              onPressed: _captureAndUploadImage,
              backgroundColor: AppColors.primaryGreen,
              icon: const Icon(Icons.auto_awesome, color: AppColors.white),
              label: const Text(
                'Enhance with AI',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.white),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Simulated generated image wrapper
                  DragTarget<Map<String, dynamic>>(
                    onAcceptWithDetails: (details) {
                      final RenderBox renderBox = _imageKey.currentContext?.findRenderObject() as RenderBox;
                      final localOffset = renderBox.globalToLocal(details.offset);
                      
                      setState(() {
                        _placedItems.add(
                          PlacedItem(
                            name: details.data['name'],
                            imageAsset: details.data['imageAsset'],
                            position: localOffset,
                          ),
                        );
                      });
                    },
                    builder: (context, candidateData, rejectedData) {
                      return RepaintBoundary(
                        key: _imageKey,
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.black12,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (widget.imageFile != null)
                                Image.network(
                                  widget.imageFile!.path,
                                  fit: BoxFit.cover,
                                ),
                              // Render placed furniture items
                              if (!_showOriginal)
                          ..._placedItems.map((item) {
                            return Positioned(
                              left: item.position.dx - 50, // Center based on default image size
                              top: item.position.dy - 50,
                              child: GestureDetector(
                                onScaleUpdate: (details) {
                                  setState(() {
                                    // Handle panning (translation)
                                    item.position += details.focalPointDelta;
                                    
                                    // Handle scaling
                                    if (details.scale != 1.0) {
                                      // Scale slightly to prevent jumping
                                      item.scale *= details.scale.clamp(0.9, 1.1);
                                    }
                                    
                                    // Handle rotation
                                    if (details.rotation != 0.0) {
                                      item.rotation += details.rotation;
                                    }
                                  });
                                },
                                onLongPress: () {
                                  // Remove item on long press
                                  setState(() {
                                    _placedItems.remove(item);
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Item removed')),
                                  );
                                },
                                child: Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()
                                    ..scale(item.scale)
                                    ..rotateZ(item.rotation),
                                  child: Image.asset(
                                    item.imageAsset,
                                    width: 150, // Base default size
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                );
                },
              ),
                  
                  // Toggle button overlay
                  if (_placedItems.isEmpty)
                    Positioned(
                      bottom: 24,
                      child: GestureDetector(
                      onTapDown: (_) => setState(() => _showOriginal = true),
                      onTapUp: (_) => setState(() => _showOriginal = false),
                      onTapCancel: () => setState(() => _showOriginal = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.black.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.compare, color: AppColors.white),
                            SizedBox(width: 8),
                            Text(
                              'Hold to view Original',
                              style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Bottom action panel
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Included Furniture',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 80,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildFurnitureItem('White Sofa', 'AED 2,200', 'assets/furniture/sofa.png'),
                        _buildFurnitureItem('Wood Table', 'AED 1,500', 'assets/furniture/table.png'),
                        _buildFurnitureItem('Area Rug', 'AED 600', 'assets/furniture/rug.png'),
                        _buildFurnitureItem('Potted Plant', 'AED 150', 'assets/furniture/plant.png'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFurnitureItem(String name, String price, String imageAsset) {
    final itemWidget = Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Image.asset(
                imageAsset,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            price,
            style: const TextStyle(color: AppColors.primaryGreen, fontSize: 12),
          ),
        ],
      ),
    );

    return Draggable<Map<String, dynamic>>(
      data: {'name': name, 'imageAsset': imageAsset},
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.8,
          child: Image.asset(
            imageAsset,
            width: 150,
            fit: BoxFit.contain,
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: itemWidget,
      ),
      child: itemWidget,
    );
  }
}
