import '../../data/models/parcel_model.dart';

/// Stage difficulty configuration and progression management
class DifficultyService {
  // Stage definitions with difficulty progression
  static const int easyStagesStart = 1;
  static const int easyStagesEnd = 5;
  static const int intermediateStagesStart = 6;
  static const int intermediateStagesEnd = 15;
  static const int advancedStagesStart = 16;

  /// Stage configuration with difficulty parameters
  static final Map<int, StageDifficulty> stageConfigs = {
    // ===== EASY STAGES (1-5) =====
    1: StageDifficulty(
      stageNumber: 1,
      category: 'easy',
      name: 'チュートリアル',
      description: 'ゲーム基本を学ぶ',
      targetHeight: 100,
      targetClearTime: 60, // seconds
      allowedStability: [StabilityTier.stable],
      parcelCountMin: 3,
      parcelCountMax: 5,
      difficultyMultiplier: 0.5,
    ),
    2: StageDifficulty(
      stageNumber: 2,
      category: 'easy',
      name: '小さな塔',
      description: '安定した箱で積み重ねる',
      targetHeight: 150,
      targetClearTime: 90,
      allowedStability: [StabilityTier.stable],
      parcelCountMin: 4,
      parcelCountMax: 6,
      difficultyMultiplier: 0.6,
    ),
    3: StageDifficulty(
      stageNumber: 3,
      category: 'easy',
      name: 'バランスの練習',
      description: '基本的なバランス感覚を養う',
      targetHeight: 200,
      targetClearTime: 120,
      allowedStability: [StabilityTier.stable, StabilityTier.moderate],
      parcelCountMin: 5,
      parcelCountMax: 8,
      parcelCountStable: 0.7, // 70% stable
      difficultyMultiplier: 0.7,
    ),
    4: StageDifficulty(
      stageNumber: 4,
      category: 'easy',
      name: 'より高く',
      description: 'より高い塔を目指す',
      targetHeight: 250,
      targetClearTime: 150,
      allowedStability: [StabilityTier.stable, StabilityTier.moderate],
      parcelCountMin: 6,
      parcelCountMax: 10,
      parcelCountStable: 0.6, // 60% stable
      difficultyMultiplier: 0.8,
    ),
    5: StageDifficulty(
      stageNumber: 5,
      category: 'easy',
      name: '上級への架け橋',
      description: '中級へのステップアップ',
      targetHeight: 300,
      targetClearTime: 180,
      allowedStability: [StabilityTier.stable, StabilityTier.moderate],
      parcelCountMin: 7,
      parcelCountMax: 12,
      parcelCountStable: 0.5, // 50% stable
      difficultyMultiplier: 0.9,
    ),

    // ===== INTERMEDIATE STAGES (6-15) =====
    6: StageDifficulty(
      stageNumber: 6,
      category: 'intermediate',
      name: '不安定な台頭',
      description: '不安定な箱の導入',
      targetHeight: 350,
      targetClearTime: 200,
      allowedStability: [StabilityTier.stable, StabilityTier.moderate, StabilityTier.unstable],
      parcelCountMin: 8,
      parcelCountMax: 14,
      parcelCountStable: 0.4, // 40% stable
      difficultyMultiplier: 1.0,
    ),
    7: StageDifficulty(
      stageNumber: 7,
      category: 'intermediate',
      name: 'テクニック試験',
      description: 'スキルが試される',
      targetHeight: 400,
      targetClearTime: 220,
      allowedStability: [StabilityTier.stable, StabilityTier.moderate, StabilityTier.unstable],
      parcelCountMin: 9,
      parcelCountMax: 15,
      parcelCountStable: 0.35,
      difficultyMultiplier: 1.1,
    ),
    8: StageDifficulty(
      stageNumber: 8,
      category: 'intermediate',
      name: '変わった形',
      description: '変わった形の箱が登場',
      targetHeight: 450,
      targetClearTime: 240,
      allowedStability: [StabilityTier.stable, StabilityTier.moderate, StabilityTier.unstable],
      parcelCountMin: 10,
      parcelCountMax: 16,
      parcelCountStable: 0.3, // 30% stable
      difficultyMultiplier: 1.2,
    ),
    9: StageDifficulty(
      stageNumber: 9,
      category: 'intermediate',
      name: 'チャレンジャーの試練',
      description: 'チャレンジプレイヤー向け',
      targetHeight: 500,
      targetClearTime: 260,
      allowedStability: [StabilityTier.stable, StabilityTier.moderate, StabilityTier.unstable],
      parcelCountMin: 11,
      parcelCountMax: 18,
      parcelCountStable: 0.25,
      difficultyMultiplier: 1.3,
    ),
    10: StageDifficulty(
      stageNumber: 10,
      category: 'intermediate',
      name: 'マスターへの道',
      description: 'マスタープレイヤー向け',
      targetHeight: 550,
      targetClearTime: 280,
      allowedStability: [StabilityTier.stable, StabilityTier.moderate, StabilityTier.unstable],
      parcelCountMin: 12,
      parcelCountMax: 20,
      parcelCountStable: 0.2, // 20% stable
      difficultyMultiplier: 1.4,
    ),
    11: StageDifficulty(
      stageNumber: 11,
      category: 'intermediate',
      name: '限界を超えて',
      description: '限界への挑戦',
      targetHeight: 600,
      targetClearTime: 300,
      allowedStability: [StabilityTier.stable, StabilityTier.moderate, StabilityTier.unstable],
      parcelCountMin: 13,
      parcelCountMax: 22,
      parcelCountStable: 0.15,
      difficultyMultiplier: 1.5,
    ),
    12: StageDifficulty(
      stageNumber: 12,
      category: 'intermediate',
      name: '無の境地',
      description: 'すべてを統合する',
      targetHeight: 650,
      targetClearTime: 320,
      allowedStability: [StabilityTier.stable, StabilityTier.moderate, StabilityTier.unstable],
      parcelCountMin: 14,
      parcelCountMax: 24,
      parcelCountStable: 0.1, // 10% stable
      difficultyMultiplier: 1.6,
    ),
    13: StageDifficulty(
      stageNumber: 13,
      category: 'intermediate',
      name: '次元の壁',
      description: 'プロレベルの挑戦',
      targetHeight: 700,
      targetClearTime: 340,
      allowedStability: [StabilityTier.stable, StabilityTier.moderate, StabilityTier.unstable],
      parcelCountMin: 15,
      parcelCountMax: 25,
      parcelCountStable: 0.1,
      difficultyMultiplier: 1.7,
    ),
    14: StageDifficulty(
      stageNumber: 14,
      category: 'intermediate',
      name: '伝説への前夜',
      description: 'レジェンドへの入口',
      targetHeight: 750,
      targetClearTime: 360,
      allowedStability: [StabilityTier.stable, StabilityTier.moderate, StabilityTier.unstable],
      parcelCountMin: 16,
      parcelCountMax: 26,
      parcelCountStable: 0.05, // 5% stable
      difficultyMultiplier: 1.8,
    ),
    15: StageDifficulty(
      stageNumber: 15,
      category: 'intermediate',
      name: 'グランドマスター',
      description: 'マスター級への最後の試練',
      targetHeight: 800,
      targetClearTime: 380,
      allowedStability: [StabilityTier.stable, StabilityTier.moderate, StabilityTier.unstable],
      parcelCountMin: 17,
      parcelCountMax: 28,
      parcelCountStable: 0.05,
      difficultyMultiplier: 1.9,
    ),

    // ===== ADVANCED STAGES (16+) =====
    16: StageDifficulty(
      stageNumber: 16,
      category: 'advanced',
      name: '伝説：始まり',
      description: 'レジェンドが解き放たれる',
      targetHeight: 850,
      targetClearTime: 400,
      allowedStability: [StabilityTier.stable, StabilityTier.moderate, StabilityTier.unstable],
      parcelCountMin: 18,
      parcelCountMax: 30,
      parcelCountStable: 0.05,
      difficultyMultiplier: 2.0,
    ),
    17: StageDifficulty(
      stageNumber: 17,
      category: 'advanced',
      name: '伝説：深淵',
      description: '深淵への旅',
      targetHeight: 900,
      targetClearTime: 420,
      allowedStability: [StabilityTier.stable, StabilityTier.moderate, StabilityTier.unstable],
      parcelCountMin: 19,
      parcelCountMax: 32,
      parcelCountStable: 0.0, // No stable parcels
      difficultyMultiplier: 2.1,
    ),
    18: StageDifficulty(
      stageNumber: 18,
      category: 'advanced',
      name: '伝説：頂点',
      description: '最高峰への道',
      targetHeight: 950,
      targetClearTime: 440,
      allowedStability: [StabilityTier.moderate, StabilityTier.unstable],
      parcelCountMin: 20,
      parcelCountMax: 34,
      parcelCountStable: 0.0,
      difficultyMultiplier: 2.2,
    ),
    19: StageDifficulty(
      stageNumber: 19,
      category: 'advanced',
      name: '伝説：創造',
      description: '新しい可能性の創造',
      targetHeight: 1000,
      targetClearTime: 460,
      allowedStability: [StabilityTier.moderate, StabilityTier.unstable],
      parcelCountMin: 21,
      parcelCountMax: 36,
      parcelCountStable: 0.0,
      difficultyMultiplier: 2.3,
    ),
    20: StageDifficulty(
      stageNumber: 20,
      category: 'advanced',
      name: '伝説：永遠',
      description: '永遠の塔を築く',
      targetHeight: 1050,
      targetClearTime: 480,
      allowedStability: [StabilityTier.moderate, StabilityTier.unstable],
      parcelCountMin: 22,
      parcelCountMax: 38,
      parcelCountStable: 0.0,
      difficultyMultiplier: 2.4,
    ),
  };

