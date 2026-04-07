import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/addon_quote_service.dart';
import '../../../../core/services/api_service.dart';
import '../../../properties/data/services/properties_service.dart';
import '../../data/models/property_model.dart';

// ─── Design System Colors (Sanzen brand + Stitch layout) ───
class _DS {
  static const Color primary = Color(0xFF192A1D);       // AppColors.primaryDark
  static const Color primaryContainer = Color(0xFF144525); // AppColors.primaryGreen - same as View Offer button
  static const Color gold = Color(0xFFC2A563);           // AppColors.gold
  static const Color goldBright = Color(0xFFD4B97A);     // AppColors.goldBright
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF8BAF8E);
  static const Color surface = Color(0xFFFAFAFA);        // AppColors.offWhite
  static const Color surfaceContainerLow = Color(0xFFF3F4F3);
  static const Color surfaceContainerHigh = Color(0xFFE7E8E7);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF111111);      // AppColors.black
  static const Color onSurfaceVariant = Color(0xFF333333); // AppColors.darkGrey
  static const Color grey = Color(0xFF888888);           // AppColors.grey
  static const Color outlineVariant = Color(0xFFE5E5E5); // AppColors.lightGrey
}

class AddonOfferPage extends StatefulWidget {
  final String addonOfferId;
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final double? price;
  final String? imageUrl;
  final String? iconEmoji;

  const AddonOfferPage({
    super.key,
    required this.addonOfferId,
    required this.title,
    required this.description,
    required this.icon,
    required this.gradientColors,
    this.price,
    this.imageUrl,
    this.iconEmoji,
  });

  @override
  State<AddonOfferPage> createState() => _AddonOfferPageState();
}

