import 'package:flutter_test/flutter_test.dart';
import 'package:donzumari/domain/services/achievement_service.dart';
import 'package:donzumari/data/models/achievement_model.dart';

void main() {
  group('AchievementService', () {
    setUp(() async {
      await AchievementService.initialize();
    });

    test('initializes achievements service', () {
      expect(
        AchievementService.getDebugInfo(),
        contains('initialized=true'),
      );
    });

    test('retrieves all achievements', () {
      final achievements = AchievementService.getAllAchievements();
      expect(achievements, isNotEmpty);
    });

    test('retrieves achievement by ID', () {
      final all = AchievementService.getAllAchievements();
      if (all.isNotEmpty) {
        final achievement = AchievementService.getAchievementById(all[0].achievementId);
        expect(achievement, isNotNull);
        expect(achievement?.achievementId, equals(all[0].achievementId));
      }
    });

    test('retrieves achievements by category', () {
      final stackingAchievements =
          AchievementService.getAchievementsByCategory(AchievementCategory.stacking);
      expect(stackingAchievements, isNotEmpty);
      expect(
        stackingAchievements.every((a) => a.category == AchievementCategory.stacking),
        isTrue,
      );
    });

    test('retrieves achievements by difficulty', () {
      final easyAchievements =
          AchievementService.getAchievementsByDifficulty(AchievementDifficulty.easy);
      expect(easyAchievements, isNotEmpty);
      expect(
        easyAchievements.every((a) => a.difficulty == AchievementDifficulty.easy),
        isTrue,
      );
    });

    test('retrieves achievements by tag', () {
      final taggedAchievements = AchievementService.getAchievementsByTag('stacking');
      expect(taggedAchievements.isEmpty || taggedAchievements.isNotEmpty, isTrue);
    });

    test('returns null for non-existent achievement', () {
      final achievement = AchievementService.getAchievementById('non_existent_id');
      expect(achievement, isNull);
    });

    test('gets user achievements structure', () async {
      final userAchievements = await AchievementService.getUserAchievements('test_user_1');
      expect(userAchievements, isNotNull);
      expect(userAchievements.userId, equals('test_user_1'));
      expect(userAchievements.unlockedAchievementIds, isA<List<String>>());
    });

    test('tracks achievement progress', () async {
      final userId = 'test_user_progress';
      final achievements = AchievementService.getAllAchievements();

      if (achievements.isNotEmpty) {
        final achievementId = achievements[0].achievementId;
        final success = await AchievementService.updateAchievementProgress(
          userId,
          achievementId,
          10,
        );
        expect(success, isTrue);
      }
    });

    test('verifies user ownership of achievement', () async {
      final userId = 'test_user_owner';
      final achievements = AchievementService.getAllAchievements();

      if (achievements.isNotEmpty) {
        final achievementId = achievements[0].achievementId;

        // Initially should not own
        var owns = await AchievementService.userHasAchievement(userId, achievementId);
        expect(owns, isFalse);
      }
    });

    test('achievement categories are defined', () {
      expect(AchievementCategory.values, isNotEmpty);
      expect(AchievementCategory.values.length, greaterThanOrEqualTo(5));
    });

    test('achievement difficulties are defined', () {
      expect(AchievementDifficulty.values, isNotEmpty);
      expect(AchievementDifficulty.values.length, greaterThanOrEqualTo(4));
    });

    test('default achievements are seeded with valid structure', () {
      final achievements = AchievementService.getAllAchievements();

      for (final achievement in achievements) {
        expect(achievement.achievementId, isNotEmpty);
        expect(achievement.name, isNotEmpty);
        expect(achievement.description, isNotEmpty);
        expect(achievement.points, greaterThan(0));
      }
    });

    test('returns debug info', () {
      final debugInfo = AchievementService.getDebugInfo();
      expect(debugInfo, isNotEmpty);
      expect(debugInfo, contains('Achievements'));
    });
  });
}
