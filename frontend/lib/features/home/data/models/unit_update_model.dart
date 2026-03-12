class UnitUpdateModel {
  final String id;
  final String updateType;
  final String title;
  final String description;
  final String time;

  UnitUpdateModel({
    required this.id,
    required this.updateType,
    required this.title,
    required this.description,
    required this.time,
  });

  factory UnitUpdateModel.fromJson(Map<String, dynamic> json) {
    return UnitUpdateModel(
      id: json['id'] as String,
      updateType: json['updateType'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      time: json['time'] as String,
    );
  }
}
