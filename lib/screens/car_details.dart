import 'package:flutter/material.dart';
import '../models/car.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Add this import
import '../providers/cart_provider.dart'; // Add this import

class CarDetails extends ConsumerStatefulWidget  {
  final Car car;
  const CarDetails({super.key, required this.car});

  @override
  ConsumerState<CarDetails> createState() => _CarDetailsState();
}

class _CarDetailsState extends ConsumerState<CarDetails> {
  // 1. Declare a PageController to drive the image transitions
  late final PageController _pageController;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    // Clean up the controller when the screen is closed to avoid memory leaks
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final car = widget.car;
    final gallery = car.galleryUrls ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(car.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Swipable Image Gallery
            if (gallery.isNotEmpty) ...[
              SizedBox(
                height: 300,
                child: PageView.builder(
                  controller: _pageController, // 2. Assign the controller here
                  itemCount: gallery.length,
                  onPageChanged: (index) => setState(() => _currentImageIndex = index),
                  itemBuilder: (context, index) {
                    return Image.network(gallery[index], fit: BoxFit.cover);
                  },
                ),
              ),
              const SizedBox(height: 8),
              // Interactive Navigation Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(gallery.length, (index) {
                  return InkWell( // 3. Wrap with InkWell to handle clicks on the dots
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0), // Expands the clickable area
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: _currentImageIndex == index ? 24 : 8, // Makes the active dot wider
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: _currentImageIndex == index
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade400,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ] else
              const SizedBox(
                height: 300,
                child: Center(child: Icon(Icons.directions_car, size: 100, color: Colors.grey)),
              ),

            // Pricing and Info Layout
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(car.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Brand: ${car.brand ?? "Generic"}', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('₹${car.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, color: Colors.green, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),

            // Technical Specifications
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Specifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Divider(),
                      _buildSpecRow('Voltage', car.voltage ?? '12V (Default)'),
                      _buildSpecRow('Parental Remote', car.remoteControl == true ? 'Yes' : 'No'),
                      _buildSpecRow('Available Colors', car.colors?.join(', ') ?? 'N/A'),
                      _buildSpecRow('Stock Status', (car.stockCount ?? 0) > 0 ? 'In Stock' : 'Out of Stock'),
                    ],
                  ),
                ),
              ),
            ),

            // Description Box
            if (car.description != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Product Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(car.description!, style: const TextStyle(fontSize: 16, height: 1.4)),
                  ],
                ),
              ),

            // Operational Action Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: (car.stockCount ?? 0) > 0
                      ? () {
                          // Read our global cart state and invoke the addCar script action
                          ref.read(cartProvider.notifier).addCar(car);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${car.name} added to cart!'),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      : null,
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('Add to Cart', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }
}