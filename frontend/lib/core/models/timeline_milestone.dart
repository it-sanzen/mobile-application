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
  final DateTime? completedDate;
  final String? estimatedDate;
  final int orderIndex;

  TimelineMilestone({
    required this.id,
    required this.phase,
    required this.title,
    this.description,
    required this.status,
    this.completedDate,
    this.estimatedDate,
    required this.orderIndex,
  });

  factory TimelineMilestone.fromJson(Map<String, dynamic> json) {
    return TimelineMilestone(
      id: json['id'] as String,
      phase: json['phase'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: MilestoneStatus.fromString(json['status'] as String),
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'] as String)
          : null,
      estimatedDate: json['estimatedDate'] as String?,
      orderIndex: json['orderIndex'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phase': phase,
      'title': title,
      'description': description,
      'status': status.value,
      'completedDate': completedDate?.toIso8601String(),
      'estimatedDate': estimatedDate,
      'orderIndex': orderIndex,
    };
  }
}
