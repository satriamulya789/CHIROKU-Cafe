import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_table/models/admin_edit_table_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_table/services/admin_edit_table_service.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:chiroku_cafe/shared/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminEditTableController extends GetxController {
  final TableService _service = TableService();
  final snackbar = CustomSnackbar();

  final tables = <TableModel>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;

  // Form controllers
  final tableNameController = TextEditingController();
  final capacityController = TextEditingController();
  final selectedStatus = 'available'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTables();
  }

  @override
  void onClose() {
    tableNameController.dispose();
    capacityController.dispose();
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

  Future<void> fetchTables() async {
    try {
      isLoading.value = true;
      tables.value = await _service.fetchTables();
    } catch (e) {
      snackbar.showErrorSnackbar('Failed to fetch tables: $e');
    } finally {
      isLoading.value = false;
    }
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
      await _service.createTable(
        tableNameController.text,
        int.parse(capacityController.text),
      );
      await fetchTables();
      clearForm();
      Get.back();
      snackbar.showSuccessSnackbar('Table created successfully');
    } catch (e) {
      snackbar.showErrorSnackbar('Failed to create table: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateTable(int id) async {
    try {
      if (!_validateForm()) return;

      isLoading.value = true;
      await _service.updateTable(
        id,
        tableName: tableNameController.text,
        capacity: int.parse(capacityController.text),
        status: selectedStatus.value,
      );
      await fetchTables();
      clearForm();
      Get.back();
      snackbar.showSuccessSnackbar('Table updated successfully');
    } catch (e) {
      snackbar.showErrorSnackbar('Failed to update table: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteTable(int id) async {
    try {
      isLoading.value = true;
      await _service.deleteTable(id);
      await fetchTables();
      snackbar.showSuccessSnackbar('Table deleted successfully');
    } catch (e) {
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
