import 'package:chiroku_cafe/core/network/network_info.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_table/models/admin_edit_table_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_table/services/admin_edit_table_service.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_table/services/tables_sync_service.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:chiroku_cafe/shared/widgets/custom_snackbar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:developer';

class AdminEditTableController extends GetxController {
  final TableService _service;
  final TablesSyncService _syncService;
  final NetworkInfo _networkInfo;
  final snackbar = CustomSnackbar();

  // Observables
  final tables = <TableModel>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;
  final isOnline = true.obs;
  final isSyncing = false.obs;
  final syncStatus = SyncStatus.idle.obs;

  // Form controllers
  final tableNameController = TextEditingController();
  final capacityController = TextEditingController();
  final selectedStatus = 'available'.obs;

  // Subscriptions
  StreamSubscription<List<TableModel>>? _tablesSubscription;
  StreamSubscription<bool>? _connectivitySubscription;
  StreamSubscription<SyncStatus>? _syncStatusSubscription;

  AdminEditTableController({
    TableService? service,
    TablesSyncService? syncService,
    NetworkInfo? networkInfo,
  }) : _service = service ?? TableService(),
       _syncService = syncService ?? TablesSyncService(),
       _networkInfo = networkInfo ?? NetworkInfoImpl(Connectivity());

  @override
  void onInit() {
    super.onInit();
    log('[Controller] Initializing controller');
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      isLoading.value = true;

      // Initialize service
      await _service.initialize();

      // Subscribe to tables stream (realtime updates)
      _tablesSubscription = _service.watchTables().listen(
        (tablesList) {
          log('[Controller] Received ${tablesList.length} tables from stream');
          tables.value = tablesList;
        },
        onError: (error) {
          log('[Controller] Error in tables stream: $error');
          snackbar.showErrorSnackbar('Error loading tables: $error');
        },
      );

      // Subscribe to connectivity changes
      _connectivitySubscription = _networkInfo.onConnectivityChanged.listen((
        online,
      ) {
        log(
          '[Controller] Connectivity changed: ${online ? "ONLINE" : "OFFLINE"}',
        );
        isOnline.value = online;

        if (online) {
          snackbar.showSuccessSnackbar('Back online - syncing data...');
        } else {
          snackbar.showInfoSnackbar('Offline mode - changes will sync later');
        }
      });

      // Subscribe to sync status
      _syncStatusSubscription = _syncService.syncStatus.listen((status) {
        log('[Controller] Sync status: $status');
        syncStatus.value = status;
        isSyncing.value = status == SyncStatus.syncing;

        if (status == SyncStatus.synced) {
          log('[Controller] Sync completed successfully');
        } else if (status == SyncStatus.error) {
          log('[Controller] Sync failed');
        }
      });

      // Start sync service
      _syncService.startListening();

      // Check initial connectivity
      isOnline.value = await _networkInfo.isConnected;
      log(
        '[Controller] Initial connectivity: ${isOnline.value ? "ONLINE" : "OFFLINE"}',
      );
    } catch (e) {
      log('[Controller] Error initializing: $e');
      snackbar.showErrorSnackbar('Failed to initialize: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    log('[Controller] Disposing controller');
    _tablesSubscription?.cancel();
    _connectivitySubscription?.cancel();
    _syncStatusSubscription?.cancel();
    tableNameController.dispose();
    capacityController.dispose();
    _service.dispose();
    _syncService.dispose();
    super.onClose();
  }

  List<TableModel> get filteredTables {
    if (searchQuery.value.isEmpty) return tables;
    return tables.where((table) {
      return table.tableName.toLowerCase().contains(
        searchQuery.value.toLowerCase(),
      );
    }).toList();
  }

  void setEditTable(TableModel table) {
    tableNameController.text = table.tableName;
    capacityController.text = table.capacity.toString();
    selectedStatus.value = table.status;
  }

  Future<void> createTable() async {
    try {
      if (!_validateForm()) return;

      isLoading.value = true;
      log('[Controller] Creating table: ${tableNameController.text}');

      await _service.createTable(
        tableNameController.text,
        int.parse(capacityController.text),
      );

      clearForm();
      Get.back();

      if (isOnline.value) {
        snackbar.showSuccessSnackbar('Table created successfully');
      } else {
        snackbar.showSuccessSnackbar('Table created offline - will sync later');
      }
    } catch (e) {
      log('[Controller] Error creating table: $e');
      snackbar.showErrorSnackbar('Failed to create table: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateTable(int id) async {
    try {
      if (!_validateForm()) return;

      isLoading.value = true;
      log('[Controller] Updating table: $id');

      await _service.updateTable(
        id,
        tableName: tableNameController.text,
        capacity: int.parse(capacityController.text),
        status: selectedStatus.value,
      );

      clearForm();
      Get.back();

      if (isOnline.value) {
        snackbar.showSuccessSnackbar('Table updated successfully');
      } else {
        snackbar.showSuccessSnackbar('Table updated offline - will sync later');
      }
    } catch (e) {
      log('[Controller] Error updating table: $e');
      snackbar.showErrorSnackbar('Failed to update table: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteTable(int id) async {
    try {
      isLoading.value = true;
      log('[Controller] Deleting table: $id');

      await _service.deleteTable(id);

      if (isOnline.value) {
        snackbar.showSuccessSnackbar('Table deleted successfully');
      } else {
        snackbar.showSuccessSnackbar('Table deleted offline - will sync later');
      }
    } catch (e) {
      log('[Controller] Error deleting table: $e');
      final errorMessage = e.toString();

      if (errorMessage.contains('23503')) {
        _showCannotDeleteTableDialog();
      } else {
        snackbar.showErrorSnackbar('Failed to delete table: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Manual sync trigger
  Future<void> syncNow() async {
    log('[Controller] Manual sync triggered');

    if (!isOnline.value) {
      snackbar.showErrorSnackbar('Cannot sync - device is offline');
      return;
    }

    try {
      await _syncService.syncNow();
      snackbar.showSuccessSnackbar('Sync completed');
    } catch (e) {
      log('[Controller] Manual sync failed: $e');
      snackbar.showErrorSnackbar('Sync failed: $e');
    }
  }

  void _showCannotDeleteTableDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Cannot Delete Table', style: AppTypography.h5),
        content: Text(
          'This table is still referenced by existing orders. You must complete or delete all associated orders before this table can be removed from the system.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brownNormal,
            ),
            child: Text(
              'Understood',
              style: AppTypography.button.copyWith(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  void showInfoSnackbar(String message) {
    Get.snackbar(
      'Info',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.blueNormal,
      colorText: AppColors.white,
      duration: const Duration(seconds: 2),
    );
  }

  bool _validateForm() {
    if (tableNameController.text.isEmpty) {
      snackbar.showErrorSnackbar('Table name is required');
      return false;
    }
    if (capacityController.text.isEmpty) {
      snackbar.showErrorSnackbar('Capacity is required');
      return false;
    }
    final capacity = int.tryParse(capacityController.text);
    if (capacity == null || capacity < 1) {
      snackbar.showErrorSnackbar('Capacity must be at least 1');
      return false;
    }
    return true;
  }

  void clearForm() {
    tableNameController.clear();
    capacityController.clear();
    selectedStatus.value = 'available';
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }
}
