/// Typed API errors. UI maps `kind` to a user-facing message.
enum ApiErrorKind {
  network,      // no response (offline, DNS, timeout)
  unauthorized, // 401 — token invalid/expired
  forbidden,    // 403 — role not allowed
  notFound,     // 404
  conflict,     // 409 — duplicate, business rule
  badRequest,   // 400 / 422 — invalid input
  server,       // 5xx
  unknown,
}

class ApiException implements Exception {
  final ApiErrorKind kind;
  final String message;
  final int? statusCode;

  const ApiException(this.kind, this.message, {this.statusCode});

  @override
  String toString() => 'ApiException(${kind.name}: $message)';

  static ApiException fromStatus(int status, String detail) {
    final kind = switch (status) {
      400 || 422 => ApiErrorKind.badRequest,
      401        => ApiErrorKind.unauthorized,
      403        => ApiErrorKind.forbidden,
      404        => ApiErrorKind.notFound,
      409        => ApiErrorKind.conflict,
      >= 500     => ApiErrorKind.server,
      _          => ApiErrorKind.unknown,
    };
    return ApiException(kind, detail, statusCode: status);
  }

  /// Short, user-friendly text.
  String get friendlyMessage => switch (kind) {
        ApiErrorKind.network      => 'No connection. Check your internet.',
        ApiErrorKind.unauthorized => 'Please sign in again.',
        ApiErrorKind.forbidden    => 'You do not have permission for this action.',
        ApiErrorKind.notFound     => 'Not found.',
        ApiErrorKind.conflict     => message,
        ApiErrorKind.badRequest   => message,
        ApiErrorKind.server       => 'Server error. Try again in a moment.',
        ApiErrorKind.unknown      => message,
      };
}
