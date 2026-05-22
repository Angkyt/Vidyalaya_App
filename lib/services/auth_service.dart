import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';

class AuthResult {
  final bool success;
  final AuthError? error;
  final AppUser? user;
  AuthResult.ok(this.user) : success = true, error = null;
  AuthResult.fail(this.error) : success = false, user = null;
}

enum AuthError {
  emptyFields,
  invalidEmail,
  invalidPhone,
  weakPassword,
  passwordMismatch,
  emailNotFound,
  incorrectPassword,
  emailAlreadyRegistered,
  phoneAlreadyRegistered,
  studentIdRequired,
  unknown,
}

extension AuthErrorX on AuthError {
  String get message => switch (this) {
        AuthError.emptyFields => 'Please fill in all required fields.',
        AuthError.invalidEmail => 'Please enter a valid email address.',
        AuthError.invalidPhone =>
          'Please enter a valid phone number (at least 7 digits).',
        AuthError.weakPassword =>
          'Password must be at least 8 characters and include an uppercase letter, a number, and a special character.',
        AuthError.passwordMismatch => 'Passwords do not match.',
        AuthError.emailNotFound =>
          'No account found with this email. Create a new account?',
        AuthError.incorrectPassword =>
          'Incorrect password. Try again or use Forgot Password?',
        AuthError.emailAlreadyRegistered =>
          'An account with this email already exists. Please sign in.',
        AuthError.phoneAlreadyRegistered =>
          'Mobile number already used. Please use a different number.',
        AuthError.studentIdRequired => 'Student ID is required.',
        AuthError.unknown => 'Something went wrong. Please try again.',
      };
}

class AuthService {
  static const _kUsers = 'users_v1';
  static const _kSessionUserId = 'session_user_id_v1';
  static const _kSessionExpiry = 'session_expiry_v1';
  static const _sessionDays = 30;

  static final RegExp emailRe =
      RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$');

  // ---------- Password hashing ----------
  static String _generateSalt([int len = 16]) {
    final r = Random.secure();
    final bytes = List<int>.generate(len, (_) => r.nextInt(256));
    return base64Url.encode(bytes);
  }

  static String _hash(String password, String salt) {
    final bytes = utf8.encode('$salt::$password');
    return sha256.convert(bytes).toString();
  }

