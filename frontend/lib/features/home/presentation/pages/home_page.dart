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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _selectedNavIndex = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildPropertyCard(),
            _buildProgressSection(),
            _buildUpdateTabs(),
            _buildUpdatesList(),
            _buildExclusiveAddons(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(String title) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 48, color: AppColors.grey),
            const SizedBox(height: 12),
            Text(
              '$title — Coming Soon',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.darkGrey.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
                l10n.goodMorning,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.darkGrey.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'James Anderson',
                style: TextStyle(
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

  Widget _buildPropertyCard() {
    final l10n = AppLocalizations.of(context);
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
                      builder: (_) => const PropertyDetailsPage(
                        propertyName: 'Zen Lagoons Villa',
                        location: 'Palm Jumeirah, Dubai',
                        unitCode: 'UNIT A-204',
                        type: 'Villa',
                        bedrooms: '5 BR',
                        area: '4,200 sqft',
                        status: 'Under Construction',
                        statusColor: AppColors.gold,
                        progress: 0.45,
                        imageAsset: 'assets/images/zen_lagoons_villa.png',
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
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF4A7C5B),
                    Color(0xFF2D5A3F),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Property image
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/zen_lagoons_villa.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
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
                      child: const Text(
                        'UNIT A-204',
                        style: TextStyle(
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
                        const Text(
                          'Zen Lagoons Villa',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Palm Jumeirah, Dubai',
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

  Widget _buildProgressSection() {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        children: [
          // Foundation Stage header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.foundationStage,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
              const Text(
                '45%',
                style: TextStyle(
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
              value: 0.45,
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
                    '${l10n.estCompletion} Dec 2024',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.darkGrey.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ViewTimelinePage(),
                    ),
                  );
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
    return Padding(
      key: const ValueKey('unit_updates'),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        children: [
          _buildUpdateItem(
            icon: Icons.electrical_services,
            iconColor: AppColors.primaryGreen,
            iconBgColor: const Color(0xFFE8F5E9),
            title: 'Electrical Wiring Complete',
            description:
                'Phase 2 electrical wiring has been successfully inspected and approved for Unit A-204.',
            time: '2h ago',
          ),
          const SizedBox(height: 12),
          _buildUpdateItem(
            icon: Icons.cloud_download_outlined,
            iconColor: AppColors.primaryGreen,
            iconBgColor: const Color(0xFFE8F5E9),
            title: 'Sukoon Project Launched',
            description:
                'Discover our newest serene living spaces at the Sukoon launch event this weekend.',
            time: '1d ago',
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyNewsList() {
    return Padding(
      key: const ValueKey('company_news'),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        children: [
          _buildUpdateItem(
            icon: Icons.campaign_outlined,
            iconColor: AppColors.primaryGreen,
            iconBgColor: const Color(0xFFE8F5E9),
            title: 'Zen Gardens Phase 3 Announced',
            description:
                'Sanzen unveils Phase 3 of Zen Gardens — a premium collection of waterfront villas launching Q2 2025.',
            time: '3h ago',
          ),
          const SizedBox(height: 12),
          _buildUpdateItem(
            icon: Icons.emoji_events_outlined,
            iconColor: const Color(0xFFC2A563),
            iconBgColor: const Color(0xFFFFF8E1),
            title: 'Best Sustainable Developer 2024',
            description:
                'Sanzen has been awarded "Best Sustainable Developer" at the Arabian Property Awards for excellence in green building.',
            time: '2d ago',
          ),
          const SizedBox(height: 12),
          _buildUpdateItem(
            icon: Icons.groups_outlined,
            iconColor: AppColors.primaryGreen,
            iconBgColor: const Color(0xFFE8F5E9),
            title: 'Community Homeowners Meetup',
            description:
                'Join fellow homeowners at the Sanzen Community Lounge this Saturday for an exclusive networking brunch.',
            time: '3d ago',
          ),
          const SizedBox(height: 12),
          _buildUpdateItem(
            icon: Icons.eco_outlined,
            iconColor: AppColors.primaryGreen,
            iconBgColor: const Color(0xFFE8F5E9),
            title: 'Solar Panel Initiative',
            description:
                'We\'re introducing rooftop solar panels across all Sanzen communities — reducing energy costs by up to 40%.',
            time: '5d ago',
          ),
        ],
      ),
    );
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
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 240,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildAddonCard(context,
                  title: 'Private Pool',
                  description:
                      'Upgrade your villa with a temperature-controlled infinity pool.',
                  imageAsset: 'assets/images/pool_addon.png',
                  offerIcon: Icons.pool,
                  offerColors: [const Color(0xFF3E8E6B), const Color(0xFF2D6B50)],
                ),
                const SizedBox(width: 14),
                _buildAddonCard(context,
                  title: 'EV Charger',
                  description:
                      'Install a high-speed home charging station for your E...',
                  imageAsset: 'assets/images/ev_charger_addon.png',
                  offerIcon: Icons.ev_station,
                  offerColors: [const Color(0xFF3E8E6B), const Color(0xFF2D6B50)],
                ),
                const SizedBox(width: 14),
                _buildAddonCard(context,
                  title: 'Home Automation',
                  description:
                      'Smart lighting, climate control & security — all from your phone.',
                  imageAsset: 'assets/images/home_automation_addon.png',
                  offerIcon: Icons.smart_toy_outlined,
                  offerColors: [const Color(0xFF1565C0), const Color(0xFF0D47A1)],
                ),
                const SizedBox(width: 14),
                _buildAddonCard(context,
                  title: 'Solar Solutions',
                  description:
                      'Reduce energy bills with premium rooftop solar panel installation.',
                  imageAsset: 'assets/images/solar_solutions_addon.png',
                  offerIcon: Icons.solar_power_outlined,
                  offerColors: [const Color(0xFFE65100), const Color(0xFFBF360C)],
                ),
                const SizedBox(width: 14),
                _buildAddonCard(context,
                  title: 'Kitchen Design',
                  description:
                      'Bespoke kitchen layouts with premium finishes and smart appliances.',
                  imageAsset: 'assets/images/kitchen_design_addon.png',
                  offerIcon: Icons.kitchen_outlined,
                  offerColors: [const Color(0xFF4E342E), const Color(0xFF3E2723)],
                ),
                const SizedBox(width: 20),
              ],
            ),
          ),
        ],
      ),
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
                        child: Icon(
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
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedNavIndex,
        onTap: (index) => setState(() => _selectedNavIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.grey,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.apartment_outlined),
            activeIcon: const Icon(Icons.apartment),
            label: l10n.properties,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.description_outlined),
            activeIcon: const Icon(Icons.description),
            label: l10n.documents,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }
}
