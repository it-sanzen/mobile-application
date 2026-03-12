class CompanyNewsModel {
  final String id;
  final String category;
  final String title;
  final String description;
  final String time;
  final bool isFeatured;

  CompanyNewsModel({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.time,
    required this.isFeatured,
  });

  factory CompanyNewsModel.fromJson(Map<String, dynamic> json) {
    return CompanyNewsModel(
      id: json['id'] as String,
      category: json['category'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      time: json['time'] as String,
      isFeatured: json['isFeatured'] as bool,
    );
  }
}
