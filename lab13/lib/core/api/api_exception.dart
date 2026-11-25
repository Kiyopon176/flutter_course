/// Everything that can go wrong between the app and the server.
///
/// `sealed` — a `switch` over an [ApiException] must name every case,
/// so the subclasses have to live in this one library.
sealed class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// No network at all: airplane mode, DNS failure, socket closed.
final class NoConnectionException extends ApiException {
  const NoConnectionException() : super('no connection');
}

/// The server did not answer in time.
final class TimeoutApiException extends ApiException {
  const TimeoutApiException() : super('timeout');
}

/// 401 / 403.
final class UnauthorizedException extends ApiException {
  const UnauthorizedException([super.message = 'unauthorized']);
}

/// 404.
final class NotFoundException extends ApiException {
  const NotFoundException([super.message = 'not found']);
}

/// 5xx.
final class ServerException extends ApiException {
  const ServerException(this.statusCode) : super('server error');

  final int statusCode;

  @override
  String toString() => 'ServerException($statusCode)';
}

/// The server answered, but not with what the contract promised.
final class BadResponseException extends ApiException {
  const BadResponseException(super.message);
}
