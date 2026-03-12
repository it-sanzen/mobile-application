import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'documents_page.dart';
import '../../../properties/presentation/pages/properties_page.dart';
import 'notifications_page.dart';
import 'profile_page.dart';
import 'view_timeline_page.dart';
import 'addon_offer_page.dart';
import 'property_details_page.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../data/services/home_service.dart';
import '../../data/models/property_model.dart';
import '../../data/models/unit_update_model.dart';
import '../../data/models/company_news_model.dart';
import '../../../../core/services/token_service.dart';
import '../../../../core/models/addon_offer.dart';
import '../../../../core/services/addon_offers_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _selectedNavIndex = 0;
  late TabController _tabController;
  final HomeService _homeService = HomeService();

  PropertyModel? _property;
  List<UnitUpdateModel> _unitUpdates = [];
  List<CompanyNewsModel> _companyNews = [];
  List<AddonOffer> _addonOffers = [];
  bool _isLoading = true;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _homeService.getMyPrimaryProperty(),
        _homeService.getUnitUpdates(),
        _homeService.getCompanyNews(),
        TokenService.getUserData(),
        AddonOffersService.getAllActiveOffers(),
      ]);

      final userData = results[3] as Map<String, String?>;

      setState(() {
        _property = results[0] as PropertyModel?;
        _unitUpdates = results[1] as List<UnitUpdateModel>;
        _companyNews = results[2] as List<CompanyNewsModel>;
        _addonOffers = results[4] as List<AddonOffer>;
        _userName = userData['name'] ?? userData['email'] ?? 'User';
        _isLoading = false;
      });
      
      // Simulate real-time push notification if there are updates
      if (_unitUpdates.isNotEmpty) {
        // Wait for build to finish then show notification
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              _showInAppNotification(_unitUpdates.first);
            }
          });
        });
      }
      
    } catch (e) {
      print('Error fetching home data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: IndexedStack(
        index: _selectedNavIndex,
        children: [
          _buildHomeBody(),
          const PropertiesPage(),
          const DocumentsPage(),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeBody() {
    if (_isLoading) {
      return const SafeArea(
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryGreen,
          ),
        ),
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            if (_property != null) _buildPropertyCard(),
            if (_property != null) _buildProgressSection(),
            _buildUpdateTabs(),
            _buildUpdatesList(),
            _buildExclusiveAddons(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _userName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationsPage(),
                ),
              );
            },
            child: Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.primaryGreen,
                    size: 22,
                  ),
                ),
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showInAppNotification(UnitUpdateModel latestUpdate) {
    if (!mounted) return;
    
    final overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => AnimatedNotificationOverlay(
        update: latestUpdate,
        onDismissed: () {
          if (overlayEntry.mounted) {
            overlayEntry.remove();
          }
        },
      ),
    );

    overlayState.insert(overlayEntry);
  }

  Widget _buildPropertyCard() {
    if (_property == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final property = _property!;

    // Determine status color
    Color statusColor = AppColors.gold;
    if (property.status.toLowerCase().contains('completed')) {
      statusColor = AppColors.primaryGreen;
    } else if (property.status.toLowerCase().contains('construction')) {
      statusColor = AppColors.gold;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        children: [
          // "My Property" header with DETAILS link
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.myProperty,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PropertyDetailsPage(
                        propertyName: property.name,
                        location: property.location,
                        unitCode: property.unitCode,
                        type: property.propertyType,
                        bedrooms: '${property.bedrooms} BR',
                        area: '${property.area.toStringAsFixed(0)} sqft',
                        status: property.status,
                        statusColor: statusColor,
                        progress: property.completionPercentage / 100,
                        imageAsset: property.imageUrl ?? 'assets/images/zen_lagoons_villa.png',
                      ),
                    ),
                  );
                },
                child: Text(
                  l10n.details,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryGreen,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Property image card
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: AppColors.luxuryGradient,
              ),
              child: Stack(
                children: [
                  // Property image
                  Positioned.fill(
                    child: _buildPropertyImage(property.imageUrl),
                  ),
                  // Gradient overlay for text readability
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.6),
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
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        property.unitCode,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  // Property name and location
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          property.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          property.location,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyImage(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      // Try to load network image, fallback to asset on error
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/zen_lagoons_villa.png'),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      );
    } else {
      // Use default asset image
      return Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/zen_lagoons_villa.png'),
            fit: BoxFit.cover,
          ),
        ),
      );
    }
  }

  Widget _buildProgressSection() {
    if (_property == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final property = _property!;
    final progressValue = property.completionPercentage / 100;
    final currentPhase = property.currentPhase ?? l10n.foundationStage;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        children: [
          // Current Phase header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                currentPhase,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
              Text(
                '${property.completionPercentage.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: 8,
              backgroundColor: AppColors.lightGrey.withValues(alpha: 0.5),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primaryGreen,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Est. completion + View Timeline
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 15,
                    color: AppColors.darkGrey.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${l10n.estCompletion} ${property.estimatedCompletion ?? 'TBD'}',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.darkGrey.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  if (_property != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ViewTimelinePage(
                          propertyId: _property!.id,
                          propertyName: _property!.name,
                        ),
                      ),
                    );
                  }
                },
                child: Row(
                  children: [
                    Text(
                      l10n.viewTimeline,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: AppColors.primaryGreen,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateTabs() {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: TabBar(
        controller: _tabController,
        onTap: (index) => setState(() {}),
        labelColor: AppColors.black,
        unselectedLabelColor: AppColors.grey,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        indicatorColor: AppColors.primaryGreen,
        indicatorWeight: 2.5,
        tabs: [
          Tab(text: l10n.unitUpdates),
          Tab(text: l10n.companyNews),
        ],
      ),
    );
  }

  Widget _buildUpdatesList() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _tabController.index == 0
          ? _buildUnitUpdatesList()
          : _buildCompanyNewsList(),
    );
  }

  Widget _buildUnitUpdatesList() {
    if (_unitUpdates.isEmpty) {
      return Padding(
        key: const ValueKey('unit_updates'),
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
        child: Center(
          child: Text(
            'No unit updates available',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.darkGrey.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }

    return Padding(
      key: const ValueKey('unit_updates'),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        children: _unitUpdates.map((update) {
          final iconData = _getUpdateTypeIcon(update.updateType);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildUpdateItem(
              icon: iconData,
              iconColor: AppColors.primaryGreen,
              iconBgColor: const Color(0xFFE8F5E9),
              title: update.title,
              description: update.description,
              time: update.time,
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _getUpdateTypeIcon(String updateType) {
    switch (updateType.toUpperCase()) {
      case 'ELECTRICAL':
        return Icons.electrical_services;
      case 'PLUMBING':
        return Icons.plumbing;
      case 'CONSTRUCTION':
        return Icons.foundation;
      case 'INSPECTION':
        return Icons.checklist;
      case 'MILESTONE':
        return Icons.flag;
      case 'GENERAL':
      default:
        return Icons.notifications;
    }
  }

  Widget _buildCompanyNewsList() {
    if (_companyNews.isEmpty) {
      return Padding(
        key: const ValueKey('company_news'),
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
        child: Center(
          child: Text(
            'No company news available',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.darkGrey.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }

    return Padding(
      key: const ValueKey('company_news'),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        children: _companyNews.map((news) {
          final iconData = _getNewsCategoryIcon(news.category);
          final iconColor = _getNewsCategoryColor(news.category);
          final bgColor = _getNewsCategoryBgColor(news.category);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildUpdateItem(
              icon: iconData,
              iconColor: iconColor,
              iconBgColor: bgColor,
              title: news.title,
              description: news.description,
              time: news.time,
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _getNewsCategoryIcon(String category) {
    switch (category.toUpperCase()) {
      case 'ANNOUNCEMENT':
        return Icons.campaign_outlined;
      case 'AWARD':
        return Icons.emoji_events_outlined;
      case 'EVENT':
        return Icons.groups_outlined;
      case 'SUSTAINABILITY':
        return Icons.eco_outlined;
      case 'COMMUNITY':
        return Icons.groups_outlined;
      default:
        return Icons.campaign_outlined;
    }
  }

  Color _getNewsCategoryColor(String category) {
    switch (category.toUpperCase()) {
      case 'AWARD':
        return const Color(0xFFC2A563); // Gold color
      case 'ANNOUNCEMENT':
      case 'EVENT':
      case 'SUSTAINABILITY':
      case 'COMMUNITY':
      default:
        return AppColors.primaryGreen;
    }
  }

  Color _getNewsCategoryBgColor(String category) {
    switch (category.toUpperCase()) {
      case 'AWARD':
        return const Color(0xFFFFF8E1); // Light gold
      case 'ANNOUNCEMENT':
      case 'EVENT':
      case 'SUSTAINABILITY':
      case 'COMMUNITY':
      default:
        return const Color(0xFFE8F5E9); // Light green
    }
  }

  Widget _buildUpdateItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String description,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.darkGrey.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.darkGrey.withValues(alpha: 0.65),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExclusiveAddons() {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.exclusiveAddons,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 14),
          _addonOffers.isEmpty
              ? const SizedBox(
                  height: 240,
                  child: Center(
                    child: Text(
                      'No add-ons available',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.lightGrey,
                      ),
                    ),
                  ),
                )
              : SizedBox(
                  height: 240,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _addonOffers.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final addon = _addonOffers[index];
                      return _buildAddonCardFromData(context, addon);
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildAddonCardFromData(BuildContext context, AddonOffer addon) {
    // Map category to icon and colors
    IconData offerIcon;
    List<Color> offerColors;

    switch (addon.category) {
      case AddonCategory.upgrade:
        offerIcon = Icons.upgrade;
        offerColors = [const Color(0xFF4E342E), const Color(0xFF3E2723)];
        break;
      case AddonCategory.smartHome:
        offerIcon = Icons.smart_toy_outlined;
        offerColors = [const Color(0xFF1565C0), const Color(0xFF0D47A1)];
        break;
      case AddonCategory.outdoor:
        offerIcon = Icons.pool;
        offerColors = [const Color(0xFF3E8E6B), const Color(0xFF2D6B50)];
        break;
      case AddonCategory.vehicle:
        offerIcon = Icons.ev_station;
        offerColors = [const Color(0xFF3E8E6B), const Color(0xFF2D6B50)];
        break;
      case AddonCategory.security:
        offerIcon = Icons.security;
        offerColors = [const Color(0xFFD32F2F), const Color(0xFFC62828)];
        break;
      case AddonCategory.other:
      default:
        offerIcon = Icons.star;
        offerColors = [const Color(0xFFFFA000), const Color(0xFFFF8F00)];
        break;
    }

    // Truncate description if too long
    String displayDescription = addon.description.length > 80
        ? '${addon.description.substring(0, 77)}...'
        : addon.description;

    return _buildAddonCard(
      context,
      title: addon.title,
      description: displayDescription,
      imageAsset: addon.imageUrl,
      offerIcon: offerIcon,
      offerColors: offerColors,
      price: addon.price,
      iconEmoji: addon.icon,
    );
  }

  Widget _buildAddonCard(BuildContext context, {
    required String title,
    required String description,
    String? imageAsset,
    IconData? placeholderIcon,
    List<Color>? placeholderColors,
    required IconData offerIcon,
    required List<Color> offerColors,
    double? price,
    String? iconEmoji,
  }) {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add-on image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: SizedBox(
              height: 100,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (imageAsset != null)
                    Image.asset(
                      imageAsset,
                      fit: BoxFit.cover,
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: placeholderColors ?? [const Color(0xFF3E8E6B), const Color(0xFF2D6B50)],
                        ),
                      ),
                      child: Center(
                        child: iconEmoji != null
                            ? Text(
                                iconEmoji,
                                style: const TextStyle(fontSize: 40),
                              )
                            : Icon(
                                placeholderIcon ?? Icons.extension,
                                size: 40,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                      ),
                    ),
                  // Gradient overlay for text
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.5),
                          ],
                          stops: const [0.4, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Title overlay on image
                  Positioned(
                    bottom: 10,
                    left: 12,
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.darkGrey.withValues(alpha: 0.7),
                      height: 1.4,
                    ),
                  ),
                  if (price != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      '\$${price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 34,
                    child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddonOfferPage(
                            title: title,
                            description: description,
                            icon: offerIcon,
                            gradientColors: offerColors,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      AppLocalizations.of(context).viewOffer,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedNavIndex,
        onTap: (index) => setState(() => _selectedNavIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: AppColors.grey,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.gold),
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home, color: AppColors.gold),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.apartment_outlined),
            activeIcon: const Icon(Icons.apartment, color: AppColors.gold),
            label: l10n.properties,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.description_outlined),
            activeIcon: const Icon(Icons.description, color: AppColors.gold),
            label: l10n.documents,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person, color: AppColors.gold),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }
}

class AnimatedNotificationOverlay extends StatefulWidget {
  final UnitUpdateModel update;
  final VoidCallback onDismissed;

  const AnimatedNotificationOverlay({
    super.key,
    required this.update,
    required this.onDismissed,
  });

  @override
  State<AnimatedNotificationOverlay> createState() => _AnimatedNotificationOverlayState();
}

class _AnimatedNotificationOverlayState extends State<AnimatedNotificationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1.5, 0.0), // Start offscreen right
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack, // Gives a slight bounce effect
    ));

    _startAnimationSequence();
  }

  Future<void> _startAnimationSequence() async {
    // Slide in
    await _controller.forward();
    // Wait for display time
    await Future.delayed(const Duration(seconds: 4));
    // Slide out
    if (mounted) {
      await _controller.reverse();
      widget.onDismissed();
    }
  }

  void _dismissManually() {
    if (mounted) {
      _controller.reverse().then((_) => widget.onDismissed());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 60,
      right: 16,
      left: MediaQuery.of(context).size.width > 400
          ? MediaQuery.of(context).size.width - 320
          : 16,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: _offsetAnimation,
          child: Dismissible(
            key: const Key('in_app_notification_overlay'),
            direction: DismissDirection.horizontal,
            onDismissed: (_) {
              widget.onDismissed();
            },
            child: GestureDetector(
              onTap: () {
                _dismissManually();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsPage()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.notifications_active,
                        color: AppColors.primaryGreen,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'New Update',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.gold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.update.title,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.update.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.darkGrey.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
