import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/models/timeline_milestone.dart';
import '../../../../core/services/timeline_service.dart';

class ViewTimelinePage extends StatefulWidget {
  final String propertyId;
  final String? propertyName;

  const ViewTimelinePage({
    super.key,
    required this.propertyId,
    this.propertyName,
  });

  @override
  State<ViewTimelinePage> createState() => _ViewTimelinePageState();
}

class _ViewTimelinePageState extends State<ViewTimelinePage> {
  List<TimelineMilestone> _milestones = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchTimeline();
  }

  Future<void> _fetchTimeline() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final milestones = await TimelineService.getPropertyTimeline(widget.propertyId);
      setState(() {
        _milestones = milestones;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      print('Error fetching timeline: $e');
    }
  }

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
          l10n.constructionTimeline,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.darkGrey,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchTimeline,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _milestones.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.timeline, size: 48, color: AppColors.lightGrey),
                          const SizedBox(height: 16),
                          Text(
                            'No timeline data available',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.darkGrey.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Property header
                          if (widget.propertyName != null)
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
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.propertyName!,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${_milestones.length} milestones',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xCCFFFFFF),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _buildProgressBadge(),
                                ],
                              ),
                            ),
                          if (widget.propertyName != null) const SizedBox(height: 28),

                          // Timeline
                          ..._milestones.asMap().entries.map((entry) {
                            final index = entry.key;
                            final milestone = entry.value;
                            return _buildMilestone(
                              milestone: milestone,
                              isFirst: index == 0,
                              isLast: index == _milestones.length - 1,
                            );
                          }).toList(),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildProgressBadge() {
    final completedCount = _milestones.where((m) => m.status == MilestoneStatus.completed).length;
    final percentage = _milestones.isEmpty ? 0 : ((completedCount / _milestones.length) * 100).round();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$percentage%',
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.gold,
        ),
      ),
    );
  }

  Widget _buildMilestone({
    required TimelineMilestone milestone,
    bool isFirst = false,
    bool isLast = false,
  }) {
    Color dotColor;
    Color dotBorderColor;
    IconData? dotIcon;
    Color lineColor;
    String statusLabel = '';

    switch (milestone.status) {
      case MilestoneStatus.completed:
        dotColor = AppColors.primaryGreen;
        dotBorderColor = AppColors.primaryGreen;
        dotIcon = Icons.check;
        lineColor = AppColors.primaryGreen;
        break;
      case MilestoneStatus.inProgress:
        dotColor = AppColors.gold;
        dotBorderColor = AppColors.gold;
        dotIcon = Icons.access_time;
        lineColor = AppColors.lightGrey;
        statusLabel = 'In Progress';
        break;
      case MilestoneStatus.delayed:
        dotColor = Colors.red;
        dotBorderColor = Colors.red;
        dotIcon = Icons.warning;
        lineColor = AppColors.lightGrey;
        statusLabel = 'Delayed';
        break;
      case MilestoneStatus.pending:
        dotColor = const Color(0xFFF5F5F5);
        dotBorderColor = AppColors.lightGrey;
        dotIcon = null;
        lineColor = AppColors.lightGrey;
        break;
    }

    final isUpcoming = milestone.status == MilestoneStatus.pending;
    final dateText = milestone.completedDate != null
        ? '${milestone.completedDate!.day}/${milestone.completedDate!.month}/${milestone.completedDate!.year}'
        : milestone.estimatedDate ?? 'TBD';

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
                    boxShadow: milestone.status == MilestoneStatus.inProgress
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
                  border: milestone.status == MilestoneStatus.inProgress
                      ? Border.all(color: AppColors.gold.withValues(alpha: 0.3), width: 1.5)
                      : milestone.status == MilestoneStatus.delayed
                          ? Border.all(color: Colors.red.withValues(alpha: 0.3), width: 1.5)
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                milestone.phase,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkGrey.withValues(alpha: 0.4),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                milestone.title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isUpcoming
                                      ? AppColors.darkGrey.withValues(alpha: 0.4)
                                      : AppColors.darkGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (statusLabel.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: milestone.status == MilestoneStatus.inProgress
                                  ? AppColors.gold.withValues(alpha: 0.12)
                                  : Colors.red.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: milestone.status == MilestoneStatus.inProgress
                                    ? AppColors.gold
                                    : Colors.red,
                              ),
                            ),
                          ),
                        if (milestone.status == MilestoneStatus.completed)
                          const Icon(Icons.check_circle, size: 18, color: AppColors.primaryGreen),
                      ],
                    ),
                    if (milestone.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        milestone.description!,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.darkGrey.withValues(alpha: 0.5),
                          height: 1.4,
                        ),
                      ),
                    ],
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
                          dateText,
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
