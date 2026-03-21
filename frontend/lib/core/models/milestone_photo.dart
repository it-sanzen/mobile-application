class MilestonePhoto {
  final String id;
  final String milestoneId;
  final String? milestoneUpdateId;
  final String photoUrl;
  final String? caption;
  final String photoType; // BEFORE, AFTER, PROGRESS
  final DateTime createdAt;

  MilestonePhoto({
    required this.id,
    required this.milestoneId,
    this.milestoneUpdateId,
    required this.photoUrl,
    this.caption,
    required this.photoType,
    required this.createdAt,
  });

  factory MilestonePhoto.fromJson(Map<String, dynamic> json) {
    return MilestonePhoto(
      id: json['id'] as String,
      milestoneId: json['milestoneId'] as String,
      milestoneUpdateId: json['milestoneUpdateId'] as String?,
      photoUrl: json['photoUrl'] as String,
      caption: json['caption'] as String?,
      photoType: json['photoType'] as String? ?? 'PROGRESS',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
