import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _svc = AuthService();
  AppUser? _user;
  bool _loading = true;

  /// One-shot message + email shown on the Sign In screen after a
  /// successful sign-up. Consumed by SignInScreen on first build and
  /// then cleared so it doesn't reappear.
  String? _postSignupMessage;
  String? _postSignupEmail;

  AppUser? get user => _user;
  bool get loading => _loading;
  bool get isLoggedIn => _user != null;
  String? get postSignupMessage => _postSignupMessage;
  String? get postSignupEmail => _postSignupEmail;

  void setPostSignupBanner({required String message, required String email}) {
    _postSignupMessage = message;
    _postSignupEmail = email;
    notifyListeners();
  }

  void consumePostSignupBanner() {
    _postSignupMessage = null;
    _postSignupEmail = null;
    // No notifyListeners — we don't want a rebuild just for clearing.
  }

  Future<void> bootstrap() async {
    _user = await _svc.currentUser();
    _loading = false;
    notifyListeners();
  }

  Future<AuthResult> login(String email, String password) async {
    final res = await _svc.login(email: email, password: password);
    if (res.success) {
      _user = res.user;
      notifyListeners();
    }
    return res;
  }

  /// Sign up does NOT start a session by default. After sign up the user
  /// is redirected to the Sign In screen.
  Future<AuthResult> register({
    required String firstName,
    required String lastName,
    required String email,
    required String studentId,
    required String phone,
    required String password,
    required String confirmPassword,
    bool startSession = false,
  }) async {
    final res = await _svc.register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      studentId: studentId,
      phone: phone,
      password: password,
      confirmPassword: confirmPassword,
      startSession: startSession,
    );
    if (res.success && startSession) {
      _user = res.user;
      notifyListeners();
    }
    return res;
  }

  Future<void> logout() async {
    await _svc.logout();
    _user = null;
    notifyListeners();
  }

  /// Permanently deletes the current user account and all data tied to it.
  /// Returns true on success. The caller should then push the user to the
  /// Sign In screen via the normal AuthGate rebuild (no manual navigation).
  Future<bool> deleteAccount() async {
    if (_user == null) return false;
    final ok = await _svc.deleteUser(_user!.id);
    if (!ok) return false;
    _user = null;
    notifyListeners();
    return true;
  }

  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? avatarPath,
    String? currentPassword,
    String? newPassword,
  }) async {
    if (_user == null) return false;
    final updated = await _svc.updateProfile(
      userId: _user!.id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      avatarPath: avatarPath,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    if (updated == null) return false;
    _user = updated;
    notifyListeners();
    return true;
  }
}
