class ProtectedUsers {
  static const List<String> emails = [
    'satriamulya456@gmail.com',
    'bintangmulya456@gmail.com',
  ];

  static bool isProtected(String? email) {
    if (email == null) return false;
    return emails.contains(email.toLowerCase());
  }
}
