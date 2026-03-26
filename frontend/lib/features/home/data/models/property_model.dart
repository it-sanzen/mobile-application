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
  final String? floor;
  final String? parking;
  final String? balcony;
  final String? furnishedStatus;
  final List<String> amenities;
  final double? downPayment;
  final double? constructionPayment;
  final double? handoverPayment;

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
    this.floor,
    this.parking,
    this.balcony,
    this.furnishedStatus,
    this.amenities = const [],
    this.downPayment,
    this.constructionPayment,
    this.handoverPayment,
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
      floor: json['floor'] as String?,
      parking: json['parking'] as String?,
      balcony: json['balcony'] as String?,
      furnishedStatus: json['furnishedStatus'] as String?,
      amenities: json['amenities'] != null
          ? (json['amenities'] as List).map((e) => e as String).toList()
          : [],
      downPayment: json['downPayment'] != null ? (json['downPayment'] as num).toDouble() : null,
      constructionPayment: json['constructionPayment'] != null ? (json['constructionPayment'] as num).toDouble() : null,
      handoverPayment: json['handoverPayment'] != null ? (json['handoverPayment'] as num).toDouble() : null,
    );
  }
}
