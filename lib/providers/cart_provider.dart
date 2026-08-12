import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/car.dart';
import '../models/cart.dart';

// 1. Switched from StateNotifier to the modern Notifier base class
class CartNotifier extends Notifier<List<Cart>> {
  @override
  List<Cart> build() {
    return []; // This defines your initial empty cart state array
  }

  // Add a car or increment quantity
  void addCar(Car car) {
    final existingIndex = state.indexWhere((item) => item.car.id == car.id);

    if (existingIndex >= 0) {
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == existingIndex)
            state[i].copyWith(quantity: state[i].quantity + 1)
          else
            state[i]
      ];
    } else {
      state = [...state, Cart(car: car)];
    }
  }

  // Decrement product quantity or drop if 0
  void removeOrDecrement(Car car) {
    final existingIndex = state.indexWhere((item) => item.car.id == car.id);
    if (existingIndex < 0) return;

    if (state[existingIndex].quantity > 1) {
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == existingIndex)
            state[i].copyWith(quantity: state[i].quantity - 1)
          else
            state[i]
      ];
    } else {
      state = state.where((item) => item.car.id != car.id).toList();
    }
  }

  // Completely drop item
  void clearItem(Car car) {
    state = state.where((item) => item.car.id != car.id).toList();
  }
}

// 2. Updated hook from StateNotifierProvider to NotifierProvider
final cartProvider = NotifierProvider<CartNotifier, List<Cart>>(() {
  return CartNotifier();
});

// Computed provider for the total bill summary remains identical
final cartTotalProvider = Provider<double>((ref) {
  final cartItems = ref.watch(cartProvider);
  return cartItems.fold(0, (sum, item) => sum + (item.car.price * item.quantity));
});
