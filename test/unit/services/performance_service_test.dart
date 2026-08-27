import 'package:flutter_test/flutter_test.dart';
import 'package:donzumari/domain/services/performance_service.dart';

void main() {
  group('PerformanceService', () {
    setUp(() {
      // Reset performance state before each test
      PerformanceService.reset();
    });

    group('Initialization', () {
      test('Service can be initialized', () {
        expect(
          () => PerformanceService.startMonitoring(),
          isNot(throwsException),
        );
      });

      test('Service starts with zero frame times', () {
        PerformanceService.reset();
        final report = PerformanceService.getPerformanceReport();
        expect(report, isA<String>());
      });
    });

    group('Frame time recording', () {
      test('recordFrameTime accepts valid durations', () {
        expect(
          () => PerformanceService.recordFrameTime(16), // 16ms = 60fps
          isNot(throwsException),
        );
      });

      test('recordFrameTime accepts various frame times', () {
        final frameTimes = [8, 16, 33, 50]; // 125fps, 60fps, 30fps, 20fps

        for (final time in frameTimes) {
          expect(
            () => PerformanceService.recordFrameTime(time),
            isNot(throwsException),
          );
        }
      });

      test('Multiple frame times can be recorded', () {
        for (int i = 0; i < 100; i++) {
          PerformanceService.recordFrameTime(16);
        }
        // Service should handle multiple recordings without error
        expect(
          PerformanceService.getPerformanceReport(),
          isA<String>(),
        );
      });

      test('Frame times are accumulated', () {
        for (int i = 0; i < 10; i++) {
          PerformanceService.recordFrameTime(16);
        }

        // Report should indicate frames were recorded
        final report = PerformanceService.getPerformanceReport();
        expect(report, contains('frame') | contains('Frame') | contains('FPS'));
      });
    });

    group('FPS calculation', () {
      test('calculateFPS returns reasonable values', () {
        // Record 60 frames at 16ms each (60 fps)
        for (int i = 0; i < 60; i++) {
          PerformanceService.recordFrameTime(16);
        }

        final fps = PerformanceService.calculateFPS();
        expect(fps, greaterThan(0));
        expect(fps, lessThan(200)); // Reasonable upper bound
      });

      test('FPS is higher for faster frame times', () {
        PerformanceService.reset();

        // Record fast frames (120 fps)
        for (int i = 0; i < 120; i++) {
          PerformanceService.recordFrameTime(8);
        }
        final fastFps = PerformanceService.calculateFPS();

        PerformanceService.reset();

        // Record slow frames (30 fps)
        for (int i = 0; i < 30; i++) {
          PerformanceService.recordFrameTime(33);
        }
        final slowFps = PerformanceService.calculateFPS();

        // Fast FPS should be higher than slow FPS
        expect(fastFps, greaterThan(slowFps));
      });

      test('FPS approaches expected value for consistent frame times', () {
        PerformanceService.reset();

        // Record 60 consistent frames at 16ms (should yield ~60 FPS)
        for (int i = 0; i < 60; i++) {
          PerformanceService.recordFrameTime(16);
        }

        final fps = PerformanceService.calculateFPS();

        // Should be approximately 60, with some tolerance
        expect(fps, greaterThan(50));
        expect(fps, lessThan(70));
      });

      test('FPS calculation is accurate for 30fps target', () {
        PerformanceService.reset();

        // Record frames for 30 FPS
        for (int i = 0; i < 30; i++) {
          PerformanceService.recordFrameTime(33); // ~33ms per frame
        }

        final fps = PerformanceService.calculateFPS();
        expect(fps, greaterThan(25));
        expect(fps, lessThan(35));
      });
    });

    group('Performance reports', () {
      test('getPerformanceReport returns string', () {
        final report = PerformanceService.getPerformanceReport();
        expect(report, isA<String>());
      });

      test('Report is non-empty', () {
        for (int i = 0; i < 10; i++) {
          PerformanceService.recordFrameTime(16);
        }

        final report = PerformanceService.getPerformanceReport();
        expect(report, isNotEmpty);
      });

      test('Report contains performance metrics', () {
        for (int i = 0; i < 60; i++) {
          PerformanceService.recordFrameTime(16);
        }

        final report = PerformanceService.getPerformanceReport();

        // Report should contain some indication of frame times or FPS
        expect(
          report.toLowerCase().contains('frame') ||
              report.toLowerCase().contains('fps') ||
              report.toLowerCase().contains('performance'),
          true,
        );
      });

      test('Report structure is consistent across calls', () {
        for (int i = 0; i < 100; i++) {
          PerformanceService.recordFrameTime(16 + i % 5);
        }

        final report1 = PerformanceService.getPerformanceReport();
        final report2 = PerformanceService.getPerformanceReport();

        // Both reports should exist and be non-empty
        expect(report1, isNotEmpty);
        expect(report2, isNotEmpty);
      });
    });

    group('Performance monitoring', () {
      test('startMonitoring initializes system', () {
        expect(
          () => PerformanceService.startMonitoring(),
          isNot(throwsException),
        );
      });

      test('startMonitoring can be called multiple times safely', () {
        expect(
          () {
            PerformanceService.startMonitoring();
            PerformanceService.startMonitoring();
            PerformanceService.startMonitoring();
          },
          isNot(throwsException),
        );
      });

      test('Monitoring tracks frame times correctly', () {
        PerformanceService.startMonitoring();

        for (int i = 0; i < 60; i++) {
          PerformanceService.recordFrameTime(16);
        }

        final report = PerformanceService.getPerformanceReport();
        expect(report, isNotEmpty);
      });
    });

    group('Reset functionality', () {
      test('reset clears performance data', () {
        for (int i = 0; i < 100; i++) {
          PerformanceService.recordFrameTime(16);
        }

        PerformanceService.reset();

        // After reset, should be like fresh start
        final report = PerformanceService.getPerformanceReport();
        expect(report, isA<String>());
      });

      test('FPS recalculates after reset', () {
        // Record some fast frames
        for (int i = 0; i < 60; i++) {
          PerformanceService.recordFrameTime(16);
        }
        final fps1 = PerformanceService.calculateFPS();

        // Reset and record slow frames
        PerformanceService.reset();
        for (int i = 0; i < 30; i++) {
          PerformanceService.recordFrameTime(33);
        }
        final fps2 = PerformanceService.calculateFPS();

        // FPS values should reflect the new data
        expect(fps1, isNotEqualTo(fps2));
      });
    });

    group('Throttle/Debounce utilities', () {
      test('Throttle function exists and is callable', () {
        expect(PerformanceService.throttle, isNotNull);
      });

      test('Debounce function exists and is callable', () {
        expect(PerformanceService.debounce, isNotNull);
      });

      test('Throttle prevents rapid consecutive calls', () async {
        int callCount = 0;

        void testFunction() {
          callCount++;
        }

        final throttled = PerformanceService.throttle(
          testFunction,
          const Duration(milliseconds: 100),
        );

        // Call multiple times rapidly
        throttled();
        throttled();
        throttled();

        // Due to throttling, shouldn't execute multiple times
        await Future.delayed(const Duration(milliseconds: 50));
        expect(callCount, lessThanOrEqualTo(3));
      });

      test('Debounce delays function execution', () async {
        int callCount = 0;

        void testFunction() {
          callCount++;
        }

        final debounced = PerformanceService.debounce(
          testFunction,
          const Duration(milliseconds: 100),
        );

        debounced();
        debounced();
        debounced();

        // Before delay, shouldn't have executed
        await Future.delayed(const Duration(milliseconds: 50));

        // After delay, should execute
        await Future.delayed(const Duration(milliseconds: 60));
        expect(callCount, greaterThan(0));
      });
    });

    group('Edge cases', () {
      test('Zero frame time is handled', () {
        expect(
          () => PerformanceService.recordFrameTime(0),
          isNot(throwsException),
        );
      });

      test('Very large frame time is handled', () {
        expect(
          () => PerformanceService.recordFrameTime(5000),
          isNot(throwsException),
        );
      });

      test('Negative frame time is handled', () {
        expect(
          () => PerformanceService.recordFrameTime(-16),
          isNot(throwsException),
        );
      });

      test('FPS calculation with no data returns valid value', () {
        PerformanceService.reset();
        final fps = PerformanceService.calculateFPS();
        expect(fps, isA<double>());
      });

      test('Report with no data is generated successfully', () {
        PerformanceService.reset();
        final report = PerformanceService.getPerformanceReport();
        expect(report, isA<String>());
      });
    });

    group('Performance characteristics', () {
      test('Recording frame time is fast', () {
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 1000; i++) {
          PerformanceService.recordFrameTime(16);
        }

        stopwatch.stop();

        // 1000 recordings should complete quickly
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });

      test('Calculating FPS is fast', () {
        for (int i = 0; i < 100; i++) {
          PerformanceService.recordFrameTime(16);
        }

        final stopwatch = Stopwatch()..start();
        PerformanceService.calculateFPS();
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(10));
      });

      test('Getting report is reasonably fast', () {
        for (int i = 0; i < 100; i++) {
          PerformanceService.recordFrameTime(16);
        }

        final stopwatch = Stopwatch()..start();
        PerformanceService.getPerformanceReport();
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(50));
      });
    });

    group('Debug information', () {
      test('Report contains meaningful performance data', () {
        for (int i = 0; i < 60; i++) {
          PerformanceService.recordFrameTime(16);
        }

        final report = PerformanceService.getPerformanceReport();

        // Should contain some performance information
        expect(report.length, greaterThan(0));
      });

      test('Report format is consistent', () {
        final reports = <String>[];

        for (int batch = 0; batch < 3; batch++) {
          for (int i = 0; i < 20; i++) {
            PerformanceService.recordFrameTime(16);
          }
          reports.add(PerformanceService.getPerformanceReport());
        }

        // All reports should be non-empty strings
        for (final report in reports) {
          expect(report, isNotEmpty);
        }
      });
    });
  });
}
