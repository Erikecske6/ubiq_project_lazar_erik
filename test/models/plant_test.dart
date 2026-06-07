import 'package:flutter_test/flutter_test.dart';
import 'package:plant_app/data/models/plant.dart';

void main() {
  group('Plant Model', () {
    final fixedDate = DateTime(2026, 6, 6);

    final plant = Plant(
      name: 'Monstera',
      species: 'Deliciosa',
      notes: 'Near sunlight',
      wateringIntervalDays: 7,
      lastWateredAt: fixedDate.subtract(const Duration(days: 7)),
      isFavorite: false,
      createdAt: fixedDate,
      updatedAt: fixedDate,
    );

    test('nextWateringDate calculates correctly', () {
      expect(plant.nextWateringDate, fixedDate);
    });

    test('needsWaterToday can be calculated', () {
      expect(plant.needsWaterToday, isA<bool>());
    });

    test('copyWith updates fields', () {
      final updated = plant.copyWith(name: 'Fiddle Leaf');

      expect(updated.name, 'Fiddle Leaf');
      expect(updated.species, 'Deliciosa');
    });

    test('toMap and fromMap preserve data', () {
      final restored = Plant.fromMap(plant.toMap());

      expect(restored.name, plant.name);
      expect(restored.species, plant.species);
      expect(restored.notes, plant.notes);
      expect(restored.wateringIntervalDays, plant.wateringIntervalDays);
    });
  });
}