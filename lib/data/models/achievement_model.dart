import 'package:freezed_annotation/freezed_annotation.dart';

part 'achievement_model.freezed.dart';
part 'achievement_model.g.dart';

/// Achievement difficulty level
enum AchievementDifficulty {
  easy,
  medium,
  hard,
  legendary,
}

/// Achievement category
enum AchievementCategory {
  stacking,      // Parcel stacking achievements
  scoring,       // High score achievements
  collection,    // Cosmetic collection achievements
  gameplay,      // General gameplay achievements
  exploration,   // Discover all doorways
  competitive,   // Multiplayer achievements
  special,       // Special/hidden achievements
}

/// Achievement definition
@freezed
class AchievementDefinition with _$AchievementDefinition {
  const factory AchievementDefinition({
    required String achievementId,
    required String name,
    required String description,
    required String iconPath,
    required AchievementCategory category,
    required AchievementDifficulty difficulty,
    required int points,
    required bool isHidden,      // Hidden until unlocked
    String? unlockedDescription, // Description after unlock
    List<String>? tags,
  }) = _AchievementDefinition;

  factory AchievementDefinition.fromJson(Map<String, dynamic> json) =>
      _$AchievementDefinitionFromJson(json);
}

/// User achievement progress
@freezed
class UserAchievement with _$UserAchievement {
  const factory UserAchievement({
    required String userId,
    required String achievementId,
    required bool isUnlocked,
    required int progress,      // 0-100 percentage
    required int progressTarget, // e.g., 100 parcels stacked
    required int? unlockedAt,   // Unix timestamp
    required int createdAt,     // Unix timestamp
    required int updatedAt,     // Unix timestamp
  }) = _UserAchievement;

  factory UserAchievement.fromJson(Map<String, dynamic> json) =>
      _$UserAchievementFromJson(json);
}

/// User achievements collection
@freezed
class UserAchievements with _$UserAchievements {
  const factory UserAchievements({
    required String userId,
    required List<String> unlockedAchievementIds,
    required int totalPoints,
    required Map<AchievementCategory, int> pointsByCategory,
    required int lastUpdated,
  }) = _UserAchievements;

  factory UserAchievements.fromJson(Map<String, dynamic> json) =>
      _$UserAchievementsFromJson(json);
}

/// Achievement progress update
@freezed
class AchievementProgressUpdate with _$AchievementProgressUpdate {
  const factory AchievementProgressUpdate({
    required String achievementId,
    required int progressIncrement,
    Map<String, dynamic>? metadata,
  }) = _AchievementProgressUpdate;

  factory AchievementProgressUpdate.fromJson(Map<String, dynamic> json) =>
      _$AchievementProgressUpdateFromJson(json);
}

/// Achievement unlock event
@freezed
class AchievementUnlock with _$AchievementUnlock {
  const factory AchievementUnlock({
    required String achievementId,
    required String userId,
    required int unlockedAt,
    required String achievementName,
    required int points,
  }) = _AchievementUnlock;

  factory AchievementUnlock.fromJson(Map<String, dynamic> json) =>
      _$AchievementUnlockFromJson(json);
}
