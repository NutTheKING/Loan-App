class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.permissions,
    this.idNumber,
    this.phone,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.profilePhotoUrl,
    this.createdAt,
  });

  final String id;
  final String email;
  final String fullName;
  final String role;
  final List<String> permissions;
  final String? idNumber;
  final String? phone;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? address;
  final String? profilePhotoUrl;
  final DateTime? createdAt;

  bool hasPermission(String permission) => permissions.contains(permission);
  bool get canAccessAdmin => hasPermission('dashboard.view');

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      role: json['role'] as String,
      permissions: (json['permissions'] as List? ?? const [])
          .whereType<String>()
          .toList(),
      idNumber: json['idNumber'] as String?,
      phone: json['phone'] as String?,
      dateOfBirth: DateTime.tryParse('${json['dateOfBirth'] ?? ''}'),
      gender: json['gender'] as String?,
      address: json['address'] as String?,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      createdAt: DateTime.tryParse('${json['createdAt'] ?? ''}'),
    );
  }
}

class AuthSession {
  const AuthSession({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  final AuthUser user;
  final String accessToken;
  final String refreshToken;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      user: AuthUser.fromJson(Map<String, dynamic>.from(json['user'] as Map)),
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }
}
