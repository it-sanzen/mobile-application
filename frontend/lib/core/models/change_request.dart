enum ChangeRequestCategory {
  structural('STRUCTURAL'),
  interior('INTERIOR'),
  electrical('ELECTRICAL'),
  plumbing('PLUMBING'),
  layout('LAYOUT'),
  material('MATERIAL'),
  other('OTHER');

  final String value;
  const ChangeRequestCategory(this.value);

  String get label {
    switch (this) {
      case ChangeRequestCategory.structural:
        return 'Structural';
      case ChangeRequestCategory.interior:
        return 'Interior';
      case ChangeRequestCategory.electrical:
        return 'Electrical';
      case ChangeRequestCategory.plumbing:
        return 'Plumbing';
      case ChangeRequestCategory.layout:
        return 'Layout';
      case ChangeRequestCategory.material:
        return 'Material';
      case ChangeRequestCategory.other:
        return 'Other';
    }
  }

  static ChangeRequestCategory fromString(String value) {
    return ChangeRequestCategory.values.firstWhere(
      (c) => c.value == value,
      orElse: () => ChangeRequestCategory.other,
    );
  }
}

enum ChangeRequestStatus {
  submitted('SUBMITTED'),
  underReview('UNDER_REVIEW'),
  approved('APPROVED'),
  rejected('REJECTED'),
  completed('COMPLETED');

  final String value;
  const ChangeRequestStatus(this.value);

  String get label {
    switch (this) {
      case ChangeRequestStatus.submitted:
        return 'Submitted';
      case ChangeRequestStatus.underReview:
        return 'Under Review';
      case ChangeRequestStatus.approved:
        return 'Approved';
      case ChangeRequestStatus.rejected:
        return 'Rejected';
      case ChangeRequestStatus.completed:
        return 'Completed';
    }
  }

  static ChangeRequestStatus fromString(String value) {
    return ChangeRequestStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => ChangeRequestStatus.submitted,
    );
  }
}

class ChangeRequestModel {
  final String id;
  final String userId;
  final String propertyId;
  final String title;
  final String description;
  final ChangeRequestCategory category;
  final ChangeRequestStatus status;
  final String? adminNotes;
  final double? costImpact;
  final String? timelineImpact;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? propertyName;
  final String? propertyLocation;

  ChangeRequestModel({
    required this.id,
    required this.userId,
    required this.propertyId,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    this.adminNotes,
    this.costImpact,
    this.timelineImpact,
    required this.createdAt,
    required this.updatedAt,
    this.propertyName,
    this.propertyLocation,
  });

  factory ChangeRequestModel.fromJson(Map<String, dynamic> json) {
    final property = json['property'] as Map<String, dynamic>?;
    return ChangeRequestModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      propertyId: json['propertyId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: ChangeRequestCategory.fromString(json['category'] as String),
      status: ChangeRequestStatus.fromString(json['status'] as String),
      adminNotes: json['adminNotes'] as String?,
      costImpact: json['costImpact'] != null ? (json['costImpact'] as num).toDouble() : null,
      timelineImpact: json['timelineImpact'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      propertyName: property?['name'] as String?,
      propertyLocation: property?['location'] as String?,
    );
  }
}