  /// Get stage configuration by stage number
  static StageDifficulty? getStageConfig(int stageNumber) {
    return stageConfigs[stageNumber];
  }

  /// Get stage category
  static String getStageCategory(int stageNumber) {
    if (stageNumber >= easyStagesStart && stageNumber <= easyStagesEnd) {
      return 'easy';
    } else if (stageNumber >= intermediateStagesStart && stageNumber <= intermediateStagesEnd) {
      return 'intermediate';
    } else if (stageNumber >= advancedStagesStart) {
      return 'advanced';
    }
    return 'unknown';
  }

  /// Check if stage is valid
  static bool isValidStage(int stageNumber) {
    return stageNumber >= 1 && stageConfigs.containsKey(stageNumber);
  }

  /// Get all easy stages
  static List<int> getEasyStages() {
    return List.generate(easyStagesEnd - easyStagesStart + 1, (i) => easyStagesStart + i);
  }

  /// Get all intermediate stages
  static List<int> getIntermediateStages() {
    return List.generate(intermediateStagesEnd - intermediateStagesStart + 1, (i) => intermediateStagesStart + i);
  }

  /// Get difficulty description
  static String getDifficultyDescription(int stageNumber) {
    final config = getStageConfig(stageNumber);
    if (config == null) return 'Unknown stage';
    return '${config.name} - ${config.description}';
  }
}

