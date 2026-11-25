import 'package:users_api/core/api/api_exception.dart';

// What the user reads when something goes wrong.
String describeError(ApiException e) => switch (e) {
  NoConnectionException() => 'No connection',
  TimeoutApiException() => 'The server is too slow',
  UnauthorizedException() => 'Please sign in again',
  NotFoundException() => 'Not found',
  ServerException() => 'Server error, try later',
  BadResponseException() => 'Something went wrong',
};
