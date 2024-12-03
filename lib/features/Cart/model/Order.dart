import '../../Coffee/model/Coffee_Model.dart';

class CartItem {
  final Coffee coffee;
  int quantity;
  String status;

  CartItem({required this.coffee, this.quantity = 1, this.status = 'In Cart'});

  // Convert CartItem to JSON
  Map<String, dynamic> toJson() => {
    'coffee': coffee.toJson(), // Assuming Coffee has a toJson() method
    'quantity': quantity,
  };

  // Create CartItem from JSON
  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    coffee: Coffee.fromJson(json['coffee']), // Assuming Coffee has a fromJson() method
    quantity: json['quantity'],
  );
}