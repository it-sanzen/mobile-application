import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/pages/sign_in_page.dart';
import 'edit_profile_page.dart';
import 'change_password_page.dart';
import 'notification_preferences_page.dart';
import 'language_page.dart';
import 'help_support_page.dart';
import 'privacy_policy_page.dart';
import 'about_sanzen_page.dart';
import 'payments_page.dart';
import '../../../../features/design_studio/presentation/pages/my_saved_designs_page.dart';

import '../../../../core/services/token_service.dart';
import '../../../../core/localization/app_localizations.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _userName = 'Loading...';
  String _userEmail = 'Loading...';
  String _userInitials = '';
  String _userPhone = 'Not provided';
  String _userAddress = 'Not provided';
  String _userUnit = 'Not provided';
  String _userJoinedDate = 'Unknown';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await TokenService.getUserData();
    print('DEBUG: TokenService returned: $userData');
    if (mounted) {
      setState(() {
        _userName = userData['name'] ?? 'Unknown User';
        _userEmail = userData['email'] ?? 'No email provided';
        _userPhone = (userData['phone']?.isNotEmpty == true) ? userData['phone']! : 'Not provided';
        _userAddress = (userData['address']?.isNotEmpty == true) ? userData['address']! : 'Not provided';
        _userUnit = (userData['unit']?.isNotEmpty == true) ? userData['unit']! : 'Not provided';
        
        // Parse and format joining date (e.g. from 2024-03-01T... to "March 2024")
        if (userData['createdAt'] != null && userData['createdAt']!.isNotEmpty) {
           try {
              final DateTime date = DateTime.parse(userData['createdAt']!);
              const List<String> months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
              _userJoinedDate = '${months[date.month - 1]} ${date.year}';
           } catch (e) {
              _userJoinedDate = 'Recently joined';
           }
        }
        
        if (_userName.isNotEmpty && _userName != 'Unknown User') {
          final parts = _userName.split(' ');
          if (parts.length > 1) {
            _userInitials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
          } else {
            _userInitials = _userName.substring(0, _userName.length > 1 ? 2 : 1).toUpperCase();
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF7F7F5),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildTopTitle(),
                const SizedBox(height: 32),
                _buildProfileAvatar(),
                const SizedBox(height: 16),
                _buildProfileName(),
                const SizedBox(height: 4),
                _buildProfileEmail(),
                const SizedBox(height: 12),
                _buildPremiumBadge(),
                const SizedBox(height: 32),
                _buildPersonalInfoCard(),
                const SizedBox(height: 16),
                _buildSettingsCard(context),
                const SizedBox(height: 16),
                _buildSupportCard(context),
                const SizedBox(height: 24),
                _buildSignOutButton(context),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopTitle() {
    return Text(
      AppLocalizations.of(context).profile,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.darkGrey,
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFE8F0EA),
        border: Border.all(
          color: const Color(0xFFD5E0D8),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          _userInitials,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDark,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileName() {
    return Text(
      _userName,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.darkGrey,
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildProfileEmail() {
    return Text(
      _userEmail,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.darkGrey.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildPremiumBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.verified_rounded,
            size: 15,
            color: AppColors.gold,
          ),
          const SizedBox(width: 5),
          Text(
            'Premium Owner',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.gold.withValues(alpha: 0.9),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    return _CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: AppLocalizations.of(context).personalDetails),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.phone_outlined, 'Phone', _userPhone),
          _buildInfoDivider(),
          _buildInfoRow(
              Icons.location_on_outlined, 'Address', _userAddress),
          _buildInfoDivider(),
          _buildInfoRow(
              Icons.apartment_outlined, 'Unit', _userUnit),
          _buildInfoDivider(),
          _buildInfoRow(
              Icons.calendar_today_outlined, 'Member Since', _userJoinedDate),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F5F1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primaryGreen, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkGrey.withValues(alpha: 0.4),
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoDivider() {
    return Divider(
      color: AppColors.darkGrey.withValues(alpha: 0.06),
      height: 1,
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: l10n.accountSettings),
          const SizedBox(height: 8),
          _buildMenuItem(
            context,
            Icons.person_outline_rounded,
            l10n.editProfile,
            const Color(0xFFF0F5F1),
            AppColors.primaryGreen,
            onTap: () async {
              final bool? shouldRefresh = await Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => const EditProfilePage())
              );
              if (shouldRefresh == true) {
                _loadUserData();
              }
            },
          ),
          _buildMenuDivider(),
          _buildMenuItem(
            context,
            Icons.design_services_outlined,
            'My Saved Designs',
            const Color(0xFFF1F0FE),
            const Color(0xFF6C63FF),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MySavedDesignsPage())),
          ),
          _buildMenuDivider(),
          _buildMenuItem(
            context,
            Icons.lock_outline_rounded,
            'Change Password',
            const Color(0xFFFAF6EE),
            AppColors.gold,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordPage())),
          ),
          _buildMenuDivider(),
          _buildMenuItem(
            context,
            Icons.payment_rounded,
            'Payments',
            const Color(0xFFE8F5E9),
            AppColors.primaryGreen,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentsPage())),
          ),
          _buildMenuDivider(),
          _buildMenuItem(
            context,
            Icons.notifications_none_rounded,
            l10n.notifications,
            const Color(0xFFEEF3FA),
            AppColors.info,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationPreferencesPage())),
          ),
          _buildMenuDivider(),
          _buildMenuItem(
            context,
            Icons.language_rounded,
            l10n.language,
            const Color(0xFFF5EEF8),
            const Color(0xFF9C27B0),
            trailing: Text(
              l10n.locale.languageCode == 'ar' ? 'العربية' : 'English',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.darkGrey.withValues(alpha: 0.4),
              ),
            ),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LanguagePage())),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: l10n.supportHelp),
          const SizedBox(height: 8),
          _buildMenuItem(
            context,
            Icons.help_outline_rounded,
            l10n.supportHelp,
            const Color(0xFFF0F5F1),
            AppColors.primaryGreen,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportPage())),
          ),
          _buildMenuDivider(),
          _buildMenuItem(
            context,
            Icons.privacy_tip_outlined,
            l10n.privacyPolicy,
            const Color(0xFFFFF5EE),
            const Color(0xFFFF9800),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyPage())),
          ),
          _buildMenuDivider(),
          _buildMenuItem(
            context,
            Icons.info_outline_rounded,
            l10n.aboutSanzen,
            const Color(0xFFEEF3FA),
            AppColors.info,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutSanzenPage())),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    Color iconBgColor,
    Color iconColor, {
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
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
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkGrey,
                ),
              ),
            ),
            if (trailing != null) ...[
              trailing,
              const SizedBox(width: 4),
            ],
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.darkGrey.withValues(alpha: 0.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuDivider() {
    return Divider(
      color: AppColors.darkGrey.withValues(alpha: 0.06),
      height: 1,
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: TextButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                l10n.logout,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGrey,
                ),
              ),
              content: Text(
                'Are you sure you want to sign out?',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.darkGrey.withValues(alpha: 0.6),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.darkGrey.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const SignInPage(),
                      ),
                      (route) => false,
                    );
                  },
                  child: Text(
                    l10n.logout,
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        icon: Icon(
          Icons.logout_rounded,
          size: 18,
          color: AppColors.error.withValues(alpha: 0.7),
        ),
        label: Text(
          l10n.logout,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.error.withValues(alpha: 0.7),
          ),
        ),
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: AppColors.error.withValues(alpha: 0.15),
            ),
          ),
        ),
      ),
    );
  }
}

// Reusable minimal card container
class _CardContainer extends StatelessWidget {
  final Widget child;
  const _CardContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.darkGrey.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

// Reusable section title
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.darkGrey.withValues(alpha: 0.4),
        letterSpacing: 0.5,
      ),
    );
  }
}

