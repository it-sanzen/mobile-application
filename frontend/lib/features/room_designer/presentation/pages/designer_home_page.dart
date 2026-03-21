import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/services/room_designer_service.dart';
import 'room_designer_webview_page.dart';
import 'my_room_designs_page.dart';

class DesignerHomePage extends StatefulWidget {
  const DesignerHomePage({Key? key}) : super(key: key);

  @override
  State<DesignerHomePage> createState() => _DesignerHomePageState();
}

class _DesignerHomePageState extends State<DesignerHomePage> {
  List<dynamic> _categories = [];
  List<dynamic> _savedDesigns = [];
  bool _isLoading = true;

  final List<_RoomTypeConfig> _roomTypes = [
    _RoomTypeConfig('LIVING_ROOM', 'Living Room', Icons.weekend, [Color(0xFF144525), Color(0xFF1E6B3A)]),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      RoomDesignerService.getShowroomCategories(),
      RoomDesignerService.getUserDesigns(),
    ]);
    if (mounted) {
      setState(() {
        _categories = results[0];
        _savedDesigns = results[1];
        _isLoading = false;
      });
    }
  }

  int _getStyleCount(String roomType) {
    final match = _categories.where(
      (c) => (c['type'] ?? c['roomType'] ?? '').toString().toUpperCase() == roomType,
    );
    if (match.isNotEmpty) {
      return (match.first['count'] ?? match.first['styleCount'] ?? 0) as int;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text(
          'Room Designer',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.white),
        actions: const [],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            )
          : RefreshIndicator(
              color: AppColors.primaryGreen,
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQuickStartCard(),
                    const SizedBox(height: 28),
                    _buildSectionHeader('Choose a Room Type'),
                    const SizedBox(height: 14),
                    _buildRoomTypeGrid(),
                    if (_savedDesigns.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      _buildSectionHeader('My Saved Designs'),
                      const SizedBox(height: 14),
                      _buildSavedDesignsRow(),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildQuickStartCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const RoomDesignerWebViewPage(roomType: 'LIVING_ROOM'),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF144525), Color(0xFF1B5E30), Color(0xFF0D2E18)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                Icons.weekend,
                size: 160,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'QUICK START',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Start with\nModern Living Room',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text(
                        'Tap to begin',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.gold,
                        size: 18,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {Widget? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.darkGrey,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildRoomTypeGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.35,
      ),
      itemCount: _roomTypes.length,
      itemBuilder: (context, index) {
        final room = _roomTypes[index];
        final styleCount = _getStyleCount(room.type);
        return _buildRoomTypeCard(room, styleCount);
      },
    );
  }

  Widget _buildRoomTypeCard(_RoomTypeConfig room, int styleCount) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RoomDesignerWebViewPage(roomType: room.type),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: room.gradientColors,
          ),
          boxShadow: [
            BoxShadow(
              color: room.gradientColors.first.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(
                room.icon,
                size: 80,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      room.icon,
                      color: AppColors.white,
                      size: 22,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.label,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (styleCount > 0) ...[
                        const SizedBox(height: 2),
                        Text(
                          '$styleCount styles',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedDesignsRow() {
    return SizedBox(
      height: 170,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _savedDesigns.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final design = _savedDesigns[index];
          return _buildSavedDesignCard(design);
        },
      ),
    );
  }

  Widget _buildSavedDesignCard(dynamic design) {
    final name = design['name'] ?? design['title'] ?? 'Untitled Design';
    final thumbnailUrl = design['thumbnailUrl'] ?? design['thumbnail'];
    final createdAt = design['createdAt'] ?? design['updatedAt'] ?? '';
    String dateLabel = '';
    if (createdAt.toString().isNotEmpty) {
      try {
        final date = DateTime.parse(createdAt.toString());
        dateLabel = '${date.day}/${date.month}/${date.year}';
      } catch (_) {}
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RoomDesignerWebViewPage(
              designId: design['id']?.toString(),
            ),
          ),
        );
      },
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryGreen.withOpacity(0.15),
                      AppColors.gold.withOpacity(0.15),
                    ],
                  ),
                ),
                child: thumbnailUrl != null
                    ? Image.network(
                        thumbnailUrl.toString().startsWith('http')
                            ? thumbnailUrl.toString()
                            : 'https://sanzen-new-demo.onrender.com$thumbnailUrl',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildThumbnailPlaceholder(),
                      )
                    : _buildThumbnailPlaceholder(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.darkGrey,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (dateLabel.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      dateLabel,
                      style: const TextStyle(
                        color: AppColors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnailPlaceholder() {
    return Center(
      child: Icon(
        Icons.design_services_outlined,
        size: 36,
        color: AppColors.primaryGreen.withOpacity(0.3),
      ),
    );
  }
}

class _RoomTypeConfig {
  final String type;
  final String label;
  final IconData icon;
  final List<Color> gradientColors;

  const _RoomTypeConfig(this.type, this.label, this.icon, this.gradientColors);
}
