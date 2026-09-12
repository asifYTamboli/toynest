import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// 1. IMPORT DART HTML TO UNBLOCK BROWSERS
import 'dart:html' as html; 
import '../providers/cart_provider.dart';

class Cart extends ConsumerWidget {
  const Cart({super.key});

  // 2. UPDATED SYNCHRONOUS ROUTING FUNCTION
    Future<void> _sendWhatsAppOrder(BuildContext context, WidgetRef ref, List cartItems, double totalAmount) async {
    final supabase = Supabase.instance.client;

    // 1. Serialize your shopping cart items cleanly into standard maps
    final List<Map<String, dynamic>> serializedItems = cartItems.map((item) => {
      'name': item.car.name,
      'quantity': item.quantity,
      'price': item.car.price,
      'subtotal': item.car.price * item.quantity
    }).toList();

    try {
      // 2. Log order details in your cars_inventory Supabase database table
      await supabase.from('customer_orders').insert({
        'order_details': serializedItems,
        'total_bill': totalAmount,
      });

      // 3. TRIGGER YOUR LIVE CLOUD EDGE FUNCTION SILENTLY IN THE BACKGROUND
      // This bypasses html.window.open entirely, preventing popup blockers and URL syntax errors
      await supabase.functions.invoke(
        'send-order-email',
        body: {
          'cartItems': serializedItems,
          'totalAmount': totalAmount,
        },
      );

      // 4. Present a native, beautiful on-screen success confirmation dialogue
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 28),
                  SizedBox(width: 8),
                  Text('Order Placed!'),
                ],
              ),
              content: const Text(
                'Your order has been confirmed successfully. Our background system has processed the checkout alert request.',
                style: TextStyle(fontSize: 16),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Dismiss dialogue box
                    Navigator.of(context).pop(); // Close shopping cart screen
                  },
                  child: const Text('Back to Store', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Checkout processing failure: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }



  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final totalAmount = ref.watch(cartTotalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Shopping Cart'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: cartItems.isEmpty
          ? const Center(child: Text('Your cart is completely empty! 🛒', style: TextStyle(fontSize: 18)))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: Image.network(
                            item.car.imageUrl ?? '', 
                            width: 50, 
                            fit: BoxFit.cover, 
                            errorBuilder: (_, _, _) => const Icon(Icons.directions_car),
                          ),
                          title: Text(item.car.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('₹${item.car.price} × ${item.quantity} = ₹${item.car.price * item.quantity}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                onPressed: () => ref.read(cartProvider.notifier).removeOrDecrement(item.car),
                              ),
                              Text('${item.quantity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                                onPressed: () => ref.read(cartProvider.notifier).addCar(item.car),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Grand Total Bill:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('₹${totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton(
                            // 4. TRIGGER WITHOUT THE AWAIT DELAY LOOP GATES
                            onPressed: () => _sendWhatsAppOrder(context, ref, cartItems, totalAmount),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary, 
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Proceed to Checkout (WhatsApp)', style: TextStyle(fontSize: 16)),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
    );
  }
}
