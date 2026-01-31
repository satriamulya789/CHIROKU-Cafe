import 'package:chiroku_cafe/core/tables/session_table.dart';

class LocalSessionModel {
  final int? id;
  final String userId;
  final String accessToken;
  final String? refreshToken;
  final int? expiresAt;
  final String? userRole;
  final String? userEmail;
  final int createdAt;
  final int updatedAt;

  LocalSessionModel({
    this.id,
    required this.userId,
    required this.accessToken,
    this.refreshToken,
    this.expiresAt,
    this.userRole,
    this.userEmail,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert from Map (database)
  factory LocalSessionModel.fromMap(Map<String, dynamic> map) {
    return LocalSessionModel(
      id: map[SessionTable.columnId] as int?,
      userId: map[SessionTable.columnUserId] as String,
      accessToken: map[SessionTable.columnAccessToken] as String,
      refreshToken: map[SessionTable.columnRefreshToken] as String?,
      expiresAt: map[SessionTable.columnExpiresAt] as int?,
      userRole: map[SessionTable.columnUserRole] as String?,
      userEmail: map[SessionTable.columnUserEmail] as String?,
      createdAt: map[SessionTable.columnCreatedAt] as int,
      updatedAt: map[SessionTable.columnUpdatedAt] as int,
    );
  }

  // Convert to Map (database)
  Map<String, dynamic> toMap() {
    return {
      SessionTable.columnUserId: userId,
      SessionTable.columnAccessToken: accessToken,
      SessionTable.columnRefreshToken: refreshToken,
      SessionTable.columnExpiresAt: expiresAt,
      SessionTable.columnUserRole: userRole,
      SessionTable.columnUserEmail: userEmail,
      SessionTable.columnCreatedAt: createdAt,
      SessionTable.columnUpdatedAt: updatedAt,
    };
  }

  // Check if session is expired
  // Check if session is expired
  bool get isExpired {
    if (expiresAt == null) return false;

    final now = DateTime.now().millisecondsSinceEpoch;
    final isExpired = now > expiresAt!;

    if (isExpired) {
      print('⚠️ Session Expired Comparison: NOW($now) > EXP($expiresAt)');
      print('   Diff: ${now - expiresAt!}ms');
    } else {
      print('✅ Session Valid: NOW($now) <= EXP($expiresAt)');
    }

    return isExpired;
  }

  // Copy with
  LocalSessionModel copyWith({
    int? id,
    String? userId,
    String? accessToken,
    String? refreshToken,
    int? expiresAt,
    String? userRole,
    String? userEmail,
    int? createdAt,
    int? updatedAt,
  }) {
    return LocalSessionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      userRole: userRole ?? this.userRole,
      userEmail: userEmail ?? this.userEmail,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'LocalSessionModel(id: $id, userId: $userId, userRole: $userRole, userEmail: $userEmail, isExpired: $isExpired)';
  }
}
