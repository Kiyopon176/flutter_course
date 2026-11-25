/// The contract the model depends on. Real or fake — the model cannot tell.
abstract interface class ItemsRepository {
  Future<List<String>> fetchItems();
}

/// Thrown by the repository; the model turns it into an error state.
class LoadException implements Exception {
  const LoadException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// A fake that fails on demand: flip [failNext] or [emptyNext] before a load.
class FakeItemsRepository implements ItemsRepository {
  FakeItemsRepository({
    this.delay = const Duration(milliseconds: 600),
    this.failNext = false,
    this.emptyNext = false,
  });

  final Duration delay;
  bool failNext;
  bool emptyNext;
  int calls = 0;

  static const items = ['Almaty', 'Astana', 'Shymkent', 'Karaganda', 'Aktobe'];

  @override
  Future<List<String>> fetchItems() async {
    calls++;
    await Future<void>.delayed(delay);
    if (failNext) {
      failNext = false; // one failure, then Retry works
      throw const LoadException('Server is down (fake)');
    }
    if (emptyNext) {
      emptyNext = false;
      return const [];
    }
    return items;
  }
}
