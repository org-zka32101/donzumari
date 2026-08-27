import 'package:cloud_firestore/cloud_firestore.dart';

/// Service for handling network errors and providing user-friendly messages
class NetworkErrorHandler {
  // Error types
  static const String networkTimeout = 'network_timeout';
  static const String connectionLost = 'connection_lost';
  static const String serverError = 'server_error';
  static const String permissionDenied = 'permission_denied';
  static const String notFound = 'not_found';
  static const String unknownError = 'unknown_error';

  /// Parse Firebase/Firestore error and return user-friendly message
  static (String errorType, String userMessage) parseError(Object error) {
    if (error is FirebaseException) {
      return _parseFirebaseError(error);
    } else if (error is SocketException) {
      return (networkTimeout, 'ネットワーク接続がタイムアウトしました。接続を確認してください。');
    } else if (error is TimeoutException) {
      return (networkTimeout, 'リクエストがタイムアウトしました。もう一度お試しください。');
    } else if (error is Exception) {
      return (unknownError, error.toString());
    }
    return (unknownError, '予期しないエラーが発生しました。');
  }

  /// Parse Firebase-specific errors
  static (String errorType, String userMessage) _parseFirebaseError(
    FirebaseException error,
  ) {
    switch (error.code) {
      case 'permission-denied':
        return (
          permissionDenied,
          'このアクションの権限がありません。',
        );
      case 'not-found':
        return (
          notFound,
          'リクエストされたデータが見つかりません。',
        );
      case 'unavailable':
        return (
          connectionLost,
          'サービスが一時的に利用不可です。後でお試しください。',
        );
      case 'deadline-exceeded':
        return (
          networkTimeout,
          'リクエストがタイムアウトしました。接続を確認してください。',
        );
      case 'unauthenticated':
        return (
          permissionDenied,
          '認証が必要です。もう一度サインインしてください。',
        );
      case 'resource-exhausted':
        return (
          serverError,
          'リソースが不足しています。しばらく待ってお試しください。',
        );
      case 'failed-precondition':
        return (
          serverError,
          '操作の前提条件が満たされていません。',
        );
      default:
        return (
          unknownError,
          'エラーが発生しました: ${error.code}',
        );
    }
  }

  /// Check if error is retryable
  static bool isRetryable(String errorType) {
    return [
      networkTimeout,
      connectionLost,
      'server_error',
    ].contains(errorType);
  }

  /// Get retry delay in milliseconds (exponential backoff)
  static int getRetryDelay(int attemptNumber) {
    // 100ms, 200ms, 400ms, 800ms, 1600ms...
    return 100 * (1 << attemptNumber.clamp(0, 4));
  }

  /// Get max retry attempts for error type
  static int getMaxRetries(String errorType) {
    switch (errorType) {
      case networkTimeout:
      case connectionLost:
        return 4;
      case 'server_error':
        return 3;
      default:
        return 1;
    }
  }

  /// Get debug info
  static String getDebugInfo() {
    return 'NetworkErrorHandler: supports retry for '
        'timeout(4x), connection(4x), server(3x)';
  }
}

/// Extension for error handling on Futures
extension ErrorHandlingFuture<T> on Future<T> {
  /// Execute with automatic retry on retryable errors
  Future<T> withRetry({
    int maxRetries = 3,
    Duration backoffDuration = const Duration(milliseconds: 100),
  }) async {
    int attempt = 0;
    Object? lastError;

    while (attempt <= maxRetries) {
      try {
        return await this;
      } catch (e) {
        lastError = e;
        final (errorType, _) = NetworkErrorHandler.parseError(e);

        if (!NetworkErrorHandler.isRetryable(errorType) ||
            attempt >= maxRetries) {
          rethrow;
        }

        attempt++;
        final delay = backoffDuration * (1 << (attempt - 1));
        await Future.delayed(delay);
      }
    }

    throw lastError ?? Exception('Unknown error after $maxRetries retries');
  }

  /// Execute with timeout
  Future<T> withTimeout(Duration duration) async {
    return await timeout(
      duration,
      onTimeout: () => throw TimeoutException(
        'Operation exceeded timeout of ${duration.inMilliseconds}ms',
        duration,
      ),
    );
  }
}

/// Custom timeout exception
class TimeoutException implements Exception {
  final String message;
  final Duration timeout;

  TimeoutException(this.message, this.timeout);

  @override
  String toString() => 'TimeoutException: $message';
}

/// Custom socket exception (for offline)
class SocketException implements Exception {
  final String message;

  SocketException(this.message);

  @override
  String toString() => 'SocketException: $message';
}

/// Retry configuration
class RetryConfig {
  final int maxRetries;
  final Duration initialDelay;
  final double backoffMultiplier;
  final Duration maxDelay;

  const RetryConfig({
    this.maxRetries = 3,
    this.initialDelay = const Duration(milliseconds: 100),
    this.backoffMultiplier = 2.0,
    this.maxDelay = const Duration(seconds: 10),
  });

  /// Calculate delay for attempt number
  Duration getDelay(int attemptNumber) {
    final delayMs = (initialDelay.inMilliseconds *
            (backoffMultiplier.pow(attemptNumber - 1)))
        .toInt();
    final clamped = Duration(
      milliseconds: delayMs.clamp(0, maxDelay.inMilliseconds),
    );
    return clamped;
  }
}

extension Pow on double {
  double pow(int exponent) {
    double result = 1.0;
    for (int i = 0; i < exponent; i++) {
      result *= this;
    }
    return result;
  }
}
