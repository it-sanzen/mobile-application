import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/services/addon_quote_service.dart';
import '../../../../core/services/api_service.dart';
import '../../../properties/data/services/properties_service.dart';
import '../../data/models/property_model.dart';

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
        const SnackBar(content: Text('No property found'), backgroundColor: AppColors.error),
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
            backgroundColor: AppColors.success,
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
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: widget.gradientColors.first,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: AppColors.white, size: 18),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Show image if available, else gradient fallback
                  if (widget.imageUrl != null)
                    Image(
                      image: widget.imageUrl!.startsWith('http') || widget.imageUrl!.startsWith('/uploads')
                          ? NetworkImage(
                              widget.imageUrl!.startsWith('http')
                                  ? widget.imageUrl!
                                  : '${ApiService.baseUrl.replaceAll('/api/v1', '')}${widget.imageUrl!}',
                            )
                          : AssetImage(widget.imageUrl!) as ImageProvider,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: widget.gradientColors),
                        ),
                        child: Center(child: Icon(widget.icon, size: 48, color: Colors.white.withValues(alpha: 0.6))),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: widget.gradientColors),
                      ),
                      child: Center(child: Icon(widget.icon, size: 48, color: Colors.white.withValues(alpha: 0.6))),
                    ),
                  // Dark overlay for text readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
                        stops: const [0.3, 1.0],
                      ),
                    ),
                  ),
                  // Title at bottom
                  Positioned(
                    bottom: 16,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.price != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text('AED ${widget.price!.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.white)),
                          ),
                        const SizedBox(height: 8),
                        Text(widget.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionCard(
                    title: l10n.aboutAddon,
                    child: Text(
                      widget.description,
                      style: TextStyle(fontSize: 14, height: 1.6, color: AppColors.darkGrey.withValues(alpha: 0.7)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (widget.price != null) ...[
                    _buildSectionCard(
                      title: l10n.pricing,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Price', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.darkGrey)),
                          Text('AED ${widget.price!.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primaryGreen)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  _buildSectionCard(
                    title: l10n.whatsIncluded,
                    child: Column(
                      children: [
                        _buildFeatureItem(l10n.feature1),
                        _buildFeatureItem(l10n.feature2),
                        _buildFeatureItem(l10n.feature3),
                        _buildFeatureItem(l10n.feature4),
                        _buildFeatureItem(l10n.feature5),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Request Quote button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitQuote,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2))
                          : const Text('Request a Quote', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
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

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.darkGrey.withValues(alpha: 0.4), letterSpacing: 0.5)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22, height: 22,
            decoration: BoxDecoration(color: AppColors.primaryGreen.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
            child: const Icon(Icons.check, size: 14, color: AppColors.primaryGreen),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: AppColors.darkGrey.withValues(alpha: 0.7), height: 1.4))),
        ],
      ),
    );
  }
}
