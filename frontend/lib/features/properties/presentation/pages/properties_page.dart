import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../home/presentation/pages/property_details_page.dart';
import 'package:mobile_erp_app/features/design_studio/presentation/pages/upload_room_photo_page.dart';
import '../../../home/data/models/property_model.dart';
import '../../data/services/properties_service.dart';

class PropertiesPage extends StatefulWidget {
  const PropertiesPage({super.key});

  @override
  State<PropertiesPage> createState() => _PropertiesPageState();
}

class _PropertiesPageState extends State<PropertiesPage> {
  int _selectedFilter = 0;
  List<PropertyModel> _properties = [];
  bool _isLoading = true;
  String? _error;

  List<String> _filters(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [l10n.all, l10n.villa, l10n.apartment, l10n.townhouse];
  }

  List<String> _filterValues = ['', 'VILLA', 'APARTMENT', 'TOWNHOUSE'];

  @override
  void initState() {
    super.initState();
    _fetchProperties();
  }

  Future<void> _fetchProperties() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final propertyType = _filterValues[_selectedFilter];
      final properties = await PropertiesService.getMyProperties(
        propertyType: propertyType.isEmpty ? null : propertyType,
      );
      setState(() {
        _properties = properties;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      print('Error fetching properties: $e');
    }
  }

