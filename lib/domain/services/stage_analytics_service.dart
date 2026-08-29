import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/play_result_model.dart';
import 'difficulty_service.dart';

/// Service for analyzing stage balance and difficulty metrics
class StageAnalyticsService {
  final FirebaseFirestore _firestore;

  StageAnalyticsService({required FirebaseFirestore firestore}) : _firestore = firestore;

  /// Get performance metrics for a specific stage
  Future<StageMetrics> getStageMetrics(int stageNumber, {int daysBack = 30}) async {
    try {
      final config = DifficultyService.getStageConfig(stageNumber);
      if (config == null) {
        throw ArgumentError('Invalid stage number: $stageNumber');
      }

      // Query play results for this stage from the last N days
      final cutoffDate = DateTime.now().subtract(Duration(days: daysBack));
      final querySnapshot = await _firestore
          .collection('playResults')
          .where('stageNumber', isEqualTo: stageNumber)
          .where('playedAt', isGreaterThanOrEqualTo: cutoffDate)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return StageMetrics(
          stageNumber: stageNumber,
          stageName: config.name,
          totalAttempts: 0,
          totalClears: 0,
          totalHeight: 0,
          avgHeight: 0,
          clearRate: 0,
          avgClearTime: 0,
          expectedClearRate: config.getEstimatedClearRate(),
          balanceRating: 'UNKNOWN',
          recommendation: 'No data yet',
        );
      }

      // Calculate metrics
      int clears = 0;
      double totalHeight = 0;
      List<int> clearTimes = [];

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final height = (data['height'] as num?)?.toDouble() ?? 0;
        final collapsed = data['collapsed'] as bool? ?? true;
        final playedAt = (data['playedAt'] as Timestamp?)?.toDate();

        totalHeight += height;

        if (!collapsed) {
          clears++;
          // Estimate clear time based on height (rough estimate)
          final estimatedTime = (height / 100 * 50).toInt();
          clearTimes.add(estimatedTime);
        }
      }

      final totalAttempts = querySnapshot.docs.length;
      final avgHeight = totalHeight / totalAttempts;
      final clearRate = (clears / totalAttempts);
      final avgClearTime = clearTimes.isNotEmpty
          ? clearTimes.reduce((a, b) => a + b) ~/ clearTimes.length
          : 0;

      // Analyze balance
      final expectedClearRate = config.getEstimatedClearRate();
      final balanceAnalysis = _analyzeBalance(
        stageNumber,
        clearRate,
        expectedClearRate,
        avgHeight,
        config.targetHeight,
      );

