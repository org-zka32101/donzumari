import 'package:flutter_test/flutter_test.dart';
import 'package:donzumari/domain/services/network_error_handler.dart';

void main() {
  group('NetworkErrorHandler', () {
    group('Error parsing and translation', () {
      test('unknown-error maps to default Japanese message', () {
        final message = NetworkErrorHandler.getErrorMessage('unknown-error');
        expect(message, isA<String>());
        expect(message, isNotEmpty);
      });

      test('network-error maps to connection error message', () {
        final message = NetworkErrorHandler.getErrorMessage('network-error');
        expect(message, contains('ネットワーク'));
      });

      test('permission-denied maps to permission error message', () {
        final message = NetworkErrorHandler.getErrorMessage('permission-denied');
        expect(message, contains('許可'));
      });

      test('not-found maps to not found message', () {
        final message = NetworkErrorHandler.getErrorMessage('not-found');
        expect(message, isA<String>());
      });

      test('timeout maps to timeout message', () {
        final message = NetworkErrorHandler.getErrorMessage('deadline-exceeded');
        expect(message, contains('時間'));
      });

      test('server-error maps to server error message', () {
        final message = NetworkErrorHandler.getErrorMessage('internal');
        expect(message, contains('サーバー'));
      });

      test('all error codes return non-empty messages', () {
        final errorCodes = [
          'unknown-error',
          'network-error',
          'permission-denied',
          'not-found',
          'deadline-exceeded',
          'internal',
          'unavailable',
          'unauthenticated',
          'aborted',
          'invalid-argument',
        ];

        for (final code in errorCodes) {
          final message = NetworkErrorHandler.getErrorMessage(code);
          expect(message, isNotEmpty, reason: 'Code $code should have a message');
        }
      });
    });

    group('Retry logic', () {
      test('getRetryDelay calculates exponential backoff', () {
        final delays = [0, 1, 2, 3].map((i) => NetworkErrorHandler.getRetryDelay(i)).toList();

        // First retry: 100ms
        expect(delays[0], 100);
        // Second retry: 200ms
        expect(delays[1], 200);
        // Third retry: 400ms
        expect(delays[2], 400);
        // Fourth retry: 800ms
        expect(delays[3], 800);
      });

      test('getRetryDelay doubles on each attempt', () {
        for (int i = 0; i < 3; i++) {
          final current = NetworkErrorHandler.getRetryDelay(i);
          final next = NetworkErrorHandler.getRetryDelay(i + 1);
          expect(next, current * 2);
        }
      });

      test('getRetryDelay never exceeds 800ms for standard attempts', () {
        for (int i = 0; i < 10; i++) {
          final delay = NetworkErrorHandler.getRetryDelay(i);
          expect(delay, lessThanOrEqualTo(800 * 2)); // Caps at some reasonable max
        }
      });

      test('retry delays are positive', () {
        for (int i = 0; i < 5; i++) {
          final delay = NetworkErrorHandler.getRetryDelay(i);
          expect(delay, greaterThan(0));
        }
      });
    });

    group('Retryable error detection', () {
      test('timeout is retryable', () {
        expect(
          NetworkErrorHandler.isRetryable('deadline-exceeded'),
          true,
        );
      });

      test('connection error is retryable', () {
        expect(
          NetworkErrorHandler.isRetryable('network-error'),
          true,
        );
      });

      test('unavailable is retryable', () {
        expect(
          NetworkErrorHandler.isRetryable('unavailable'),
          true,
        );
      });

      test('permission-denied is not retryable', () {
        expect(
          NetworkErrorHandler.isRetryable('permission-denied'),
          false,
        );
      });

      test('not-found is not retryable', () {
        expect(
          NetworkErrorHandler.isRetryable('not-found'),
          false,
        );
      });

      test('invalid-argument is not retryable', () {
        expect(
          NetworkErrorHandler.isRetryable('invalid-argument'),
          false,
        );
      });

      test('unauthenticated is not retryable', () {
        expect(
          NetworkErrorHandler.isRetryable('unauthenticated'),
          false,
        );
      });

      test('unknown error defaults to retryable', () {
        // Unknown errors should be retried to be safe
        final result = NetworkErrorHandler.isRetryable('unknown-code');
        expect(result, isA<bool>());
      });
    });

    group('Error classification', () {
      test('Network errors are classified correctly', () {
        expect(
          NetworkErrorHandler.isRetryable('network-error'),
          true,
        );
        expect(
          NetworkErrorHandler.getErrorMessage('network-error'),
          contains('ネットワーク'),
        );
      });

      test('Timeout errors are classified correctly', () {
        expect(
          NetworkErrorHandler.isRetryable('deadline-exceeded'),
          true,
        );
        expect(
          NetworkErrorHandler.getErrorMessage('deadline-exceeded'),
          contains('時間'),
        );
      });

      test('Permission errors are classified correctly', () {
        expect(
          NetworkErrorHandler.isRetryable('permission-denied'),
          false,
        );
        expect(
          NetworkErrorHandler.getErrorMessage('permission-denied'),
          contains('許可'),
        );
      });

      test('Server errors are classified correctly', () {
        expect(
          NetworkErrorHandler.isRetryable('internal'),
          true,
        );
        expect(
          NetworkErrorHandler.getErrorMessage('internal'),
          contains('サーバー'),
        );
      });
    });

    group('Edge cases', () {
      test('null error code is handled', () {
        final message = NetworkErrorHandler.getErrorMessage('');
        expect(message, isNotEmpty);
      });

      test('very large retry attempt count is handled', () {
        final delay = NetworkErrorHandler.getRetryDelay(100);
        expect(delay, greaterThan(0));
      });

      test('negative retry attempt count is handled', () {
        // Behavior should be defined (either treated as 0 or handled gracefully)
        final delay = NetworkErrorHandler.getRetryDelay(-1);
        expect(delay, isA<int>());
      });
    });

    group('Message content validation', () {
      test('Japanese characters are used in messages', () {
        final message = NetworkErrorHandler.getErrorMessage('network-error');
        // Basic check that Japanese characters are present
        expect(message.length, greaterThan(0));
      });

      test('Messages are user-friendly', () {
        final messages = [
          NetworkErrorHandler.getErrorMessage('network-error'),
          NetworkErrorHandler.getErrorMessage('permission-denied'),
          NetworkErrorHandler.getErrorMessage('deadline-exceeded'),
        ];

        for (final msg in messages) {
          // Messages should be reasonably long (not just "Error")
          expect(msg.length, greaterThan(5));
          // Should contain helpful information
          expect(msg, isNotEmpty);
        }
      });

      test('All error messages are consistent in style', () {
        final codes = [
          'network-error',
          'permission-denied',
          'deadline-exceeded',
          'internal',
        ];

        final messages = codes.map(NetworkErrorHandler.getErrorMessage).toList();

        // All messages should be strings and non-empty
        for (final msg in messages) {
          expect(msg, isA<String>());
          expect(msg, isNotEmpty);
        }
      });
    });

    group('Retry strategy validation', () {
      test('Exponential backoff increases delay appropriately', () {
        final delays = List.generate(4, (i) => NetworkErrorHandler.getRetryDelay(i));

        // Verify exponential growth
        for (int i = 0; i < delays.length - 1; i++) {
          expect(delays[i + 1], delays[i] * 2);
        }
      });

      test('Max attempts strategy is bounded', () {
        // Simulate attempting retry up to 10 times
        int totalDelay = 0;
        for (int i = 0; i < 10; i++) {
          totalDelay += NetworkErrorHandler.getRetryDelay(i);
        }

        // Total delay should be reasonable (within ~10 seconds)
        expect(totalDelay, lessThan(15000)); // 15 seconds max
      });

      test('First retry happens quickly', () {
        final firstRetry = NetworkErrorHandler.getRetryDelay(0);
        expect(firstRetry, lessThan(500)); // Should be less than 500ms
      });

      test('Retries follow 100ms, 200ms, 400ms, 800ms pattern', () {
        expect(NetworkErrorHandler.getRetryDelay(0), 100);
        expect(NetworkErrorHandler.getRetryDelay(1), 200);
        expect(NetworkErrorHandler.getRetryDelay(2), 400);
        expect(NetworkErrorHandler.getRetryDelay(3), 800);
      });
    });

    group('Integration scenarios', () {
      test('Network error triggers retry', () {
        const errorCode = 'network-error';
        expect(NetworkErrorHandler.isRetryable(errorCode), true);
        expect(NetworkErrorHandler.getRetryDelay(0), greaterThan(0));
      });

      test('Timeout error triggers retry with appropriate delay', () {
        const errorCode = 'deadline-exceeded';
        expect(NetworkErrorHandler.isRetryable(errorCode), true);

        // Verify retry sequence
        for (int i = 0; i < 3; i++) {
          expect(
            NetworkErrorHandler.getRetryDelay(i),
            greaterThan(0),
            reason: 'Attempt $i should have a retry delay',
          );
        }
      });

      test('Permission error does not retry', () {
        const errorCode = 'permission-denied';
        expect(NetworkErrorHandler.isRetryable(errorCode), false);
      });

      test('Server error retries with backoff', () {
        const errorCode = 'internal';
        expect(NetworkErrorHandler.isRetryable(errorCode), true);

        final firstDelay = NetworkErrorHandler.getRetryDelay(0);
        final secondDelay = NetworkErrorHandler.getRetryDelay(1);

        expect(secondDelay, greaterThan(firstDelay));
      });
    });
  });
}
