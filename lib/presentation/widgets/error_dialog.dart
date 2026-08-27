import 'package:flutter/material.dart';
import '../../domain/services/network_error_handler.dart';

/// Reusable error dialog widget
class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback onRetry;
  final bool isRetryable;

  const ErrorDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.onRetry,
    this.buttonLabel = '再試行',
    this.isRetryable = true,
  }) : super(key: key);

  factory ErrorDialog.fromException(
    Object error, {
    required VoidCallback onRetry,
  }) {
    final (errorType, userMessage) = NetworkErrorHandler.parseError(error);
    final isRetryable = NetworkErrorHandler.isRetryable(errorType);

    return ErrorDialog(
      title: _getTitleForError(errorType),
      message: userMessage,
      onRetry: onRetry,
      isRetryable: isRetryable,
    );
  }

  static String _getTitleForError(String errorType) {
    switch (errorType) {
      case 'network_timeout':
        return 'ネットワークエラー';
      case 'connection_lost':
        return '接続が失われました';
      case 'server_error':
        return 'サーバーエラー';
      case 'permission_denied':
        return 'アクセスが拒否されました';
      case 'not_found':
        return 'データが見つかりません';
      default:
        return 'エラーが発生しました';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          const SizedBox(height: 16),
          // Show retry hint for retryable errors
          if (isRetryable)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '自動的に数回まで再試行されます',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        if (isRetryable)
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onRetry();
            },
            child: const Text(buttonLabel),
          ),
      ],
    );
  }
}

/// Reusable error snackbar widget
class ErrorSnackBar extends SnackBar {
  factory ErrorSnackBar({
    required String message,
    VoidCallback? onRetry,
    Duration duration = const Duration(seconds: 4),
  }) {
    return ErrorSnackBar._(
      content: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message),
          ),
        ],
      ),
      backgroundColor: Colors.red[600],
      duration: duration,
      action: onRetry != null
          ? SnackBarAction(
              label: '再試',
              textColor: Colors.white,
              onPressed: onRetry,
            )
          : null,
    );
  }

  factory ErrorSnackBar.fromException(
    Object error, {
    VoidCallback? onRetry,
  }) {
    final (_, userMessage) = NetworkErrorHandler.parseError(error);
    return ErrorSnackBar(
      message: userMessage,
      onRetry: onRetry,
    );
  }

  ErrorSnackBar._({
    required Widget content,
    required Color? backgroundColor,
    required Duration duration,
    required SnackBarAction? action,
  }) : super(
    content: content,
    backgroundColor: backgroundColor,
    duration: duration,
    action: action,
  );
}

/// Network status indicator widget
class NetworkStatusIndicator extends StatelessWidget {
  final bool isOnline;
  final Duration animationDuration;

  const NetworkStatusIndicator({
    Key? key,
    required this.isOnline,
    this.animationDuration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isOnline ? 0 : 1,
      duration: animationDuration,
      child: AnimatedContainer(
        duration: animationDuration,
        height: isOnline ? 0 : 48,
        color: Colors.red[600],
        child: Material(
          color: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.signal_cellular_off,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'インターネット接続がありません',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Retry button widget for operations
class RetryButton extends StatefulWidget {
  final Future<void> Function() onRetry;
  final String label;
  final bool isLoading;

  const RetryButton({
    Key? key,
    required this.onRetry,
    this.label = '再試行',
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<RetryButton> createState() => _RetryButtonState();
}

class _RetryButtonState extends State<RetryButton> {
  late bool _isLoading;

  @override
  void initState() {
    super.initState();
    _isLoading = widget.isLoading;
  }

  @override
  void didUpdateWidget(RetryButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLoading != widget.isLoading) {
      setState(() {
        _isLoading = widget.isLoading;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : _handleRetry,
      icon: _isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            )
          : const Icon(Icons.refresh),
      label: Text(widget.label),
    );
  }

  Future<void> _handleRetry() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onRetry();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          ErrorSnackBar.fromException(e),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
