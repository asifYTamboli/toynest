import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/car.dart';

// A FutureProvider cleanly manages async states (Loading, Data, Error) automatically
final carsListProvider = FutureProvider<List<Car>>((ref) async {
  final supabase = Supabase.instance.client;

  // Query table 'cars_inventory' and select all available records
  final List<dynamic> response = await supabase
      .from('cars_inventory')
      .select()
      .order('id', ascending: true);

  // Map the raw dynamic list maps into our typed CarItem model structure
  return response.map((json) => Car.fromJson(json as Map<String, dynamic>)).toList();
});
