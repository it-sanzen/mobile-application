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
  int? _expandedMilestoneIndex;

  @override
  void initState() {
    super.initState();
    _fetchTimeline();
  }

  List<TimelineMilestone> _getDefaultMilestones() {
    return [
      TimelineMilestone(id: '1', phase: 'Phase 1', title: 'Land Preparation', description: 'Site clearing, grading & soil testing', status: MilestoneStatus.completed, estimatedDate: 'Q1 2026', orderIndex: 0),
      TimelineMilestone(id: '2', phase: 'Phase 2', title: 'Foundation', description: 'Piling, raft foundation & waterproofing', status: MilestoneStatus.completed, estimatedDate: 'Q2 2026', orderIndex: 1),
      TimelineMilestone(id: '3', phase: 'Phase 3', title: 'Structure', description: 'Columns, slabs & structural framework', status: MilestoneStatus.inProgress, estimatedDate: 'Q3 2026', orderIndex: 2),
      TimelineMilestone(id: '4', phase: 'Phase 4', title: 'MEP Rough-in', description: 'Mechanical, electrical & plumbing rough installation', status: MilestoneStatus.pending, estimatedDate: 'Q1 2027', orderIndex: 3),
      TimelineMilestone(id: '5', phase: 'Phase 5', title: 'Interior Finishing', description: 'Flooring, painting, fixtures & cabinetry', status: MilestoneStatus.pending, estimatedDate: 'Q3 2027', orderIndex: 4),
      TimelineMilestone(id: '6', phase: 'Phase 6', title: 'Handover', description: 'Final inspection, snagging & key handover', status: MilestoneStatus.pending, estimatedDate: 'Q4 2027', orderIndex: 5),
    ];
  }

  Future<void> _fetchTimeline() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final milestones = await TimelineService.getPropertyTimeline(widget.propertyId);
      setState(() {
        _milestones = milestones.isEmpty ? _getDefaultMilestones() : milestones;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _milestones = _getDefaultMilestones();
        _error = null;
        _isLoading = false;
      });
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
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.darkGrey),
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
                      ElevatedButton(onPressed: _fetchTimeline, child: Text(AppLocalizations.of(context).retry)),
                    ],
                  ),
                )
              : _buildTimelineTab(),
    );
  }

  // ======================== TIMELINE TAB ========================

  Widget _buildTimelineTab() {
    if (_milestones.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.timeline, size: 48, color: AppColors.lightGrey),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context).noTimelineData,
                style: TextStyle(fontSize: 16, color: AppColors.darkGrey.withValues(alpha: 0.6))),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchTimeline,
      color: AppColors.primaryGreen,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.propertyName != null) ...[
              _buildPropertyHeader(),
              const SizedBox(height: 28),
            ],
            ..._milestones.asMap().entries.map((entry) {
              return _buildMilestone(
                milestone: entry.value,
                index: entry.key,
                isFirst: entry.key == 0,
                isLast: entry.key == _milestones.length - 1,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyHeader() {
    final completedCount = _milestones.where((m) => m.status == MilestoneStatus.completed).length;
    final percentage = _milestones.isEmpty ? 0 : ((completedCount / _milestones.length) * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1D3724), Color(0xFF0E552B)]),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
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
                Text(widget.propertyName!,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.white)),
                const SizedBox(height: 2),
                Text('${_milestones.length} ${AppLocalizations.of(context).milestonesLabel}',
                    style: const TextStyle(fontSize: 12, color: Color(0xCCFFFFFF))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text('$percentage%',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.gold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestone({
    required TimelineMilestone milestone,
    required int index,
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
        statusLabel = AppLocalizations.of(context).inProgress;
        break;
      case MilestoneStatus.delayed:
        dotColor = Colors.red;
        dotBorderColor = Colors.red;
        dotIcon = Icons.warning;
        lineColor = AppColors.lightGrey;
        statusLabel = AppLocalizations.of(context).delayed;
        break;
      case MilestoneStatus.pending:
        dotColor = const Color(0xFFF5F5F5);
        dotBorderColor = AppColors.lightGrey;
        dotIcon = null;
        lineColor = AppColors.lightGrey;
        break;
    }

    final isUpcoming = milestone.status == MilestoneStatus.pending;
    final isExpanded = _expandedMilestoneIndex == index;
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
                if (!isFirst)
                  Container(width: 2, height: 8, color: lineColor)
                else
                  const SizedBox(height: 8),
                Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: dotBorderColor, width: 2),
                    boxShadow: milestone.status == MilestoneStatus.inProgress
                        ? [BoxShadow(color: AppColors.gold.withValues(alpha: 0.3), blurRadius: 8, spreadRadius: 1)]
                        : null,
                  ),
                  child: dotIcon != null ? Icon(dotIcon, size: 16, color: AppColors.white) : null,
                ),
                if (!isLast)
                  Expanded(child: Container(width: 2, color: lineColor))
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
              child: GestureDetector(
                onTap: null,
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
                      BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(milestone.phase,
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.darkGrey.withValues(alpha: 0.4), letterSpacing: 0.5)),
                                const SizedBox(height: 2),
                                Text(milestone.title,
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isUpcoming ? AppColors.darkGrey.withValues(alpha: 0.4) : AppColors.darkGrey)),
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
                              child: Text(statusLabel,
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                                      color: milestone.status == MilestoneStatus.inProgress ? AppColors.gold : Colors.red)),
                            ),
                          if (milestone.status == MilestoneStatus.completed)
                            const Icon(Icons.check_circle, size: 18, color: AppColors.primaryGreen),
                        ],
                      ),
                      if (milestone.description != null) ...[
                        const SizedBox(height: 4),
                        Text(milestone.description!,
                            style: TextStyle(fontSize: 12, color: AppColors.darkGrey.withValues(alpha: 0.5), height: 1.4)),
                      ],

                      // Progress bar
                      if (milestone.completionPercentage > 0) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: milestone.completionPercentage / 100,
                                  backgroundColor: AppColors.lightGrey,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    milestone.completionPercentage == 100 ? AppColors.primaryGreen : AppColors.gold,
                                  ),
                                  minHeight: 6,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('${milestone.completionPercentage}%',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                                    color: milestone.completionPercentage == 100 ? AppColors.primaryGreen : AppColors.gold)),
                          ],
                        ),
                      ],

                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.darkGrey.withValues(alpha: 0.35)),
                          const SizedBox(width: 5),
                          Text(dateText,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.darkGrey.withValues(alpha: 0.4))),
                          const Spacer(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ======================== HELPERS ========================

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
