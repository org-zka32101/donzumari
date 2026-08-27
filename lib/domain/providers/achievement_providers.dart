import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/achievement_service.dart';
import '../../data/models/achievement_model.dart';

/// Achievement service provider
final achievementServiceProvider = Provider<AchievementService>((ref) {
  return AchievementService();
});

/// Initialize achievements
final initializeAchievementsProvider = FutureProvider<void>((ref) async {
  await AchievementService.initialize();
});

/// Get all achievement definitions
final allAchievementsProvider = Provider<List<AchievementDefinition>>((ref) {
  return AchievementService.getAllAchievements();
});

/// Get achievement by ID
final achievementByIdProvider =
    Provider.family<AchievementDefinition?, String>((ref, achievementId) {
  return AchievementService.getAchievementById(achievementId);
});

/// Get achievements by category
final achievementsByCategoryProvider =
    Provider.family<List<AchievementDefinition>, AchievementCategory>((ref, category) {
  return AchievementService.getAchievementsByCategory(category);
});

/// Get achievements by difficulty
final achievementsByDifficultyProvider =
    Provider.family<List<AchievementDefinition>, AchievementDifficulty>((ref, difficulty) {
  return AchievementService.getAchievementsByDifficulty(difficulty);
});

/// Get user's achievements
final userAchievementsProvider = FutureProvider<UserAchievements>((ref) async {
  final currentUser = ref.watch(currentUserAsyncProvider);
  return currentUser.when(
    data: (user) async {
      if (user != null) {
        return await AchievementService.getUserAchievements(user.uid);
      }
      throw StateError('User not authenticated');
    },
    loading: () async => throw StateError('Loading user'),
    error: (err, stack) async => throw err,
  );
});

/// Get user's progress on specific achievement
final userAchievementProgressProvider =
    FutureProvider.family<UserAchievement?, String>((ref, achievementId) async {
  final currentUser = ref.watch(currentUserAsyncProvider);
  return currentUser.when(
    data: (user) async {
      if (user != null) {
        return await AchievementService.getUserAchievementProgress(user.uid, achievementId);
      }
      return null;
    },
    loading: () async => null,
    error: (err, stack) async => null,
  );
});

/// Check if user has achievement
final userHasAchievementProvider =
    FutureProvider.family<bool, String>((ref, achievementId) async {
  final currentUser = ref.watch(currentUserAsyncProvider);
  return currentUser.when(
    data: (user) async {
      if (user != null) {
        return await AchievementService.userHasAchievement(user.uid, achievementId);
      }
      return false;
    },
    loading: () async => false,
    error: (err, stack) async => false,
  );
});

/// Update achievement progress
final updateAchievementProgressProvider =
    FutureProvider.family<bool, (String, int)>((ref, args) async {
  final (achievementId, progressIncrement) = args;
  final currentUser = ref.watch(currentUserAsyncProvider);

  return currentUser.when(
    data: (user) async {
      if (user != null) {
        final success = await AchievementService.updateAchievementProgress(
          user.uid,
          achievementId,
          progressIncrement,
        );

        if (success) {
          ref.refresh(userAchievementsProvider);
        }

        return success;
      }
      throw StateError('User not authenticated');
    },
    loading: () async => throw StateError('Loading user'),
    error: (err, stack) async => throw err,
  );
});

/// Get achievements by tag
final achievementsByTagProvider =
    Provider.family<List<AchievementDefinition>, String>((ref, tag) {
  return AchievementService.getAchievementsByTag(tag);
});

/// Get all categories
final achievementCategoriesProvider = Provider<List<AchievementCategory>>((ref) {
  return AchievementCategory.values;
});

/// Get all difficulties
final achievementDifficultiesProvider = Provider<List<AchievementDifficulty>>((ref) {
  return AchievementDifficulty.values;
});

/// Get user's total achievement points
final userAchievementPointsProvider = FutureProvider<int>((ref) async {
  final achievements = ref.watch(userAchievementsProvider);
  return achievements.when(
    data: (data) => data.totalPoints,
    loading: () => 0,
    error: (err, stack) => 0,
  );
});

/// Get user's achieved percentage
final userAchievementPercentageProvider = FutureProvider<double>((ref) async {
  final allAchievements = ref.watch(allAchievementsProvider);
  final userAchievements = ref.watch(userAchievementsProvider);

  return userAchievements.when(
    data: (data) {
      if (allAchievements.isEmpty) return 0.0;
      return (data.unlockedAchievementIds.length / allAchievements.length) * 100;
    },
    loading: () => 0.0,
    error: (err, stack) => 0.0,
  );
});

// Imported from existing providers
final currentUserAsyncProvider = FutureProvider<CurrentUser?>((ref) async {
  // This would be imported from auth_providers.dart
  return null;
});

// Placeholder for CurrentUser type
class CurrentUser {
  final String uid;
  CurrentUser({required this.uid});
}
