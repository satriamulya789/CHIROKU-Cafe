class CartItemModel {
  final String id;
  final int menuId;
  final String productName;
  final double price;
  final int quantity;
  final String? imageUrl;
  final String? category;
  final String? note;

  CartItemModel({
    required this.id,
    required this.menuId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.imageUrl,
    this.category,
    this.note,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as String? ?? '',
      menuId: (json['menu_id'] as num?)?.toInt() ?? 0,
      productName: json['product_name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      imageUrl: json['image_url'] as String?,
      category: json['category'] as String?,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'menu_id': menuId,
      'product_name': productName,
      'price': price,
      'quantity': quantity,
      'image_url': imageUrl,
      'category': category,
      'note': note,
    };
  }

  CartItemModel copyWith({
    String? id,
    int? menuId,
    String? productName,
    double? price,
    int? quantity,
    String? imageUrl,
    String? category,
    String? note,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      menuId: menuId ?? this.menuId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      note: note ?? this.note,
    );
  }

  double get total => price * quantity;
}