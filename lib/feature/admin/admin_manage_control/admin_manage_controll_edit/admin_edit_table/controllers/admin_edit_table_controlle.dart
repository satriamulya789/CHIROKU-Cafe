import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_table/models/admin_edit_table_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_table/services/admin_edit_table_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminEditTableController extends GetxController {
  final TableService _service = TableService();

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
      return table.tableName.toLowerCase().contains(searchQuery.value.toLowerCase());
    }).toList();
  }

  Future<void> fetchTables() async {
    try {
      isLoading.value = true;
      tables.value = await _service.fetchTables();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch tables: $e',
          snackPosition: SnackPosition.BOTTOM);
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
      Get.snackbar('Success', 'Table created successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to create table: $e',
          snackPosition: SnackPosition.BOTTOM);
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
      Get.snackbar('Success', 'Table updated successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update table: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteTable(int id) async {
    try {
      isLoading.value = true;
      await _service.deleteTable(id);
      await fetchTables();
      Get.snackbar('Success', 'Table deleted successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete table: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateForm() {
    if (tableNameController.text.isEmpty) {
      Get.snackbar('Error', 'Table name is required', 
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    if (capacityController.text.isEmpty) {
      Get.snackbar('Error', 'Capacity is required', 
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    final capacity = int.tryParse(capacityController.text);
    if (capacity == null || capacity < 1) {
      Get.snackbar('Error', 'Capacity must be at least 1', 
          snackPosition: SnackPosition.BOTTOM);
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