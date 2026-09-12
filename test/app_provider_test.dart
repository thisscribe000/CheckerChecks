import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:checkerchecks/providers/app_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AppProvider Tests', () {
    test('Initializes with default inventory and default wedding gig', () async {
      final provider = AppProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(provider.inventory.isNotEmpty, true);
      expect(provider.gigs.isNotEmpty, true);
      expect(provider.gigs.first.name, 'Wedding Shoot');
    });

    test('Add, update, and delete inventory item', () async {
      final provider = AppProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      final initialCount = provider.inventory.length;
      provider.addInventoryItem(
        name: 'DJI RS3 Gimbal',
        category: 'Accessories',
        quantity: 2,
        brand: 'DJI',
      );

      expect(provider.inventory.length, initialCount + 1);
      final added = provider.inventory.first;
      expect(added.name, 'DJI RS3 Gimbal');
      expect(added.quantity, 2);

      // Update item
      provider.updateInventoryItem(
        id: added.id,
        name: 'DJI RS3 Pro Gimbal',
        category: 'Accessories',
        quantity: 3,
        brand: 'DJI',
      );

      final updated = provider.inventory.firstWhere((i) => i.id == added.id);
      expect(updated.name, 'DJI RS3 Pro Gimbal');
      expect(updated.quantity, 3);

      // Delete item
      provider.deleteInventoryItem(added.id);
      expect(provider.inventory.any((i) => i.id == added.id), false);
    });

    test('Gig creation, update, reset, and deletion', () async {
      final provider = AppProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      final gig = provider.createGig(
        name: 'Corporate Headshots',
        type: 'Photography',
        size: 'Small',
        location: 'Indoor',
        date: 'Next Friday',
      );

      expect(provider.gigs.any((g) => g.id == gig.id), true);
      expect(gig.status, 'IN PREP');

      // Add item and toggle packed
      provider.addManualChecklistItem(
        gigId: gig.id,
        name: '50mm f/1.2',
        category: 'LENSES',
      );

      final updatedGig = provider.gigs.firstWhere((g) => g.id == gig.id);
      expect(updatedGig.items.length, 1);
      final itemId = updatedGig.items.first.id;

      provider.toggleChecklistItemPacked(gig.id, itemId);
      final packedGig = provider.gigs.firstWhere((g) => g.id == gig.id);
      expect(packedGig.items.first.packed, true);
      expect(packedGig.isReady, true);
      expect(packedGig.status, 'READY');

      // Reset checklist
      provider.resetGigChecklist(gig.id);
      final resetGig = provider.gigs.firstWhere((g) => g.id == gig.id);
      expect(resetGig.items.first.packed, false);
      expect(resetGig.status, 'IN PREP');

      // Update gig details
      provider.updateGig(
        id: gig.id,
        name: 'Corporate Executive Portraits',
        type: 'Photography',
        size: 'Medium',
        location: 'Both',
        date: 'Next Saturday',
      );

      final editedGig = provider.gigs.firstWhere((g) => g.id == gig.id);
      expect(editedGig.name, 'Corporate Executive Portraits');
      expect(editedGig.size, 'Medium');

      // Delete gig
      provider.deleteGig(gig.id);
      expect(provider.gigs.any((g) => g.id == gig.id), false);
    });

    test('Quick-add missing item from checklist resolves missing flag', () async {
      final provider = AppProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      final gig = provider.createGig(
        name: 'Podcast Interview',
        type: 'Audio',
        size: 'Small',
        location: 'Indoor',
        date: 'Today',
      );

      // Add an item that is definitely not in inventory
      provider.addManualChecklistItem(
        gigId: gig.id,
        name: 'Shure SM7B Special Edition',
        category: 'AUDIO',
      );

      final gigAfterAdd = provider.gigs.firstWhere((g) => g.id == gig.id);
      final item = gigAfterAdd.items.first;
      expect(item.isMissingFromInventory, true);

      // Quick-add to inventory
      final createdInv = provider.quickAddInventoryItemFromChecklist(
        gigId: gig.id,
        checklistItemId: item.id,
        name: item.name,
        category: item.category,
      );

      expect(createdInv.name, 'Shure SM7B Special Edition');
      expect(createdInv.category, 'Audio');

      final refreshedGig = provider.gigs.firstWhere((g) => g.id == gig.id);
      final refreshedItem = refreshedGig.items.first;
      expect(refreshedItem.isMissingFromInventory, false);
      expect(refreshedItem.inventoryItemId, createdInv.id);
    });

    test('Rental creation, completion, and inventory status updates', () async {
      final provider = AppProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      final itemToRent = provider.inventory.first;
      
      expect(itemToRent.rentalStatus, 'Available');
      expect(itemToRent.activeRentalId, null);

      // Create a rental
      final rental = provider.createRental(
        customerName: 'Alice',
        customerContact: 'alice@test.com',
        startDate: 'Today',
        expectedReturnDate: 'Tomorrow',
        inventoryItemIds: [itemToRent.id],
      );

      expect(provider.rentals.length, 1);
      expect(rental.status, 'Active');

      // Check inventory status updated
      final rentedItem = provider.inventory.firstWhere((i) => i.id == itemToRent.id);
      expect(rentedItem.rentalStatus, 'Rented Out');
      expect(rentedItem.activeRentalId, rental.id);

      // Complete rental
      provider.completeRental(rental.id);
      
      final returnedRental = provider.rentals.firstWhere((r) => r.id == rental.id);
      expect(returnedRental.status, 'Returned');

      // Check inventory status restored
      final returnedItem = provider.inventory.firstWhere((i) => i.id == itemToRent.id);
      expect(returnedItem.rentalStatus, 'Available');
      expect(returnedItem.activeRentalId, null);
    });

    test('Profile update, cloud sync toggle, and JSON export/import', () async {
      final provider = AppProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      // Test profile update
      provider.updateProfile(
        name: 'Jordan Lee',
        email: 'jordan@filmmaker.io',
        role: 'Filmmaker',
      );
      expect(provider.userName, 'Jordan Lee');
      expect(provider.userEmail, 'jordan@filmmaker.io');
      expect(provider.userRole, 'Filmmaker');

      // Test cloud sync toggle
      expect(provider.cloudSyncEnabled, true);
      provider.toggleCloudSync(false);
      expect(provider.cloudSyncEnabled, false);

      // Test export
      final jsonOutput = provider.exportDataAsJson();
      expect(jsonOutput.contains('Jordan Lee'), true);
      expect(jsonOutput.contains('CheckerChecks'), true);

      // Test import
      final newJson = '''
      {
        "app": "CheckerChecks",
        "profile": {
          "name": "Sam Taylor",
          "email": "sam@studio.org",
          "role": "Audio"
        },
        "inventory": [
          {
            "id": "imported-1",
            "name": "Sennheiser MKH 416",
            "category": "Audio",
            "quantity": 1
          }
        ],
        "gigs": [],
        "rentals": []
      }
      ''';
      final success = provider.importDataFromJson(newJson);
      expect(success, true);
      expect(provider.userName, 'Sam Taylor');
      expect(provider.inventory.length, 1);
      expect(provider.inventory.first.name, 'Sennheiser MKH 416');

      // Test reset to defaults
      provider.resetToDefaults();
      expect(provider.inventory.length, 10);
      expect(provider.gigs.length, 1);
    });
  });
}
