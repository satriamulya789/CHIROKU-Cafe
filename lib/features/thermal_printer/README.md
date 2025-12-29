# Thermal Printer Integration - Chiroku Cafe

## Overview
Fitur thermal printer untuk mencetak struk transaksi menggunakan printer bluetooth thermal. Fitur ini terintegrasi dengan sistem kasir untuk mencetak struk otomatis setelah checkout.

## Package yang Digunakan
- `print_bluetooth_thermal: ^1.1.9` - Untuk koneksi dan print ke printer thermal
- `esc_pos_utils_plus: ^2.0.2` - Untuk format ESC/POS commands

## Struktur Fitur

```
lib/features/thermal_printer/
├── models/
│   └── printer_model.dart          # Model untuk printer, receipt, status
├── repositories/
│   └── thermal_printer_repository.dart  # Logic printer (scan, connect, print)
├── controllers/
│   └── thermal_printer_controller.dart  # State management dengan GetX
├── bindings/
│   └── thermal_printer_binding.dart     # Dependency injection
├── services/
│   └── print_service.dart               # Helper service untuk print dari mana saja
├── printer_settings_page.dart           # UI untuk setup printer
└── thermal_printer.dart                 # Export file
```

## Cara Penggunaan

### 1. Setup Printer (Pertama Kali)

Cashier perlu setup printer sekali, setelah itu printer akan auto-connect:

```dart
// Navigate ke halaman printer settings
Get.toNamed('/printer-settings');

// Atau menggunakan PrintService
PrintService().openPrinterSettings();
```

Di halaman Printer Settings, cashier bisa:
- Scan printer bluetooth yang sudah dipasangkan
- Connect ke printer
- Test print untuk memastikan printer bekerja

### 2. Print Receipt dari Checkout

Ada dua cara untuk print struk:

#### Cara 1: Menggunakan PrintService (Recommended)

```dart
import 'package:chiroku_cafe/features/thermal_printer/thermal_printer.dart';

// Di dalam _processCheckout() atau setelah payment berhasil
final printService = PrintService();

// Simple print dengan map data
await printService.printTransactionReceipt(
  receiptNumber: order.id.toString(),
  cashierName: 'Nama Kasir', // dari session/auth
  items: cartItems.map((item) => {
    'name': item.productName,
    'quantity': item.quantity,
    'price': item.price,
    'subtotal': item.totalPrice,
  }).toList(),
  subtotal: subtotal,
  tax: tax,
  discount: discount,
  total: total,
  cash: cashReceived,
  change: changeAmount,
  notes: 'Terima kasih telah berbelanja!',
);
```

#### Cara 2: Menggunakan ReceiptData Model

```dart
import 'package:chiroku_cafe/features/thermal_printer/thermal_printer.dart';

final receiptData = ReceiptData(
  receiptNumber: order.id.toString(),
  dateTime: DateTime.now(),
  cashierName: 'Nama Kasir',
  items: cartItems.map((item) => ReceiptItem(
    name: item.productName,
    quantity: item.quantity,
    price: item.price,
    subtotal: item.totalPrice,
  )).toList(),
  subtotal: subtotal,
  tax: tax,
  discount: discount,
  total: total,
  cash: cashReceived,
  change: changeAmount,
  notes: 'Terima kasih!',
);

final printService = PrintService();
await printService.printReceipt(receiptData);
```

### 3. Check Printer Status

```dart
final printService = PrintService();

// Check if printer connected
final isConnected = await printService.isConnected();

if (isConnected) {
  print('Printer terhubung: ${printService.currentPrinter?.name}');
} else {
  print('Printer tidak terhubung');
}

// Get connection status
final status = printService.connectionStatus;
```

## Implementasi di Checkout Page

Tambahkan import di `checkout_page.dart`:

```dart
import 'package:chiroku_cafe/features/thermal_printer/thermal_printer.dart';
```

Tambahkan print logic di method `_processCheckout()` setelah order berhasil:

```dart
Future<void> _processCheckout() async {
  setState(() => isProcessing = true);

  try {
    // ... existing checkout logic ...
    
    // 6. Get complete order data for receipt
    final orderData = await _orderService.getOrderDetailsWithItems(order.id);

    // 7. Print receipt (TAMBAHKAN INI)
    final printService = PrintService();
    try {
      await printService.printTransactionReceipt(
        receiptNumber: order.id.toString(),
        cashierName: 'Kasir', // TODO: Ambil dari user session
        items: cartItems.map((item) => {
          'name': item.productName,
          'quantity': item.quantity,
          'price': item.price,
          'subtotal': item.totalPrice,
        }).toList(),
        subtotal: subtotal,
        tax: tax,
        discount: discount,
        total: total,
        cash: 0, // TODO: Implement cash input
        change: 0, // TODO: Calculate change
        notes: 'Terima kasih telah berkunjung!',
      );
    } catch (printError) {
      // Print error tidak menghentikan flow checkout
      print('Print error: $printError');
      // Optional: tampilkan snackbar bahwa print gagal
    }

    setState(() => isProcessing = false);

    // Show success and navigate
    if (mounted && orderData != null) {
      Get.snackbar(
        'Success',
        'Pembayaran berhasil!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      Get.off(() => ReceiptPage(orderData: orderData));
    }
  } catch (e) {
    // ... error handling ...
  }
}
```

## Fitur-Fitur Printer

