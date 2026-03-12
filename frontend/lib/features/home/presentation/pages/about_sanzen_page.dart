import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutSanzenPage extends StatelessWidget {
  const AboutSanzenPage({super.key});

  // Social media URLs
  static const String _websiteUrl = 'https://sanzen.ae/';
  static const String _instagramUrl = 'https://www.instagram.com/sanzendevelopments/';
  static const String _linkedinUrl = 'https://www.linkedin.com/company/sanzen-developments';

  Future<void> _launchSocialUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open link')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening link: $e')),
        );
      }
    }
  }

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
          l10n.aboutSanzen,
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
          children: [
            // Logo / Brand card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 36),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1D3724), Color(0xFF0E552B)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Center(
                      child: Text(
                        'S',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'SANZEN',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Properties',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.white.withValues(alpha: 0.7),
                      letterSpacing: 3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // About section
            _buildCard(
              title: l10n.ourStory,
              content: l10n.ourStoryText,
            ),
            const SizedBox(height: 12),

            // Mission & Vision
            _buildCard(
              title: l10n.ourMission,
              content: l10n.ourMissionText,
            ),
            const SizedBox(height: 12),
            _buildCard(
              title: l10n.ourVision,
              content: l10n.ourVisionText,
            ),
            const SizedBox(height: 12),

            // Key numbers
            _buildCard(
              title: l10n.byTheNumbers,
              child: Row(
                children: [
                  _buildStatItem('15+', l10n.years),
                  _buildStatDivider(),
                  _buildStatItem('2,500+', l10n.units),
                  _buildStatDivider(),
                  _buildStatItem('12', l10n.projects),
                  _buildStatDivider(),
                  _buildStatItem('4.8★', l10n.rating),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Social links with real URLs
            _buildCard(
              title: l10n.followUs,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialIcon(
                    context,
                    Icons.language,
                    l10n.website,
                    _websiteUrl,
                  ),
                  const SizedBox(width: 20),
                  _buildSocialIcon(
                    context,
                    Icons.camera_alt_outlined,
                    'Instagram',
                    _instagramUrl,
                  ),
                  const SizedBox(width: 20),
                  _buildSocialIcon(
                    context,
                    Icons.people_outlined,
                    'LinkedIn',
                    _linkedinUrl,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // App version
            Text(
              l10n.appVersion,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.darkGrey.withValues(alpha: 0.35),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.copyright,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.darkGrey.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required String title, String? content, Widget? child}) {
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
          const SizedBox(height: 12),
          if (content != null)
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.darkGrey.withValues(alpha: 0.65),
                height: 1.6,
              ),
            ),
          if (child != null) child,
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.darkGrey.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 32,
      color: AppColors.darkGrey.withValues(alpha: 0.06),
    );
  }

  Widget _buildSocialIcon(BuildContext context, IconData icon, String label, String url) {
    return GestureDetector(
      onTap: () => _launchSocialUrl(context, url),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F5F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: AppColors.primaryGreen),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.darkGrey.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}
