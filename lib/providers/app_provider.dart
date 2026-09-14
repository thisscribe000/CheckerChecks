import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/inventory_item.dart';
import '../models/gig.dart';
import '../models/checklist_item.dart';
import '../models/rental.dart';
import '../services/firebase_sync_service.dart';

class AppProvider with ChangeNotifier {
  bool _onboardingCompleted = false;
  String _userRole = 'Photography';
  String _userName = 'Alex Mercer';
  String _userEmail = 'alex.mercer@creative.studio';
  bool _cloudSyncEnabled = true;
  List<InventoryItem> _inventory = [];
  List<Gig> _gigs = [];
  List<Rental> _rentals = [];
  Gig? _activeGig;

  bool get onboardingCompleted => _onboardingCompleted;
  String get userRole => _userRole;
  String get userName => _userName;
  String get userEmail => _userEmail;
  bool get cloudSyncEnabled => _cloudSyncEnabled;
  List<InventoryItem> get inventory => _inventory;
  List<Gig> get gigs => _gigs;
  List<Rental> get rentals => _rentals;
  List<Rental> get pendingRentals => _rentals.where((r) => r.status == 'Pending').toList();
  List<Rental> get activeRentals => _rentals.where((r) => r.status == 'Active').toList();
  List<Rental> get pastRentals => _rentals.where((r) => r.status == 'Returned' || r.status == 'Declined').toList();
  int get pendingRentalsCount => pendingRentals.length;
  List<InventoryItem> get availableInventory => _inventory.where((i) => i.rentalStatus == 'Available').toList();

  String getBookingLink() {
    final slug = _userName.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    final cleanSlug = slug.isEmpty ? 'studio' : slug;
    return 'https://checkerchecks.app/rent/$cleanSlug';
  }
  Gig? get activeGig {
    if (_activeGig != null) {
      final found = _gigs.where((g) => g.id == _activeGig!.id).toList();
      if (found.isNotEmpty) return found.first;
    }
    return _gigs.isNotEmpty ? _gigs.first : null;
  }

  Gig? get nextGig {
    final upcoming = _gigs.where((g) => g.status != 'COMPLETED').toList();
    return upcoming.isNotEmpty ? upcoming.first : null;
  }

  AppProvider() {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    _onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
    _userRole = prefs.getString('user_role') ?? 'Photography';

    _userName = prefs.getString('user_name') ?? 'Alex Mercer';
    _userEmail = prefs.getString('user_email') ?? 'alex.mercer@creative.studio';
    _cloudSyncEnabled = prefs.getBool('cloud_sync_enabled') ?? true;

    final inventoryString = prefs.getString('inventory_data');
    if (inventoryString != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(inventoryString);
        _inventory = jsonList.map((item) => InventoryItem.fromJson(item)).toList();
      } catch (_) {
        _populateDefaultInventory();
      }
    } else {
      _populateDefaultInventory();
    }

