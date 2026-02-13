class AuthFailure implements Exception {
  final String message;
  final Object? originalError;
  final StackTrace? stackTrace;

  const AuthFailure(this.message, [this.originalError, this.stackTrace]);

  @override
  String toString() {
    if (originalError != null) {
      return 'AuthFailure: $message (Caused by: $originalError)';
    }
    return 'AuthFailure: $message';
  }
}
