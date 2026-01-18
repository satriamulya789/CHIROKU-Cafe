class SettingErrorModel {
  final String message;
  final String code;
  final int? statusCode;

  SettingErrorModel({
    required this.message,
    required this.code,
    required this.statusCode,
  });

  // ==================== Validation Errors ====================

  /// Error when setting name is empty
  factory SettingErrorModel.settingNameEmpty() {
    return SettingErrorModel(
      message: 'Setting name must not be empty',
      code: 'setting_name_empty',
      statusCode: 400,
    );
  }

  /// Error when setting value is empty
  factory SettingErrorModel.settingValueEmpty() {
    return SettingErrorModel(
      message: 'Setting value must not be empty',
      code: 'setting_value_empty',
      statusCode: 400,
    );
  }

  /// Error when invalid configuration value
  factory SettingErrorModel.invalidConfigurationValue() {
    return SettingErrorModel(
      message: 'Invalid configuration value',
      code: 'invalid_configuration_value',
      statusCode: 400,
    );
  }

  /// Error when invalid setting type
  factory SettingErrorModel.invalidSettingType() {
    return SettingErrorModel(
      message: 'Invalid setting type',
      code: 'invalid_setting_type',
      statusCode: 400,
    );
  }

  /// Error when setting value out of range
  factory SettingErrorModel.valueOutOfRange() {
    return SettingErrorModel(
      message: 'Setting value is out of acceptable range',
      code: 'value_out_of_range',
      statusCode: 400,
    );
  }

  // ==================== Configuration Errors ====================

  /// Error when failed to load settings
  factory SettingErrorModel.failedLoadSettings() {
    return SettingErrorModel(
      message: 'Failed to load settings. Please try again.',
      code: 'failed_load_settings',
      statusCode: 500,
    );
  }

  /// Error when failed to save settings
  factory SettingErrorModel.failedSaveSettings() {
    return SettingErrorModel(
      message: 'Failed to save settings. Please try again.',
      code: 'failed_save_settings',
      statusCode: 500,
    );
  }

  /// Error when failed to update settings
  factory SettingErrorModel.updateSettingsFailed() {
    return SettingErrorModel(
      message: 'Failed to update settings. Please try again.',
      code: 'update_settings_failed',
      statusCode: 500,
    );
  }

  /// Error when failed to delete settings
  factory SettingErrorModel.deleteSettingsFailed() {
    return SettingErrorModel(
      message: 'Failed to delete settings. Please try again.',
      code: 'delete_settings_failed',
      statusCode: 500,
    );
  }

  /// Error when failed to reset settings
  factory SettingErrorModel.resetSettingsFailed() {
    return SettingErrorModel(
      message: 'Failed to reset settings to default. Please try again.',
      code: 'reset_settings_failed',
      statusCode: 500,
    );
  }

  /// Error when setting not found
  factory SettingErrorModel.settingNotFound() {
    return SettingErrorModel(
      message: 'Setting not found',
      code: 'setting_not_found',
      statusCode: 404,
    );
  }

  /// Error when configuration file is corrupted
  factory SettingErrorModel.configurationCorrupted() {
    return SettingErrorModel(
      message: 'Configuration file is corrupted. Please reset to default.',
      code: 'configuration_corrupted',
      statusCode: 500,
    );
  }

  /// Error when failed to export settings
  factory SettingErrorModel.exportSettingsFailed() {
    return SettingErrorModel(
      message: 'Failed to export settings. Please try again.',
      code: 'export_settings_failed',
      statusCode: 500,
    );
  }

  /// Error when failed to import settings
  factory SettingErrorModel.importSettingsFailed() {
    return SettingErrorModel(
      message: 'Failed to import settings. Please try again.',
      code: 'import_settings_failed',
      statusCode: 500,
    );
  }

  /// Error when invalid import file
  factory SettingErrorModel.invalidImportFile() {
    return SettingErrorModel(
      message: 'Invalid import file format',
      code: 'invalid_import_file',
      statusCode: 400,
    );
  }

  // ==================== Theme & Appearance Errors ====================

  /// Error when failed to apply theme
  factory SettingErrorModel.applyThemeFailed() {
    return SettingErrorModel(
      message: 'Failed to apply theme. Please try again.',
      code: 'apply_theme_failed',
      statusCode: 500,
    );
  }

  /// Error when theme not found
  factory SettingErrorModel.themeNotFound() {
    return SettingErrorModel(
      message: 'Theme not found',
      code: 'theme_not_found',
      statusCode: 404,
    );
  }

  /// Error when invalid theme configuration
  factory SettingErrorModel.invalidThemeConfiguration() {
    return SettingErrorModel(
      message: 'Invalid theme configuration',
      code: 'invalid_theme_configuration',
      statusCode: 400,
    );
  }

  // ==================== Language & Localization Errors ====================

  /// Error when failed to change language
  factory SettingErrorModel.changeLanguageFailed() {
    return SettingErrorModel(
      message: 'Failed to change language. Please try again.',
      code: 'change_language_failed',
      statusCode: 500,
    );
  }

  /// Error when language not supported
  factory SettingErrorModel.languageNotSupported() {
    return SettingErrorModel(
      message: 'Language is not supported',
      code: 'language_not_supported',
      statusCode: 400,
    );
  }

  /// Error when failed to load language pack
  factory SettingErrorModel.loadLanguagePackFailed() {
    return SettingErrorModel(
      message: 'Failed to load language pack. Please try again.',
      code: 'load_language_pack_failed',
      statusCode: 500,
    );
  }

  // ==================== Notification Settings Errors ====================

  /// Error when failed to update notification settings
  factory SettingErrorModel.updateNotificationSettingsFailed() {
    return SettingErrorModel(
      message: 'Failed to update notification settings. Please try again.',
      code: 'update_notification_settings_failed',
      statusCode: 500,
    );
  }

  /// Error when notification settings not available
  factory SettingErrorModel.notificationSettingsNotAvailable() {
    return SettingErrorModel(
      message: 'Notification settings are not available on this device',
      code: 'notification_settings_not_available',
      statusCode: 400,
    );
  }

  // ==================== Privacy & Security Errors ====================

  /// Error when failed to update privacy settings
  factory SettingErrorModel.updatePrivacySettingsFailed() {
    return SettingErrorModel(
      message: 'Failed to update privacy settings. Please try again.',
      code: 'update_privacy_settings_failed',
      statusCode: 500,
    );
  }

  /// Error when failed to update security settings
  factory SettingErrorModel.updateSecuritySettingsFailed() {
    return SettingErrorModel(
      message: 'Failed to update security settings. Please try again.',
      code: 'update_security_settings_failed',
      statusCode: 500,
    );
  }

  /// Error when biometric authentication not available
  factory SettingErrorModel.biometricNotAvailable() {
    return SettingErrorModel(
      message: 'Biometric authentication is not available on this device',
      code: 'biometric_not_available',
      statusCode: 400,
    );
  }

  /// Error when failed to enable biometric
  factory SettingErrorModel.enableBiometricFailed() {
    return SettingErrorModel(
      message: 'Failed to enable biometric authentication. Please try again.',
      code: 'enable_biometric_failed',
      statusCode: 500,
    );
  }

  // ==================== Storage & Cache Errors ====================

  /// Error when failed to clear cache
  factory SettingErrorModel.clearCacheFailed() {
    return SettingErrorModel(
      message: 'Failed to clear cache. Please try again.',
      code: 'clear_cache_failed',
      statusCode: 500,
    );
  }

  /// Error when failed to clear data
  factory SettingErrorModel.clearDataFailed() {
    return SettingErrorModel(
      message: 'Failed to clear data. Please try again.',
      code: 'clear_data_failed',
      statusCode: 500,
    );
  }

  /// Error when insufficient storage space
  factory SettingErrorModel.insufficientStorage() {
    return SettingErrorModel(
      message: 'Insufficient storage space',
      code: 'insufficient_storage',
      statusCode: 507,
    );
  }

  /// Error when failed to calculate storage usage
  factory SettingErrorModel.calculateStorageFailed() {
    return SettingErrorModel(
      message: 'Failed to calculate storage usage. Please try again.',
      code: 'calculate_storage_failed',
      statusCode: 500,
    );
  }

  // ==================== Backup & Restore Errors ====================

  /// Error when failed to create backup
  factory SettingErrorModel.createBackupFailed() {
    return SettingErrorModel(
      message: 'Failed to create backup. Please try again.',
      code: 'create_backup_failed',
      statusCode: 500,
    );
  }

  /// Error when failed to restore backup
  factory SettingErrorModel.restoreBackupFailed() {
    return SettingErrorModel(
      message: 'Failed to restore backup. Please try again.',
      code: 'restore_backup_failed',
      statusCode: 500,
    );
  }

  /// Error when backup file not found
  factory SettingErrorModel.backupFileNotFound() {
    return SettingErrorModel(
      message: 'Backup file not found',
      code: 'backup_file_not_found',
      statusCode: 404,
    );
  }

  /// Error when invalid backup file
  factory SettingErrorModel.invalidBackupFile() {
    return SettingErrorModel(
      message: 'Invalid backup file format',
      code: 'invalid_backup_file',
      statusCode: 400,
    );
  }

  // ==================== Network & Server Errors ====================

  /// Error when network connection is unavailable
  factory SettingErrorModel.networkError() {
    return SettingErrorModel(
      message:
          'A network error occurred. Please check your internet connection.',
      code: 'network_error',
      statusCode: null,
    );
  }

  /// Error when request times out
  factory SettingErrorModel.requestTimeOut() {
    return SettingErrorModel(
      message: 'The request timed out. Please try again later.',
      code: 'timeout',
      statusCode: 408,
    );
  }

  /// Error when server encounters an internal error
  factory SettingErrorModel.internalServer() {
    return SettingErrorModel(
      message: 'An internal server error occurred. Please try again later.',
      code: 'internal_server_error',
      statusCode: 500,
    );
  }

  /// Error when an unknown error occurs
  factory SettingErrorModel.unknownError() {
    return SettingErrorModel(
      message: 'An unknown error occurred. Please try again later.',
      code: 'unknown_error',
      statusCode: null,
    );
  }

  // ==================== Permission Errors ====================

  /// Error when user doesn't have permission
  factory SettingErrorModel.permissionDenied() {
    return SettingErrorModel(
      message: 'You do not have permission to change this setting.',
      code: 'permission_denied',
      statusCode: 403,
    );
  }

  /// Error when storage permission is denied
  factory SettingErrorModel.storagePermissionDenied() {
    return SettingErrorModel(
      message: 'Storage permission denied. Please enable it in app settings.',
      code: 'storage_permission_denied',
      statusCode: 403,
    );
  }

  // ==================== Sync Errors ====================

  /// Error when failed to sync settings
  factory SettingErrorModel.syncSettingsFailed() {
    return SettingErrorModel(
      message: 'Failed to sync settings. Please try again.',
      code: 'sync_settings_failed',
      statusCode: 500,
    );
  }

  /// Error when sync is not available
  factory SettingErrorModel.syncNotAvailable() {
    return SettingErrorModel(
      message: 'Settings sync is not available. Please sign in to enable sync.',
      code: 'sync_not_available',
      statusCode: 400,
    );
  }

  /// Error when sync conflict detected
  factory SettingErrorModel.syncConflict() {
    return SettingErrorModel(
      message: 'Sync conflict detected. Please resolve the conflict manually.',
      code: 'sync_conflict',
      statusCode: 409,
    );
  }
}
