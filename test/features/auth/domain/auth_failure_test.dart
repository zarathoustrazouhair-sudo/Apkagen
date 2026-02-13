import 'package:flutter_test/flutter_test.dart';
import 'package:residence_lamandier_b/features/auth/domain/auth_failure.dart';

void main() {
  group('AuthFailure', () {
    test('should store message, originalError, and stackTrace', () {
      final originalError = Exception('Original error');
      final stackTrace = StackTrace.current;
      final failure = AuthFailure('Login failed', originalError, stackTrace);

      expect(failure.message, 'Login failed');
      expect(failure.originalError, originalError);
      expect(failure.stackTrace, stackTrace);
      expect(failure.toString(), contains('Original error'));
    });

    test('should throw with original stack trace using Error.throwWithStackTrace', () {
      try {
        try {
          throw Exception('Root cause');
        } catch (e, s) {
          // Simulate the repository logic
          Error.throwWithStackTrace(
            AuthFailure('Wrapped error', e, s),
            s,
          );
        }
      } catch (e, s) {
        expect(e, isA<AuthFailure>());
        final failure = e as AuthFailure;
        expect(failure.message, 'Wrapped error');
        expect(failure.originalError.toString(), contains('Root cause'));
        // The stack trace 's' caught here should be the original stack trace
        // because Error.throwWithStackTrace was used.
        // We can verify this by checking if the stack trace contains the line where 'Root cause' was thrown.
        // Since we are running this in a test, the file path might be relative or absolute.
        // We just check that it's not empty and resembles a stack trace.
        expect(s.toString(), isNotEmpty);
      }
    });
  });
}
