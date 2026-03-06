import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';

class ViewTimelinePage extends StatelessWidget {
  const ViewTimelinePage({super.key});

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
          l10n.constructionTimeline,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.darkGrey,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1D3724), Color(0xFF0E552B)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.apartment, color: AppColors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Zen Lagoons Villa',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Unit A-204 • Est. Dec 2024',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xCCFFFFFF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      '45%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Timeline
            _buildMilestone(
              title: l10n.landPreparation,
              subtitle: l10n.landPreparationDesc,
              date: 'Jan 2024',
              status: _MilestoneStatus.completed,
              isFirst: true,
            ),
            _buildMilestone(
              title: l10n.foundationLabel,
              subtitle: l10n.foundationDesc,
              date: 'Mar 2024',
              status: _MilestoneStatus.completed,
            ),
            _buildMilestone(
              title: l10n.structure,
              subtitle: l10n.structureDesc,
              date: 'Jun 2024',
              status: _MilestoneStatus.inProgress,
            ),
            _buildMilestone(
              title: l10n.mepRoughin,
              subtitle: l10n.mepRoughinDesc,
              date: 'Sep 2024',
              status: _MilestoneStatus.upcoming,
            ),
            _buildMilestone(
              title: l10n.interiorFinishing,
              subtitle: l10n.interiorFinishingDesc,
              date: 'Nov 2024',
              status: _MilestoneStatus.upcoming,
            ),
            _buildMilestone(
              title: l10n.handover,
              subtitle: l10n.handoverDesc,
              date: 'Dec 2024',
              status: _MilestoneStatus.upcoming,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestone({
    required String title,
    required String subtitle,
    required String date,
    required _MilestoneStatus status,
    bool isFirst = false,
    bool isLast = false,
  }) {
    Color dotColor;
    Color dotBorderColor;
    IconData? dotIcon;
    Color lineColor;

    switch (status) {
      case _MilestoneStatus.completed:
        dotColor = AppColors.primaryGreen;
        dotBorderColor = AppColors.primaryGreen;
        dotIcon = Icons.check;
        lineColor = AppColors.primaryGreen;
        break;
      case _MilestoneStatus.inProgress:
        dotColor = AppColors.gold;
        dotBorderColor = AppColors.gold;
        dotIcon = Icons.access_time;
        lineColor = AppColors.lightGrey;
        break;
      case _MilestoneStatus.upcoming:
        dotColor = const Color(0xFFF5F5F5);
        dotBorderColor = AppColors.lightGrey;
        dotIcon = null;
        lineColor = AppColors.lightGrey;
        break;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline column
          SizedBox(
            width: 40,
            child: Column(
              children: [
                // Top line
                if (!isFirst)
                  Container(width: 2, height: 8, color: lineColor)
                else
                  const SizedBox(height: 8),
                // Dot
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: dotBorderColor, width: 2),
                    boxShadow: status == _MilestoneStatus.inProgress
                        ? [
                            BoxShadow(
                              color: AppColors.gold.withValues(alpha: 0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: dotIcon != null
                      ? Icon(dotIcon, size: 16, color: AppColors.white)
                      : null,
                ),
                // Bottom line
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: lineColor),
                  )
                else
                  const Expanded(child: SizedBox()),
              ],
            ),
          ),
          const SizedBox(width: 14),
          // Content card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: status == _MilestoneStatus.inProgress
                      ? Border.all(color: AppColors.gold.withValues(alpha: 0.3), width: 1.5)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: status == _MilestoneStatus.upcoming
                                  ? AppColors.darkGrey.withValues(alpha: 0.4)
                                  : AppColors.darkGrey,
                            ),
                          ),
                        ),
                        if (status == _MilestoneStatus.inProgress)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'In Progress',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.gold,
                              ),
                            ),
                          ),
                        if (status == _MilestoneStatus.completed)
                          const Icon(Icons.check_circle, size: 18, color: AppColors.primaryGreen),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.darkGrey.withValues(alpha: 0.5),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 13,
                          color: AppColors.darkGrey.withValues(alpha: 0.35),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          date,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.darkGrey.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _MilestoneStatus { completed, inProgress, upcoming }
