import 'dart:async';
import 'package:flutter/foundation.dart';

/// Service for monitoring and optimizing performance
class PerformanceService {
  static final Map<String, List<int>> _frameTimes = {};
  static final Map<String, int> _lastRecordTime = {};
  static bool _isMonitoring = false;
  static const int _sampleWindowMs = 1000; // Sample every 1 second

  /// Start monitoring performance
  static void startMonitoring() {
    _isMonitoring = true;
    print('📊 Performance monitoring started');
  }

  /// Stop monitoring performance
  static void stopMonitoring() {
    _isMonitoring = false;
    _frameTimes.clear();
    _lastRecordTime.clear();
    print('📊 Performance monitoring stopped');
  }

  /// Record frame time for a specific operation
  static void recordFrame(String operationName, int durationMs) {
    if (!_isMonitoring) return;

    _frameTimes.putIfAbsent(operationName, () => []);
    _frameTimes[operationName]!.add(durationMs);

    // Keep only last 60 samples per operation
    if (_frameTimes[operationName]!.length > 60) {
      _frameTimes[operationName]!.removeAt(0);
    }
  }

  /// Get average frame time for operation
  static double getAverageFrameTime(String operationName) {
    final times = _frameTimes[operationName];
    if (times == null || times.isEmpty) return 0;
    return times.reduce((a, b) => a + b) / times.length;
  }

  /// Get FPS (frames per second) estimate
  static double getEstimatedFPS(String operationName) {
    final avgMs = getAverageFrameTime(operationName);
    if (avgMs <= 0) return 0;
    return 1000 / avgMs;
  }

  /// Check if operation is performing below target FPS (60)
  static bool isPerformanceIssue(String operationName, {double targetFPS = 60}) {
    final fps = getEstimatedFPS(operationName);
    return fps > 0 && fps < targetFPS;
  }

  /// Get performance report
  static Map<String, dynamic> getPerformanceReport() {
    final report = <String, dynamic>{};

    for (final operation in _frameTimes.keys) {
      final times = _frameTimes[operation]!;
      final avgTime = times.reduce((a, b) => a + b) / times.length;
      final maxTime = times.reduce((a, b) => a > b ? a : b);
      final minTime = times.reduce((a, b) => a < b ? a : b);

      report[operation] = {
        'avg_ms': avgTime.toStringAsFixed(2),
        'max_ms': maxTime,
        'min_ms': minTime,
        'fps': (1000 / avgTime).toStringAsFixed(1),
        'samples': times.length,
      };
    }

    return report;
  }

  /// Print performance report to console
  static void printPerformanceReport() {
    if (kDebugMode) {
      final report = getPerformanceReport();
      print('\n📊 === Performance Report ===');
      report.forEach((operation, metrics) {
        print('$operation:');
        print('  Avg: ${metrics['avg_ms']}ms');
        print('  Max: ${metrics['max_ms']}ms');
        print('  Min: ${metrics['min_ms']}ms');
        print('  FPS: ${metrics['fps']}');
        print('  Samples: ${metrics['samples']}');
      });
      print('============================\n');
    }
  }

  /// Execute function with performance tracking
  static Future<T> trackAsync<T>(
    String name,
    Future<T> Function() operation,
  ) async {
    final stopwatch = Stopwatch()..start();
    try {
      return await operation();
    } finally {
      stopwatch.stop();
      recordFrame(name, stopwatch.elapsedMilliseconds);
    }
  }

  /// Execute sync function with performance tracking
  static T trackSync<T>(
    String name,
    T Function() operation,
  ) {
    final stopwatch = Stopwatch()..start();
    try {
      return operation();
    } finally {
      stopwatch.stop();
      recordFrame(name, stopwatch.elapsedMilliseconds);
    }
  }

  /// Memory optimization: suggest cache clearing if needed
  static bool shouldClearCaches() {
    // Suggest clearing after 60 minutes of gameplay
    return false; // TODO: Implement based on memory pressure
  }

  /// Get optimal sprite cache size based on device memory
  static int getOptimalCacheSize() {
    // TODO: Query device memory and return appropriate cache size
    return 50; // Default to 50 sprites
  }

  /// Check if device is in low memory condition
  static bool isLowMemory() {
    // TODO: Implement based on device memory
    return false;
  }

  /// Get debug info
  static String getDebugInfo() {
    return 'Performance: Monitoring=$_isMonitoring, Operations=${_frameTimes.length}';
  }

  /// Clear all performance data
  static void clearData() {
    _frameTimes.clear();
    _lastRecordTime.clear();
    print('🗑️ Performance data cleared');
  }
}

/// Performance monitoring decorator for Riverpod providers
class PerformanceMonitor {
  static Future<T> measureProvider<T>(
    String providerName,
    Future<T> Function() provider,
  ) async {
    return PerformanceService.trackAsync(
      'provider:$providerName',
      provider,
    );
  }

  static T measureSync<T>(
    String operationName,
    T Function() operation,
  ) {
    return PerformanceService.trackSync(
      operationName,
      operation,
    );
  }
}

/// Throttle rapid calls to function
class ThrottledFunction<T> {
  final Function<Future<T> Function()> function;
  final Duration throttleDuration;
  DateTime? _lastCall;
  Timer? _timer;

  ThrottledFunction({
    required this.function,
    this.throttleDuration = const Duration(milliseconds: 500),
  });

  Future<T> call() async {
    final now = DateTime.now();
    if (_lastCall == null || now.difference(_lastCall!) >= throttleDuration) {
      _lastCall = now;
      return await function();
    }
    throw Exception(
      'Function throttled. Wait ${throttleDuration.inMilliseconds}ms',
    );
  }

  void dispose() {
    _timer?.cancel();
  }
}

/// Debounce calls to function
class DebouncedFunction<T> {
  final Function<Future<T> Function()> function;
  final Duration debounceDuration;
  Timer? _timer;

  DebouncedFunction({
    required this.function,
    this.debounceDuration = const Duration(milliseconds: 500),
  });

  Future<T> call() async {
    _timer?.cancel();
    final completer = Completer<T>();
    _timer = Timer(debounceDuration, () async {
      try {
        final result = await function();
        completer.complete(result);
      } catch (e) {
        completer.completeError(e);
      }
    });
    return completer.future;
  }

  void dispose() {
    _timer?.cancel();
  }
}