  void _onFilterChanged(int index) {
    setState(() => _selectedFilter = index);
    _fetchProperties();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen))
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: $_error'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchProperties,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context),
                        _buildQuickStats(context),
                        _buildAiDesignerCard(context),
                        _buildFilterChips(),
                        _buildPropertyList(context),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
      ),
    );
  }

  // ───────────────────────────── HEADER ─────────────────────────────

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.myProperties,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${_properties.length} ${l10n.propertiesOwned}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8A8A8A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────── AI DESIGNER ──────────────────────────

  Widget _buildAiDesignerCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: GestureDetector(
        onTap: () async {
          await Navigator.push<Object?>(
            context,
            MaterialPageRoute(builder: (_) => const UploadRoomPhotoPage()),
          );
        },
        child: Container(
          width: double.infinity,
          height: 90,
          decoration: BoxDecoration(
            gradient: AppColors.luxuryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 20),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: AppColors.gold,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sanzen Creative Studio',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Upload a photo to build in 3D',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.gold,
                size: 16,
              ),
              const SizedBox(width: 20),
            ],
          ),
        ),
      ),
    );
  }


  // ─────────────────────────── QUICK STATS ──────────────────────────

  Widget _buildQuickStats(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final total = _properties.length;
    final building =
        _properties.where((p) => p.status == 'UNDER_CONSTRUCTION').length;
    final ready = _properties.where((p) => p.status == 'READY').length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          _buildStatCard(
            icon: Icons.apartment,
            iconBg: const Color(0xFFE8F5E9),
            iconColor: AppColors.primaryGreen,
            value: '$total',
            label: l10n.total,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            icon: Icons.construction,
            iconBg: const Color(0xFFFFF8E1),
            iconColor: AppColors.gold,
            value: '$building',
            label: l10n.building,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            icon: Icons.check_circle_outline,
            iconBg: const Color(0xFFE8F5E9),
            iconColor: AppColors.success,
            value: '$ready',
            label: l10n.ready,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.darkGrey.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────── FILTERS ─────────────────────────────

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 0, 4),
      child: SizedBox(
        height: 38,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _filters(context).length,
          itemBuilder: (context, index) {
            final isSelected = _selectedFilter == index;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => _onFilterChanged(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryGreen
                        : AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryGreen
                          : AppColors.lightGrey,
                      width: 1.2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color:
                                  AppColors.primaryGreen.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    _filters(context)[index],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color:
                          isSelected ? AppColors.white : AppColors.darkGrey,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ──────────────────────── PROPERTY LIST ────────────────────────────

  Widget _buildPropertyList(BuildContext context) {
    if (_properties.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: Text(
            'No properties found',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.lightGrey,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        children: _properties
            .map((property) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildPropertyCardFromData(property, context),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildPropertyCardFromData(
      PropertyModel property, BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Map status
    String statusLabel;
    Color statusColor;
    switch (property.status) {
      case 'UNDER_CONSTRUCTION':
        statusLabel = l10n.underConstruction;
        statusColor = AppColors.gold;
        break;
      case 'READY':
        statusLabel = l10n.ready;
        statusColor = AppColors.success;
        break;
      case 'HANDOVER_COMPLETE':
        statusLabel = 'Handover Complete';
        statusColor = AppColors.primaryGreen;
        break;
      default:
        statusLabel = property.status;
        statusColor = AppColors.lightGrey;
    }

    // Map property type
    String typeLabel;
    switch (property.propertyType) {
      case 'VILLA':
        typeLabel = l10n.villa;
        break;
      case 'APARTMENT':
        typeLabel = l10n.apartment;
        break;
      case 'TOWNHOUSE':
        typeLabel = l10n.townhouse;
        break;
      case 'PENTHOUSE':
        typeLabel = 'Penthouse';
        break;
      default:
        typeLabel = property.propertyType;
    }

    return _buildPropertyCard(
      imageAsset: property.imageUrl ??
          'assets/images/zen_lagoons_villa.png', // fallback
      unitBadge: property.unitCode ?? 'UNIT',
      name: property.name,
      location: property.location,
      type: typeLabel,
      bedrooms: '${property.bedrooms} BR',
      area: '${property.area.toStringAsFixed(0)} sqft',
      status: statusLabel,
      statusColor: statusColor,
      progress: property.completionPercentage / 100,
      progressLabel: '${property.completionPercentage.toInt()}%',
      context: context,
    );
  }

  Widget _buildPropertyCard({
    required String imageAsset,
    required String unitBadge,
    required String name,
    required String location,
    required String type,
    required String bedrooms,
    required String area,
    required String status,
    required Color statusColor,
    required double? progress,
    required String? progressLabel,
    required BuildContext context,
  }) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image section ──
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: SizedBox(
              height: 180,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  imageAsset.startsWith('http')
                      ? Image.network(imageAsset, fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: const BoxDecoration(
                              gradient: AppColors.luxuryGradient,
                            ),
                            child: const Icon(Icons.apartment,
                                size: 50, color: AppColors.white),
                          );
                        })
                      : Image.asset(imageAsset, fit: BoxFit.cover),
                  // Luxurious gradient overlay
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.1),
                            Colors.black.withValues(alpha: 0.75),
                          ],
                          stops: const [0.4, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Unit badge
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        unitBadge,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  // Status badge
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                  // Name + Location
                  Positioned(
                    bottom: 14,
                    left: 14,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: AppColors.white.withValues(alpha: 0.85),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              location,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Details section ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              children: [
                // Property specs row
                Row(
                  children: [
                    _buildSpecChip(Icons.home_outlined, type),
                    const SizedBox(width: 10),
                    _buildSpecChip(Icons.bed_outlined, bedrooms),
                    const SizedBox(width: 10),
                    _buildSpecChip(Icons.square_foot, area),
                  ],
                ),

                // Progress bar (conditional)
                if (progress != null && progress > 0) ...[
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.constructionProgress,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.darkGrey.withValues(alpha: 0.7),
                        ),
                      ),
                      Text(
                        progressLabel ?? '',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor:
                          AppColors.lightGrey.withValues(alpha: 0.5),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 14),

                // Action row
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PropertyDetailsPage(
                                  propertyName: name,
                                  location: location,
                                  unitCode: unitBadge,
                                  type: type,
                                  bedrooms: bedrooms,
                                  area: area,
                                  status: status,
                                  statusColor: statusColor,
                                  progress: progress,
                                  imageAsset: imageAsset,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: AppColors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            l10n.viewDetails,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.more_horiz,
                        color: AppColors.primaryGreen,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: AppColors.darkGrey.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.darkGrey.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
