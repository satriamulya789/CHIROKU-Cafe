class CartItemModel {
  final String id;
  final String productName;
  final double price;
  final int quantity;
  final String? category;
  final String? imageUrl;
  final String? note;

  CartItemModel({
    required this.id,
    required this.productName,
    required this.price,
    required this.quantity,
    this.category,
    this.imageUrl,
    this.note,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'].toString(),
      productName: json['productName'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      category: json['category'] as String?,
      imageUrl: json['imageUrl'] as String?,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'category': category,
      'imageUrl': imageUrl,
      'note': note,
    };
  }

  double get total => price * quantity;

  CartItemModel copyWith({
    String? id,
    String? productName,
    double? price,
    int? quantity,
    String? category,
    String? imageUrl,
    String? note,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      note: note ?? this.note,
    );
  }
}