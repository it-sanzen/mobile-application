import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/models/change_request.dart';
import '../../../change_requests/data/services/change_request_service.dart';
import '../../../change_requests/presentation/pages/change_requests_page.dart';
import '../../../change_requests/presentation/pages/submit_change_request_page.dart';
import '../../../change_requests/presentation/pages/edit_change_request_page.dart';
import '../../../referrals/presentation/pages/referral_dashboard_page.dart';
import 'payments_page.dart';

class PropertyDetailsPage extends StatefulWidget {
  final String? propertyId;
  final String propertyName;
  final String location;
  final String unitCode;
  final String type;
  final String bedrooms;
  final String area;
  final String status;
  final Color statusColor;
  final double? progress;
  final String imageAsset;
  final String? currentPhase;
  final String? estimatedCompletion;
  final String? floor;
  final String? parking;
  final String? balcony;
  final String? furnishedStatus;
  final List<String> amenities;
  final double? downPayment;
  final double? constructionPayment;
  final double? handoverPayment;

  const PropertyDetailsPage({
    super.key,
    this.propertyId,
    required this.propertyName,
    required this.location,
    required this.unitCode,
    required this.type,
    required this.bedrooms,
    required this.area,
    required this.status,
    required this.statusColor,
    this.progress,
    required this.imageAsset,
    this.currentPhase,
    this.estimatedCompletion,
    this.floor,
    this.parking,
    this.balcony,
    this.furnishedStatus,
    this.amenities = const [],
    this.downPayment,
    this.constructionPayment,
    this.handoverPayment,
  });

  @override
  State<PropertyDetailsPage> createState() => _PropertyDetailsPageState();
}

class _PropertyDetailsPageState extends State<PropertyDetailsPage> {
  List<ChangeRequestModel> _recentRequests = [];
  bool _isLoadingRequests = false;

  @override
  void initState() {
    super.initState();
    _fetchRecentRequests();
  }

  Future<void> _fetchRecentRequests() async {
    setState(() => _isLoadingRequests = true);
    try {
      final requests = await ChangeRequestService.getMyRequests();
      setState(() {
        _recentRequests = requests.where((r) => r.status != ChangeRequestStatus.completed).take(3).toList();
        _isLoadingRequests = false;
      });
    } catch (e) {
      setState(() => _isLoadingRequests = false);
    }
  }

  Color _statusColor(ChangeRequestStatus status) {
    switch (status) {
      case ChangeRequestStatus.submitted:
        return AppColors.info;
      case ChangeRequestStatus.underReview:
        return AppColors.warning;
      case ChangeRequestStatus.approved:
        return AppColors.success;
      case ChangeRequestStatus.rejected:
        return AppColors.error;
      case ChangeRequestStatus.completed:
        return AppColors.primaryGreen;
    }
  }

