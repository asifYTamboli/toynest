import 'car.dart';

class Cart {
  final Car car;
  final int quantity;

  Cart({
    required this.car,
    this.quantity = 1,
  });

  // Helper method to create a copy of the item with a new quantity easily
  Cart copyWith({int? quantity}) {
    return Cart(
      car: car,
      quantity: quantity ?? this.quantity,
    );
  }
}