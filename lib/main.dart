import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/cars_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kids Ride-On Cars Store'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
            return Card(
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
                    child: Text(car.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('\$${car.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green)),
                  ),
                ],
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
