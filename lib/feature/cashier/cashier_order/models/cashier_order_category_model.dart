class CategoryMenuModel {
  final int id;
  final String name;

  CategoryMenuModel({required this.id, required this.name});

  factory CategoryMenuModel.fromJson(Map<String, dynamic> json) {
    try {
      return CategoryMenuModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name'] as String? ?? '',
      );
    } catch (e) {
      print('❌ Error parsing CategoryMenuModel: $e');
      print('📦 JSON data: $json');
      rethrow;
    }
  }
}
