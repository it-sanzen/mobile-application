import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';

class NotificationPreferencesPage extends StatefulWidget {
  const NotificationPreferencesPage({super.key});

  @override
  State<NotificationPreferencesPage> createState() => _NotificationPreferencesPageState();
}

class _NotificationPreferencesPageState extends State<NotificationPreferencesPage> {
  bool _unitUpdates = true;
  bool _companyNews = true;
  bool _paymentReminders = true;
  bool _constructionMilestones = true;
  bool _promotions = false;
  bool _emailNotifications = true;
  bool _pushNotifications = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.darkGrey, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.notificationPreferences,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.darkGrey,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification types section
            _buildSectionCard(
              title: l10n.notificationTypes,
              child: Column(
                children: [
                  _buildToggleRow(
                    icon: Icons.apartment,
                    iconColor: AppColors.primaryGreen,
                    iconBgColor: const Color(0xFFE8F5E9),
                    title: l10n.unitUpdates,
                    subtitle: l10n.constructionProgressInfo,
                    value: _unitUpdates,
                    onChanged: (v) => setState(() => _unitUpdates = v),
                  ),
                  _buildDivider(),
                  _buildToggleRow(
                    icon: Icons.campaign_outlined,
                    iconColor: AppColors.info,
                    iconBgColor: const Color(0xFFE3F2FD),
                    title: l10n.companyNews,
                    subtitle: l10n.latestAnnouncements,
                    value: _companyNews,
                    onChanged: (v) => setState(() => _companyNews = v),
                  ),
                  _buildDivider(),
                  _buildToggleRow(
                    icon: Icons.payment_outlined,
                    iconColor: AppColors.gold,
                    iconBgColor: const Color(0xFFFFF8E1),
                    title: l10n.paymentReminders,
                    subtitle: l10n.upcomingOverdue,
                    value: _paymentReminders,
                    onChanged: (v) => setState(() => _paymentReminders = v),
                  ),
                  _buildDivider(),
                  _buildToggleRow(
                    icon: Icons.flag_outlined,
                    iconColor: const Color(0xFF9C27B0),
                    iconBgColor: const Color(0xFFF3E5F5),
                    title: l10n.constructionMilestones,
                    subtitle: l10n.phaseCompletion,
                    value: _constructionMilestones,
                    onChanged: (v) => setState(() => _constructionMilestones = v),
                  ),
                  _buildDivider(),
                  _buildToggleRow(
                    icon: Icons.local_offer_outlined,
                    iconColor: const Color(0xFFE65100),
                    iconBgColor: const Color(0xFFFFF3E0),
                    title: l10n.promotionsOffers,
                    subtitle: l10n.exclusiveSeasonal,
                    value: _promotions,
                    onChanged: (v) => setState(() => _promotions = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Delivery channels section
            _buildSectionCard(
              title: l10n.deliveryChannels,
              child: Column(
                children: [
                  _buildToggleRow(
                    icon: Icons.email_outlined,
                    iconColor: AppColors.primaryGreen,
                    iconBgColor: const Color(0xFFE8F5E9),
                    title: l10n.emailNotifications,
                    subtitle: l10n.receiveViaEmail,
                    value: _emailNotifications,
                    onChanged: (v) => setState(() => _emailNotifications = v),
                  ),
                  _buildDivider(),
                  _buildToggleRow(
                    icon: Icons.phone_iphone,
                    iconColor: AppColors.info,
                    iconBgColor: const Color(0xFFE3F2FD),
                    title: l10n.pushNotifications,
                    subtitle: l10n.receivePushAlerts,
                    value: _pushNotifications,
                    onChanged: (v) => setState(() => _pushNotifications = v),
                  ),
                ],
              ),
            ),
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
        border: Border.all(color: AppColors.darkGrey.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.darkGrey.withValues(alpha: 0.4),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkGrey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.darkGrey.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryGreen,
            inactiveTrackColor: AppColors.lightGrey,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: AppColors.darkGrey.withValues(alpha: 0.06), height: 1);
  }
}