/// Configuration for a single stage
class StageDifficulty {
  final int stageNumber;
  final String category; // 'easy', 'intermediate', 'advanced'
  final String name;
  final String description;
  final double targetHeight; // Expected height to clear
  final int targetClearTime; // Expected clear time in seconds
  final List<StabilityTier> allowedStability;
  final int parcelCountMin; // Minimum parcels in stage
  final int parcelCountMax; // Maximum parcels in stage
  final double parcelCountStable; // Proportion of stable parcels (0.0-1.0)
  final double difficultyMultiplier; // Physics difficulty multiplier

  StageDifficulty({
    required this.stageNumber,
    required this.category,
    required this.name,
    required this.description,
    required this.targetHeight,
    required this.targetClearTime,
    required this.allowedStability,
    required this.parcelCountMin,
    required this.parcelCountMax,
    this.parcelCountStable = 0.5, // Default 50% stable
    required this.difficultyMultiplier,
  });

  /// Get estimated clear rate (for analytics)
  double getEstimatedClearRate() {
    // Higher multiplier = harder = lower clear rate
    return 1.0 / (difficultyMultiplier * 1.5);
  }

  /// Get debug info
  String getDebugInfo() {
    return 'Stage $stageNumber: $name, Difficulty: ${(difficultyMultiplier * 100).toStringAsFixed(0)}%, '
        'Target Height: ${targetHeight.toStringAsFixed(0)}';
  }
}
