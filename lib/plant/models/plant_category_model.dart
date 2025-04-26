class PlantCategory {
  final String id;
  final String name;
  final String imageUrl;

  PlantCategory({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory PlantCategory.fromJson(Map<String, dynamic> json) {
    return PlantCategory(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': imageUrl,
    };
  }
}
