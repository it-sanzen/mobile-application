import 'milestone_photo.dart';

class MilestoneUpdate {
  final String id;
  final String milestoneId;
  final String notes;
  final DateTime createdAt;
  final List<MilestonePhoto> photos;
  final String? milestonePhase;
  final String? milestoneTitle;

  MilestoneUpdate({
    required this.id,
    required this.milestoneId,
    required this.notes,
    required this.createdAt,
    required this.photos,
    this.milestonePhase,
    this.milestoneTitle,
  });

  factory MilestoneUpdate.fromJson(Map<String, dynamic> json) {
    final milestone = json['milestone'] as Map<String, dynamic>?;
    return MilestoneUpdate(
      id: json['id'] as String,
      milestoneId: json['milestoneId'] as String,
      notes: json['notes'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      photos: (json['photos'] as List<dynamic>?)
              ?.map((p) => MilestonePhoto.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      milestonePhase: milestone?['phase'] as String?,
      milestoneTitle: milestone?['title'] as String?,
    );
  }
}
