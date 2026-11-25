import 'package:flutter/foundation.dart';

import '../../domain/user_repository.dart';

sealed class UsersState {
  const UsersState();
}

class UsersLoading extends UsersState {
  const UsersLoading();
}

class UsersLoaded extends UsersState {
  const UsersLoaded(this.page);
  final UsersPage page;
}

class UsersOffline extends UsersState {
  const UsersOffline(this.host, this.reason);
  final String host;
  final String reason;
}

class UsersFailed extends UsersState {
  const UsersFailed(this.message);
  final String message;
}

class UsersViewModel extends ChangeNotifier {
  UsersViewModel(this._repo);

  final UserRepository _repo;
  UsersState _state = const UsersLoading();
  UsersState get state => _state;
  bool _disposed = false;

  Future<void> load() async {
    _set(const UsersLoading());
    try {
      _set(UsersLoaded(await _repo.fetchUsers()));
    } on OfflineException catch (e) {
      _set(UsersOffline(e.host, e.reason));
    } catch (e) {
      _set(UsersFailed('$e'));
    }
  }

  void _set(UsersState s) {
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
