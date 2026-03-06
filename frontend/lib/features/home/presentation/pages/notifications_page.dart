import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // Dummy notification data
  final List<_NotificationItem> _todayNotifications = [
    _NotificationItem(
      icon: Icons.electrical_services,
      iconBgColor: const Color(0xFFE8F5E9),
      iconColor: AppColors.primaryGreen,
      title: 'Electrical Wiring Complete',
      description: 'Phase 2 electrical wiring has been successfully inspected and approved for Unit A-204.',
      time: '2h ago',
      isRead: false,
    ),
    _NotificationItem(
      icon: Icons.payments_outlined,
      iconBgColor: const Color(0xFFFFF8E1),
      iconColor: const Color(0xFFC2A563),
      title: 'Payment Received',
      description: 'Your installment payment of AED 125,000 has been received. Thank you!',
      time: '5h ago',
      isRead: false,
    ),
  ];

  final List<_NotificationItem> _earlierNotifications = [
    _NotificationItem(
      icon: Icons.cloud_download_outlined,
      iconBgColor: const Color(0xFFE8F5E9),
      iconColor: AppColors.primaryGreen,
      title: 'Sukoon Project Launched',
      description: 'Discover our newest serene living spaces at the Sukoon launch event this weekend.',
      time: '1d ago',
      isRead: true,
    ),
    _NotificationItem(
      icon: Icons.description_outlined,
      iconBgColor: const Color(0xFFE3F2FD),
      iconColor: const Color(0xFF448AFF),
      title: 'Document Ready',
      description: 'Your updated Sales & Purchase Agreement is ready for review.',
      time: '2d ago',
      isRead: true,
    ),
    _NotificationItem(
      icon: Icons.construction_outlined,
      iconBgColor: const Color(0xFFFFF3E0),
      iconColor: const Color(0xFFFF9800),
      title: 'Construction Milestone',
      description: 'Foundation work for Block A has been completed ahead of schedule.',
      time: '3d ago',
      isRead: true,
    ),
    _NotificationItem(
      icon: Icons.campaign_outlined,
      iconBgColor: const Color(0xFFE8F5E9),
      iconColor: AppColors.primaryGreen,
      title: 'Exclusive Offer',
      description: 'Limited time offer on private pool add-on. Save 15% when you upgrade before month end.',
      time: '5d ago',
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context).notifications,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                for (var n in _todayNotifications) {
                  n.isRead = true;
                }
              });
            },
            child: Text(
              AppLocalizations.of(context).markAllRead,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Today section
          if (_todayNotifications.isNotEmpty) ...[
            _buildSectionHeader(AppLocalizations.of(context).todayLabel),
            const SizedBox(height: 10),
            ..._todayNotifications.map((n) => _buildNotificationCard(n)),
          ],
          // Earlier section
          if (_earlierNotifications.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildSectionHeader(AppLocalizations.of(context).earlierLabel),
            const SizedBox(height: 10),
            ..._earlierNotifications.map((n) => _buildNotificationCard(n)),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.darkGrey.withValues(alpha: 0.6),
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildNotificationCard(_NotificationItem notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notification.isRead
            ? AppColors.white
            : AppColors.primaryGreen.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: notification.isRead
            ? null
            : Border.all(
                color: AppColors.primaryGreen.withValues(alpha: 0.15),
                width: 1,
              ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: notification.iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              notification.icon,
              color: notification.iconColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: notification.isRead
                              ? FontWeight.w500
                              : FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!notification.isRead)
                          Container(
                            width: 7,
                            height: 7,
                            margin: const EdgeInsets.only(right: 6, top: 4),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                        Text(
                          notification.time,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.darkGrey.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.description,
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
}

class _NotificationItem {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String description;
  final String time;
  bool isRead;

  _NotificationItem({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.time,
    required this.isRead,
  });
}
