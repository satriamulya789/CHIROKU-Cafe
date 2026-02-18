import 'package:chiroku_cafe/core/databases/drift_database.dart';

class UserModel {
  final String id;
  final String fullName;
  final String? email;
  final String? avatarUrl;
  final String role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // ✅ Added for offline-first tracking
  final bool needsSync;
  final bool isDeleted;
  final String? pendingOperation; // 'CREATE', 'UPDATE', 'DELETE'

  UserModel({
    required this.id,
    required this.fullName,
    this.email,
    this.avatarUrl,
    required this.role,
    this.createdAt,
    this.updatedAt,
    this.needsSync = false,
    this.isDeleted = false,
    this.pendingOperation,
  });

  // ==================== FROM JSON (Supabase) ====================
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      needsSync: false, // Supabase data is always synced
      isDeleted: false,
    );
  }

  // ==================== FROM LOCAL DB ====================
  factory UserModel.fromLocal(UsersLocal local) {
    return UserModel(
      id: local.id,
      fullName: local.fullName,
      email: local.email,
      avatarUrl: local.avatarUrl,
      role: local.role,
      createdAt: local.createdAt,
      updatedAt: local.updatedAt,
      needsSync: local.needsSync,
      isDeleted: local.isDeleted,
      pendingOperation: local.pendingOperation,
    );
  }

  // ==================== TO LOCAL DB ====================
  UsersLocal toLocal() {
    return UsersLocal(
      id: id,
      fullName: fullName,
      email: email,
      avatarUrl: avatarUrl,
      role: role,
      createdAt: createdAt,
      updatedAt: updatedAt,
      syncedAt: DateTime.now(),
      needsSync: needsSync,
      isDeleted: isDeleted,
      pendingOperation: pendingOperation,
      isLocalOnly: false, // Not local-only if created online
    );
  }

  // ==================== TO JSON (Supabase) ====================
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'avatar_url': avatarUrl,
      'role': role,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // ==================== COPY WITH ====================
  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? avatarUrl,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? needsSync,
    bool? isDeleted,
    String? pendingOperation,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      needsSync: needsSync ?? this.needsSync,
      isDeleted: isDeleted ?? this.isDeleted,
      pendingOperation: pendingOperation ?? this.pendingOperation,
    );
  }

  // ==================== HELPERS ====================

  /// Check if this is a temporary (offline-created) user
  bool get isTemporary => id.startsWith('temp_');

  /// Check if this user needs to be synced to server
  bool get requiresSync => needsSync || isTemporary;

  /// Get display name (for UI)
  String get displayName => fullName.isEmpty ? email ?? 'Unknown' : fullName;

  /// Check if user has valid email
  bool get hasEmail => email != null && email!.isNotEmpty;

  @override
  String toString() {
    return 'UserModel(id: $id, fullName: $fullName, email: $email, '
        'role: $role, needsSync: $needsSync, isDeleted: $isDeleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
