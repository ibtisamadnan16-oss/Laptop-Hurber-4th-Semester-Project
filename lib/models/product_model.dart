class ProductModel {
  final String id;
  final String name;
  final String brand;
  final String category;
  final String specSubtitle;
  final double price;
  final double? originalPrice;
  final String imageUrl;
  final List<String> images;
  final String description;
  final double rating;
  final int reviewsCount;
  final int stock;
  final bool isFeatured;
  final bool isLatest;
  final int popularity;
  final Map<String, String> specifications;

  final String processor;
  final String ram;
  final String storage;
  final String gpu;
  final String screenSize;
  final String operatingSystem;

  const ProductModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    this.specSubtitle = '',
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    this.images = const [],
    required this.description,
    this.rating = 4.5,
    this.reviewsCount = 18,
    this.stock = 15,
    this.isFeatured = false,
    this.isLatest = false,
    this.popularity = 85,
    this.specifications = const {},
    this.processor = '',
    this.ram = '',
    this.storage = '',
    this.gpu = '',
    this.screenSize = '',
    this.operatingSystem = '',
  });

  List<String> get allImages {
    if (images.isNotEmpty) return images;
    if (imageUrl.isNotEmpty) return [imageUrl];
    return [];
  }

  int get stockQuantity => stock;

  String get resolvedProcessor => processor.isNotEmpty
      ? processor
      : (specifications['Processor'] ?? specSubtitle);

  String get resolvedRam =>
      ram.isNotEmpty ? ram : (specifications['RAM'] ?? '16GB DDR4');

  String get resolvedStorage =>
      storage.isNotEmpty ? storage : (specifications['Storage'] ?? '512GB SSD');

  String get resolvedGpu => gpu.isNotEmpty
      ? gpu
      : (specifications['Graphics'] ??
          specifications['GPU'] ??
          'Integrated Graphics');

  String get resolvedScreenSize => screenSize.isNotEmpty
      ? screenSize
      : (specifications['Display'] ??
          specifications['Screen Size'] ??
          '15.6" FHD');

  String get resolvedOS => operatingSystem.isNotEmpty
      ? operatingSystem
      : (specifications['OS'] ??
          specifications['Operating System'] ??
          'Windows 11');

  String get os => operatingSystem.isNotEmpty ? operatingSystem : resolvedOS;

  String get formattedPrice {
    final intPrice = price.round();
    final str = intPrice.toString();
    final regex = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formatted = str.replaceAllMapped(regex, (m) => '${m[1]},');
    return 'Rs. $formatted';
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? brand,
    String? category,
    String? specSubtitle,
    double? price,
    double? originalPrice,
    String? imageUrl,
    List<String>? images,
    String? description,
    double? rating,
    int? reviewsCount,
    int? stock,
    bool? isFeatured,
    bool? isLatest,
    int? popularity,
    Map<String, String>? specifications,
    String? processor,
    String? ram,
    String? storage,
    String? gpu,
    String? screenSize,
    String? operatingSystem,
    String? os,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      specSubtitle: specSubtitle ?? this.specSubtitle,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      stock: stock ?? this.stock,
      isFeatured: isFeatured ?? this.isFeatured,
      isLatest: isLatest ?? this.isLatest,
      popularity: popularity ?? this.popularity,
      specifications: specifications ?? this.specifications,
      processor: processor ?? this.processor,
      ram: ram ?? this.ram,
      storage: storage ?? this.storage,
      gpu: gpu ?? this.gpu,
      screenSize: screenSize ?? this.screenSize,
      operatingSystem: os ?? operatingSystem ?? this.operatingSystem,
    );
  }

  factory ProductModel.fromMap(String id, Map<String, dynamic> map) {
    double parsePrice(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    Map<String, String> parseSpecs(dynamic rawSpecs) {
      if (rawSpecs is Map) {
        return rawSpecs
            .map((key, val) => MapEntry(key.toString(), val.toString()));
      }
      return {};
    }

    List<String> parseImages(dynamic rawImages, String mainImage) {
      if (rawImages is List && rawImages.isNotEmpty) {
        return rawImages.map((e) => e.toString()).toList();
      }
      if (mainImage.isNotEmpty) {
        return [mainImage];
      }
      return [];
    }

    final specs = parseSpecs(map['specifications'] ?? map['specs']);
    final mainImage = map['imageUrl']?.toString() ?? '';
    final imagesList = parseImages(map['images'], mainImage);

    final rawSubtitle = map['specSubtitle']?.toString() ??
        map['subtitle']?.toString() ??
        specs['Processor'] ??
        specs['CPU'] ??
        'High Performance';

    final popularityVal =
        (map['popularity'] is num) ? (map['popularity'] as num).toInt() : 85;

    return ProductModel(
      id: id,
      name: map['name']?.toString() ?? 'Laptop',
      brand: map['brand']?.toString() ?? 'Generic',
      category:
          map['category']?.toString() ?? map['type']?.toString() ?? 'General',
      specSubtitle: rawSubtitle,
      price: parsePrice(map['price']),
      originalPrice: map['originalPrice'] != null
          ? parsePrice(map['originalPrice'])
          : null,
      imageUrl: mainImage,
      images: imagesList,
      description: map['description']?.toString() ?? '',
      rating: map['rating'] != null ? parsePrice(map['rating']) : 4.5,
      reviewsCount: (map['reviewsCount'] is num)
          ? (map['reviewsCount'] as num).toInt()
          : 18,
      stock: (map['stock'] is num) ? (map['stock'] as num).toInt() : 10,
      isFeatured: map['isFeatured'] == true || popularityVal >= 90,
      isLatest: map['isLatest'] == true ||
          id.contains('new') ||
          id.contains('latest'),
      popularity: popularityVal,
      specifications: specs,
      processor: map['processor']?.toString() ?? specs['Processor'] ?? '',
      ram: map['ram']?.toString() ?? specs['RAM'] ?? '',
      storage: map['storage']?.toString() ?? specs['Storage'] ?? '',
      gpu: map['gpu']?.toString() ?? specs['Graphics'] ?? specs['GPU'] ?? '',
      screenSize: map['screenSize']?.toString() ??
          specs['Display'] ??
          specs['Screen Size'] ??
          '',
      operatingSystem: map['operatingSystem']?.toString() ??
          specs['OS'] ??
          specs['Operating System'] ??
          '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'brand': brand,
      'category': category,
      'specSubtitle': specSubtitle,
      'price': price,
      'originalPrice': originalPrice,
      'imageUrl': imageUrl,
      'images': images,
      'description': description,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'stock': stock,
      'isFeatured': isFeatured,
      'isLatest': isLatest,
      'popularity': popularity,
      'specifications': specifications,
      'processor': resolvedProcessor,
      'ram': resolvedRam,
      'storage': resolvedStorage,
      'gpu': resolvedGpu,
      'screenSize': resolvedScreenSize,
      'operatingSystem': resolvedOS,
    };
  }
}
