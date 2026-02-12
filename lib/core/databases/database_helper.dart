import 'package:chiroku_cafe/core/databases/drift_database.dart';
import 'package:get/get.dart';
import 'dart:developer';

class DatabaseHelper extends GetxService {
  late final AppDatabase database;

  Future<DatabaseHelper> init() async {
    log('🚀 Initializing DatabaseHelper...');
    database = AppDatabase();
    log('✅ DatabaseHelper initialized');
    return this;
  }

  @override
  void onClose() {
    database.close();
    super.onClose();
  }
}