import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class DesignItem {
  final String id;
  final String name;
  final String category;
  final String iconAsset;
  final String imageAsset;
  final String theme; // e.g., 'Modern', 'Minimalist', 'Classic'

  DesignItem({
    required this.id,
    required this.name,
    required this.category,
    required this.iconAsset,
    required this.imageAsset,
    required this.theme,
  });
}

class PlacedItem {
  final DesignItem item;
  Offset position;

  PlacedItem({required this.item, required this.position});
}

class ManualDesignStudioPage extends StatefulWidget {
  const ManualDesignStudioPage({super.key});

  @override
  State<ManualDesignStudioPage> createState() => _ManualDesignStudioPageState();
}

class _ManualDesignStudioPageState extends State<ManualDesignStudioPage> {
  String _selectedCategory = 'Furniture';
  List<PlacedItem> _placedItems = [];

  final List<String> _categories = [
    'Furniture',
    'Rugs',
    'Art',
    'Lighting',
    'Plants'
  ];

  // Placeholder catalog data
  final List<DesignItem> _catalog = [
    DesignItem(
      id: 'sofa_modern',
      name: 'Modern White Sofa',
      category: 'Furniture',
      iconAsset: 'assets/icons/sofa.png', // Fallback to IconData if missing
      imageAsset: 'assets/images/sofa_cutout.png', // Needs transparency
      theme: 'Modern',
    ),
    DesignItem(
      id: 'rug_persian',
      name: 'Persian Rug',
      category: 'Rugs',
      iconAsset: 'assets/icons/rug.png',
      imageAsset: 'assets/images/rug_cutout.png',
      theme: 'Classic',
    ),
    DesignItem(
      id: 'plant_monstera',
      name: 'Monstera Plant',
      category: 'Plants',
      iconAsset: 'assets/icons/plant.png',
      imageAsset: 'assets/images/plant_cutout.png',
      theme: 'Tropical',
    ),
     DesignItem(
      id: 'art_abstract',
      name: 'Abstract Canvas',
      category: 'Art',
      iconAsset: 'assets/icons/art.png',
      imageAsset: 'assets/images/art_cutout.png',
      theme: 'Modern',
    ),
  ];

  List<DesignItem> get _filteredCatalog => 
      _catalog.where((item) => item.category == _selectedCategory).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('Sanzen Design Studio', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blueGrey),
            onPressed: () {
              setState(() {
                _placedItems.clear();
              });
            },
            tooltip: 'Clear Room',
          ),
           IconButton(
            icon: const Icon(Icons.check_circle_outline, color: AppColors.primaryGreen),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Design saved to your profile!')),
              );
            },
            tooltip: 'Save Design',
          ),
        ],
      ),
      body: Column(
        children: [
          // The Interactive Canvas (Room)
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF0F0F0),
                // In a real app, use a base room image
                // image: DecorationImage(image: AssetImage('assets/images/empty_room.jpg'), fit: BoxFit.cover),
              ),
              child: Stack(
                children: [
                  // Base Room Background Placeholder
                  const Center(
                    child: Text(
                      'Drag items here from\nthe catalog below',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 18),
                    ),
                  ),
                  
                  // Drag Target for dropping new items
                  DragTarget<DesignItem>(
                    onAcceptWithDetails: (DragTargetDetails<DesignItem> details) {
                      // Calculate local position within the canvas
                      final RenderBox renderBox = context.findRenderObject() as RenderBox;
                      final Offset localOffset = renderBox.globalToLocal(details.offset);
                      
                      setState(() {
                        _placedItems.add(
                          PlacedItem(
                            item: details.data,
                            // Adjusting offset so the center of the item lands where dropped
                            position: Offset(localOffset.dx, localOffset.dy - kToolbarHeight - 24), 
                          ),
                        );
                      });
                    },
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: candidateData.isNotEmpty ? Colors.green.withValues(alpha:0.1) : Colors.transparent,
                      );
                    },
                  ),

                  // Placed Items on top
                  ..._placedItems.map((placedItem) {
                    return Positioned(
                      left: placedItem.position.dx,
                      top: placedItem.position.dy,
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          // Allow moving already placed items
                          setState(() {
                            placedItem.position = Offset(
                              placedItem.position.dx + details.delta.dx,
                              placedItem.position.dy + details.delta.dy,
                            );
                          });
                        },
                        onLongPress: () {
                           // Remove item on long press
                           setState(() {
                             _placedItems.remove(placedItem);
                           });
                        },
                        child: _buildDraggableFeedback(placedItem.item, isPlaced: true),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          
          // The Asset Catalog (Bottom Section)
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Catalog Categories Tab Bar
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = category),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: isSelected ? AppColors.primaryGreen : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? AppColors.primaryGreen : Colors.grey,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Draggable Items List
                Expanded(
                  child: _filteredCatalog.isEmpty 
                    ? const Center(child: Text('No items in this category yet', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredCatalog.length,
                      itemBuilder: (context, index) {
                        final item = _filteredCatalog[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Draggable<DesignItem>(
                            data: item,
                            feedback: _buildDraggableFeedback(item),
                            childWhenDragging: Opacity(
                              opacity: 0.5,
                              child: _buildCatalogItem(item),
                            ),
                            child: _buildCatalogItem(item),
                          ),
                        );
                      },
                    ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Visual representation of the item in the bottom catalog
  Widget _buildCatalogItem(DesignItem item) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
           // Placeholder for actual image asset
           Icon(_getIconForCategory(item.category), size: 40, color: AppColors.primaryGreen),
           const SizedBox(height: 12),
           Text(
             item.name,
             textAlign: TextAlign.center,
             style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
             maxLines: 2,
             overflow: TextOverflow.ellipsis,
           ),
        ],
      ),
    );
  }

  // Visual representation when the item is being dragged or placed on canvas
  Widget _buildDraggableFeedback(DesignItem item, {bool isPlaced = false}) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          // Optional: Add a subtle border when placed so it's visible against white backgrounds
          border: isPlaced ? Border.all(color: Colors.blueAccent.withValues(alpha:0.3), width: 1, style: BorderStyle.solid) : null,
        ),
        child: Center(
          child: Column(
             mainAxisSize: MainAxisSize.min,
            children: [
               Icon(_getIconForCategory(item.category), size: 80, color: AppColors.primaryGreen.withValues(alpha:0.8)),
               if (isPlaced) ...[
                 const SizedBox(height: 8),
                 Text(item.name, style: const TextStyle(backgroundColor: Colors.white70, fontSize: 10))
               ]
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Furniture': return Icons.chair;
      case 'Rugs': return Icons.layers;
      case 'Art': return Icons.color_lens;
      case 'Lighting': return Icons.lightbulb;
      case 'Plants': return Icons.local_florist;
      default: return Icons.home;
    }
  }
}
