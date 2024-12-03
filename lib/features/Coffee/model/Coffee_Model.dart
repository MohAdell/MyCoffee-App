class Coffee {
  final int id;
  final String title;
  final String description;
  final String image;
  final List<String> ingredients;
  final double? price;
  int quantity;


  Coffee({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.ingredients,
    this.price,
    this.quantity = 1,

  });

  factory Coffee.fromJson(Map<String, dynamic> json) {
    return Coffee(
      id: json['id'] is String
          ? int.tryParse(json['id']) ?? 0
          : json['id'],
      title: json['title'] ?? 'Unknown Title',
      description: json['description'] ?? 'No description available',
      image: json['image'] ?? 'https://png.pngtree.com/png-vector/20240322/ourmid/pngtree-warm-coffee-drinking-cup-set-with-beautiful-random-splash-png-image_12184415.png', // تأكد من وجود صورة افتراضية عند الضرورة
      ingredients: List<String>.from(json['ingredients'] ?? []),
      price: json['price'] != null
          ? (json['price'] is String
          ? double.tryParse(json['price']) ?? 0.0
          : (json['price'] as num).toDouble())
          : 10.0,
      quantity: json['quantity'] ?? 1,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image,
      'ingredients': ingredients,
      'price': price,
      'quantity': quantity,
    };
  }

}
