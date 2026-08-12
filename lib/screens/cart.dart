import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// 1. IMPORT DART HTML TO UNBLOCK BROWSERS
import 'dart:html' as html; 
import '../providers/cart_provider.dart';

class Cart extends ConsumerWidget {
  const Cart({super.key});

  // 2. UPDATED SYNCHRONOUS ROUTING FUNCTION
      void _sendWhatsAppOrder(BuildContext context, List cartItems, double totalAmount) {
    // 1. MUST BE PURE DIGITS ONLY: No '+', no dashes, no spaces, no leading zeros!
    const String businessPhoneNumber = "918087622595"; 

    // Build the string using explicit URL-friendly spacing patterns
    String textMessage = "🛍️ New Order from ToyNest Web Store: ";
    
    List<String> itemsList = [];
    for (var item in cartItems) {
      itemsList.add("${item.car.name} (Qty: ${item.quantity} - ₹${(item.car.price * item.quantity).toStringAsFixed(2)})");
    }
    
    textMessage += itemsList.join(", ");
    textMessage += " | 💰 Grand Total Bill: ₹${totalAmount.toStringAsFixed(2)}. Please confirm my order! 🙏";

    // 2. USE THE UNIFIED UNIVERSAL SHORTLINK FORMAT
    final String urlEncodedText = Uri.encodeComponent(textMessage);
    final String whatsappUrl = "https://wa.me";

    try {
      // Direct native browser window tab redirection injection (bypasses browser security locks)
      html.window.open(whatsappUrl, '_blank'); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error redirecting to WhatsApp: $e'), backgroundColor: Colors.red),
      );
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
                            errorBuilder: (_, __, _) => const Icon(Icons.directions_car),
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
                            onPressed: () => _sendWhatsAppOrder(context, cartItems, totalAmount),
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
