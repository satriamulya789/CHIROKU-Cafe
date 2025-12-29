import 'package:chiroku_cafe/shared/models/table_models.dart';
import 'package:chiroku_cafe/shared/repositories/table/table_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class TableManagementPage extends StatefulWidget {
  const TableManagementPage({super.key});

  @override
  State<TableManagementPage> createState() => _TableManagementPageState();
}

class _TableManagementPageState extends State<TableManagementPage> {
  final TableService _tableService = TableService();

  List<TableModel> tables = [];
  bool isLoading = true;
  String selectedFilter = 'all'; // all, available, occupied, reserved

  @override
  void initState() {
    super.initState();
    _loadTables();
  }

  Future<void> _loadTables() async {
    setState(() => isLoading = true);
    try {
      final allTables = await _tableService.getTables();
      setState(() {
        tables = allTables;
      });
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          'Gagal memuat data meja: $e',
          backgroundColor: Colors.red[700],
          colorText: Colors.white,
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  List<TableModel> get filteredTables {
    if (selectedFilter == 'all') return tables;
    return tables.where((table) => table.status == selectedFilter).toList();
  }

  Future<void> _updateTableStatus(TableModel table, String newStatus) async {
    try {
      await _tableService.updateTableStatus(table.id, newStatus);

      Get.snackbar(
        'Berhasil',
        'Status ${table.tableName} diubah menjadi ${_getStatusLabel(newStatus)}',
        backgroundColor: Colors.green[700],
        colorText: Colors.white,
      );

      _loadTables(); // Refresh the list
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengubah status meja: $e',
        backgroundColor: Colors.red[700],
        colorText: Colors.white,
      );
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'available':
        return 'Tersedia';
      case 'occupied':
        return 'Terisi';
      case 'reserved':
        return 'Direservasi';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'available':
        return Colors.green;
      case 'occupied':
        return Colors.orange;
      case 'reserved':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'available':
        return Icons.check_circle;
      case 'occupied':
        return Icons.restaurant;
      case 'reserved':
        return Icons.bookmark;
      default:
        return Icons.table_restaurant;
    }
  }

  void _showEditStatusDialog(TableModel table) {
    String selectedStatus = table.status;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.table_restaurant,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Edit Status Meja',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontStyle: GoogleFonts.montserrat().fontStyle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                table.tableName,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontStyle: GoogleFonts.montserrat().fontStyle,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Pilih Status Baru:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontStyle: GoogleFonts.montserrat().fontStyle,
                ),
              ),
              const SizedBox(height: 12),

              // Status Options
              StatefulBuilder(
                builder: (context, setDialogState) => Column(
                  children: [
                    _buildStatusOption(
                      'available',
                      'Tersedia',
                      'Meja kosong dan siap digunakan',
                      Icons.check_circle,
                      Colors.green,
                      selectedStatus == 'available',
                      (value) => setDialogState(() => selectedStatus = value),
                    ),
                    const SizedBox(height: 8),
                    _buildStatusOption(
                      'reserved',
                      'Direservasi',
                      'Meja dipesan oleh pelanggan',
                      Icons.bookmark,
                      Colors.blue,
                      selectedStatus == 'reserved',
                      (value) => setDialogState(() => selectedStatus = value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Batal',
                      style: TextStyle(
                        fontStyle: GoogleFonts.montserrat().fontStyle,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      if (selectedStatus != table.status) {
                        _updateTableStatus(table, selectedStatus);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Simpan',
                      style: TextStyle(
                        fontStyle: GoogleFonts.montserrat().fontStyle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusOption(
    String value,
    String title,
    String description,
    IconData icon,
    Color color,
    bool isSelected,
    Function(String) onChanged,
  ) {
    return InkWell(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey[400], size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : Colors.black87,
                      fontStyle: GoogleFonts.montserrat().fontStyle,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: GoogleFonts.montserrat().fontStyle,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: color),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTablesList = filteredTables;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Kelola Meja',
          style: TextStyle(
            fontStyle: GoogleFonts.montserrat().fontStyle,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadTables),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Filter:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontStyle: GoogleFonts.montserrat().fontStyle,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('all', 'Semua', tables.length),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'available',
                            'Tersedia',
                            tables.where((t) => t.isAvailable).length,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'occupied',
                            'Terisi',
                            tables.where((t) => t.isOccupied).length,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'reserved',
                            'Direservasi',
                            tables.where((t) => t.isReserved).length,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tables List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredTablesList.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _loadTables,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredTablesList.length,
                      itemBuilder: (context, index) {
                        final table = filteredTablesList[index];
                        return _buildTableCard(table);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, int count) {
    final isSelected = selectedFilter == value;

    return InkWell(
      onTap: () => setState(() => selectedFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontStyle: GoogleFonts.montserrat().fontStyle,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.3)
                    : Theme.of(context).primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).primaryColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableCard(TableModel table) {
    final statusColor = _getStatusColor(table.status);
    final statusIcon = _getStatusIcon(table.status);
    final statusLabel = _getStatusLabel(table.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showEditStatusDialog(table),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Status Indicator
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(statusIcon, color: statusColor, size: 30),
              ),
              const SizedBox(width: 16),

              // Table Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      table.tableName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontStyle: GoogleFonts.montserrat().fontStyle,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.people, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Kapasitas: ${table.capacity}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontStyle: GoogleFonts.montserrat().fontStyle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                          fontStyle: GoogleFonts.montserrat().fontStyle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Edit Button
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.edit,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.table_restaurant, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            selectedFilter == 'all'
                ? 'Belum ada meja yang terdaftar'
                : 'Tidak ada meja dengan status ${_getStatusLabel(selectedFilter).toLowerCase()}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontStyle: GoogleFonts.montserrat().fontStyle,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadTables,
            icon: const Icon(Icons.refresh),
            label: Text(
              'Refresh',
              style: TextStyle(fontStyle: GoogleFonts.montserrat().fontStyle),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
