import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/parcel_service.dart';
import '../services/physics_service.dart';
import '../../data/models/parcel_model.dart';
import '../../data/providers/firebase_provider.dart';

// Parcel service provider
final parcelServiceProvider = Provider<ParcelService>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return ParcelService(firestore: firestore);
});

// Physics service provider (stateless)
final physicsServiceProvider = Provider<PhysicsService>((ref) {
  return PhysicsService();
});

// Get all parcels
final getAllParcelsProvider = FutureProvider<List<ParcelModel>>((ref) async {
  final parcelService = ref.watch(parcelServiceProvider);
  return await parcelService.getAllParcels();
});

// Get next game parcel based on parcel count
final getNextGameParcelProvider =
    FutureProvider.family<ParcelModel?, int>((ref, parcelCount) async {
  final parcelService = ref.watch(parcelServiceProvider);
  return await parcelService.getNextGameParcel(parcelCount);
});

// Get parcels by stability tier
final getParcelsByStabilityProvider = FutureProvider.family<
    List<ParcelModel>,
    StabilityTier>((ref, stabilityTier) async {
  final parcelService = ref.watch(parcelServiceProvider);
  return await parcelService.getParcelsByStability(stabilityTier);
});

// Get seasonal parcels
final getSeasonalParcelsProvider =
    FutureProvider.family<List<ParcelModel>, String>((ref, seasonTag) async {
  final parcelService = ref.watch(parcelServiceProvider);
  return await parcelService.getSeasonalParcels(seasonTag);
});
