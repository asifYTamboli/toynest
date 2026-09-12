import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/cars_provider.dart';
import 'package:flutter_application_1/providers/cart_provider.dart';
import 'package:flutter_application_1/screens/car_details.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/cart.dart';
import 'screens/admin_login.dart';
import 'screens/admin_dashboard.dart';


// 1. Create a class to hold your admin login true/false state status
class AdminModeNotifier extends Notifier<bool> {
  @override
  bool build() => false; // Sets your default starting value to false

  void setAdminMode(bool value) {
    state = value; // Allows switching states during login
  }
}

// 2. Expose the notifier to your entire application tree globally
final isAdminModeProvider = NotifierProvider<AdminModeNotifier, bool>(AdminModeNotifier.new);



void main() async {
  // Ensures Flutter framework services are ready before running asynchronous native code
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the global Supabase client instance
  await Supabase.initialize(
    url: 'https://zefywdhyvvmfzfzrrtiv.supabase.co',
    publishableKey: 'sb_publishable_cwbZaDg6-VXFT5SvWTgkGQ_hgRhBYAH',
  );

  // Wrap the entire app in a ProviderScope to enable Riverpod state management
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'High Performance App',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
      ),
      home: const HomeScreen(),
    );
  }
}

// Modify main.dart (or extract to catalog_screen.dart)
class HomeScreen extends ConsumerWidget { // Switched to ConsumerWidget
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { // Added WidgetRef parameter

  
    // Watch your cars list provider
    final carsAsync = ref.watch(carsListProvider);

    // Watch the cart items to display a real-time count badge
    final cartItems = ref.watch(cartProvider);
    final totalCartItems = cartItems.fold(0, (sum, item) => sum + item.quantity);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kids Ride-On Cars Store'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings, size: 26),
            onPressed: () {
              // 1. Read your active login state flag from your NotifierProvider
              final bool isLoggedIn = ref.read(isAdminModeProvider);

              if (isLoggedIn) {
                // 2. Already Logged In: Route straight to your active Operations Dashboard panel
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminDashboardScreen(),
                  ),
                );
              } else {
                // 3. Not Logged In: Open the secure login credentials form entry page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminLoginScreen(),
                  ),
                );
              }
            },
          ),

        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart, size: 28),
              onPressed: () {
                // 2. THIS OPENS YOUR HIDDEN CART SCREEN
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Cart()),
                );
              },
            ),
            // Floating numeric bubble badge showing current count
            if (totalCartItems > 0)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    '$totalCartItems',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 12),
      ]
      ),
      body: carsAsync.when(
        // 1. Handled Data State
        data: (cars) => GridView.builder(
          padding: const EdgeInsets.all(16.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, 
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: cars.length,
          itemBuilder: (context, index) {
            final car = cars[index];
            return InkWell( // Wrap card with InkWell for click action
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CarDetails(car: car),
                  ),
                );
              },
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: car.imageUrl != null
                          ? Image.network(car.imageUrl!, fit: BoxFit.cover, width: double.infinity)
                          : const Center(child: Icon(Icons.directions_car, size: 50)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(car.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('₹${car.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
            );
          },

        ),
        // 2. Handled Loading State
        loading: () => const Center(child: CircularProgressIndicator()),
        // 3. Handled Error State
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
