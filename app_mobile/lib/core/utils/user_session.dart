class UserSession {
  static String? id;
  static String? username;
  static String? fullName;
  static String? email;
  static String? role;

  static void saveSession(Map<String, dynamic> userData) {
    // Check cả chữ thường lẫn chữ Hoa để không bao giờ bị sót data
    id = userData['id'] ?? userData['Id'];
    username = userData['username'] ?? userData['Username'];
    fullName = userData['fullName'] ?? userData['FullName']; // Gỡ bẫy ở đây!
    email = userData['email'] ?? userData['Email'];
    role = userData['role'] ?? userData['Role'];
  }

  static void clearSession() {
    id = null;
    username = null;
    fullName = null;
    email = null;
    role = null;
  }
}
