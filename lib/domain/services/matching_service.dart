import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/doorway_model.dart';
import '../../data/models/play_result_model.dart';

/// Service for intelligent doorway matching and recommendation
class MatchingService {
  final FirebaseFirestore _firestore;

  MatchingService({required FirebaseFirestore firestore}) : _firestore = firestore;

  /// Get matching candidates for a user
  /// Returns up to 3 doorways based on composite scoring
  Future<List<DoorwayModel>> getMatchingCandidates(
    String userId,
    double userHighScore,
  ) async {
    try {
      // Get recent doorways (limit 50 for processing)
      final recentDoorways = await _getRecentDoorways(50);

      if (recentDoorways.isEmpty) {
        return [];
      }

      // Score each doorway
      final scoredDoorways = <(DoorwayModel, double)>[];

      for (final doorway in recentDoorways) {
        // Skip own doorway
        if (doorway.ownerUid == userId) {
          continue;
        }

        final score = _calculateCompositeScore(
          doorway: doorway,
          userHighScore: userHighScore,
          userId: userId,
        );

        scoredDoorways.add((doorway, score));
      }

      // Sort by score (descending)
      scoredDoorways.sort((a, b) => b.$2.compareTo(a.$2));

      // Return top 3
      return scoredDoorways.take(3).map((e) => e.$1).toList();
    } catch (e) {
      print('Error getting matching candidates: $e');
      rethrow;
    }
  }

  /// Calculate composite score for a doorway
  /// Combines: skill match (40%) + activity (35%) + novelty (25%)
  double _calculateCompositeScore({
    required DoorwayModel doorway,
    required double userHighScore,
    required String userId,
  }) {
    // Weight factors
    const double skillWeight = 0.40;
    const double activityWeight = 0.35;
    const double noveltyWeight = 0.25;

    // 1. Skill-based matching: ±20% of user's high score
    final skillScore = _scoreSkillMatch(doorway.topScore, userHighScore);

    // 2. Activity freshness: within 24 hours = high score
    final activityScore = _scoreActivityFreshness(doorway.lastActivityAt);

    // 3. Novelty: unvisited = high score
    final noveltyScore = _scoreNovelty(doorway.lastVisitedBy, userId);

    // Composite score
    return (skillScore * skillWeight) +
        (activityScore * activityWeight) +
        (noveltyScore * noveltyWeight);
  }

  /// Score skill compatibility (0-100)
  /// Peak at user's high score ±20%
  double _scoreSkillMatch(double doorwayScore, double userHighScore) {
    if (userHighScore == 0) return 50; // Default for new users

    final lowerBound = userHighScore * 0.8;
    final upperBound = userHighScore * 1.2;

    if (doorwayScore < lowerBound) {
      // Too easy: score decreases as gap increases
      final gap = lowerBound - doorwayScore;
      return (50 * (1 - (gap / userHighScore))).clamp(0, 100);
    } else if (doorwayScore > upperBound) {
      // Too hard: score decreases as gap increases
      final gap = doorwayScore - upperBound;
      return (50 * (1 - (gap / userHighScore))).clamp(0, 100);
    } else {
      // Within range: high score
      return 100;
    }
  }

  /// Score activity freshness (0-100)
  /// Within 24 hours = 100, older = decreasing
  double _scoreActivityFreshness(DateTime lastActivity) {
    final now = DateTime.now();
    final hoursAgo = now.difference(lastActivity).inHours;

    if (hoursAgo <= 24) {
      return 100;
    } else if (hoursAgo <= 72) {
      // 1-3 days: gradual decrease
      return 100 - ((hoursAgo - 24) / 48 * 50);
    } else {
      // Older than 3 days: low score
      return 50;
    }
  }

  /// Score novelty (0-100)
  /// Unvisited by user = 100, already visited = 50
  double _scoreNovelty(String? lastVisitedBy, String userId) {
    // If never visited by this user, high score
    if (lastVisitedBy == null || lastVisitedBy != userId) {
      return 100;
    }
    // Already visited: lower score
    return 50;
  }

  /// Get recent doorways from Firestore
  Future<List<DoorwayModel>> _getRecentDoorways(int limit) async {
    try {
      final snapshot = await _firestore
          .collection('doorways')
          .orderBy('lastActivityAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => DoorwayModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting recent doorways: $e');
      return [];
    }
  }

  /// Get NPC doorways for cold start
  Future<List<DoorwayModel>> getNPCDoorways() async {
    try {
      final snapshot = await _firestore
          .collection('doorways')
          .where('ownerUid', isEqualTo: 'npc_admin')
          .get();

      return snapshot.docs
          .map((doc) => DoorwayModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting NPC doorways: $e');
      return [];
    }
  }

  /// Get candidates with fallback to NPC doorways
  Future<List<DoorwayModel>> getCandidatesWithFallback(
    String userId,
    double userHighScore,
  ) async {
    try {
      var candidates = await getMatchingCandidates(userId, userHighScore);

      // If not enough candidates, add NPC doorways
      if (candidates.length < 3) {
        final npcDoorways = await getNPCDoorways();
        final needed = 3 - candidates.length;
        candidates.addAll(npcDoorways.take(needed));
      }

      return candidates;
    } catch (e) {
      print('Error getting candidates with fallback: $e');
      return [];
    }
  }

  /// Update doorway's last visited info
  Future<void> recordDoorwayVisit(
    String doorwayId,
    String visitorUid,
  ) async {
    try {
      await _firestore
          .collection('doorways')
          .doc(doorwayId)
          .update({
        'lastVisitedBy': visitorUid,
        'lastActivityAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      print('Error recording doorway visit: $e');
      rethrow;
    }
  }
}
