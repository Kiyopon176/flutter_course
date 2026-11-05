import 'package:flutter/foundation.dart';

/// Counts down from [from] to 0, one value per second.
/// The debugPrint comes AFTER the yield: when nobody listens any more,
/// the generator stops at its next await and the console goes quiet.
Stream<int> countdown(int from) async* {
  for (var i = from; i >= 0; i--) {
    await Future.delayed(const Duration(seconds: 1));
    yield i;
    debugPrint('tick $i');
  }
}
