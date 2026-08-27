import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../fixtures/parcel_presets.dart';

/// Service to seed Firestore with initial data
class FirestoreSeeder {
  final FirebaseFirestore _firestore;

  FirestoreSeeder({required FirebaseFirestore firestore}) : _firestore = firestore;

  /// Seed all parcel presets to Firestore
  /// Safe to call multiple times (uses set with merge: false to avoid duplicates)
  Future<void> seedParcels() async {
    try {
      final parcelsRef = _firestore.collection('parcelPresets');

      // Check if parcels already exist
      final snapshot = await parcelsRef.limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        print('Parcels already seeded, skipping...');
        return;
      }

      print('Seeding ${ParcelPresets.presets.length} parcel presets...');

      for (final preset in ParcelPresets.presets) {
        final model = ParcelPresets.presetToModel(preset);
        await parcelsRef.doc(model.parcelId).set(model);
      }

      print('✅ Parcel presets seeded successfully!');
    } catch (e) {
      print('❌ Error seeding parcels: $e');
      rethrow;
    }
  }

  /// Create a sample NPC doorway for cold start
  Future<void> seedNPCDoorways() async {
    try {
      final doorwaysRef = _firestore.collection(AppConstants.doorwaysCollection);

      // Check if NPC doorways already exist
      final npcCheck = await doorwaysRef
          .where('ownerUid', isEqualTo: 'npc_admin')
          .limit(1)
          .get();

      if (npcCheck.docs.isNotEmpty) {
        print('NPC doorways already exist, skipping...');
        return;
      }

      print('Creating NPC example doorways...');

      // Create a few example doorways for new users
      final npcDoorwayIds = [
        'npc_doorway_01',
        'npc_doorway_02',
        'npc_doorway_03',
      ];

      for (final doorwayId in npcDoorwayIds) {
        await doorwaysRef.doc(doorwayId).set({
          'doorwayId': doorwayId,
          'ownerUid': 'npc_admin',
          'currentStack': [],
          'topScore': 150.0 + (npcDoorwayIds.indexOf(doorwayId) * 50),
          'lastVisitedBy': null,
          AppConstants.lastActivityAtField: DateTime.now(),
        });
      }

      print('✅ NPC doorways created successfully!');
    } catch (e) {
      print('❌ Error seeding NPC doorways: $e');
      rethrow;
    }
  }

  /// Seed all initial data
  Future<void> seedAll() async {
    try {
      print('🌱 Starting Firestore initialization...');
      await seedParcels();
      await seedNPCDoorways();
      print('✅ Firestore initialization complete!');
    } catch (e) {
      print('❌ Error during seeding: $e');
      rethrow;
    }
  }
}