      return StageMetrics(
        stageNumber: stageNumber,
        stageName: config.name,
        totalAttempts: totalAttempts,
        totalClears: clears,
        totalHeight: totalHeight.toInt(),
        avgHeight: avgHeight,
        clearRate: clearRate,
        avgClearTime: avgClearTime,
        expectedClearRate: expectedClearRate,
        balanceRating: balanceAnalysis['rating'],
        recommendation: balanceAnalysis['recommendation'],
      );
    } catch (e) {
      print('Error getting stage metrics: $e');
      rethrow;
    }
  }

  /// Get metrics for all stages
  Future<List<StageMetrics>> getAllStageMetrics({int daysBack = 30}) async {
    final metrics = <StageMetrics>[];

    for (int stageNum = 1; stageNum <= 20; stageNum++) {
      if (DifficultyService.isValidStage(stageNum)) {
        final stageMetrics = await getStageMetrics(stageNum, daysBack: daysBack);
        metrics.add(stageMetrics);
      }
    }

    return metrics;
  }

  /// Get metrics by difficulty category
  Future<CategoryMetrics> getCategoryMetrics(String category, {int daysBack = 30}) async {
    try {
      List<int> stageNumbers = [];
      if (category == 'easy') {
        stageNumbers = DifficultyService.getEasyStages();
      } else if (category == 'intermediate') {
        stageNumbers = DifficultyService.getIntermediateStages();
      } else if (category == 'advanced') {
        stageNumbers = List.generate(5, (i) => 16 + i); // Stages 16-20
      }

      int totalAttempts = 0;
      int totalClears = 0;
      double totalHeight = 0;
      double totalExpectedClearRate = 0;

      for (final stageNum in stageNumbers) {
        final metrics = await getStageMetrics(stageNum, daysBack: daysBack);
        totalAttempts += metrics.totalAttempts;
        totalClears += metrics.totalClears;
        totalHeight += metrics.totalHeight;
        totalExpectedClearRate += metrics.expectedClearRate;
      }

      final avgClearRate = totalAttempts > 0 ? totalClears / totalAttempts : 0;
      final avgHeight = totalAttempts > 0 ? totalHeight / totalAttempts : 0;
      final avgExpectedClearRate = totalExpectedClearRate / stageNumbers.length;

      return CategoryMetrics(
        category: category,
        stageCount: stageNumbers.length,
        totalAttempts: totalAttempts,
        totalClears: totalClears,
        avgClearRate: avgClearRate,
        avgHeight: avgHeight,
        expectedClearRate: avgExpectedClearRate,
      );
    } catch (e) {
      print('Error getting category metrics: $e');
      rethrow;
    }
  }

  /// Analyze balance for a stage and provide recommendations
  Map<String, dynamic> _analyzeBalance(
    int stageNumber,
    double actualClearRate,
    double expectedClearRate,
    double actualHeight,
    double targetHeight,
  ) {
    // Define acceptable range: 70-90% of expected clear rate
    final minAcceptable = expectedClearRate * 0.7;
    final maxAcceptable = expectedClearRate * 0.9;

    String rating;
    String recommendation;

    if (actualClearRate < minAcceptable) {
      // Too hard
      rating = 'TOO_HARD';
      recommendation = 'Stage is too difficult. Consider reducing parcel instability or increasing target time.';
    } else if (actualClearRate > maxAcceptable * 1.3) {
      // Too easy
      rating = 'TOO_EASY';
      recommendation = 'Stage is too easy. Consider increasing parcel count or introducing more unstable parcels.';
    } else if (actualClearRate >= minAcceptable && actualClearRate <= maxAcceptable) {
      // Perfect balance
      rating = 'BALANCED';
      recommendation = 'Stage difficulty is well-balanced.';
    } else {
      // Slightly off
      rating = 'SLIGHTLY_HARD';
      recommendation = 'Stage is slightly harder than expected. Monitor player feedback.';
    }

    return {
      'rating': rating,
      'recommendation': recommendation,
      'clearRateDifference': actualClearRate - expectedClearRate,
      'heightDifference': actualHeight - targetHeight,
    };
  }

  /// Generate balance report
  Future<String> generateBalanceReport({int daysBack = 30}) async {
    try {
      final report = StringBuffer();
      report.writeln('='.padRight(80, '='));
      report.writeln('DONZUMARI STAGE BALANCE REPORT');
      report.writeln('Generated: ${DateTime.now()}');
      report.writeln('Analysis Period: Last $daysBack days');
      report.writeln('='.padRight(80, '='));
      report.writeln('');

      // Easy stages
      report.writeln('📊 EASY STAGES (1-5)');
      report.writeln('-'.padRight(80, '-'));
      final easyMetrics = await getCategoryMetrics('easy', daysBack: daysBack);
      report.writeln('${easyMetrics.getReportLine()}');
      report.writeln('');

      // Intermediate stages
      report.writeln('📊 INTERMEDIATE STAGES (6-15)');
      report.writeln('-'.padRight(80, '-'));
      final intermediateMetrics = await getCategoryMetrics('intermediate', daysBack: daysBack);
      report.writeln('${intermediateMetrics.getReportLine()}');
      report.writeln('');

      // Advanced stages
      report.writeln('📊 ADVANCED STAGES (16+)');
      report.writeln('-'.padRight(80, '-'));
      final advancedMetrics = await getCategoryMetrics('advanced', daysBack: daysBack);
      report.writeln('${advancedMetrics.getReportLine()}');
      report.writeln('');

      // Individual stage details
      report.writeln('📌 DETAILED STAGE ANALYSIS');
      report.writeln('='.padRight(80, '='));

      final allMetrics = await getAllStageMetrics(daysBack: daysBack);
      for (final metrics in allMetrics) {
        report.writeln(metrics.getDetailedReport());
      }

      report.writeln('');
      report.writeln('='.padRight(80, '='));
      report.writeln('END OF REPORT');

      return report.toString();
    } catch (e) {
      print('Error generating balance report: $e');
      rethrow;
    }
  }

  /// Identify problematic stages
  Future<List<ProblematicStage>> getProblematicStages({int daysBack = 30}) async {
    try {
      final problematic = <ProblematicStage>[];
      final allMetrics = await getAllStageMetrics(daysBack: daysBack);

      for (final metrics in allMetrics) {
        if (metrics.totalAttempts < 5) {
          // Need at least 5 attempts for meaningful analysis
          continue;
        }

        if (metrics.balanceRating == 'TOO_HARD' || metrics.balanceRating == 'TOO_EASY') {
          problematic.add(ProblematicStage(
            stageNumber: metrics.stageNumber,
            stageName: metrics.stageName,
            issue: metrics.balanceRating,
            clearRate: metrics.clearRate,
            expectedClearRate: metrics.expectedClearRate,
            recommendation: metrics.recommendation,
          ));
        }
      }

      return problematic;
    } catch (e) {
      print('Error getting problematic stages: $e');
      rethrow;
    }
  }
}

