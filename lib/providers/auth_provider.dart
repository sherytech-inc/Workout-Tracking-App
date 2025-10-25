import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _auth = AuthService();
  final UserService _users = UserService();

  User? _user;
  User? get user => _user;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  void init() {
    // subscribe to auth state
    _auth.onAuthStateChanged.listen((u) async {
      _user = u;
      if (_user != null) {
        await _users.ensureUserDocument(_user!);
      }
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      await _auth.signIn(email, password);
    } on FirebaseAuthException catch (e) {
      _setError(_mapAuthError(e));
    } catch (e) {
      _setError('Unexpected error. Try again.');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      final user = await _auth.register(email, password);
      await _users.createUserDocument(user);
    } on FirebaseAuthException catch (e) {
      _setError(_mapAuthError(e));
    } catch (e) {
      _setError('Unexpected error. Try again.');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _auth.signOut();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  void _setError(String? e) {
    _error = e;
    notifyListeners();
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-not-found':
      case 'wrong-password':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'Email already in use.';
      case 'weak-password':
        return 'Password is too weak.';
      default:
        return 'Authentication error. Code: ${e.code}';
    }
  }
}
