class User {
  final String email;
  final String? name;
  final bool isAdminOrStaff;
  final String? profileImage;
  final String? role;
  final String? createdAt;
  final String? lastLogin;

  User({
    required this.email,
    this.name,
    required this.isAdminOrStaff,
    this.profileImage,
    this.role = 'user',
    this.createdAt,
    this.lastLogin,
  });

  // Factory constructor untuk membuat User dari Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      email: map['email'],
      name: map['name'],
      isAdminOrStaff: map['role'] == 'admin' || map['role'] == 'staff',
      profileImage: map['profile_image'],
      role: map['role'] ?? 'user',
      createdAt: map['created_at'],
      lastLogin: map['last_login'],
    );
  }

  // Metode untuk mengkonversi User ke Map
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'profile_image': profileImage,
      'created_at': createdAt,
      'last_login': lastLogin,
    };
  }
}
