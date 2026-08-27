import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/achievement_model.dart';

/// Service for managing achievements
class AchievementService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static late List<AchievementDefinition> _achievementCache;
  static bool _initialized = false;

  /// Initialize achievement service
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      await _loadAchievements();
      _initialized = true;
      print('✅ Achievement service initialized');
    } catch (e) {
      print('⚠️ Achievement service initialization warning: $e');
    }
  }

  /// Load all achievement definitions from Firestore
  static Future<void> _loadAchievements() async {
    try {
      final snapshot = await _firestore.collection('achievements').get();
      _achievementCache = snapshot.docs
          .map((doc) => AchievementDefinition.fromJson({...doc.data(), 'achievementId': doc.id}))
          .toList();
      print('🏆 Loaded ${_achievementCache.length} achievements');
    } catch (e) {
      print('⚠️ Failed to load achievements: $e');
      _achievementCache = [];
    }
  }

  /// Get all achievement definitions
  static List<AchievementDefinition> getAllAchievements() {
    _ensureInitialized();
    return List.from(_achievementCache);
  }

  /// Get achievement by ID
  static AchievementDefinition? getAchievementById(String achievementId) {
    _ensureInitialized();
    try {
      return _achievementCache.firstWhere((a) => a.achievementId == achievementId);
    } catch (e) {
      return null;
    }
  }

  /// Get achievements by category
  static List<AchievementDefinition> getAchievementsByCategory(
    AchievementCategory category,
  ) {
    _ensureInitialized();
    return _achievementCache.where((a) => a.category == category).toList();
  }

  /// Get achievements by difficulty
  static List<AchievementDefinition> getAchievementsByDifficulty(
    AchievementDifficulty difficulty,
  ) {
    _ensureInitialized();
    return _achievementCache.where((a) => a.difficulty == difficulty).toList();
  }

  /// Get user's achievements
  static Future<UserAchievements> getUserAchievements(String userId) async {
    _ensureInitialized();

    try {
      final doc = await _firestore.collection('userAchievements').doc(userId).get();

      if (doc.exists) {
        return UserAchievements.fromJson({...doc.data()!, 'userId': userId});
      } else {
        // Create default achievement record for new user
        final defaultAchievements = UserAchievements(
          userId: userId,
          unlockedAchievementIds: [],
          totalPoints: 0,
          pointsByCategory: {
            for (final category in AchievementCategory.values) category: 0
          },
          lastUpdated: DateTime.now().millisecondsSinceEpoch,
        );

        await _firestore
            .collection('userAchievements')
            .doc(userId)
            .set(defaultAchievements.toJson());

        return defaultAchievements;
      }
    } catch (e) {
      print('⚠️ Failed to get user achievements: $e');
      throw StateError('Failed to load user achievements: $e');
    }
  }

  /// Get user's progress on specific achievement
  static Future<UserAchievement?> getUserAchievementProgress(
    String userId,
    String achievementId,
  ) async {
    _ensureInitialized();

    try {
      final doc = await _firestore
          .collection('userAchievementProgress')
          .doc('${userId}_$achievementId')
          .get();

      if (doc.exists) {
        return UserAchievement.fromJson({...doc.data()!, 'userId': userId});
      }
      return null;
    } catch (e) {
      print('⚠️ Failed to get achievement progress: $e');
      return null;
    }
  }

  /// Update achievement progress
  static Future<bool> updateAchievementProgress(
    String userId,
    String achievementId,
    int progressIncrement,
  ) async {
    _ensureInitialized();

    try {
      final achievement = getAchievementById(achievementId);
      if (achievement == null) {
        print('⚠️ Achievement not found: $achievementId');
        return false;
      }

      final docId = '${userId}_$achievementId';
      final docRef = _firestore.collection('userAchievementProgress').doc(docId);

      final existingDoc = await docRef.get();
      final now = DateTime.now().millisecondsSinceEpoch;

      if (existingDoc.exists) {
        final data = existingDoc.data()!;
        int currentProgress = data['progress'] ?? 0;
        bool isUnlocked = data['isUnlocked'] ?? false;

        currentProgress += progressIncrement;

        // Check if achievement should be unlocked
        if (!isUnlocked && currentProgress >= (data['progressTarget'] ?? 100)) {
          isUnlocked = true;
          await _unlockAchievement(userId, achievementId, achievement);
        }

        await docRef.update({
          'progress': currentProgress,
          'isUnlocked': isUnlocked,
          'updatedAt': now,
          if (isUnlocked) 'unlockedAt': now,
        });
      } else {
        // Create new progress record
        await docRef.set({
          'userId': userId,
          'achievementId': achievementId,
          'isUnlocked': false,
          'progress': progressIncrement,
          'progressTarget': 100, // Default target
          'unlockedAt': null,
          'createdAt': now,
          'updatedAt': now,
        });
      }

      print('📈 Achievement progress updated: $achievementId for $userId');
      return true;
    } catch (e) {
      print('⚠️ Failed to update achievement progress: $e');
      return false;
    }
  }

  /// Unlock achievement
  static Future<bool> _unlockAchievement(
    String userId,
    String achievementId,
    AchievementDefinition achievement,
  ) async {
    try {
      final userAchievementsDoc = _firestore.collection('userAchievements').doc(userId);
      final now = DateTime.now().millisecondsSinceEpoch;

      // Update user's achievement collection
      await userAchievementsDoc.update({
        'unlockedAchievementIds': FieldValue.arrayUnion([achievementId]),
        'totalPoints': FieldValue.increment(achievement.points),
        'pointsByCategory.${achievement.category.toString()}':
            FieldValue.increment(achievement.points),
        'lastUpdated': now,
      });

      // Record unlock event
      await _firestore
          .collection('achievementUnlocks')
          .doc('${userId}_${DateTime.now().millisecondsSinceEpoch}')
          .set({
        'achievementId': achievementId,
        'userId': userId,
        'unlockedAt': now,
        'achievementName': achievement.name,
        'points': achievement.points,
      });

      print('🏆 Achievement unlocked: ${achievement.name} for $userId');
      return true;
    } catch (e) {
      print('⚠️ Failed to unlock achievement: $e');
      return false;
    }
  }

  /// Check if user owns achievement
  static Future<bool> userHasAchievement(String userId, String achievementId) async {
    _ensureInitialized();

    try {
      final userAchievements = await getUserAchievements(userId);
      return userAchievements.unlockedAchievementIds.contains(achievementId);
    } catch (e) {
      print('⚠️ Failed to check achievement ownership: $e');
      return false;
    }
  }

  /// Get achievements by tag
  static List<AchievementDefinition> getAchievementsByTag(String tag) {
    _ensureInitialized();
    return _achievementCache.where((a) => a.tags?.contains(tag) ?? false).toList();
  }

  /// Seed initial achievements (admin function)
  static Future<void> seedAchievements() async {
    try {
      final achievements = _getDefaultAchievements();

      for (final achievement in achievements) {
        await _firestore
            .collection('achievements')
            .doc(achievement.achievementId)
            .set(achievement.toJson());
      }

      print('🌱 Seeded ${achievements.length} achievements');
      await _loadAchievements();
    } catch (e) {
      print('⚠️ Failed to seed achievements: $e');
    }
  }

  /// Get default achievements
  static List<AchievementDefinition> _getDefaultAchievements() {
    return [
      // Stacking achievements
      AchievementDefinition(
        achievementId: 'first_parcel',
        name: '最初の一歩',
        description: '1つの箱を積み重ねる',
        iconPath: 'assets/achievements/first_parcel.png',
        category: AchievementCategory.stacking,
        difficulty: AchievementDifficulty.easy,
        points: 10,
        isHidden: false,
        tags: ['stacking', 'beginner'],
      ),
      AchievementDefinition(
        achievementId: 'tower_builder',
        name: 'タワービルダー',
        description: '50個の箱を積み重ねる',
        iconPath: 'assets/achievements/tower_builder.png',
        category: AchievementCategory.stacking,
        difficulty: AchievementDifficulty.medium,
        points: 50,
        isHidden: false,
        tags: ['stacking'],
      ),
      AchievementDefinition(
        achievementId: 'perfect_stack',
        name: 'パーフェクトスタック',
        description: 'パーフェクトスタックを達成する',
        iconPath: 'assets/achievements/perfect_stack.png',
        category: AchievementCategory.stacking,
        difficulty: AchievementDifficulty.hard,
        points: 100,
        isHidden: false,
        tags: ['stacking', 'skill'],
      ),

      // Scoring achievements
      AchievementDefinition(
        achievementId: 'score_1000',
        name: '1000点達成',
        description: '1000点を獲得する',
        iconPath: 'assets/achievements/score_1000.png',
        category: AchievementCategory.scoring,
        difficulty: AchievementDifficulty.easy,
        points: 25,
        isHidden: false,
        tags: ['scoring'],
      ),
      AchievementDefinition(
        achievementId: 'score_5000',
        name: '5000点マイルストーン',
        description: '5000点を獲得する',
        iconPath: 'assets/achievements/score_5000.png',
        category: AchievementCategory.scoring,
        difficulty: AchievementDifficulty.hard,
        points: 75,
        isHidden: false,
        tags: ['scoring'],
      ),

      // Cosmetic collection achievements
      AchievementDefinition(
        achievementId: 'collector',
        name: 'コレクター',
        description: '5つの化粧品を収集する',
        iconPath: 'assets/achievements/collector.png',
        category: AchievementCategory.collection,
        difficulty: AchievementDifficulty.easy,
        points: 30,
        isHidden: false,
        tags: ['collection', 'cosmetics'],
      ),

      // Gameplay achievements
      AchievementDefinition(
        achievementId: 'player_10games',
        name: 'アクティブプレイヤー',
        description: '10ゲームをプレイする',
        iconPath: 'assets/achievements/player_10games.png',
        category: AchievementCategory.gameplay,
        difficulty: AchievementDifficulty.easy,
        points: 15,
        isHidden: false,
        tags: ['gameplay'],
      ),

      // Hidden achievement
      AchievementDefinition(
        achievementId: 'secret_master',
        name: 'シークレットマスター',
        description: 'すべての秘密を発見する',
        iconPath: 'assets/achievements/secret_master.png',
        category: AchievementCategory.special,
        difficulty: AchievementDifficulty.legendary,
        points: 200,
        isHidden: true,
        unlockedDescription: 'シークレットマスターになった！',
        tags: ['secret', 'legendary'],
      ),
    ];
  }

  /// Ensure service is initialized
  static void _ensureInitialized() {
    if (!_initialized) {
      throw StateError(
        'AchievementService not initialized. Call initialize() first.',
      );
    }
  }

  /// Get debug info
  static String getDebugInfo() {
    return 'Achievements: initialized=$_initialized, loaded=${_achievementCache.length}';
  }
}
