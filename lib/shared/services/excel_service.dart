import 'dart:io';
import 'package:chiroku_cafe/shared/models/report/report_transaction_model.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xls;
import 'package:share_plus/share_plus.dart';

class ExcelService {
  static Future<void> exportTransactionsToExcel(
    List<ReportTransaction> transactions,
  ) async {
    // Create a new Excel document.
    final xls.Workbook workbook = xls.Workbook();
    // Accessing leaf sheet of the workbook via index.
    final xls.Worksheet sheet = workbook.worksheets[0];
    sheet.name = 'Transactions';

    // Headers
    sheet.getRangeByIndex(1, 1).setText('ID');
    sheet.getRangeByIndex(1, 2).setText('Date');
    sheet.getRangeByIndex(1, 3).setText('Cashier');
    sheet.getRangeByIndex(1, 4).setText('Customer');
    sheet.getRangeByIndex(1, 5).setText('Table');
    sheet.getRangeByIndex(1, 6).setText('Payment');
    sheet.getRangeByIndex(1, 7).setText('Status');
    sheet.getRangeByIndex(1, 8).setText('Total');

    // Style headers
    final xls.Style headerStyle = workbook.styles.add('headerStyle');
    headerStyle.fontColor = '#FFFFFF';
    headerStyle.backColor = '#4E342E'; // brownNormal
    headerStyle.bold = true;
    sheet.getRangeByName('A1:H1').cellStyle = headerStyle;

    // Data
    for (int i = 0; i < transactions.length; i++) {
      final t = transactions[i];
      final row = i + 2;
      sheet.getRangeByIndex(row, 1).setText(t.id.toString());
      sheet
          .getRangeByIndex(row, 2)
          .setText(DateFormat('yyyy-MM-dd HH:mm').format(t.createdAt));
      sheet.getRangeByIndex(row, 3).setText(t.cashierName);
      sheet.getRangeByIndex(row, 4).setText(t.customerName ?? '-');
      sheet.getRangeByIndex(row, 5).setText(t.tableName ?? '-');
      sheet
          .getRangeByIndex(row, 6)
          .setText(t.paymentMethod?.toUpperCase() ?? 'CASH');
      sheet.getRangeByIndex(row, 7).setText(t.orderStatus.toUpperCase());
      sheet.getRangeByIndex(row, 8).setNumber(t.total);
    }

    // Auto-fit columns
    sheet.getRangeByName('A1:H${transactions.length + 1}').autoFitColumns();

    // Save and launch
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final String path = (await getTemporaryDirectory()).path;
    final String fileName =
        '$path/Transactions_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.xlsx';
    final File file = File(fileName);
    await file.writeAsBytes(bytes, flush: true);

    // Share the file
    await Share.shareXFiles([XFile(fileName)], text: 'Export Transactions');
  }
}