  IconData _categoryIcon(ChangeRequestCategory category) {
    switch (category) {
      case ChangeRequestCategory.structural:
        return Icons.foundation;
      case ChangeRequestCategory.interior:
        return Icons.chair;
      case ChangeRequestCategory.electrical:
        return Icons.electrical_services;
      case ChangeRequestCategory.plumbing:
        return Icons.plumbing;
      case ChangeRequestCategory.layout:
        return Icons.dashboard;
      case ChangeRequestCategory.material:
        return Icons.texture;
      case ChangeRequestCategory.other:
        return Icons.more_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          // Hero image
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppColors.primaryDark,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: AppColors.white, size: 18),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(widget.imageAsset, fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.65),
                        ],
                        stops: const [0.3, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: widget.statusColor.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            widget.status,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.white),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.propertyName,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.white),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 15, color: AppColors.white.withValues(alpha: 0.85)),
                            const SizedBox(width: 4),
                            Text(
                              widget.location,
                              style: TextStyle(fontSize: 14, color: AppColors.white.withValues(alpha: 0.85)),
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

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Specs row
                  Row(
                    children: [
                      _buildSpecCard(Icons.home_outlined, l10n.typeLabel, widget.type),
                      const SizedBox(width: 10),
                      _buildSpecCard(Icons.bed_outlined, l10n.bedroomsLabel, widget.bedrooms),
                      const SizedBox(width: 10),
                      _buildSpecCard(Icons.square_foot, l10n.areaLabel, widget.area),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Unit details card
                  _buildSectionCard(
                    title: l10n.unitDetails,
                    child: Column(
                      children: [
                        _buildDetailRow(l10n.unitCode, widget.unitCode),
                        _buildCardDivider(),
                        _buildDetailRow(l10n.floor, widget.floor ?? '-'),
                        _buildCardDivider(),
                        _buildDetailRow(l10n.parking, widget.parking ?? '-'),
                        _buildCardDivider(),
                        _buildDetailRow(l10n.balcony, widget.balcony ?? '-'),
                        _buildCardDivider(),
                        _buildDetailRow(l10n.furnished, widget.furnishedStatus ?? '-'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Progress section
                  if (widget.progress != null) ...[
                    _buildSectionCard(
                      title: 'Construction Progress',
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Overall Completion',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.darkGrey.withValues(alpha: 0.7)),
                              ),
                              Text(
                                '${(widget.progress! * 100).toInt()}%',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primaryGreen),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: widget.progress!,
                              minHeight: 8,
                              backgroundColor: AppColors.lightGrey.withValues(alpha: 0.5),
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow(l10n.currentPhase, widget.currentPhase ?? l10n.structure),
                          _buildCardDivider(),
                          _buildDetailRow(l10n.estCompletionDate, widget.estimatedCompletion ?? 'TBD'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Payment plan card
                  _buildSectionCard(
                    title: l10n.paymentPlan,
                    child: Column(
                      children: [
                        _buildPaymentRow(l10n.downPayment, '${(widget.downPayment ?? 20).toInt()}%', true),
                        _buildCardDivider(),
                        _buildPaymentRow(l10n.duringConstruction, '${(widget.constructionPayment ?? 50).toInt()}%', widget.progress != null && widget.progress! < 1.0),
                        _buildCardDivider(),
                        _buildPaymentRow(l10n.onHandover, '${(widget.handoverPayment ?? 30).toInt()}%', false),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Amenities card
                  if (widget.amenities.isNotEmpty)
                    _buildSectionCard(
                      title: l10n.amenities,
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: widget.amenities.map((a) => _buildAmenityChip(_amenityIcon(a), a)).toList(),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Quick Actions grid
                  _buildSectionCard(
                    title: 'QUICK ACTIONS',
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _buildQuickActionTile(
                              icon: Icons.payment_rounded,
                              label: 'Payments',
                              color: AppColors.primaryGreen,
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentsPage())),
                            ),
                            const SizedBox(width: 12),
                            _buildQuickActionTile(
                              icon: Icons.card_giftcard_rounded,
                              label: 'Refer &\nEarn',
                              color: AppColors.gold,
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReferralDashboardPage())),
                            ),
                            const SizedBox(width: 12),
                            _buildQuickActionTile(
                              icon: Icons.edit_note_rounded,
                              label: 'Change\nRequests',
                              color: AppColors.info,
                              onTap: () async {
                                await Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangeRequestsPage()));
                                _fetchRecentRequests();
                              },
                            ),
                          ],
                        ),
                        // Recent change requests
                        if (_recentRequests.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Text('Recent Requests', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.darkGrey.withValues(alpha: 0.5))),
                              const Spacer(),
                              GestureDetector(
                                onTap: () async {
                                  final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const SubmitChangeRequestPage()));
                                  if (result == true) _fetchRecentRequests();
                                },
                                child: Row(
                                  children: [
                                    Icon(Icons.add, size: 14, color: AppColors.primaryGreen),
                                    const SizedBox(width: 2),
                                    Text('New', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryGreen)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ..._recentRequests.map((req) => _buildMiniRequestCard(req)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Contact button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.managerWillContact),
                            backgroundColor: AppColors.primaryGreen,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                      icon: const Icon(Icons.headset_mic_outlined, size: 20),
                      label: Text(l10n.contactPropertyManager, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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

  Widget _buildMiniRequestCard(ChangeRequestModel request) {
    final statusColor = _statusColor(request.status);
    final categoryIcon = _categoryIcon(request.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(categoryIcon, size: 18, color: AppColors.primaryGreen),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(request.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.darkGrey), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(request.category.label, style: TextStyle(fontSize: 11, color: AppColors.grey)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(request.status.label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor)),
          ),
          if (request.status == ChangeRequestStatus.submitted) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () async {
                final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => EditChangeRequestPage(request: request)));
                if (result == true) _fetchRecentRequests();
              },
              child: Icon(Icons.edit_outlined, size: 16, color: AppColors.primaryGreen),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActionTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.darkGrey, height: 1.3)),
            ],
          ),
        ),
      ),
    );
  }

  IconData _amenityIcon(String amenity) {
    switch (amenity.toLowerCase()) {
      case 'pool': return Icons.pool;
      case 'gym': return Icons.fitness_center;
      case 'parking': return Icons.local_parking;
      case 'security': return Icons.security;
      case 'garden': return Icons.park;
      case 'kids area': return Icons.child_care;
      case 'spa': return Icons.spa;
      case 'bbq area': return Icons.restaurant;
      default: return Icons.star;
    }
  }

  Widget _buildSpecCard(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: AppColors.primaryGreen),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.darkGrey)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, color: AppColors.darkGrey.withValues(alpha: 0.5))),
          ],
        ),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: AppColors.darkGrey.withValues(alpha: 0.6))),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.darkGrey)),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String percentage, bool isPaid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(isPaid ? Icons.check_circle : Icons.radio_button_unchecked, size: 18, color: isPaid ? AppColors.primaryGreen : AppColors.lightGrey),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(fontSize: 13, color: AppColors.darkGrey.withValues(alpha: isPaid ? 0.8 : 0.5)))),
          Text(percentage, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isPaid ? AppColors.primaryGreen : AppColors.darkGrey.withValues(alpha: 0.4))),
        ],
      ),
    );
  }

  Widget _buildCardDivider() {
    return Divider(color: AppColors.darkGrey.withValues(alpha: 0.06), height: 1);
  }

  Widget _buildAmenityChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFFF0F5F1), borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primaryGreen),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.darkGrey)),
        ],
      ),
    );
  }
}
