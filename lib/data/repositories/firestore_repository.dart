import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../models/doorway_model.dart';
import '../models/play_result_model.dart';
import '../models/ranking_model.dart';
import 'package:uuid/uuid.dart';

/// Repository for Firestore operations
class FirestoreRepository {
  final FirebaseFirestore _firestore;

  FirestoreRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  // Doorway operations

  /// Get doorway by ID
  Future<DoorwayModel?> getDoorway(String doorwayId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.doorwaysCollection)
          .doc(doorwayId)
          .get();

      if (doc.exists) {
        return DoorwayModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting doorway: $e');
      rethrow;
    }
  }

  /// Create new doorway
  Future<DoorwayModel> createDoorway(String ownerUid) async {
    try {
      final doorwayId = const Uuid().v4();
      final now = DateTime.now();

      final doorway = DoorwayModel(
        doorwayId: doorwayId,
        ownerUid: ownerUid,
        currentStack: [],
        topScore: 0,
        lastVisitedBy: null,
        lastActivityAt: now,
      );

      await _firestore
          .collection(AppConstants.doorwaysCollection)
          .doc(doorwayId)
          .set(doorway);

      return doorway;
    } catch (e) {
      print('Error creating doorway: $e');
      rethrow;
    }
  }

  /// Update doorway's current stack and last activity
  Future<void> updateDoorwayStack(
    String doorwayId,
    List<ParcelPlacement> stack,
    String? lastVisitedBy,
  ) async {
    try {
      await _firestore
          .collection(AppConstants.doorwaysCollection)
          .doc(doorwayId)
          .update({
        'currentStack': stack.map((p) => p).toList(),
        'lastVisitedBy': lastVisitedBy,
        AppConstants.lastActivityAtField: DateTime.now(),
      });
    } catch (e) {
      print('Error updating doorway stack: $e');
      rethrow;
    }
  }

  /// Update doorway's top score
  Future<void> updateDoorwayTopScore(String doorwayId, double score) async {
    try {
      await _firestore
          .collection(AppConstants.doorwaysCollection)
          .doc(doorwayId)
          .update({'topScore': score});
    } catch (e) {
      print('Error updating doorway top score: $e');
      rethrow;
    }
  }

  /// Get recent doorways for visit selection
  Future<List<DoorwayModel>> getRecentDoorways(int limit) async {
    try {
      final query = await _firestore
          .collection(AppConstants.doorwaysCollection)
          .orderBy(AppConstants.lastActivityAtField, descending: true)
          .limit(limit)
          .get();

      return query.docs
          .map((doc) => DoorwayModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting recent doorways: $e');
      rethrow;
    }
  }

  // Play Result operations

  /// Save play result
  Future<PlayResultModel> savePlayResult(
    String uid,
    String doorwayId,
    double height,
    bool collapsed,
    String? gifRef,
  ) async {
    try {
      final resultId = const Uuid().v4();
      final now = DateTime.now();

      final result = PlayResultModel(
        resultId: resultId,
        uid: uid,
        doorwayId: doorwayId,
        height: height,
        collapsed: collapsed,
        gifRef: gifRef,
        playedAt: now,
      );

      await _firestore
          .collection(AppConstants.playResultsCollection)
          .doc(resultId)
          .set(result);

      return result;
    } catch (e) {
      print('Error saving play result: $e');
      rethrow;
    }
  }

  /// Get play results for a doorway
  Future<List<PlayResultModel>> getDoorwayResults(String doorwayId) async {
    try {
      final query = await _firestore
          .collection(AppConstants.playResultsCollection)
          .where('doorwayId', isEqualTo: doorwayId)
          .orderBy('playedAt', descending: true)
          .limit(100)
          .get();

      return query.docs
          .map((doc) => PlayResultModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting doorway results: $e');
      rethrow;
    }
  }

  /// Get user's play results
  Future<List<PlayResultModel>> getUserResults(String uid) async {
    try {
      final query = await _firestore
          .collection(AppConstants.playResultsCollection)
          .where('uid', isEqualTo: uid)
          .orderBy('playedAt', descending: true)
          .limit(50)
          .get();

      return query.docs
          .map((doc) => PlayResultModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting user results: $e');
      rethrow;
    }
  }

  // Ranking operations

  /// Get ranking for a doorway
  Future<RankingModel?> getDoorwayRanking(String doorwayId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.rankingsCollection)
          .doc(doorwayId)
          .get();

      if (doc.exists) {
        return RankingModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting ranking: $e');
      rethrow;
    }
  }

  /// Update ranking for a doorway
  Future<void> updateDoorwayRanking(
    String doorwayId,
    List<RankingEntry> entries,
  ) async {
    try {
      final ranking = RankingModel(
        doorwayId: doorwayId,
        entries: entries,
      );

      await _firestore
          .collection(AppConstants.rankingsCollection)
          .doc(doorwayId)
          .set(ranking);
    } catch (e) {
      print('Error updating ranking: $e');
      rethrow;
    }
  }
}
