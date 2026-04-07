import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../home/presentation/pages/property_details_page.dart';
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

  final List<String> _filterValues = ['', 'VILLA', 'APARTMENT', 'TOWNHOUSE'];

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
    }
  }

  void _onFilterChanged(int index) {
    setState(() => _selectedFilter = index);
    _fetchProperties();
  }

  // ── Design system colors (from DESIGN.md / code.html) ──
  static const Color _surface = Color(0xFFF9F9F8);
  static const Color _surfaceContainer = Color(0xFFEDEEED);
  static const Color _surfaceContainerHigh = Color(0xFFE7E8E7);
  static const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color _primaryContainer = Color(0xFF1A3C34);
  static const Color _primary = Color(0xFF01261F);
  static const Color _onPrimary = Color(0xFFFFFFFF);
  static const Color _onSurface = Color(0xFF191C1C);
  static const Color _onSurfaceVariant = Color(0xFF414846);
  static const Color _outline = Color(0xFF717976);
  static const Color _outlineVariant = Color(0xFFC1C8C4);
  static const Color _surfaceVariant = Color(0xFFE1E3E2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child:
                    CircularProgressIndicator(color: AppColors.primaryGreen))
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 48, color: _outline.withValues(alpha: 0.6)),
                        const SizedBox(height: 16),
                        Text('Error: $_error',
                            style: const TextStyle(color: _onSurface)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchProperties,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryContainer,
                            foregroundColor: _onPrimary,
                            shape: const StadiumBorder(),
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context),
                        const SizedBox(height: 32),
                        _buildQuickStats(context),
                        const SizedBox(height: 32),
                        _buildFilterChips(),
                        const SizedBox(height: 24),
                        _buildPropertyList(context),
                      ],
                    ),
                  ),
      ),
    );
  }

  // ───────────────────────────── HEADER ─────────────────────────────

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.myProperties,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: _primary,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: _primaryContainer,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${_properties.length} ${_properties.length == 1 ? 'Property' : 'Properties'} owned',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────── QUICK STATS ──────────────────────────

  Widget _buildQuickStats(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final total = _properties.length;
    final building =
        _properties.where((p) => p.status == 'UNDER_CONSTRUCTION').length;
    final ready = _properties.where((p) => p.status == 'READY').length;

    return Column(
      children: [
        // Portfolio Total
        _buildStatCard(
          value: total.toString().padLeft(2, '0'),
          label: 'Active Assets',
          headerLabel: 'PORTFOLIO TOTAL',
          bgColor: _surfaceContainerLowest,
        ),
        const SizedBox(height: 12),
        // In Development — with left accent border
        _buildStatCard(
          value: building.toString().padLeft(2, '0'),
          label: l10n.building,
          headerLabel: 'IN DEVELOPMENT',
          bgColor: _surfaceContainer,
          leftBorderColor: _primaryContainer,
          headerColor: _primaryContainer,
          valueColor: _primaryContainer,
        ),
        const SizedBox(height: 12),
        // Ready to Move
        _buildStatCard(
          value: ready.toString().padLeft(2, '0'),
          label: 'Completed',
          headerLabel: 'READY TO MOVE',
          bgColor: _surfaceContainerLowest,
          valueColor: _outline,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required String headerLabel,
    required Color bgColor,
    Color? leftBorderColor,
    Color? headerColor,
    Color? valueColor,
  }) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: leftBorderColor != null
              ? Border(left: BorderSide(color: leftBorderColor, width: 4))
              : null,
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            headerLabel,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: headerColor ?? _onSurfaceVariant,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: valueColor ?? _primary,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: _onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
  // ──────────────────────────── FILTERS ─────────────────────────────

  Widget _buildFilterChips() {
    return SizedBox(
      height: 44,
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
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _primaryContainer
                      : _surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                  child: Text(
                    _filters(context)[index].toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: isSelected ? _onPrimary : _onSurface,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ──────────────────────── PROPERTY LIST ────────────────────────────

  Widget _buildPropertyList(BuildContext context) {
    if (_properties.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(48),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.apartment_outlined,
                  size: 48, color: _onSurface.withValues(alpha: 0.2)),
              const SizedBox(height: 16),
              Text(
                'No properties found',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  color: _onSurface.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _properties
          .map((property) => Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: _buildPropertyCardFromData(property, context),
              ))
          .toList(),
    );
  }

  Widget _buildPropertyCardFromData(
      PropertyModel property, BuildContext context) {
    final l10n = AppLocalizations.of(context);

    String statusLabel;
    Color statusColor;
    switch (property.status) {
      case 'UNDER_CONSTRUCTION':
        statusLabel = l10n.underConstruction;
        statusColor = _primaryContainer;
        break;
      case 'READY':
        statusLabel = l10n.ready;
        statusColor = AppColors.success;
        break;
      case 'HANDOVER_COMPLETE':
        statusLabel = 'Handover Complete';
        statusColor = _primaryContainer;
        break;
      default:
        statusLabel = property.status;
        statusColor = _outline;
    }

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
      propertyId: property.id,
      propertyModel: property,
      imageAsset: property.imageUrl ?? 'assets/images/zen_lagoons_villa.png',
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
      estimatedCompletion: property.estimatedCompletion,
      context: context,
    );
  }

  Widget _buildPropertyCard({
    String? propertyId,
    PropertyModel? propertyModel,
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
    String? estimatedCompletion,
    required BuildContext context,
  }) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _onSurface.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero Image ──
          SizedBox(
            height: 240,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                imageAsset.startsWith('http')
                    ? Image.network(imageAsset, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [_primary, _primaryContainer],
                            ),
                          ),
                          child: const Icon(Icons.apartment,
                              size: 50, color: _onPrimary),
                        );
                      })
                    : Image.asset(imageAsset, fit: BoxFit.cover),
                // Badges
                Positioned(
                  top: 16,
                  left: 16,
                  child: Row(
                    children: [
                      // Status pill — glass effect
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _onPrimary,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Unit ID pill — white glass
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: _surfaceContainerLowest.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          'UNIT ID: $unitBadge',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _primaryContainer,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Content Section ──
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + more button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: _primary,
                          height: 1.2,
                        ),
                      ),
                    ),
                    GestureDetector(
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(Icons.more_vert,
                            color: _onSurface.withValues(alpha: 0.4),
                            size: 22),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Location
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 14, color: _onSurfaceVariant),
                    const SizedBox(width: 3),
                    Text(
                      location,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: _onSurfaceVariant,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Details Grid — 2x2
                Row(
                  children: [
                    Expanded(child: _buildSpecItem('TYPE', type)),
                    Expanded(child: _buildSpecItem('BEDROOMS', bedrooms)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _buildSpecItem('AREA', area)),
                    Expanded(
                        child: _buildSpecItem(
                            'COMPLETION', estimatedCompletion ?? '—')),
                  ],
                ),

                // Progress
                if (progress != null && progress > 0) ...[
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        l10n.constructionProgress.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _primaryContainer,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        progressLabel ?? '',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _primaryContainer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: _surfaceVariant,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          _primaryContainer),
                    ),
                  ),
                  if (propertyModel?.currentPhase != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _formatPhase(propertyModel!.currentPhase!),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: _onSurfaceVariant,
                      ),
                    ),
                  ],
                ],

                const SizedBox(height: 32),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PropertyDetailsPage(
                                  propertyId: propertyId,
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
                                  currentPhase: propertyModel?.currentPhase,
                                  estimatedCompletion:
                                      propertyModel?.estimatedCompletion,
                                  floor: propertyModel?.floor,
                                  parking: propertyModel?.parking,
                                  balcony: propertyModel?.balcony,
                                  furnishedStatus:
                                      propertyModel?.furnishedStatus,
                                  amenities: propertyModel?.amenities ?? [],
                                  downPayment: propertyModel?.downPayment,
                                  constructionPayment:
                                      propertyModel?.constructionPayment,
                                  handoverPayment:
                                      propertyModel?.handoverPayment,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryContainer,
                            foregroundColor: _onPrimary,
                            elevation: 0,
                            shape: const StadiumBorder(),
                          ),
                          child: Text(
                            l10n.viewDetails.toUpperCase(),
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ),
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

  Widget _buildSpecItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: _outline,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: _onSurface,
          ),
        ),
      ],
    );
  }

  String _formatPhase(String phase) {
    return phase
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .map((w) =>
            w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : w)
        .join(' ');
  }
}
