import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:checkerchecks/providers/app_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Inventory Matching Tests', () {
    test('Finds exact match and partial match', () async {
      final provider = AppProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      // Exact match (default inventory has 'Sony A7 IV')
      final exactMatch = provider.findMatchingInventoryItem('Sony A7 IV', 'CAMERA');
      expect(exactMatch, isNotNull);
      expect(exactMatch!.name, 'Sony A7 IV');

      // Keyword match (default inventory has 'Tripod')
      final keywordMatch = provider.findMatchingInventoryItem('Carbon Tripod', 'SUPPORT');
      expect(keywordMatch, isNotNull);
      expect(keywordMatch!.name, 'Tripod');

      // Non-existent item
      final noMatch = provider.findMatchingInventoryItem('Underwater Housing Rig 8000', 'HOUSING');
      expect(noMatch, isNull);
    });

    test('Category count aggregation', () async {
      final provider = AppProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      final counts = provider.getCategoryCounts();
      expect(counts.containsKey('Cameras'), true);
      expect(counts.containsKey('Lenses'), true);
      expect(counts['Cameras']! >= 2, true);
      expect(counts['Lenses']! >= 3, true);
    });
  });
}