/// Metrics for a single stage
class StageMetrics {
  final int stageNumber;
  final String stageName;
  final int totalAttempts;
  final int totalClears;
  final int totalHeight;
  final double avgHeight;
  final double clearRate;
  final int avgClearTime;
  final double expectedClearRate;
  final String balanceRating;
  final String recommendation;

  StageMetrics({
    required this.stageNumber,
    required this.stageName,
    required this.totalAttempts,
    required this.totalClears,
    required this.totalHeight,
    required this.avgHeight,
    required this.clearRate,
    required this.avgClearTime,
    required this.expectedClearRate,
    required this.balanceRating,
    required this.recommendation,
  });

  String getDetailedReport() {
    final ratingEmoji = _getRatingEmoji(balanceRating);
    final lines = [
      '',
      'Stage $stageNumber: $stageName $ratingEmoji',
      '  Attempts: $totalAttempts | Clears: $totalClears | Clear Rate: ${(clearRate * 100).toStringAsFixed(1)}%',
      '  Expected: ${(expectedClearRate * 100).toStringAsFixed(1)}% | Avg Height: ${avgHeight.toStringAsFixed(0)}',
      '  💡 $recommendation',
    ];
    return lines.join('\n');
  }

  String _getRatingEmoji(String rating) {
    switch (rating) {
      case 'BALANCED':
        return '✅';
      case 'TOO_EASY':
        return '😴';
      case 'TOO_HARD':
        return '😤';
      case 'SLIGHTLY_HARD':
        return '⚠️';
      default:
        return '❓';
    }
  }
}

/// Metrics for a category of stages
class CategoryMetrics {
  final String category;
  final int stageCount;
  final int totalAttempts;
  final int totalClears;
  final double avgClearRate;
  final double avgHeight;
  final double expectedClearRate;

  CategoryMetrics({
    required this.category,
    required this.stageCount,
    required this.totalAttempts,
    required this.totalClears,
    required this.avgClearRate,
    required this.avgHeight,
    required this.expectedClearRate,
  });

  String getReportLine() {
    final categoryName = _getCategoryName(category);
    return '$categoryName: Stages $stageCount | Attempts: $totalAttempts | '
        'Clear Rate: ${(avgClearRate * 100).toStringAsFixed(1)}% | '
        'Expected: ${(expectedClearRate * 100).toStringAsFixed(1)}% | '
        'Avg Height: ${avgHeight.toStringAsFixed(0)}';
  }

  String _getCategoryName(String cat) {
    switch (cat) {
      case 'easy':
        return '🟢 EASY';
      case 'intermediate':
        return '🟡 INTERMEDIATE';
      case 'advanced':
        return '🔴 ADVANCED';
      default:
        return 'UNKNOWN';
    }
  }
}

/// Problematic stage identified
class ProblematicStage {
  final int stageNumber;
  final String stageName;
  final String issue; // 'TOO_EASY' or 'TOO_HARD'
  final double clearRate;
  final double expectedClearRate;
  final String recommendation;

  ProblematicStage({
    required this.stageNumber,
    required this.stageName,
    required this.issue,
    required this.clearRate,
    required this.expectedClearRate,
    required this.recommendation,
  });

  String getReport() {
    return 'Stage $stageNumber ($stageName): $issue\n'
        '  Clear Rate: ${(clearRate * 100).toStringAsFixed(1)}% (Expected: ${(expectedClearRate * 100).toStringAsFixed(1)}%)\n'
        '  ➜ $recommendation';
  }
}
