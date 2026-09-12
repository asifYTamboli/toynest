import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import 'add_product.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final supabase = Supabase.instance.client;
  List<dynamic> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  // 1. Fetch real-time checkout entries out of your customer_orders database table
  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    try {
      final data = await supabase
          .from('customer_orders')
          .select('*')
          .order('created_at', ascending: false);

      setState(() {
        _orders = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load orders: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 2. Simple toggle tool to switch status flags directly on the server
  Future<void> _updateOrderStatus(int orderId, String currentStatus) async {
    final nextStatus = currentStatus == 'Pending' ? 'Shipped' : 'Delivered';
    try {
      await supabase
          .from('customer_orders')
          .update({'status': nextStatus})
          .eq('id', orderId);

      _fetchOrders(); // Refresh table view tracking points
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Operations Dashboard'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchOrders),
          Consumer(
            builder: (context, ref, child) {
              return IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  // Revoke admin access state switches cleanly on sign out
                  ref.read(isAdminModeProvider.notifier).setAdminMode(false);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
          ? const Center(
              child: Text(
                'No orders recorded yet! 📦',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                final List<dynamic> items = order['order_details'] ?? [];
                final totalBill = order['total_bill'] ?? 0.0;
                final status = order['status'] ?? 'Pending';
                final date = DateTime.parse(order['created_at']).toLocal();

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order ID: #${order['id']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Chip(
                              label: Text(status),
                              backgroundColor: status == 'Pending'
                                  ? Colors.amber.shade100
                                  : status == 'Shipped'
                                  ? Colors.blue.shade100
                                  : Colors.green.shade100,
                            ),
                          ],
                        ),
                        Text(
                          'Date: ${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                        ),
                        const Divider(height: 24),
                        ...items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${item['car_name'] ?? 'Item'} x ${item['quantity']}',
                                ),
                                Text(
                                  '₹${(item['subtotal'] ?? 0.0).toStringAsFixed(2)}',
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              onPressed: status == 'Delivered'
                                  ? null
                                  : () =>
                                        _updateOrderStatus(order['id'], status),
                              icon: const Icon(Icons.local_shipping),
                              label: Text(
                                status == 'Pending'
                                    ? 'Mark as Shipped'
                                    : 'Mark as Delivered',
                              ),
                            ),
                            Text(
                              'Total: ₹${totalBill.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Open up the product entry form and listen for successful saves
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductScreen()),
          );

          // Optional: If you choose to display an inventory preview grid on your admin page,
          // you can trigger a refresh callback here when result == true.
        },
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add New Car'),
      ),
    );
  }
}
