import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/inventory_item.dart';
import '../models/gig.dart';
import '../models/rental.dart';

class FirebaseSyncService {
  static Future<void> syncAll(
    List<InventoryItem> inventory,
    List<Gig> gigs,
    List<Rental> rentals,
  ) async {
    try {
      if (Firebase.apps.isEmpty) {
        return;
      }

      final auth = FirebaseAuth.instance;
      final user = auth.currentUser;
      if (user == null) {
        debugPrint("FirebaseSyncService: No user signed in, skipping sync.");
        return;
      }

      final uid = user.uid;
      final db = FirebaseFirestore.instance;
      final userDoc = db.collection('users').doc(uid);
      
      // Write Inventory
      final inventoryBatch = db.batch();
      for (final item in inventory) {
        final docRef = userDoc.collection('inventory').doc(item.id);
        inventoryBatch.set(docRef, item.toJson());
      }
      if (inventory.isNotEmpty) await inventoryBatch.commit();

      // Write Gigs
      final gigsBatch = db.batch();
      for (final gig in gigs) {
        final docRef = userDoc.collection('gigs').doc(gig.id);
        gigsBatch.set(docRef, gig.toJson());
      }
      if (gigs.isNotEmpty) await gigsBatch.commit();

      // Write Rentals
      final rentalsBatch = db.batch();
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