  /// New stricter rules:
  /// - min 8 chars
  /// - at least one uppercase letter
  /// - at least one digit
  /// - at least one special character
  static bool isStrong(String p) {
    if (p.length < 8) return false;
    if (!p.contains(RegExp(r'[A-Z]'))) return false;
    if (!p.contains(RegExp(r'\d'))) return false;
    if (!p.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\/`~;]'))) {
      return false;
    }
    return true;
  }

  /// Returns a list of missing rule descriptions for live feedback.
  static List<String> missingPasswordRules(String p) {
    final missing = <String>[];
    if (p.length < 8) missing.add('At least 8 characters');
    if (!p.contains(RegExp(r'[A-Z]'))) missing.add('One uppercase letter');
    if (!p.contains(RegExp(r'\d'))) missing.add('One number');
    if (!p.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\/`~;]'))) {
      missing.add('One special character');
    }
    return missing;
  }

  static bool isValidPhone(String p) {
    final digits = p.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 7;
  }

  // ---------- Storage ----------
  Future<List<AppUser>> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kUsers);
    if (raw == null) return [];
    final List list = jsonDecode(raw) as List;
    return list
        .map((e) => AppUser.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveAll(List<AppUser> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _kUsers, jsonEncode(users.map((u) => u.toJson()).toList()));
  }

  // ---------- Public API ----------
  /// Now returns the user without writing a session — the sign up flow
  /// shows a confirmation screen and then routes to Sign In, so the
  /// caller decides whether to start a session.
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
    if (firstName.trim().isEmpty ||
        lastName.trim().isEmpty ||
        email.trim().isEmpty ||
        phone.trim().isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      return AuthResult.fail(AuthError.emptyFields);
    }
    if (studentId.trim().isEmpty) {
      return AuthResult.fail(AuthError.studentIdRequired);
    }
    if (!emailRe.hasMatch(email.trim())) {
      return AuthResult.fail(AuthError.invalidEmail);
    }
    if (!isValidPhone(phone)) {
      return AuthResult.fail(AuthError.invalidPhone);
    }
    if (!isStrong(password)) {
      return AuthResult.fail(AuthError.weakPassword);
    }
    if (password != confirmPassword) {
      return AuthResult.fail(AuthError.passwordMismatch);
    }

    final users = await _loadAll();
    final existingEmail = users.any(
        (u) => u.email.toLowerCase() == email.trim().toLowerCase());
    if (existingEmail) {
      return AuthResult.fail(AuthError.emailAlreadyRegistered);
    }
    // Compare phone numbers using only their digits, so formatting differences
    // (spaces, dashes, +country codes) don't allow duplicates.
    final newDigits = phone.replaceAll(RegExp(r'\D'), '');
    final existingPhone = users.any((u) =>
        u.phone.replaceAll(RegExp(r'\D'), '') == newDigits &&
        newDigits.isNotEmpty);
    if (existingPhone) {
      return AuthResult.fail(AuthError.phoneAlreadyRegistered);
    }

    final salt = _generateSalt();
    final user = AppUser(
      id: const Uuid().v4(),
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      email: email.trim().toLowerCase(),
      studentId: studentId.trim(),
      phone: phone.trim(),
      passwordHash: _hash(password, salt),
      salt: salt,
      createdAt: DateTime.now().toIso8601String(),
    );
    users.add(user);
    await _saveAll(users);
    if (startSession) await _writeSession(user.id);
    return AuthResult.ok(user);
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.isEmpty) {
      return AuthResult.fail(AuthError.emptyFields);
    }
    if (!emailRe.hasMatch(email.trim())) {
      return AuthResult.fail(AuthError.invalidEmail);
    }

    final users = await _loadAll();
    final user = users.where(
      (u) => u.email.toLowerCase() == email.trim().toLowerCase(),
    );
    if (user.isEmpty) {
      return AuthResult.fail(AuthError.emailNotFound);
    }
    final u = user.first;
    if (_hash(password, u.salt) != u.passwordHash) {
      return AuthResult.fail(AuthError.incorrectPassword);
    }
    await _writeSession(u.id);
    return AuthResult.ok(u);
  }

  Future<AppUser?> currentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_kSessionUserId);
    final expiry = prefs.getInt(_kSessionExpiry);
    if (id == null || expiry == null) return null;
    if (DateTime.now().millisecondsSinceEpoch > expiry) {
      await logout();
      return null;
    }
    final users = await _loadAll();
    final found = users.where((u) => u.id == id);
    return found.isEmpty ? null : found.first;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSessionUserId);
    await prefs.remove(_kSessionExpiry);
  }

  Future<void> _writeSession(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSessionUserId, userId);
    await prefs.setInt(
      _kSessionExpiry,
      DateTime.now()
          .add(const Duration(days: _sessionDays))
          .millisecondsSinceEpoch,
    );
  }

  /// Update user profile. `studentId` cannot be changed (locked field).
  /// Returns null on failure (e.g. phone already used by another account).
  Future<AppUser?> updateProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? avatarPath,
    String? currentPassword,
    String? newPassword,
  }) async {
    final users = await _loadAll();
    final idx = users.indexWhere((u) => u.id == userId);
    if (idx < 0) return null;
    final u = users[idx];

    // If phone is being changed, ensure no other user already has it.
    if (phone != null && phone.trim().isNotEmpty) {
      final newDigits = phone.replaceAll(RegExp(r'\D'), '');
      final taken = users.any((other) =>
          other.id != userId &&
          other.phone.replaceAll(RegExp(r'\D'), '') == newDigits &&
          newDigits.isNotEmpty);
      if (taken) return null;
    }

    if (firstName != null) u.firstName = firstName;
    if (lastName != null) u.lastName = lastName;
    if (email != null) u.email = email.toLowerCase();
    if (phone != null) u.phone = phone;
    if (avatarPath != null) u.avatarPath = avatarPath;

    if (newPassword != null && newPassword.isNotEmpty) {
      if (currentPassword == null ||
          _hash(currentPassword, u.salt) != u.passwordHash) {
        return null;
      }
      if (!isStrong(newPassword)) return null;
      final newSalt = _generateSalt();
      u.salt = newSalt;
      u.passwordHash = _hash(newPassword, newSalt);
    }
    users[idx] = u;
    await _saveAll(users);
    return u;
  }

  /// Permanently delete a user account along with their session.
  /// Course/assignment data is cleaned up separately by the caller
  /// (StudyDataProvider has its own per-user storage keys).
  Future<bool> deleteUser(String userId) async {
    final users = await _loadAll();
    final before = users.length;
    users.removeWhere((u) => u.id == userId);
    if (users.length == before) return false;
    await _saveAll(users);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSessionUserId);
    await prefs.remove(_kSessionExpiry);
    // Wipe per-user study data keys created by StudyDataProvider.
    for (final key in prefs.getKeys().toList()) {
      if (key.contains('_${userId}_')) {
        await prefs.remove(key);
      }
    }
    return true;
  }
}
