import 'package:myapp/models/user.dart';

class AuthProvider {
  static User? currentUser;

  // Login method dengan handling state user
  static void login(User user) {
    currentUser = user;
  }

  // Logout method dengan cleaning state
  static void logout() {
    currentUser = null;
  }

  // Getter untuk nama user dengan fallback
  static String get currentUserName => currentUser?.email ?? 'Pengguna Umum';

  // Check login status
  static bool get isLoggedIn => currentUser != null;

  // Check admin/staff privileges
  static bool get isAdminOrStaff => currentUser?.isAdminOrStaff ?? false;

  // Mendapatkan role user
  static String get userRole =>
      currentUser?.isAdminOrStaff == true ? 'admin' : 'user';
}
