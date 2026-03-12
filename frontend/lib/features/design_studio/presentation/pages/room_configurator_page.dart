import 'package:flutter/material.dart';

class RoomConfiguratorPage extends StatefulWidget {
  final String roomType;

  const RoomConfiguratorPage({Key? key, required this.roomType}) : super(key: key);

  @override
  State<RoomConfiguratorPage> createState() => _RoomConfiguratorPageState();
}

class _RoomConfiguratorPageState extends State<RoomConfiguratorPage> {
  late List<Map<String, String>> _packages;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.roomType == 'kitchen') {
      _packages = [
        {
          'id': 'modern_dark',
          'name': 'Midnight Modern',
          'desc': 'Matte black cabinetry with moody, dark marble countertops.',
          'image': 'assets/images/design_studio/kitchen_dark_modern.png',
          'color': '0xFF1A1A1A',
        },
        {
          'id': 'scandi_light',
          'name': 'Nordic Bright',
          'desc': 'Gloss white cabinetry, light oak timber, and bright natural daylight.',
          'image': 'assets/images/design_studio/kitchen_scandi_light.png',
          'color': '0xFFF0EAE1',
        },
        {
          'id': 'industrial',
          'name': 'Industrial Raw',
          'desc': 'Brushed stainless steel, exposed concrete, and warm strip lighting.',
          'image': 'assets/images/design_studio/kitchen_industrial_concrete.png',
          'color': '0xFF8A8D8F',
        },
      ];
    } else {
      // Courtyard
      _packages = [
        {
          'id': 'oasis',
          'name': 'Tropical Oasis',
          'desc': 'Lush palms, dark wood decking, and an infinity plunge pool.',
          'image': 'assets/images/design_studio/courtyard_oasis_lush.png',
          'color': '0xFF2E4C3B',
        },
        {
          'id': 'desert',
          'name': 'Desert Modern',
          'desc': 'Saguaro cacti, concrete minimalist angles, and a central fire pit.',
          'image': 'assets/images/design_studio/courtyard_desert_modern.png',
          'color': '0xFFD4A373',
        },
        {
          'id': 'zen',
          'name': 'Zen Retreat',
          'desc': 'Raked sand, smooth pebbles, and traditional bamboo features.',
          'image': 'assets/images/design_studio/courtyard_zen_stones.png',
          'color': '0xFF9AA098',
        },
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPackage = _packages[_selectedIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.roomType == 'kitchen' ? 'Kitchen Design' : 'Courtyard Design',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black54, blurRadius: 10)],
          ),
        ),
      ),
      body: Stack(
        children: [
          // 1. The Full-Screen Room Image with Cross-Fade Animation
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: Image.asset(
                currentPackage['image']!,
                key: ValueKey<String>(currentPackage['image']!),
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),

          // Optional Gradient Overlay for text readability at the bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.4,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.9),
                    Colors.black.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),

          // 2. The Interactive UI Drawer
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentPackage['name']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currentPackage['desc']!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'SELECT DESIGN PACKAGE',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Horizontally Scrollable Materials List
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _packages.length,
                    itemBuilder: (context, index) {
                      final pkg = _packages[index];
                      final isSelected = index == _selectedIndex;
                      final swatchColor = Color(int.parse(pkg['color']!));

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(right: 20),
                          width: 80,
                          decoration: BoxDecoration(
                            color: swatchColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.transparent,
                              width: isSelected ? 4 : 0,
                            ),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: swatchColor.withOpacity(0.6),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                )
                            ],
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, color: Colors.white)
                              : null,
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
}
