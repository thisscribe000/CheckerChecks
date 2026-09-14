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

    test('Barcode assignment and lookup by barcode, serial number, and ID', () async {
      final provider = AppProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      final targetItem = provider.inventory.first;

      // Assign barcode
      provider.assignBarcodeToInventoryItem(targetItem.id, 'BARCODE-999');
      final updatedItem = provider.inventory.firstWhere((i) => i.id == targetItem.id);
      expect(updatedItem.barcode, 'BARCODE-999');

      // Lookup by barcode
      final foundByBarcode = provider.findInventoryItemByCode('BARCODE-999');
      expect(foundByBarcode, isNotNull);
      expect(foundByBarcode!.id, targetItem.id);

      // Lookup by case-insensitive barcode
      final foundCaseInsensitive = provider.findInventoryItemByCode('barcode-999');
      expect(foundCaseInsensitive, isNotNull);
      expect(foundCaseInsensitive!.id, targetItem.id);

      // Lookup by item ID
      final foundById = provider.findInventoryItemByCode(targetItem.id);
      expect(foundById, isNotNull);
      expect(foundById!.id, targetItem.id);

      // Lookup by serial number
      final itemWithSerial = provider.inventory.firstWhere((i) => i.serialNumber != null);
      final foundBySerial = provider.findInventoryItemByCode(itemWithSerial.serialNumber!);
      expect(foundBySerial, isNotNull);
      expect(foundBySerial!.id, itemWithSerial.id);

      // Non-existent code returns null
      final notFound = provider.findInventoryItemByCode('DOES-NOT-EXIST-404');
      expect(notFound, isNull);
    });

    test('Rental scan-to-return item verification workflow', () async {
      final provider = AppProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      final itemA = provider.inventory[0];
      final itemB = provider.inventory[1];

      provider.assignBarcodeToInventoryItem(itemA.id, 'A7IV-BARCODE-01');
      provider.assignBarcodeToInventoryItem(itemB.id, '2470-BARCODE-02');

      // Create a rental with 2 items
      final rental = provider.createRental(
        customerName: 'Marcus Cole',
        customerContact: 'marcus@lensrentals.test',
        startDate: '2026-09-12',
        expectedReturnDate: '2026-09-15',
        inventoryItemIds: [itemA.id, itemB.id],
      );

      expect(rental.verifiedReturnItemIds.isEmpty, true);
      expect(rental.isFullyVerified, false);
      expect(rental.verifiedCount, 0);

      // Scan first item
      final scanResultA = provider.verifyRentalItemReturn(rental.id, 'A7IV-BARCODE-01');
      expect(scanResultA, true);

      final updatedRental1 = provider.rentals.firstWhere((r) => r.id == rental.id);
      expect(updatedRental1.verifiedCount, 1);
      expect(updatedRental1.isItemVerified(itemA.id), true);
      expect(updatedRental1.isItemVerified(itemB.id), false);
      expect(updatedRental1.isFullyVerified, false);

      // Scan same item again (already verified, returns false)
      final scanDuplicate = provider.verifyRentalItemReturn(rental.id, 'A7IV-BARCODE-01');
      expect(scanDuplicate, false);

      // Scan item not in this rental (returns false)
      final scanWrongItem = provider.verifyRentalItemReturn(rental.id, 'NON-RENTED-CODE');
      expect(scanWrongItem, false);

      // Scan second item
      final scanResultB = provider.verifyRentalItemReturn(rental.id, '2470-BARCODE-02');
      expect(scanResultB, true);

      final updatedRental2 = provider.rentals.firstWhere((r) => r.id == rental.id);
      expect(updatedRental2.verifiedCount, 2);
      expect(updatedRental2.isFullyVerified, true);

      // Test manual toggle and reset
      provider.toggleRentalItemVerified(rental.id, itemA.id);
      final toggledRental = provider.rentals.firstWhere((r) => r.id == rental.id);
      expect(toggledRental.isItemVerified(itemA.id), false);

      provider.resetRentalVerification(rental.id);
      final resetRental = provider.rentals.firstWhere((r) => r.id == rental.id);
      expect(resetRental.verifiedCount, 0);
    });

    test('Client booking request receipt, approval, and decline workflow', () async {
      final provider = AppProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      // Clear any existing rentals for clean testing
      final item1 = provider.inventory[0];
      final item2 = provider.inventory[1];

      expect(item1.rentalStatus, 'Available');
      expect(item2.rentalStatus, 'Available');

      // 1. Receive a rental request via client booking link
      final request = provider.receiveRentalRequest(
        customerName: 'Elena Fisher',
        customerContact: 'elena@naughtydog.test',
        startDate: 'Oct 15, 2026',
        expectedReturnDate: 'Oct 18, 2026',
        inventoryItemIds: [item1.id, item2.id],
        projectShootName: 'Uncharted Documentary',
        notes: 'Needs morning pickup and fully charged batteries',
        bookingSource: 'link',
      );

      expect(request.status, 'Pending');
      expect(request.isPending, true);
      expect(request.isBookedViaLink, true);
      expect(request.projectShootName, 'Uncharted Documentary');
      expect(provider.pendingRentalsCount, 1);
      expect(provider.pendingRentals.first.id, request.id);

      // Verify that items are NOT locked to 'Rented Out' while still pending
      final pendingItem1 = provider.inventory.firstWhere((i) => i.id == item1.id);
      expect(pendingItem1.rentalStatus, 'Available');
      expect(pendingItem1.activeRentalId, isNull);

      // 2. Approve the rental request
      final approved = provider.approveRental(request.id);
      expect(approved, true);

      expect(provider.pendingRentalsCount, 0);
      expect(provider.activeRentals.length, 1);
      final activeRental = provider.activeRentals.first;
      expect(activeRental.id, request.id);
      expect(activeRental.status, 'Active');
      expect(activeRental.isActive, true);

      // Verify that items ARE now locked to 'Rented Out'
      final rentedItem1 = provider.inventory.firstWhere((i) => i.id == item1.id);
      final rentedItem2 = provider.inventory.firstWhere((i) => i.id == item2.id);
      expect(rentedItem1.rentalStatus, 'Rented Out');
      expect(rentedItem1.activeRentalId, request.id);
      expect(rentedItem2.rentalStatus, 'Rented Out');
      expect(rentedItem2.activeRentalId, request.id);

      // 3. Test Decline workflow on a second request
      final request2 = provider.receiveRentalRequest(
        customerName: 'Victor Sullivan',
        customerContact: 'sully@treasure.test',
        startDate: 'Nov 1, 2026',
        expectedReturnDate: 'Nov 3, 2026',
        inventoryItemIds: [item1.id],
        notes: 'Quick test shoot',
      );

      expect(provider.pendingRentalsCount, 1);
      provider.declineRental(request2.id, reason: 'Equipment booked for another production');

      expect(provider.pendingRentalsCount, 0);
      expect(provider.pastRentals.any((r) => r.id == request2.id), true);

      final declinedRental = provider.rentals.firstWhere((r) => r.id == request2.id);
      expect(declinedRental.status, 'Declined');
      expect(declinedRental.isDeclined, true);
      expect(declinedRental.notes?.contains('Declined: Equipment booked'), true);

      // 4. Test booking link generation
      final link = provider.getBookingLink();
      expect(link.startsWith('https://checkerchecks.app/rent/'), true);
    });
  });
}
