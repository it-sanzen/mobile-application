enum AddonCategory {
  upgrade('UPGRADE'),
  smartHome('SMART_HOME'),
  outdoor('OUTDOOR'),
  vehicle('VEHICLE'),
  security('SECURITY'),
  other('OTHER');

  final String value;
  const AddonCategory(this.value);

  static AddonCategory fromString(String value) {
    return AddonCategory.values.firstWhere(
      (category) => category.value == value,
      orElse: () => AddonCategory.other,
    );
  }
}

class AddonOffer {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String? icon;
  final double? price;
  final AddonCategory category;

  AddonOffer({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.icon,
    this.price,
    required this.category,
  });

  factory AddonOffer.fromJson(Map<String, dynamic> json) {
    return AddonOffer(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
      icon: json['icon'] as String?,
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      category: AddonCategory.fromString(json['category'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'icon': icon,
      'price': price,
      'category': category.value,
    };
  }
}
