import 'package:flutter/foundation.dart';
import 'package:users_api/secure_store.dart';

/// Signed in or not. The token lives in the secure store, not only in memory.
class AuthModel extends ChangeNotifier {
  final _store = SecureStore();

  String? email;
  String? loginError;
  bool restoring = true;

  bool get isLoggedIn => email != null;

  Future<void> restore() async {
    final token = await _store.readToken();
    email = token == null ? null : await _store.readEmail();
    restoring = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    if (!email.contains('@') || password.length < 4) {
      loginError = 'Email or password is not valid';
      notifyListeners();
      return;
    }
    await _store.writeSession(token: 'token-${email.hashCode}', email: email);
    this.email = email;
    loginError = null;
    print('signed in as $email');
    notifyListeners();
  }

  Future<void> logout() async {
    await _store.clear();
    email = null;
    notifyListeners();
  }
}
