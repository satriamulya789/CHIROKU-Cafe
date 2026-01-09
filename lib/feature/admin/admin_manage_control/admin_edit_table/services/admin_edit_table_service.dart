import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_edit_table/models/admin_edit_table_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_edit_table/repositories/admin_edit_table_repositories.dart';

class TableService {
  final TableRepositories _repository = TableRepositories();

  Future<List<TableModel>> fetchTables() async {
    return await _repository.getTables();
  }

  Future<void> createTable(String tableName, int capacity) async {
    final table = TableModel(tableName: tableName, capacity: capacity);
    await _repository.createTable(table);
  }

  Future<void> updateTable(int id, {
    String? tableName,
    int? capacity,
    String? status,
  }) async {
    final data = <String, dynamic>{};
    if (tableName != null) data['table_name'] = tableName;
    if (capacity != null) data['capacity'] = capacity;
    if (status != null) data['status'] = status;

    await _repository.updateTable(id, data);
  }

  Future<void> deleteTable(int id) async {
    await _repository.deleteTable(id);
  }
}