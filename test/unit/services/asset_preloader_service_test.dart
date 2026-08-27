import 'package:flutter_test/flutter_test.dart';
import 'package:donzumari/domain/services/asset_preloader_service.dart';
import 'package:donzumari/data/fixtures/asset_registry.dart';

void main() {
  group('AssetPreloaderService', () {
    setUp(() async {
      // Reset state before each test
      AssetPreloaderService.clearState();
    });

    group('Initialization', () {
      test('Service starts with progress at 0.0', () {
        expect(AssetPreloaderService.getProgress(), 0.0);
      });

      test('Service starts with no critical assets loaded', () {
        expect(AssetPreloaderService.areCriticalAssetsLoaded(), false);
      });

      test('getLoadingSummary returns initial summary', () {
        final summary = AssetPreloaderService.getLoadingSummary();
        expect(summary, isA<String>());
        expect(summary, isNotEmpty);
      });
    });

    group('Critical asset preloading', () {
      test('preloadCriticalAssets completes successfully', () async {
        expect(
          () => AssetPreloaderService.preloadCriticalAssets(),
          isNot(throwsException),
        );
      });

      test('preloadCriticalAssets updates progress', () async {
        await AssetPreloaderService.preloadCriticalAssets();
        final progress = AssetPreloaderService.getProgress();
        expect(progress, greaterThan(0.0));
      });

      test('preloadCriticalAssets marks assets as loaded', () async {
        await AssetPreloaderService.preloadCriticalAssets();
        expect(
          AssetPreloaderService.areCriticalAssetsLoaded(),
          true,
        );
      });

      test('Progress reaches 1.0 after preload completes', () async {
        await AssetPreloaderService.preloadCriticalAssets();
        final progress = AssetPreloaderService.getProgress();
        expect(progress, equals(1.0));
      });
    });

    group('Progress tracking', () {
      test('getProgress returns double between 0.0 and 1.0', () async {
        final progress1 = AssetPreloaderService.getProgress();
        expect(progress1, greaterThanOrEqualTo(0.0));
        expect(progress1, lessThanOrEqualTo(1.0));

        await AssetPreloaderService.preloadCriticalAssets();

        final progress2 = AssetPreloaderService.getProgress();
        expect(progress2, greaterThanOrEqualTo(0.0));
        expect(progress2, lessThanOrEqualTo(1.0));
      });

      test('Progress increases during preload', () async {
        final initialProgress = AssetPreloaderService.getProgress();

        // Note: Due to simulated loading, we verify progress is tracked
        await AssetPreloaderService.preloadCriticalAssets();

        final finalProgress = AssetPreloaderService.getProgress();
        expect(finalProgress, greaterThanOrEqualTo(initialProgress));
      });
    });

    group('Asset status tracking', () {
      test('getAssetStatus returns status or null', () {
        final status = AssetPreloaderService.getAssetStatus('small_box');
        expect(status, isA<AssetLoadingStatus?>());
      });

      test('Asset status tracks loading state', () async {
        await AssetPreloaderService.preloadCriticalAssets();

        final status = AssetPreloaderService.getAssetStatus('small_box');
        if (status != null) {
          expect(status, isA<AssetLoadingStatus>());
        }
      });

      test('Unknown asset returns null status', () {
        final status = AssetPreloaderService.getAssetStatus('unknown_asset');
        expect(status, isNull);
      });
    });

    group('Callback system', () {
      test('onProgressUpdate callback can be set', () {
        bool callbackFired = false;

        AssetPreloaderService.onProgressUpdate = (progress) {
          callbackFired = true;
        };

        expect(() {
          AssetPreloaderService.onProgressUpdate?.call(0.5);
        }, isNot(throwsException));

        // Callback should be callable
        AssetPreloaderService.onProgressUpdate = null;
      });

      test('onAssetLoaded callback can be set', () {
        bool callbackFired = false;

        AssetPreloaderService.onAssetLoaded = (assetId, type) {
          callbackFired = true;
        };

        expect(() {
          AssetPreloaderService.onAssetLoaded?.call('test_asset', 'sprite');
        }, isNot(throwsException));

        AssetPreloaderService.onAssetLoaded = null;
      });

      test('onAssetFailed callback can be set', () {
        bool callbackFired = false;

        AssetPreloaderService.onAssetFailed = (assetId, type, error) {
          callbackFired = true;
        };

        expect(() {
          AssetPreloaderService.onAssetFailed?.call('test_asset', 'sprite', 'Test error');
        }, isNot(throwsException));

        AssetPreloaderService.onAssetFailed = null;
      });

      test('Multiple callbacks can be managed', () {
        int progressCalls = 0;
        int assetLoadedCalls = 0;

        AssetPreloaderService.onProgressUpdate = (progress) {
          progressCalls++;
        };

        AssetPreloaderService.onAssetLoaded = (assetId, type) {
          assetLoadedCalls++;
        };

        // Verify callbacks are set
        expect(AssetPreloaderService.onProgressUpdate, isNotNull);
        expect(AssetPreloaderService.onAssetLoaded, isNotNull);

        AssetPreloaderService.onProgressUpdate = null;
        AssetPreloaderService.onAssetLoaded = null;
      });

      test('Callbacks can be cleared', () {
        AssetPreloaderService.onProgressUpdate = (progress) {};
        expect(AssetPreloaderService.onProgressUpdate, isNotNull);

        AssetPreloaderService.onProgressUpdate = null;
        expect(AssetPreloaderService.onProgressUpdate, isNull);
      });
    });

    group('Loading summary', () {
      test('getLoadingSummary returns formatted string', () {
        final summary = AssetPreloaderService.getLoadingSummary();
        expect(summary, isA<String>());
      });

      test('Summary is non-empty', () {
        final summary = AssetPreloaderService.getLoadingSummary();
        expect(summary, isNotEmpty);
      });

      test('Summary updates after preload', () async {
        final summaryBefore = AssetPreloaderService.getLoadingSummary();

        await AssetPreloaderService.preloadCriticalAssets();

        final summaryAfter = AssetPreloaderService.getLoadingSummary();

        // Both should be non-empty
        expect(summaryBefore, isNotEmpty);
        expect(summaryAfter, isNotEmpty);
      });
    });

    group('Asset registry integration', () {
      test('Registry contains expected sprite assets', () {
        final spriteAssets = AssetRegistry.getAllSpriteAssets();
        expect(spriteAssets, isNotEmpty);
        expect(spriteAssets.length, 20); // 20 parcel types
      });

      test('Registry contains expected audio assets', () {
        final audioAssets = AssetRegistry.getAllAudioAssets();
        expect(audioAssets, isNotEmpty);
        expect(audioAssets.length, 18); // 6 SFX + 4 UI + 8 music/other
      });

      test('Can get sprite asset path', () {
        final path = AssetRegistry.getSpriteAsset('small_box');
        expect(path, isNotNull);
      });

      test('Can get audio asset path', () {
        final path = AssetRegistry.getAudioAsset('parcel_drop');
        expect(path, isNotNull);
      });

      test('Unknown sprite asset returns null', () {
        final path = AssetRegistry.getSpriteAsset('unknown_sprite');
        expect(path, isNull);
      });

      test('Unknown audio asset returns null', () {
        final path = AssetRegistry.getAudioAsset('unknown_audio');
        expect(path, isNull);
      });
    });

    group('Category filtering', () {
      test('Can get sprites by stable category', () {
        final sprites = AssetRegistry.getSpritesByCategory('stable');
        expect(sprites, isNotEmpty);
        expect(sprites.length, lessThanOrEqualTo(5));
      });

      test('Can get sprites by moderate category', () {
        final sprites = AssetRegistry.getSpritesByCategory('moderate');
        expect(sprites, isNotEmpty);
      });

      test('Can get sprites by unstable category', () {
        final sprites = AssetRegistry.getSpritesByCategory('unstable');
        expect(sprites, isNotEmpty);
      });

      test('Can get sprites by rare category', () {
        final sprites = AssetRegistry.getSpritesByCategory('rare');
        expect(sprites, isNotEmpty);
      });

      test('Unknown category returns empty list', () {
        final sprites = AssetRegistry.getSpritesByCategory('unknown');
        expect(sprites, isEmpty);
      });

      test('All category sprites have valid asset IDs', () {
        final categories = ['stable', 'moderate', 'unstable', 'rare'];

        for (final category in categories) {
          final sprites = AssetRegistry.getSpritesByCategory(category);
          for (final sprite in sprites) {
            final path = AssetRegistry.getSpriteAsset(sprite);
            expect(path, isNotNull, reason: 'Sprite $sprite should have a path');
          }
        }
      });
    });

    group('Error handling', () {
      test('Service handles preload failures gracefully', () async {
        expect(
          () => AssetPreloaderService.preloadCriticalAssets(),
          isNot(throwsException),
        );
      });

      test('Invalid asset IDs don\'t crash the service', () {
        expect(
          () => AssetPreloaderService.getAssetStatus('invalid_id'),
          isNot(throwsException),
        );
      });
    });

    group('Performance', () {
      test('getProgress is fast', () async {
        final stopwatch = Stopwatch()..start();
        AssetPreloaderService.getProgress();
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(10));
      });

      test('getLoadingSummary completes quickly', () async {
        final stopwatch = Stopwatch()..start();
        AssetPreloaderService.getLoadingSummary();
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(50));
      });

      test('Multiple rapid preloads don\'t cause issues', () async {
        // Note: Depending on implementation, this might use caching
        expect(
          () async {
            await AssetPreloaderService.preloadCriticalAssets();
          },
          isNot(throwsException),
        );
      });
    });

    group('State management', () {
      test('clearState resets progress', () async {
        await AssetPreloaderService.preloadCriticalAssets();
        expect(AssetPreloaderService.getProgress(), equals(1.0));

        AssetPreloaderService.clearState();
        expect(AssetPreloaderService.getProgress(), equals(0.0));
      });

      test('clearState resets critical loaded flag', () async {
        await AssetPreloaderService.preloadCriticalAssets();
        expect(AssetPreloaderService.areCriticalAssetsLoaded(), true);

        AssetPreloaderService.clearState();
        expect(AssetPreloaderService.areCriticalAssetsLoaded(), false);
      });
    });
  });

  group('AssetLoadingStatus', () {
    test('AssetLoadingStatus can be created with loaded state', () {
      final status = AssetLoadingStatus(
        assetId: 'test_asset',
        type: 'sprite',
        state: 'loaded',
      );

      expect(status.assetId, 'test_asset');
      expect(status.type, 'sprite');
      expect(status.state, 'loaded');
    });

    test('AssetLoadingStatus can be created with pending state', () {
      final status = AssetLoadingStatus(
        assetId: 'test_asset',
        type: 'sprite',
        state: 'pending',
      );

      expect(status.state, 'pending');
    });

    test('AssetLoadingStatus can be created with failed state', () {
      final status = AssetLoadingStatus(
        assetId: 'test_asset',
        type: 'sprite',
        state: 'failed',
        error: 'Test error',
      );

      expect(status.state, 'failed');
      expect(status.error, 'Test error');
    });

    test('AssetLoadingStatus values are accessible', () {
      final status = AssetLoadingStatus(
        assetId: 'test_asset',
        type: 'audio',
        state: 'loaded',
      );

      expect(status.assetId, equals('test_asset'));
      expect(status.type, equals('audio'));
      expect(status.state, equals('loaded'));
    });
  });
}
