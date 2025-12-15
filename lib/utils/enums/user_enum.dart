enum UserRole {
  admin,
  cashier,
}

extension UserRoleExt on UserRole {
  String get value {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.cashier:
        return 'cashier';
    }
  }

  static UserRole fromString(String role) {
    return UserRole.values.firstWhere(
      (e) => e.value == role,
      orElse: () => UserRole.cashier,
    );
  }
}




