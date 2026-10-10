class WatchModel {
  final String id;
  final String name;
  final String brand;
  final String type;
  final double price;
  final String imageUrl;
  final int stock;
  final Map<String, dynamic>? specs;
  final int popularity;

  WatchModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.type,
    required this.price,
    required this.imageUrl,
    required this.stock,
    required this.popularity,
    this.specs,
  });

  factory WatchModel.fromMap(String id, Map<String, dynamic> m) {
    double parsedPrice = 0.0;
    if (m['price'] is int) {
      parsedPrice = (m['price'] as int).toDouble();
    } else if (m['price'] is double) {
      parsedPrice = m['price'];
    } else if (m['price'] is String) {
      parsedPrice = double.tryParse(m['price']) ?? 0.0;
    }

    return WatchModel(
      id: id,
      name: m['name'] ?? '',
      brand: m['brand'] ?? '',
      type: m['type'] ?? '',
      price: parsedPrice,
      imageUrl: m['imageUrl'] ?? '',
      stock: (m['stock'] ?? 0) as int,
      popularity: (m['popularity'] ?? 0) as int,
      specs: (m['specs'] is Map) ? Map<String, dynamic>.from(m['specs']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'brand': brand,
      'type': type,
      'price': price,
      'imageUrl': imageUrl,
      'stock': stock,
      'popularity': popularity,
      'specs': specs,
    };
  }
}
