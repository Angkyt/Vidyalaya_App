class AppUser {
  final String id;
  String firstName;
  String lastName;
  String email;
  String studentId;
  String phone;
  String avatarPath; // local file path or empty
  // Hashed password (sha256(password + salt))
  String passwordHash;
  String salt;
  // ISO timestamp
  String createdAt;

  AppUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.studentId,
    required this.phone,
    required this.passwordHash,
    required this.salt,
    required this.createdAt,
    this.avatarPath = '',
  });

  String get fullName {
    final f = firstName.trim();
    final l = lastName.trim();
    if (f.isEmpty && l.isEmpty) return '';
    if (l.isEmpty) return f;
    if (f.isEmpty) return l;
    return '$f $l';
  }

  String get initials {
    final f = firstName.trim();
    final l = lastName.trim();
    if (f.isEmpty && l.isEmpty) return '?';
    if (l.isEmpty) return f[0].toUpperCase();
    if (f.isEmpty) return l[0].toUpperCase();
    return '${f[0]}${l[0]}'.toUpperCase();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'studentId': studentId,
        'phone': phone,
        'avatarPath': avatarPath,
        'passwordHash': passwordHash,
        'salt': salt,
        'createdAt': createdAt,
      };

  factory AppUser.fromJson(Map<String, dynamic> j) {
    // Migration: handle legacy `fullName` field from v2.0 users
    String first = (j['firstName'] ?? '') as String;
    String last = (j['lastName'] ?? '') as String;
    if (first.isEmpty && last.isEmpty && j['fullName'] != null) {
      final full = (j['fullName'] as String).trim();
      final parts = full.split(RegExp(r'\s+'));
      if (parts.isNotEmpty) {
        first = parts.first;
        if (parts.length > 1) {
          last = parts.sublist(1).join(' ');
        }
      }
    }
    return AppUser(
      id: j['id'] as String,
      firstName: first,
      lastName: last,
      email: j['email'] as String,
      studentId: (j['studentId'] ?? '') as String,
      phone: (j['phone'] ?? '') as String,
      avatarPath: (j['avatarPath'] ?? '') as String,
      passwordHash: j['passwordHash'] as String,
      salt: j['salt'] as String,
      createdAt: j['createdAt'] as String,
    );
  }
}