class _AddonOfferPageState extends State<AddonOfferPage> {
  bool _isSubmitting = false;
  List<PropertyModel> _properties = [];
  String? _selectedPropertyId;
  int _selectedPackageIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    try {
      final properties = await PropertiesService.getMyProperties();
      setState(() {
        _properties = properties;
        if (properties.isNotEmpty) _selectedPropertyId = properties.first.id;
      });
    } catch (_) {}
  }

  Future<void> _submitQuote() async {
    if (_selectedPropertyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No property found'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await AddonQuoteService.submitQuote(
        propertyId: _selectedPropertyId!,
        addonOfferIds: [widget.addonOfferId],
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Quote request submitted! We will get back to you soon.'),
            backgroundColor: _DS.primaryContainer,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String get _categoryLabel {
    final title = widget.title.toLowerCase();
    if (title.contains('kitchen') || title.contains('upgrade')) return 'Curated Upgrade';
    if (title.contains('pool') || title.contains('outdoor')) return 'Outdoor Living';
    if (title.contains('smart') || title.contains('home')) return 'Smart Home';
    if (title.contains('solar') || title.contains('energy')) return 'Energy Solutions';
    if (title.contains('security') || title.contains('safe')) return 'Home Security';
    if (title.contains('garden') || title.contains('landscape')) return 'Landscape Design';
    if (title.contains('ev') || title.contains('charger') || title.contains('vehicle')) return 'EV Solutions';
    return 'Exclusive Add-on';
  }

  String get _collectionTitle {
    final title = widget.title.toLowerCase();
    if (title.contains('kitchen')) return 'Kitchen Collection';
    if (title.contains('pool')) return 'Pool Collection';
    if (title.contains('smart')) return 'Smart Home Collection';
    if (title.contains('solar') || title.contains('energy')) return 'Energy Collection';
    if (title.contains('security')) return 'Security Collection';
    if (title.contains('garden') || title.contains('landscape')) return 'Garden Collection';
    if (title.contains('ev') || title.contains('charger')) return 'EV Collection';
    return 'Add-on Collection';
  }

  ImageProvider? get _heroImage {
    if (widget.imageUrl == null) return null;
    if (widget.imageUrl!.startsWith('http')) {
      return NetworkImage(widget.imageUrl!);
    } else if (widget.imageUrl!.startsWith('/uploads')) {
      return NetworkImage('${ApiService.baseUrl.replaceAll('/api/v1', '')}${widget.imageUrl!}');
    } else {
      return AssetImage(widget.imageUrl!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: _DS.surface,
      body: Stack(
        children: [
          // ─── Scrollable content ───
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Hero Image ───
                _buildHeroImage(topPadding),

                // ─── Lifted Content Card (overlaps hero) ───
                Transform.translate(
                  offset: const Offset(0, -48),
                  child: _buildContentCard(),
                ),

                // ─── Gallery Teaser ───
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                  child: _buildGalleryImage(),
                ),
              ],
            ),
          ),

          // ─── Glass Header ───
          _buildGlassHeader(topPadding),

          // ─── Bottom Action Bar ───
          _buildBottomBar(bottomPadding),
        ],
      ),
    );
  }

  // ─── Glass Navigation Header ───
  Widget _buildGlassHeader(double topPadding) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(top: topPadding),
        decoration: BoxDecoration(
          color: _DS.surface.withValues(alpha: 0.9),
          boxShadow: [
            BoxShadow(
              color: _DS.onSurface.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              const SizedBox(width: 12),
              // Back button
              _buildCircleButton(
                icon: Icons.arrow_back,
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(width: 12),
              // Title
              Text(
                _collectionTitle,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _DS.primaryContainer,
                ),
              ),
              const Spacer(),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
          border: Border.all(color: Colors.transparent),
        ),
        child: Icon(icon, color: _DS.primaryContainer, size: 22),
      ),
    );
  }

  // ─── Hero Image Section ───
  Widget _buildHeroImage(double topPadding) {
    return SizedBox(
      height: 400,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_heroImage != null)
            Image(
              image: _heroImage!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildGradientFallback(),
            )
          else
            _buildGradientFallback(),
          // Bottom gradient fade to surface
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 160,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    _DS.surface.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientFallback() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.gradientColors,
        ),
      ),
      child: Center(
        child: Icon(widget.icon, size: 64, color: Colors.white.withValues(alpha: 0.3)),
      ),
    );
  }

  // ─── Main Content Card (lifted over hero) ───
  Widget _buildContentCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _DS.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _DS.onSurface.withValues(alpha: 0.04),
            blurRadius: 32,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category badge
          _buildCategoryBadge(),
          const SizedBox(height: 20),

          // Title
          Text(
            widget.title,
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: _DS.primary,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            widget.description,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w300,
              color: _DS.grey,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 28),

          // Pricing cards
          if (widget.price != null) ...[
            _buildPackageCards(),
            const SizedBox(height: 40),
          ],

          // What's Included + Timeline
          _buildWhatsIncludedAndTimeline(),
        ],
      ),
    );
  }

  // ─── Category Badge ───
  Widget _buildCategoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _DS.primaryContainer,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        _categoryLabel.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: _DS.onPrimary,
          letterSpacing: 1.8,
        ),
      ),
    );
  }

  // ─── Package Pricing Cards ───
  Widget _buildPackageCards() {
    final basePrice = widget.price!;
    final premiumPrice = (basePrice * 1.85).roundToDouble();

    return Column(
      children: [
        // Base Package
        _buildPackageCard(
          index: 0,
          title: 'Base Package',
          subtitle: 'The Essential Refinement',
          price: 'AED ${_formatPrice(basePrice)}',
          isHighlighted: false,
        ),
        const SizedBox(height: 12),

        // Premium Package (elevated, dark)
        _buildPackageCard(
          index: 1,
          title: 'Premium Package',
          subtitle: 'Complete Mastery',
          price: 'AED ${_formatPrice(premiumPrice)}',
          isHighlighted: true,
        ),
        const SizedBox(height: 12),

        // Custom Package
        _buildPackageCard(
          index: 2,
          title: 'Custom Package',
          subtitle: 'Bespoke Design',
          price: 'Get Quote',
          isHighlighted: false,
        ),
      ],
    );
  }

  Widget _buildPackageCard({
    required int index,
    required String title,
    required String subtitle,
    required String price,
    required bool isHighlighted,
  }) {
    final isSelected = _selectedPackageIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedPackageIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isHighlighted
              ? _DS.primaryContainer
              : _DS.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: !isHighlighted && isSelected
              ? Border.all(color: _DS.primaryContainer, width: 2)
              : null,
          boxShadow: isHighlighted
              ? [
                  BoxShadow(
                    color: _DS.primaryContainer.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isHighlighted ? _DS.onPrimary : _DS.primary,
                    ),
                  ),
                ),
                if (isHighlighted)
                  Icon(Icons.star, color: _DS.onPrimary, size: 22),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isHighlighted
                    ? _DS.onPrimaryContainer
                    : _DS.onSurfaceVariant,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              price,
              style: GoogleFonts.inter(
                fontSize: isHighlighted ? 26 : 22,
                fontWeight: FontWeight.w700,
                color: isHighlighted ? _DS.onPrimary : _DS.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── What's Included + Installation Timeline ───
  Widget _buildWhatsIncludedAndTimeline() {
    final features = [
      _Feature(
        'Professional installation by certified experts',
        'Industry-certified team with premium craftsmanship.',
      ),
      _Feature(
        'Premium quality materials and components',
        'Sustainably sourced, highest-grade finishing.',
      ),
      _Feature(
        '2-year comprehensive warranty',
        'Full coverage for peace of mind.',
      ),
      _Feature(
        '24/7 after-sales support',
        'Round-the-clock dedicated assistance.',
      ),
      _Feature(
        'Free maintenance for the first year',
        'Complimentary servicing included.',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with left accent
        Row(
          children: [
            Container(
              width: 4,
              height: 28,
              decoration: BoxDecoration(
                color: _DS.primaryContainer,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "What's Included",
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: _DS.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Feature items
        ...features.map((f) => _buildFeatureRow(f)),

        const SizedBox(height: 24),

        // Installation Timeline Card
        _buildTimelineCard(),
      ],
    );
  }

  Widget _buildFeatureRow(_Feature feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline,
            color: _DS.primaryContainer,
            size: 22,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _DS.onSurface,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  feature.subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: _DS.onSurfaceVariant,
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

  // ─── Installation Timeline Card ───
  Widget _buildTimelineCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _DS.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.schedule, color: _DS.primaryContainer, size: 36),
          const SizedBox(height: 12),
          Text(
            'Installation Timeline',
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _DS.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Most installations are completed within 14\u201321 business days with minimal disruption to your daily routine.',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: _DS.onSurfaceVariant,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: SizedBox(
              height: 6,
              child: Stack(
                children: [
                  Container(color: _DS.surfaceContainerLow),
                  FractionallySizedBox(
                    widthFactor: 0.65,
                    child: Container(color: _DS.primaryContainer),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DESIGN',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: _DS.onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'IN PROGRESS',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: _DS.primaryContainer,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'COMPLETE',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: _DS.onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Gallery Image ───
  Widget _buildGalleryImage() {
    if (_heroImage == null) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: double.infinity,
        height: 200,
        child: Image(
          image: _heroImage!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: widget.gradientColors),
            ),
            child: Center(
              child: Icon(widget.icon, size: 48, color: Colors.white.withValues(alpha: 0.3)),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Bottom Action Bar ───
  Widget _buildBottomBar(double bottomPadding) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 14, 20, 14 + bottomPadding),
        decoration: BoxDecoration(
          color: _DS.surfaceContainerLowest,
          boxShadow: [
            BoxShadow(
              color: _DS.onSurface.withValues(alpha: 0.04),
              blurRadius: 32,
              offset: const Offset(0, -8),
            ),
          ],
          border: Border(
            top: BorderSide(
              color: _DS.outlineVariant.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Price info (visible on wider screens)
            if (widget.price != null && MediaQuery.of(context).size.width > 400) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ESTIMATED STARTING PRICE',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: _DS.onSurfaceVariant,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'AED ${_formatPrice(widget.price!)}',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _DS.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
            ],

            // CTA Button
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitQuote,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _DS.primaryContainer,
                    foregroundColor: _DS.onPrimary,
                    elevation: 0,
                    shadowColor: _DS.primaryContainer.withValues(alpha: 0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100), // pill shape
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          _selectedPackageIndex == 2 ? 'Request a Quote' : 'Configure & Reserve',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      final formatted = price.toStringAsFixed(0);
      final result = StringBuffer();
      int count = 0;
      for (int i = formatted.length - 1; i >= 0; i--) {
        result.write(formatted[i]);
        count++;
        if (count == 3 && i != 0) {
          result.write(',');
          count = 0;
        }
      }
      return result.toString().split('').reversed.join('');
    }
    return price.toStringAsFixed(0);
  }
}

class _Feature {
  final String title;
  final String subtitle;
  const _Feature(this.title, this.subtitle);
}
