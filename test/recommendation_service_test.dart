import 'package:flutter_test/flutter_test.dart';
import 'package:checkerchecks/services/recommendation_service.dart';
import 'package:checkerchecks/models/inventory_item.dart';

void main() {
  group('RecommendationService Tests', () {
    final inventory = [
      InventoryItem(id: 'inv-1', name: 'Sony A7 IV', category: 'Cameras'),
      InventoryItem(id: 'inv-2', name: '24-70mm Lens', category: 'Lenses'),
      InventoryItem(id: 'inv-3', name: 'Tripod', category: 'Accessories'),
    ];

    test('Generates recommendations for Wedding Photography with inventory matching', () {
      final results = RecommendationService.instance.getRecommendations(
        gigType: 'Photography',
        gigSize: 'Small',
        gigLocation: 'Indoor',
        inventory: inventory,
      );

      expect(results.isNotEmpty, true);

      // Camera body should match Sony A7 IV in inventory
      final cameraRec = results.firstWhere((r) => r.name.toLowerCase().contains('camera'));
      expect(cameraRec.inInventory, true);
      expect(cameraRec.inventoryItemId, 'inv-1');
    });

    test('Adds outdoor extra recommendations when location is Outdoor', () {
      final outdoorResults = RecommendationService.instance.getRecommendations(
        gigType: 'Photography',
        gigSize: 'Large',
        gigLocation: 'Outdoor',
        inventory: inventory,
      );

      final hasOutdoorExtra = outdoorResults.any(
        (r) => r.name == 'Rain cover' || r.name == 'ND filter' || r.name == 'Extension cable',
      );
      expect(hasOutdoorExtra, true);
    });

    test('Converts results to persistent checklist items', () {
      final results = RecommendationService.instance.getRecommendations(
        gigType: 'Video',
        gigSize: 'Medium',
        gigLocation: 'Indoor',
        inventory: inventory,
      );

      final checklistItems = RecommendationService.instance.toChecklistItems(
        gigId: 'gig-test-123',
        results: results,
      );

      expect(checklistItems.length, results.length);
      expect(checklistItems.every((i) => i.gigId == 'gig-test-123'), true);
      expect(checklistItems.every((i) => !i.packed), true);
    });
  });
}
