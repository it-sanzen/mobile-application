import 'milestone_photo.dart';
import 'milestone_update.dart';

enum MilestoneStatus {
  completed('COMPLETED'),
  inProgress('IN_PROGRESS'),
  pending('PENDING'),
  delayed('DELAYED');

  final String value;
  const MilestoneStatus(this.value);

  static MilestoneStatus fromString(String value) {
    return MilestoneStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => MilestoneStatus.pending,
    );
  }
}

class TimelineMilestone {
  final String id;
  final String phase;
  final String title;
  final String? description;
  final MilestoneStatus status;
  final int completionPercentage;
  final DateTime? completedDate;
  final String? estimatedDate;
  final int orderIndex;
  final List<MilestoneUpdate> updates;
  final List<MilestonePhoto> photos;

  TimelineMilestone({
    required this.id,
    required this.phase,
    required this.title,
    this.description,
    required this.status,
    this.completionPercentage = 0,
    this.completedDate,
    this.estimatedDate,
    required this.orderIndex,
    this.updates = const [],
    this.photos = const [],
  });

  factory TimelineMilestone.fromJson(Map<String, dynamic> json) {
    return TimelineMilestone(
      id: json['id'] as String,
      phase: json['phase'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: MilestoneStatus.fromString(json['status'] as String),
      completionPercentage: json['completionPercentage'] as int? ?? 0,
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'] as String)
          : null,
      estimatedDate: json['estimatedDate'] as String?,
      orderIndex: json['orderIndex'] as int,
      updates: (json['updates'] as List<dynamic>?)
              ?.map((u) => MilestoneUpdate.fromJson(u as Map<String, dynamic>))
              .toList() ??
          [],
      photos: (json['photos'] as List<dynamic>?)
              ?.map((p) => MilestonePhoto.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phase': phase,
      'title': title,
      'description': description,
      'status': status.value,
      'completionPercentage': completionPercentage,
      'completedDate': completedDate?.toIso8601String(),
      'estimatedDate': estimatedDate,
      'orderIndex': orderIndex,
    };
  }
}