### Automatic Formatting
Repository sudah handle format struk dengan:
- Header toko (nama, alamat, telp)
- Info transaksi (no struk, kasir, tanggal/waktu)
- List item dengan qty dan harga
- Subtotal, pajak, diskon
- Total dengan format bold/besar
- Info pembayaran (tunai, kembali)
- Footer ucapan terima kasih
- Auto paper feed dan cut

### Error Handling
- Auto detect jika printer tidak terhubung
- Show dialog untuk setup printer
- Tidak menghentikan flow checkout jika print gagal
- Error message yang jelas untuk user

### Permissions
Sudah dikonfigurasi untuk:
- Android: Bluetooth permissions (BLUETOOTH, BLUETOOTH_ADMIN, BLUETOOTH_CONNECT, BLUETOOTH_SCAN)
- iOS: Bluetooth usage descriptions
- macOS: Bluetooth entitlements

## Testing

### Test Print Function
```dart
// Di printer settings page ada tombol "Test Print"
// Atau via code:
final controller = Get.find<ThermalPrinterController>();
await controller.testPrint();
```

### Manual Test dari Dart Console
```dart
final printService = PrintService();

// Test dengan data dummy
await printService.printTransactionReceipt(
  receiptNumber: 'TEST-001',
  cashierName: 'Test Cashier',
  items: [
    {
      'name': 'Kopi Latte',
      'quantity': 2,
      'price': 25000,
      'subtotal': 50000,
    },
    {
      'name': 'Nasi Goreng',
      'quantity': 1,
      'price': 35000,
      'subtotal': 35000,
    },
  ],
  subtotal: 85000,
  tax: 8500,
  discount: 0,
  total: 93500,
  cash: 100000,
  change: 6500,
);
```

## Troubleshooting

### Printer tidak terdeteksi
1. Pastikan printer sudah di-pair di Settings Bluetooth HP/Tablet
2. Pastikan printer dalam keadaan ON
3. Coba scan ulang di Printer Settings page

### Gagal connect
1. Pastikan printer tidak terhubung ke device lain
2. Restart printer
3. Unpair dan pair ulang di Settings Bluetooth
4. Restart aplikasi

### Print hasil aneh/karakter error
1. Pastikan menggunakan paper thermal 58mm
2. Cek encoding di generator (default: CP1252)
3. Cek apakah printer support ESC/POS commands

### Print tidak keluar
1. Pastikan paper tidak habis
2. Cek connection status
3. Test print dari halaman settings
4. Pastikan battery printer cukup (jika wireless)

## Customization

### Mengubah Format Struk

Edit di `thermal_printer_repository.dart`, method `_generateReceiptBytes()`:

```dart
// Contoh: Tambah logo
bytes += generator.image(logoImage);

// Contoh: Ubah ukuran header
bytes += generator.text(
  'CHIROKU CAFE',
  styles: const PosStyles(
    align: PosAlign.center,
    height: PosTextSize.size3, // Ubah dari size2 ke size3
    width: PosTextSize.size3,
    bold: true,
  ),
);

// Contoh: Tambah barcode
bytes += generator.barcode(
  Barcode.code128(receiptNumber),
  height: 70,
);
```

### Mengubah Info Toko

Edit bagian header di `_generateReceiptBytes()`:

```dart
bytes += generator.text(
  'CHIROKU CAFE',  // Nama toko
  styles: const PosStyles(align: PosAlign.center, ...),
);
bytes += generator.text(
  'Jl. Contoh No. 123',  // Alamat
  styles: const PosStyles(align: PosAlign.center),
);
bytes += generator.text(
  'Telp: 0123-4567-890',  // No telp
  styles: const PosStyles(align: PosAlign.center),
);
```

## API Reference

### PrintService Methods

- `isConnected()` - Check printer connection status
- `printReceipt(ReceiptData)` - Print with ReceiptData model
- `printTransactionReceipt({...})` - Quick print with parameters
- `openPrinterSettings()` - Navigate to printer settings page
- `currentPrinter` - Get connected printer info
- `connectionStatus` - Get current connection status

### ThermalPrinterController Methods

- `scanForPrinters()` - Scan for available printers
- `connectToPrinter(BluetoothPrinter)` - Connect to specific printer
- `disconnectPrinter()` - Disconnect current printer
- `checkConnection()` - Check if printer still connected
- `printReceipt(ReceiptData)` - Print receipt
- `testPrint()` - Print test receipt

## Best Practices

1. **Always check connection before printing**
   ```dart
   final isConnected = await printService.isConnected();
   if (!isConnected) {
     // Handle not connected
   }
   ```

2. **Don't block checkout flow if print fails**
   ```dart
   try {
     await printService.printReceipt(data);
   } catch (e) {
     // Log error but continue
     print('Print failed: $e');
   }
   ```

3. **Show printer setup dialog for first-time users**
   - PrintService already handles this automatically

4. **Test with actual thermal printer**
   - Different printers may have different behaviors
   - Always test before production

5. **Handle edge cases**
   - Paper out
   - Battery low
   - Connection lost
   - Printer busy

## Notes

- Paper size: 58mm (configurable in repository)
- Encoding: CP1252 (configurable)
- ESC/POS commands compatible
- Support bluetooth classic printers
- Auto-reconnect not implemented (user must manually reconnect)

---

Created for Chiroku Cafe POS System
