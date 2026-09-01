import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;
import '../../core/constants/app_constants.dart';
import '../../data/models/parcel_model.dart';
import 'difficulty_service.dart';
import 'package:uuid/uuid.dart';

/// Service for managing parcel data and presets
class ParcelService {
  final FirebaseFirestore _firestore;

  ParcelService({required FirebaseFirestore firestore}) : _firestore = firestore;

  // Firestore collection for parcel presets
  static const String _parcelsCollection = 'parcelPresets';

  /// Get all available parcel presets
  Future<List<ParcelModel>> getAllParcels() async {
    try {
      final querySnapshot =
          await _firestore.collection(_parcelsCollection).get();
      return querySnapshot.docs
          .map((doc) => ParcelModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting parcels: $e');
      rethrow;
    }
  }

  /// Get parcels by stability tier
  Future<List<ParcelModel>> getParcelsByStability(
    StabilityTier stabilityTier,
  ) async {
    try {
      final stabString = _stabilityTierToString(stabilityTier);
      final querySnapshot = await _firestore
          .collection(_parcelsCollection)
          .where('stabilityTier', isEqualTo: stabString)
          .get();

      return querySnapshot.docs
          .map((doc) => ParcelModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting parcels by stability: $e');
      rethrow;
    }
  }

  /// Get a random parcel of specified stability
  Future<ParcelModel?> getRandomParcelByStability(
    StabilityTier stabilityTier,
  ) async {
    try {
      final parcels = await getParcelsByStability(stabilityTier);
      if (parcels.isEmpty) return null;

      parcels.shuffle();
      return parcels.first;
    } catch (e) {
      print('Error getting random parcel: $e');
      rethrow;
    }
  }

  /// Create a new parcel preset (admin function)
  Future<ParcelModel> createParcel({
    required List<Map<String, double>> vertices,
    required double centerOfMassX,
    required double centerOfMassY,
    required StabilityTier stabilityTier,
    required double weight,
    required ParcelRarity rarity,
    String? seasonTag,
    required String spriteRef,
  }) async {
    try {
      final parcelId = const Uuid().v4();

      final shape = ParcelShape(
        vertices: vertices,
        centerOfMass_x: centerOfMassX,
        centerOfMass_y: centerOfMassY,
      );

      final parcel = ParcelModel(
        parcelId: parcelId,
        shape: shape,
        stabilityTier: stabilityTier,
        weight: weight,
        rarity: rarity,
        seasonTag: seasonTag,
        spriteRef: spriteRef,
      );

      await _firestore
          .collection(_parcelsCollection)
          .doc(parcelId)
          .set(parcel.toJson());

      return parcel;
    } catch (e) {
      print('Error creating parcel: $e');
      rethrow;
    }
  }

  /// Get parcels with seasonal tag
  Future<List<ParcelModel>> getSeasonalParcels(String seasonTag) async {
    try {
      final querySnapshot = await _firestore
          .collection(_parcelsCollection)
          .where('seasonTag', isEqualTo: seasonTag)
          .get();

      return querySnapshot.docs
          .map((doc) => ParcelModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting seasonal parcels: $e');
      rethrow;
    }
  }

  /// Get next parcel for game progression based on stage difficulty
  /// Respects stage configuration for balanced difficulty curve
  Future<ParcelModel?> getNextGameParcel(int parcelCount, {int? stageNumber}) async {
    try {
      // If stage number provided, use stage-aware selection
      if (stageNumber != null && DifficultyService.isValidStage(stageNumber)) {
        return await _getStageParcel(stageNumber, parcelCount);
      }

      // Fallback to legacy progression system
      StabilityTier tier;

      if (parcelCount == 0) {
        // First parcel is always stable
        tier = StabilityTier.stable;
      } else if (parcelCount < 3) {
        // First 3: mostly stable
        tier = [
          StabilityTier.stable,
          StabilityTier.stable,
          StabilityTier.moderate,
        ][parcelCount];
      } else if (parcelCount < 8) {
        // Introduce moderate and unstable mix
        tier = (parcelCount % 2 == 0)
            ? StabilityTier.moderate
            : StabilityTier.unstable;
      } else {
        // Late game: all types equally
        final options = [
          StabilityTier.stable,
          StabilityTier.moderate,
          StabilityTier.unstable,
        ];
        tier = options[parcelCount % 3];
      }

      return await getRandomParcelByStability(tier);
    } catch (e) {
      print('Error getting next game parcel: $e');
      rethrow;
    }
  }

  /// Get parcel for specific stage - respects stage difficulty configuration
  Future<ParcelModel?> _getStageParcel(int stageNumber, int parcelCount) async {
    try {
      final stageConfig = DifficultyService.getStageConfig(stageNumber);
      if (stageConfig == null) return await getRandomParcelByStability(StabilityTier.stable);

      // Determine if this parcel should be stable based on stage proportion
      final random = math.Random();
      final shouldBeStable = random.nextDouble() < stageConfig.parcelCountStable;

      // Select stability tier based on stage configuration
      StabilityTier selectedTier;

      // If we want stable and it's allowed, pick stable
      if (shouldBeStable && stageConfig.allowedStability.contains(StabilityTier.stable)) {
        selectedTier = StabilityTier.stable;
      } else {
        // Pick from non-stable parcels, or any available if none allowed
        final nonStableTiers = stageConfig.allowedStability
            .where((t) => t != StabilityTier.stable)
            .toList();

        if (nonStableTiers.isNotEmpty) {
          selectedTier = nonStableTiers[random.nextInt(nonStableTiers.length)];
        } else {
          // Fallback if only stable is available (shouldn't happen in normal stages)
          selectedTier = stageConfig.allowedStability.first;
        }
      }

      return await getRandomParcelByStability(selectedTier);
    } catch (e) {
      print('Error getting stage parcel: $e');
      rethrow;
    }
  }

  String _stabilityTierToString(StabilityTier tier) {
    switch (tier) {
      case StabilityTier.stable:
        return 'stable';
      case StabilityTier.moderate:
        return 'moderate';
      case StabilityTier.unstable:
        return 'unstable';
    }
  }

  StabilityTier _stringToStabilityTier(String str) {
    switch (str) {
      case 'stable':
        return StabilityTier.stable;
      case 'moderate':
        return StabilityTier.moderate;
      case 'unstable':
        return StabilityTier.unstable;
      default:
        return StabilityTier.stable;
    }
  }
}
