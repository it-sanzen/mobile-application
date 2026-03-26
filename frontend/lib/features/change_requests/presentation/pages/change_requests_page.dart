import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/models/change_request.dart';
import '../../data/services/change_request_service.dart';
import 'submit_change_request_page.dart';
import 'edit_change_request_page.dart';

class ChangeRequestsPage extends StatefulWidget {
  const ChangeRequestsPage({super.key});

  @override
  State<ChangeRequestsPage> createState() => _ChangeRequestsPageState();
}

class _ChangeRequestsPageState extends State<ChangeRequestsPage> {
  List<ChangeRequestModel> _requests = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final requests = await ChangeRequestService.getMyRequests();
      setState(() {
        _requests = requests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Change Requests',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.white),
        ),
        backgroundColor: AppColors.primaryGreen,
        iconTheme: const IconThemeData(color: AppColors.white),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SubmitChangeRequestPage()),
          );
          if (result == true) _fetchRequests();
        },
        backgroundColor: AppColors.primaryGreen,
        icon: const Icon(Icons.add, color: AppColors.white),
        label: const Text('New Request', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text('Error: $_error', textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _fetchRequests, child: const Text('Retry')),
                    ],
                  ),
                )
              : _requests.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit_note, size: 64, color: AppColors.grey.withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          const Text(
                            'No change requests yet',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.darkGrey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Submit a request to modify your villa',
                            style: TextStyle(fontSize: 14, color: AppColors.grey),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchRequests,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _requests.length,
                        itemBuilder: (context, index) => _buildRequestCard(_requests[index]),
                      ),
                    ),
    );
  }

  Widget _buildRequestCard(ChangeRequestModel request) {
    final statusColor = _statusColor(request.status);
    final categoryIcon = _categoryIcon(request.category);
    final timeAgo = _formatTimeAgo(request.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(categoryIcon, color: AppColors.primaryGreen, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.title,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.black),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${request.category.label} • $timeAgo',
                        style: TextStyle(fontSize: 12, color: AppColors.grey),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    request.status.label,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              request.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: AppColors.darkGrey.withValues(alpha: 0.7)),
            ),
            if (request.propertyName != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.home_outlined, size: 14, color: AppColors.grey),
                  const SizedBox(width: 4),
                  Text(
                    request.propertyName!,
                    style: TextStyle(fontSize: 12, color: AppColors.grey),
                  ),
                ],
              ),
            ],
            if (request.adminNotes != null && request.adminNotes!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.comment_outlined, size: 14, color: statusColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        request.adminNotes!,
                        style: TextStyle(fontSize: 12, color: AppColors.darkGrey),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (request.costImpact != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.monetization_on_outlined, size: 14, color: AppColors.gold),
                  const SizedBox(width: 4),
                  Text(
                    'Cost Impact: AED ${request.costImpact!.toStringAsFixed(0)}',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.gold),
                  ),
                ],
              ),
            ],
            // Status message
            if (request.status == ChangeRequestStatus.underReview) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.hourglass_top, size: 14, color: AppColors.warning),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'We are studying your request and will get back to you soon.',
                        style: TextStyle(fontSize: 12, color: AppColors.darkGrey),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (request.status == ChangeRequestStatus.approved) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, size: 14, color: AppColors.success),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your request has been approved!',
                        style: TextStyle(fontSize: 12, color: AppColors.darkGrey),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (request.status == ChangeRequestStatus.rejected) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.cancel_outlined, size: 14, color: AppColors.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your request has been rejected.',
                        style: TextStyle(fontSize: 12, color: AppColors.darkGrey),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            // Edit button for submitted requests only
            if (request.status == ChangeRequestStatus.submitted) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 36,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => EditChangeRequestPage(request: request)),
                    );
                    if (result == true) _fetchRequests();
                  },
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit Request', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryGreen,
                    side: const BorderSide(color: AppColors.primaryGreen),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} months ago';
    if (diff.inDays > 0) return '${diff.inDays} days ago';
    if (diff.inHours > 0) return '${diff.inHours} hours ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes} min ago';
    return 'Just now';
  }
}