    final gigsString = prefs.getString('gigs_data');
    if (gigsString != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(gigsString);
        _gigs = jsonList.map((item) => Gig.fromJson(item)).toList();
      } catch (_) {
        _populateDefaultGigs();
      }
    } else {
      _populateDefaultGigs();
    }

    final rentalsString = prefs.getString('rentals_data');
    if (rentalsString != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(rentalsString);
        _rentals = jsonList.map((item) => Rental.fromJson(item)).toList();
      } catch (_) {
        _rentals = [];
      }
    } else {
      _rentals = [];
    }

    _refreshInventoryMatchingForAllGigs();
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', _onboardingCompleted);
    await prefs.setString('user_role', _userRole);
    await prefs.setString('user_name', _userName);
    await prefs.setString('user_email', _userEmail);
    await prefs.setBool('cloud_sync_enabled', _cloudSyncEnabled);
    final inventoryJson = jsonEncode(_inventory.map((i) => i.toJson()).toList());
    await prefs.setString('inventory_data', inventoryJson);
    final gigsJson = jsonEncode(_gigs.map((g) => g.toJson()).toList());
    await prefs.setString('gigs_data', gigsJson);
    final rentalsJson = jsonEncode(_rentals.map((r) => r.toJson()).toList());
    await prefs.setString('rentals_data', rentalsJson);

    // Fire off the background sync to Firebase only if enabled
    if (_cloudSyncEnabled) {
      FirebaseSyncService.syncAll(_inventory, _gigs, _rentals);
    }
  }

  void _populateDefaultInventory() {
    _inventory = [
      InventoryItem(id: 'inv-1', name: 'Sony A7 IV', category: 'Cameras', quantity: 1, brand: 'Sony', serialNumber: 'SN: SONY-A7IV-001'),
      InventoryItem(id: 'inv-2', name: 'Canon R5', category: 'Cameras', quantity: 1, brand: 'Canon', serialNumber: 'SN: CANON-R5-002'),
      InventoryItem(id: 'inv-3', name: '24-70mm f/2.8 Lens', category: 'Lenses', quantity: 1, brand: 'Sony', serialNumber: 'E-Mount · Zoom'),
      InventoryItem(id: 'inv-4', name: '35mm f/1.4 Lens', category: 'Lenses', quantity: 1, brand: 'Sony', serialNumber: 'E-Mount · Prime'),
      InventoryItem(id: 'inv-5', name: '85mm f/1.8 Lens', category: 'Lenses', quantity: 1, brand: 'Sony', serialNumber: 'E-Mount · Prime'),
      InventoryItem(id: 'inv-6', name: 'Wireless Microphone', category: 'Audio', quantity: 1, brand: 'DJI', notes: '2× Tx, 1× Rx'),
      InventoryItem(id: 'inv-7', name: 'Tripod', category: 'Accessories', quantity: 2, brand: 'Manfrotto'),
      InventoryItem(id: 'inv-8', name: 'LED Light', category: 'Lighting', quantity: 2, brand: 'Aputure'),
      InventoryItem(id: 'inv-9', name: 'Battery Pack', category: 'Power', quantity: 3, brand: 'SmallRig'),
      InventoryItem(id: 'inv-10', name: 'SD Card 128GB', category: 'Accessories', quantity: 4, brand: 'SanDisk'),
    ];
  }

  void _populateDefaultGigs() {
    final gig1 = Gig(
      id: 'gig-1',
      name: 'Wedding Shoot',
      type: 'Photography',
      date: 'Tomorrow · 2:00 PM',
      location: 'Indoor & Outdoor',
      size: 'Medium',
      status: 'IN PREP',
      items: [
        ChecklistItem(id: 'c1', gigId: 'gig-1', name: 'Sony A7 IV', category: 'CAMERA', packed: true, inventoryItemId: 'inv-1', source: 'template'),
        ChecklistItem(id: 'c2', gigId: 'gig-1', name: '24-70mm Lens', category: 'CAMERA', packed: true, inventoryItemId: 'inv-3', source: 'template'),
        ChecklistItem(id: 'c3', gigId: 'gig-1', name: '35mm Lens', category: 'CAMERA', packed: true, inventoryItemId: 'inv-4', source: 'template'),
        ChecklistItem(id: 'c4', gigId: 'gig-1', name: '85mm Lens', category: 'CAMERA', packed: true, inventoryItemId: 'inv-5', source: 'template'),
        ChecklistItem(id: 'c5', gigId: 'gig-1', name: 'Wireless Microphone', category: 'AUDIO', packed: true, inventoryItemId: 'inv-6', source: 'template'),
        ChecklistItem(id: 'c6', gigId: 'gig-1', name: 'LED Light', category: 'LIGHTING', packed: true, inventoryItemId: 'inv-8', source: 'template'),
        ChecklistItem(id: 'c7', gigId: 'gig-1', name: 'Battery Pack', category: 'POWER', packed: true, inventoryItemId: 'inv-9', source: 'template'),
        ChecklistItem(id: 'c8', gigId: 'gig-1', name: 'SD Card 128GB', category: 'ACCESSORIES', packed: true, inventoryItemId: 'inv-10', source: 'template'),
        ChecklistItem(id: 'c9', gigId: 'gig-1', name: 'Tripod', category: 'ACCESSORIES', packed: true, inventoryItemId: 'inv-7', source: 'template'),
        ChecklistItem(id: 'c10', gigId: 'gig-1', name: 'Spare battery', category: 'POWER', packed: false, isMissingFromInventory: true, source: 'template'),
        ChecklistItem(id: 'c11', gigId: 'gig-1', name: 'Extra SD card', category: 'ACCESSORIES', packed: false, isMissingFromInventory: true, source: 'template'),
        ChecklistItem(id: 'c12', gigId: 'gig-1', name: 'Audio recorder', category: 'AUDIO', packed: false, isMissingFromInventory: true, source: 'template'),
        ChecklistItem(id: 'c13', gigId: 'gig-1', name: 'Extension cable', category: 'POWER', packed: false, isMissingFromInventory: true, source: 'template'),
        ChecklistItem(id: 'c14', gigId: 'gig-1', name: 'Canon R5 (Backup)', category: 'CAMERA', packed: true, inventoryItemId: 'inv-2', source: 'template'),
      ],
    );
    _gigs = [gig1];
  }

  // ── Inventory matching ───────────────────────────────────────────────────

  void _refreshInventoryMatchingForAllGigs() {
    for (final gig in _gigs) {
      for (final item in gig.items) {
        // Only re-check items that don't already have an explicit inventoryItemId
        if (item.inventoryItemId == null) {
          final match = findMatchingInventoryItem(item.name, item.category);
          item.isMissingFromInventory = match == null;
        } else {
          // Verify the referenced item still exists
          final exists = _inventory.any((inv) => inv.id == item.inventoryItemId);
          item.isMissingFromInventory = !exists;
        }
      }
    }
  }

  InventoryItem? findMatchingInventoryItem(String name, String category) {
    final nameLower = name.toLowerCase();
    final catLower = category.toLowerCase();

    for (final inv in _inventory) {
      final invName = inv.name.toLowerCase();
      final invCat = inv.category.toLowerCase();

      // Exact substring match (either direction)
      if (invName.contains(nameLower) || nameLower.contains(invName)) return inv;

      // Key word match (words longer than 3 chars)
      final words = nameLower.split(RegExp(r'[\s\-\/()]+'));
      for (final word in words) {
        if (word.length > 3 && invName.contains(word)) return inv;
      }

      // Loose category match — only when name echoes category
      if ((invCat.contains(catLower) || catLower.contains(invCat)) &&
          nameLower.contains(invCat.replaceAll('s', ''))) {
        return inv;
      }
    }
    return null;
  }

  // ── Onboarding ───────────────────────────────────────────────────────────

  void completeOnboarding(String role) {
    _onboardingCompleted = true;
    _userRole = role;
    _saveData();
    notifyListeners();
  }

  // ── Profile & Settings ─────────────────────────────────────────────────────

  void updateProfile({
    required String name,
    required String email,
    required String role,
  }) {
    _userName = name;
    _userEmail = email;
    _userRole = role;
    _saveData();
    notifyListeners();
  }

  void toggleCloudSync(bool enabled) {
    _cloudSyncEnabled = enabled;
    _saveData();
    notifyListeners();
  }

  String exportDataAsJson() {
    final data = {
      'app': 'CheckerChecks',
      'version': '1.0.0+1',
      'exportedAt': DateTime.now().toIso8601String(),
      'profile': {
        'name': _userName,
        'email': _userEmail,
        'role': _userRole,
      },
      'inventory': _inventory.map((i) => i.toJson()).toList(),
      'gigs': _gigs.map((g) => g.toJson()).toList(),
      'rentals': _rentals.map((r) => r.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  bool importDataFromJson(String jsonString) {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonString);
      if (data.containsKey('profile') && data['profile'] is Map) {
        final profile = data['profile'] as Map<String, dynamic>;
        if (profile['name'] != null) _userName = profile['name'].toString();
        if (profile['email'] != null) _userEmail = profile['email'].toString();
        if (profile['role'] != null) _userRole = profile['role'].toString();
      }
      if (data.containsKey('inventory') && data['inventory'] is List) {
        final invList = data['inventory'] as List<dynamic>;
        _inventory = invList.map((i) => InventoryItem.fromJson(i)).toList();
      }
      if (data.containsKey('gigs') && data['gigs'] is List) {
        final gigsList = data['gigs'] as List<dynamic>;
        _gigs = gigsList.map((g) => Gig.fromJson(g)).toList();
      }
      if (data.containsKey('rentals') && data['rentals'] is List) {
        final rentalsList = data['rentals'] as List<dynamic>;
        _rentals = rentalsList.map((r) => Rental.fromJson(r)).toList();
      }
      _refreshInventoryMatchingForAllGigs();
      _saveData();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error importing data: $e");
      return false;
    }
  }

  void resetToDefaults() {
    _populateDefaultInventory();
    _populateDefaultGigs();
    _rentals = [];
    _refreshInventoryMatchingForAllGigs();
    _saveData();
    notifyListeners();
  }

  // ── Active gig ───────────────────────────────────────────────────────────

  void setActiveGig(Gig gig) {
    _activeGig = gig;
    notifyListeners();
  }

  // ── Inventory CRUD ────────────────────────────────────────────────────────

  void addInventoryItem({
    required String name,
    required String category,
    int quantity = 1,
    String? brand,
    String? notes,
    String? serialNumber,
    String? barcode,
  }) {
    final newItem = InventoryItem(
      id: 'inv-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      category: category,
      quantity: quantity,
      brand: brand,
      notes: notes,
      serialNumber: serialNumber,
      barcode: barcode,
    );
    _inventory.insert(0, newItem);
    _refreshInventoryMatchingForAllGigs();
    _saveData();
    notifyListeners();
  }

  void updateInventoryItem({
    required String id,
    required String name,
    required String category,
    int quantity = 1,
    String? brand,
    String? notes,
    String? serialNumber,
    String? barcode,
  }) {
    final index = _inventory.indexWhere((i) => i.id == id);
    if (index != -1) {
      _inventory[index] = _inventory[index].copyWith(
        name: name,
        category: category,
        quantity: quantity,
        brand: brand,
        notes: notes,
        serialNumber: serialNumber,
        barcode: barcode,
      );
      _refreshInventoryMatchingForAllGigs();
      _saveData();
      notifyListeners();
    }
  }

  void assignBarcodeToInventoryItem(String id, String barcode) {
    final index = _inventory.indexWhere((i) => i.id == id);
    if (index != -1) {
      _inventory[index] = _inventory[index].copyWith(barcode: barcode);
      _saveData();
      notifyListeners();
    }
  }

  InventoryItem? findInventoryItemByCode(String rawCode) {
    final code = rawCode.trim().toLowerCase();
    if (code.isEmpty) return null;

    for (final item in _inventory) {
      if (item.barcode != null && item.barcode!.trim().toLowerCase() == code) {
        return item;
      }
      if (item.serialNumber != null && item.serialNumber!.trim().toLowerCase() == code) {
        return item;
      }
      if (item.id.toLowerCase() == code) {
        return item;
      }
    }
    return null;
  }

  void deleteInventoryItem(String id) {
    _inventory.removeWhere((i) => i.id == id);
    _refreshInventoryMatchingForAllGigs();
    _saveData();
    notifyListeners();
  }

  /// Quick-adds a missing checklist item to inventory and links it immediately.
  InventoryItem quickAddInventoryItemFromChecklist({
    required String gigId,
    required String checklistItemId,
    required String name,
    required String category,
  }) {
    // Format category nicely (e.g., "CAMERA" -> "Cameras", "POWER" -> "Power")
    String formattedCat = 'Other';
    const catMap = {
      'CAMERA': 'Cameras',
      'CAMERAS': 'Cameras',
      'LENSES': 'Lenses',
      'LENS': 'Lenses',
      'AUDIO': 'Audio',
      'LIGHTING': 'Lighting',
      'POWER': 'Power',
      'ACCESSORIES': 'Accessories',
      'SUPPORT': 'Accessories',
      'TOOLS': 'Tools',
      'SWITCHER': 'Other',
    };
    final upperCat = category.toUpperCase().trim();
    if (catMap.containsKey(upperCat)) {
      formattedCat = catMap[upperCat]!;
    } else {
      formattedCat = category.length > 1
          ? category[0].toUpperCase() + category.substring(1).toLowerCase()
          : category;
    }

    final newItem = InventoryItem(
      id: 'inv-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      category: formattedCat,
      quantity: 1,
    );
    _inventory.insert(0, newItem);

    // Directly link this item in the gig checklist
    final gigIndex = _gigs.indexWhere((g) => g.id == gigId);
    if (gigIndex != -1) {
      final itemIndex = _gigs[gigIndex].items.indexWhere((i) => i.id == checklistItemId);
      if (itemIndex != -1) {
        _gigs[gigIndex].items[itemIndex] = _gigs[gigIndex].items[itemIndex].copyWith(
          inventoryItemId: newItem.id,
          isMissingFromInventory: false,
        );
      }
    }

    _refreshInventoryMatchingForAllGigs();
    _saveData();
    notifyListeners();
    return newItem;
  }

  // ── Gig CRUD ──────────────────────────────────────────────────────────────

  Gig createGig({
    required String name,
    required String type,
    required String size,
    required String location,
    required String date,
  }) {
    final newGig = Gig(
      id: 'gig-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      type: type,
      size: size,
      location: location,
      date: date.isNotEmpty ? date : 'Upcoming',
      status: 'IN PREP',
      items: [],
    );
    _gigs.insert(0, newGig);
    _activeGig = newGig;
    _saveData();
    notifyListeners();
    return newGig;
  }

  void updateGig({
    required String id,
    required String name,
    required String type,
    required String size,
    required String location,
    required String date,
  }) {
    final index = _gigs.indexWhere((g) => g.id == id);
    if (index != -1) {
      _gigs[index] = _gigs[index].copyWith(
        name: name,
        type: type,
        size: size,
        location: location,
        date: date,
      );
      if (_activeGig?.id == id) _activeGig = _gigs[index];
      _saveData();
      notifyListeners();
    }
  }

  void deleteGig(String id) {
    _gigs.removeWhere((g) => g.id == id);
    if (_activeGig?.id == id) {
      _activeGig = _gigs.isNotEmpty ? _gigs.first : null;
    }
    _saveData();
    notifyListeners();
  }

  void resetGigChecklist(String gigId) {
    final index = _gigs.indexWhere((g) => g.id == gigId);
    if (index != -1) {
      for (final item in _gigs[index].items) {
        item.packed = false;
      }
      _gigs[index].status = 'IN PREP';
      if (_activeGig?.id == gigId) _activeGig = _gigs[index];
      _saveData();
      notifyListeners();
    }
  }

  void markGigCompleted(String gigId) {
    final index = _gigs.indexWhere((g) => g.id == gigId);
    if (index != -1) {
      _gigs[index].status = 'COMPLETED';
      _saveData();
      notifyListeners();
    }
  }

  void reopenGig(String gigId) {
    final index = _gigs.indexWhere((g) => g.id == gigId);
    if (index != -1) {
      _updateGigStatus(index);
      _saveData();
      notifyListeners();
    }
  }

  // ── Checklist CRUD ────────────────────────────────────────────────────────

  void addManualChecklistItem({
    required String gigId,
    required String name,
    required String category,
  }) {
    final gigIndex = _gigs.indexWhere((g) => g.id == gigId);
    if (gigIndex == -1) return;
    final match = findMatchingInventoryItem(name, category);
    final newItem = ChecklistItem(
      id: 'c-${DateTime.now().millisecondsSinceEpoch}',
      gigId: gigId,
      name: name,
      category: category.toUpperCase(),
      source: 'manual',
      inventoryItemId: match?.id,
      packed: false,
      isMissingFromInventory: match == null,
    );
    _gigs[gigIndex].items.add(newItem);
    _updateGigStatus(gigIndex);
    _saveData();
    notifyListeners();
  }

  void addItemsToGigChecklist(String gigId, List<ChecklistItem> newItems) {
    final index = _gigs.indexWhere((g) => g.id == gigId);
    if (index == -1) return;
    // Re-run inventory matching before persisting
    for (final item in newItems) {
      if (item.inventoryItemId != null) {
        final exists = _inventory.any((inv) => inv.id == item.inventoryItemId);
        item.isMissingFromInventory = !exists;
      } else {
        final match = findMatchingInventoryItem(item.name, item.category);
        item.isMissingFromInventory = match == null;
      }
    }
    _gigs[index].items.addAll(newItems);
    _updateGigStatus(index);
    if (_activeGig?.id == gigId) _activeGig = _gigs[index];
    _saveData();
    notifyListeners();
  }

  void toggleChecklistItemPacked(String gigId, String itemId) {
    final gigIndex = _gigs.indexWhere((g) => g.id == gigId);
    if (gigIndex == -1) return;
    final itemIndex = _gigs[gigIndex].items.indexWhere((i) => i.id == itemId);
    if (itemIndex == -1) return;
    _gigs[gigIndex].items[itemIndex].packed = !_gigs[gigIndex].items[itemIndex].packed;
    _updateGigStatus(gigIndex);
    if (_activeGig?.id == gigId) _activeGig = _gigs[gigIndex];
    _saveData();
    notifyListeners();
  }

  void deleteChecklistItem(String gigId, String itemId) {
    final gigIndex = _gigs.indexWhere((g) => g.id == gigId);
    if (gigIndex == -1) return;
    _gigs[gigIndex].items.removeWhere((i) => i.id == itemId);
    _updateGigStatus(gigIndex);
    if (_activeGig?.id == gigId) _activeGig = _gigs[gigIndex];
    _saveData();
    notifyListeners();
  }

  void _updateGigStatus(int gigIndex) {
    final gig = _gigs[gigIndex];
    if (gig.isReady) {
      gig.status = 'READY';
    } else if (gig.status == 'READY') {
      gig.status = 'IN PREP';
    }
  }

  void reorderChecklistItems(String gigId, int oldIndex, int newIndex) {
    final gigIndex = _gigs.indexWhere((g) => g.id == gigId);
    if (gigIndex == -1) return;
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _gigs[gigIndex].items.removeAt(oldIndex);
    _gigs[gigIndex].items.insert(newIndex, item);
    if (_activeGig?.id == gigId) _activeGig = _gigs[gigIndex];
    _saveData();
    notifyListeners();
  }

  // ── Category counts for inventory screen ─────────────────────────────────

  Map<String, int> getCategoryCounts() {
    final map = <String, int>{
      'Cameras': 0,
      'Lenses': 0,
      'Audio': 0,
      'Lighting': 0,
      'Power': 0,
      'Accessories': 0,
      'Tools': 0,
      'Other': 0,
    };
    for (final item in _inventory) {
      final cat = item.category;
      if (map.containsKey(cat)) {
        map[cat] = map[cat]! + item.quantity;
      } else {
        bool matched = false;
        for (final key in map.keys) {
          if (key.toLowerCase() == cat.toLowerCase()) {
            map[key] = map[key]! + item.quantity;
            matched = true;
            break;
          }
        }
        if (!matched) map['Other'] = map['Other']! + item.quantity;
      }
    }
    return map;
  }

  // ── Rental CRUD ───────────────────────────────────────────────────────────

  Rental createRental({
    required String customerName,
    required String customerContact,
    required String startDate,
    required String expectedReturnDate,
    required List<String> inventoryItemIds,
    String? notes,
  }) {
    final newRental = Rental(
      id: 'rental-${DateTime.now().millisecondsSinceEpoch}',
      customerName: customerName,
      customerContact: customerContact,
      startDate: startDate,
      expectedReturnDate: expectedReturnDate,
      inventoryItemIds: inventoryItemIds,
      notes: notes,
      status: 'Active',
    );
    _rentals.insert(0, newRental);

    // Update inventory items to 'Rented Out'
    for (final itemId in inventoryItemIds) {
      final index = _inventory.indexWhere((i) => i.id == itemId);
      if (index != -1) {
        _inventory[index] = _inventory[index].copyWith(
          rentalStatus: 'Rented Out',
          activeRentalId: newRental.id,
        );
      }
    }

    _saveData();
    notifyListeners();
    return newRental;
  }

  void updateRental({
    required String id,
    required String customerName,
    required String customerContact,
    required String startDate,
    required String expectedReturnDate,
    String? notes,
  }) {
    final index = _rentals.indexWhere((r) => r.id == id);
    if (index != -1) {
      _rentals[index] = _rentals[index].copyWith(
        customerName: customerName,
        customerContact: customerContact,
        startDate: startDate,
        expectedReturnDate: expectedReturnDate,
        notes: notes,
      );
      _saveData();
      notifyListeners();
    }
  }

  Rental receiveRentalRequest({
    required String customerName,
    required String customerContact,
    required String startDate,
    required String expectedReturnDate,
    required List<String> inventoryItemIds,
    String? projectShootName,
    String? notes,
    String bookingSource = 'link',
  }) {
    final newRequest = Rental(
      id: 'req-${DateTime.now().millisecondsSinceEpoch}',
      customerName: customerName,
      customerContact: customerContact,
      startDate: startDate,
      expectedReturnDate: expectedReturnDate,
      inventoryItemIds: inventoryItemIds,
      projectShootName: projectShootName,
      notes: notes,
      status: 'Pending',
      bookingSource: bookingSource,
    );
    _rentals.insert(0, newRequest);
    _saveData();
    notifyListeners();
    return newRequest;
  }

  bool approveRental(String rentalId) {
    final index = _rentals.indexWhere((r) => r.id == rentalId);
    if (index == -1) return false;

    final rental = _rentals[index];
    _rentals[index] = rental.copyWith(status: 'Active');

    // Update all assigned inventory items to 'Rented Out'
    for (final itemId in rental.inventoryItemIds) {
      final invIndex = _inventory.indexWhere((i) => i.id == itemId);
      if (invIndex != -1) {
        _inventory[invIndex] = _inventory[invIndex].copyWith(
          rentalStatus: 'Rented Out',
          activeRentalId: rental.id,
        );
      }
    }

    _saveData();
    notifyListeners();
    return true;
  }

  void declineRental(String rentalId, {String? reason}) {
    final index = _rentals.indexWhere((r) => r.id == rentalId);
    if (index == -1) return;

    final rental = _rentals[index];
    String updatedNotes = rental.notes ?? '';
    if (reason != null && reason.trim().isNotEmpty) {
      updatedNotes = updatedNotes.isEmpty
          ? 'Declined: $reason'
          : '$updatedNotes (Declined: $reason)';
    }

    _rentals[index] = rental.copyWith(
      status: 'Declined',
      notes: updatedNotes.isEmpty ? null : updatedNotes,
    );

    _saveData();
    notifyListeners();
  }

  bool verifyRentalItemReturn(String rentalId, String codeOrId) {
    final rentalIndex = _rentals.indexWhere((r) => r.id == rentalId);
    if (rentalIndex == -1) return false;

    final rental = _rentals[rentalIndex];
    final trimmedCode = codeOrId.trim().toLowerCase();

    // Check if code matches any item assigned to this rental
    String? matchedItemId;
    for (final itemId in rental.inventoryItemIds) {
      if (itemId.toLowerCase() == trimmedCode) {
        matchedItemId = itemId;
        break;
      }
      final invItem = _inventory.firstWhere(
        (i) => i.id == itemId,
        orElse: () => InventoryItem(id: '', name: '', category: ''),
      );
      if (invItem.id.isNotEmpty) {
        if (invItem.barcode != null && invItem.barcode!.trim().toLowerCase() == trimmedCode) {
          matchedItemId = itemId;
          break;
        }
        if (invItem.serialNumber != null && invItem.serialNumber!.trim().toLowerCase() == trimmedCode) {
          matchedItemId = itemId;
          break;
        }
      }
    }

    if (matchedItemId != null) {
      if (!rental.verifiedReturnItemIds.contains(matchedItemId)) {
        final updatedVerified = List<String>.from(rental.verifiedReturnItemIds)..add(matchedItemId);
        _rentals[rentalIndex] = rental.copyWith(verifiedReturnItemIds: updatedVerified);
        _saveData();
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  void toggleRentalItemVerified(String rentalId, String itemId) {
    final rentalIndex = _rentals.indexWhere((r) => r.id == rentalId);
    if (rentalIndex == -1) return;

    final rental = _rentals[rentalIndex];
    final updatedVerified = List<String>.from(rental.verifiedReturnItemIds);
    if (updatedVerified.contains(itemId)) {
      updatedVerified.remove(itemId);
    } else {
      updatedVerified.add(itemId);
    }
    _rentals[rentalIndex] = rental.copyWith(verifiedReturnItemIds: updatedVerified);
    _saveData();
    notifyListeners();
  }

  void resetRentalVerification(String rentalId) {
    final rentalIndex = _rentals.indexWhere((r) => r.id == rentalId);
    if (rentalIndex != -1) {
      _rentals[rentalIndex] = _rentals[rentalIndex].copyWith(verifiedReturnItemIds: []);
      _saveData();
      notifyListeners();
    }
  }

  void completeRental(String rentalId) {
    final index = _rentals.indexWhere((r) => r.id == rentalId);
    if (index != -1) {
      _rentals[index] = _rentals[index].copyWith(status: 'Returned');
      
      // Update inventory items back to 'Available'
      for (final itemId in _rentals[index].inventoryItemIds) {
        final invIndex = _inventory.indexWhere((i) => i.id == itemId);
        if (invIndex != -1 && _inventory[invIndex].activeRentalId == rentalId) {
          _inventory[invIndex] = _inventory[invIndex].copyWith(
            rentalStatus: 'Available',
            clearActiveRentalId: true, // Clear active rental ID
          );
        }
      }

      _saveData();
      notifyListeners();
    }
  }

  void deleteRental(String rentalId) {
    final index = _rentals.indexWhere((r) => r.id == rentalId);
    if (index != -1) {
      // If deleting an active rental, free the inventory items
      if (_rentals[index].status == 'Active') {
        for (final itemId in _rentals[index].inventoryItemIds) {
          final invIndex = _inventory.indexWhere((i) => i.id == itemId);
          if (invIndex != -1 && _inventory[invIndex].activeRentalId == rentalId) {
            _inventory[invIndex] = _inventory[invIndex].copyWith(
              rentalStatus: 'Available',
              clearActiveRentalId: true,
            );
          }
        }
      }
      _rentals.removeAt(index);
      _saveData();
      notifyListeners();
    }
  }
}
