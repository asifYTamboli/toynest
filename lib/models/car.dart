class Car {
  final int id;
  final DateTime? createdAt;
  final String name;
  final String? brand;
  final String? voltage;
  final double price;
  final List<String>? colors;
  final bool? remoteControl;
  final int? stockCount;
  final String? imageUrl;
  final String? description;
  final List<String>? galleryUrls;

  const Car({
    required this.id,
    this.createdAt,
    required this.name,
    this.brand,
    this.voltage,
    required this.price,
    this.colors,
    this.remoteControl,
    this.stockCount,
    this.imageUrl,
    this.description,
    this.galleryUrls,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'] as int,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      name: json['name'] as String,
      brand: json['brand'] as String?,
      voltage: json['voltage'] as String?,
      price: (json['price'] as num).toDouble(),
      colors: json['color'] != null 
              ? List<String>.from(json['color'] as Iterable) 
              : null,
      remoteControl: json['remote_control'] as bool?,
      stockCount: json['stock_count'] as int?,
      imageUrl: json['image_url'] as String?,
      description: json['description'] as String?,
      galleryUrls: json['gallery_urls'] != null 
                  ? List<String>.from(json['gallery_urls'] as Iterable) 
                  : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt?.toIso8601String(),
      'name': name,
      'brand': brand,
      'voltage': voltage,
      'price': price,
      'color': colors,
      'remote_control': remoteControl,
      'stock_count': stockCount,
      'image_url': imageUrl,
      'description': description,
      'gallery_urls': galleryUrls,
    };
  }
}