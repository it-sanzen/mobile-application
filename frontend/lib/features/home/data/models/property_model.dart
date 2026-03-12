class PropertyModel {
  final String id;
  final String name;
  final String location;
  final String propertyType;
  final String? imageUrl;
  final int bedrooms;
  final double area;
  final String status;
  final double completionPercentage;
  final String? currentPhase;
  final String? estimatedCompletion;
  final String unitCode;

  PropertyModel({
    required this.id,
    required this.name,
    required this.location,
    required this.propertyType,
    this.imageUrl,
    required this.bedrooms,
    required this.area,
    required this.status,
    required this.completionPercentage,
    this.currentPhase,
    this.estimatedCompletion,
    required this.unitCode,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      propertyType: json['propertyType'] as String,
      imageUrl: json['imageUrl'] as String?,
      bedrooms: json['bedrooms'] as int,
      area: (json['area'] as num).toDouble(),
      status: json['status'] as String,
      completionPercentage: (json['completionPercentage'] as num).toDouble(),
      currentPhase: json['currentPhase'] as String?,
      estimatedCompletion: json['estimatedCompletion'] as String?,
      unitCode: json['unitCode'] as String,
    );
  }
}
