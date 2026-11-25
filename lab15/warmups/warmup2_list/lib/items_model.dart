import 'package:flutter/foundation.dart';

import 'items_repository.dart';

/// Four states, sealed: the screen's switch must handle every one of them.
sealed class ItemsState {
  const ItemsState();
}

class Loading extends ItemsState {
  const Loading();
}

class Failed extends ItemsState {
  const Failed(this.message);
  final String message;
}

class Empty extends ItemsState {
  const Empty();
}

class Loaded extends ItemsState {
  const Loaded(this.items);
  final List<String> items;
}

/// "Mounted-free": no BuildContext, no State, no `mounted`. If the provider
/// disposes it mid-request, the `_disposed` flag swallows the late notify.
class ItemsModel extends ChangeNotifier {
  ItemsModel(this._repo); // repository through the constructor → testable

  final ItemsRepository _repo;
  ItemsState _state = const Loading();
  ItemsState get state => _state;
  bool _disposed = false;

  Future<void> load() async {
    _set(const Loading());
    try {
      final items = await _repo.fetchItems();
      _set(items.isEmpty ? const Empty() : Loaded(items));
    } on LoadException catch (e) {
      _set(Failed(e.message));
    }
  }

  void _set(ItemsState s) {
    if (_disposed) return;
    _state = s;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
