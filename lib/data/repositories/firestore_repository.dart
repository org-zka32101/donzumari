import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/services/network_error_handler.dart';
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

  /// Get doorway by ID (with automatic retry on transient errors)
  Future<DoorwayModel?> getDoorway(String doorwayId) async {
    return _retryableOperation<DoorwayModel?>(
      'getDoorway:$doorwayId',
      () async {
        final doc = await _firestore
            .collection(AppConstants.doorwaysCollection)
            .doc(doorwayId)
            .get();

        if (doc.exists) {
          return DoorwayModel.fromJson(doc.data() as Map<String, dynamic>);
        }
        return null;
      },
    );
  }

  /// Create new doorway (with automatic retry)
  Future<DoorwayModel> createDoorway(String ownerUid) async {
    return _retryableOperation<DoorwayModel>(
      'createDoorway:$ownerUid',
      () async {
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
            .set(doorway.toJson());

        return doorway;
      },
    );
  }

  /// Update doorway's current stack and last activity (with automatic retry)
  Future<void> updateDoorwayStack(
    String doorwayId,
    List<ParcelPlacement> stack,
    String? lastVisitedBy,
  ) async {
    return _retryableOperation<void>(
      'updateDoorwayStack:$doorwayId',
      () async {
        await _firestore
            .collection(AppConstants.doorwaysCollection)
            .doc(doorwayId)
            .update({
          'currentStack': stack.map((p) => p.toJson()).toList(),
          'lastVisitedBy': lastVisitedBy,
          AppConstants.lastActivityAtField: DateTime.now(),
        });
      },
    );
  }

  /// Update doorway's top score (with automatic retry)
  Future<void> updateDoorwayTopScore(String doorwayId, double score) async {
    return _retryableOperation<void>(
      'updateDoorwayTopScore:$doorwayId',
      () async {
        await _firestore
            .collection(AppConstants.doorwaysCollection)
            .doc(doorwayId)
            .update({'topScore': score});
      },
    );
  }

  /// Get recent doorways for visit selection (with automatic retry)
  Future<List<DoorwayModel>> getRecentDoorways(int limit) async {
    return _retryableOperation<List<DoorwayModel>>(
      'getRecentDoorways:$limit',
      () async {
        final query = await _firestore
            .collection(AppConstants.doorwaysCollection)
            .orderBy(AppConstants.lastActivityAtField, descending: true)
            .limit(limit)
            .get();

        return query.docs
            .map((doc) => DoorwayModel.fromJson(doc.data()))
            .toList();
      },
    );
  }

  // Play Result operations

  /// Save play result (with automatic retry)
  Future<PlayResultModel> savePlayResult(
    String uid,
    String doorwayId,
    double height,
    bool collapsed,
    String? gifRef,
  ) async {
    return _retryableOperation<PlayResultModel>(
      'savePlayResult:$doorwayId',
      () async {
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
            .set(result.toJson());

        return result;
      },
    );
  }

  /// Get play results for a doorway (with automatic retry)
  Future<List<PlayResultModel>> getDoorwayResults(String doorwayId) async {
    return _retryableOperation<List<PlayResultModel>>(
      'getDoorwayResults:$doorwayId',
      () async {
        final query = await _firestore
            .collection(AppConstants.playResultsCollection)
            .where('doorwayId', isEqualTo: doorwayId)
            .orderBy('playedAt', descending: true)
            .limit(100)
            .get();

        return query.docs
            .map((doc) => PlayResultModel.fromJson(doc.data()))
            .toList();
      },
    );
  }

  /// Get user's play results (with automatic retry)
  Future<List<PlayResultModel>> getUserResults(String uid) async {
    return _retryableOperation<List<PlayResultModel>>(
      'getUserResults:$uid',
      () async {
        final query = await _firestore
            .collection(AppConstants.playResultsCollection)
            .where('uid', isEqualTo: uid)
            .orderBy('playedAt', descending: true)
            .limit(50)
            .get();

        return query.docs
            .map((doc) => PlayResultModel.fromJson(doc.data()))
            .toList();
      },
    );
  }

  // Ranking operations

  /// Get ranking for a doorway (with automatic retry)
  Future<RankingModel?> getDoorwayRanking(String doorwayId) async {
    return _retryableOperation<RankingModel?>(
      'getDoorwayRanking:$doorwayId',
      () async {
        final doc = await _firestore
            .collection(AppConstants.rankingsCollection)
            .doc(doorwayId)
            .get();

        if (doc.exists) {
          return RankingModel.fromJson(doc.data() as Map<String, dynamic>);
        }
        return null;
      },
    );
  }

  /// Update ranking for a doorway
  Future<void> updateDoorwayRanking(
    String doorwayId,
    List<RankingEntry> entries,
  ) async {
    return _retryableOperation<void>(
      'updateDoorwayRanking:$doorwayId',
      () async {
        final ranking = RankingModel(
          doorwayId: doorwayId,
          entries: entries,
        );

        await _firestore
            .collection(AppConstants.rankingsCollection)
            .doc(doorwayId)
            .set(ranking.toJson());
      },
    );
  }

  // Helper methods

  /// Execute operation with automatic retry on transient errors
  Future<T> _retryableOperation<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    const maxRetries = 3;
    int attempt = 0;

    while (attempt <= maxRetries) {
      try {
        return await operation();
      } catch (e) {
        final (errorType, userMessage) = NetworkErrorHandler.parseError(e);

        if (!NetworkErrorHandler.isRetryable(errorType) ||
            attempt >= maxRetries) {
          print('❌ Operation failed after ${attempt + 1} attempts: $operationName\n'
              '   Error: $errorType - $userMessage');
          rethrow;
        }

        attempt++;
        final delay = NetworkErrorHandler.getRetryDelay(attempt);
        print('⚠️  Attempt $attempt failed for $operationName, '
            'retrying in ${delay}ms...');

        await Future.delayed(Duration(milliseconds: delay));
      }
    }

    throw Exception('Operation failed: $operationName');
  }
}
