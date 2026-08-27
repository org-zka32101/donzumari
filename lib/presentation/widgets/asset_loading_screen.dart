import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/providers/asset_providers.dart';
import '../../domain/services/asset_preloader_service.dart';

/// Screen displayed while assets are preloading
class AssetLoadingScreen extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const AssetLoadingScreen({
    Key? key,
    required this.onComplete,
  }) : super(key: key);

  @override
  ConsumerState<AssetLoadingScreen> createState() =>
      _AssetLoadingScreenState();
}

class _AssetLoadingScreenState extends ConsumerState<AssetLoadingScreen> {
  late double _progress = 0.0;
  late String _status = 'アセットを読み込み中...';

  @override
  void initState() {
    super.initState();
    _setupProgressListener();
  }

  void _setupProgressListener() {
    // Set up callbacks for asset preloader
    AssetPreloaderService.onProgressUpdate = (progress) {
      if (mounted) {
        setState(() {
          _progress = progress;
        });
      }
    };

    AssetPreloaderService.onAssetLoaded = (assetId, type) {
      if (mounted) {
        setState(() {
          _status = 'アセット読み込み中: $assetId';
        });
      }
    };

    AssetPreloaderService.onAssetFailed = (assetId, type, error) {
      if (mounted) {
        setState(() {
          _status = '警告: $assetId の読み込みに失敗しました';
        });
      }
    };

    // Start preload and complete when done
    _startPreload();
  }

  Future<void> _startPreload() async {
    try {
      await AssetPreloaderService.preloadCriticalAssets();

      if (mounted) {
        setState(() {
          _status = 'アセット読み込み完了!';
        });

        // Brief delay to show completion message
        await Future.delayed(const Duration(milliseconds: 500));
        widget.onComplete();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = 'エラー: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Game title/logo
            Text(
              '宅配ドン詰まり',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),

            // Loading indicator
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                value: _progress,
                strokeWidth: 4,
              ),
            ),
            const SizedBox(height: 24),

            // Progress percentage
            Text(
              '${(_progress * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            // Status text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _status,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 48),

            // Asset count
            Text(
              AssetPreloaderService.getLoadingSummary(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clear callbacks
    AssetPreloaderService.onProgressUpdate = null;
    AssetPreloaderService.onAssetLoaded = null;
    AssetPreloaderService.onAssetFailed = null;
    super.dispose();
  }
}

/// Asset loading widget for splash screen integration
class AssetLoadingOverlay extends ConsumerWidget {
  final bool isVisible;
  final Duration transitionDuration;

  const AssetLoadingOverlay({
    Key? key,
    required this.isVisible,
    this.transitionDuration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = AssetPreloaderService.getProgress();

    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: transitionDuration,
      child: AnimatedContainer(
        duration: transitionDuration,
        color: isVisible
            ? Colors.black.withOpacity(0.3)
            : Colors.transparent,
        child: isVisible
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        value: progress,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            : null,
      ),
    );
  }
}
