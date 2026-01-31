class SessionTable {
  static const String tableName = 'sessions';
  
  // Column names
  static const String columnId = 'id';
  static const String columnUserId = 'user_id';
  static const String columnAccessToken = 'access_token';
  static const String columnRefreshToken = 'refresh_token';
  static const String columnExpiresAt = 'expires_at';
  static const String columnUserRole = 'user_role';
  static const String columnUserEmail = 'user_email';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';

  // Create table SQL
  static const String createTableSQL = '''
    CREATE TABLE $tableName (
      $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnUserId TEXT NOT NULL UNIQUE,
      $columnAccessToken TEXT NOT NULL,
      $columnRefreshToken TEXT,
      $columnExpiresAt INTEGER,
      $columnUserRole TEXT,
      $columnUserEmail TEXT,
      $columnCreatedAt INTEGER NOT NULL,
      $columnUpdatedAt INTEGER NOT NULL
    )
  ''';
}