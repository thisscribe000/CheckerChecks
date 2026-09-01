import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/inventory_item.dart';
import '../models/gig.dart';
import '../models/rental.dart';

class FirebaseSyncService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> syncAll(
    List<InventoryItem> inventory,
    List<Gig> gigs,
    List<Rental> rentals,
  ) async {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint("FirebaseSyncService: No user signed in, skipping sync.");
      return;
    }

    final uid = user.uid;
    
    try {
      final userDoc = _db.collection('users').doc(uid);
      
      // Write Inventory
      final inventoryBatch = _db.batch();
      for (final item in inventory) {
        final docRef = userDoc.collection('inventory').doc(item.id);
        inventoryBatch.set(docRef, item.toJson());
      }
      if (inventory.isNotEmpty) await inventoryBatch.commit();

      // Write Gigs
      final gigsBatch = _db.batch();
      for (final gig in gigs) {
        final docRef = userDoc.collection('gigs').doc(gig.id);
        gigsBatch.set(docRef, gig.toJson());
      }
      if (gigs.isNotEmpty) await gigsBatch.commit();

      // Write Rentals
      final rentalsBatch = _db.batch();
      for (final rental in rentals) {
        final docRef = userDoc.collection('rentals').doc(rental.id);
        rentalsBatch.set(docRef, rental.toJson());
      }
      if (rentals.isNotEmpty) await rentalsBatch.commit();

      // Store a timestamp
      await userDoc.set({
        'lastSynced': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint("FirebaseSyncService: Successfully synced to cloud for user $uid.");
    } catch (e) {
      debugPrint("FirebaseSyncService: Error syncing to cloud: $e");
    }
  }
}
