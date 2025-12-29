import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AllTransactionsPage extends StatefulWidget {
  const AllTransactionsPage({super.key});

  @override
  State<AllTransactionsPage> createState() => _AllTransactionsPageState();
}

class _AllTransactionsPageState extends State<AllTransactionsPage> {
  final supabase = Supabase.instance.client;
  bool isLoading = true;
  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => isLoading = true);
    try {
      final response = await supabase
          .from('orders')
          .select('id, total, order_status, created_at, user_id, cashier_name, customer_name, payment_method')
          .order('created_at', ascending: false);

      setState(() {
        transactions = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint('Error loading transactions: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _navigateToDetail(Map<String, dynamic> transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionDetailPage(transaction: transaction),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Semua Transaksi',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : transactions.isEmpty
              ? Center(
                  child: Text(
                    'Tidak ada transaksi',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        onTap: () => _navigateToDetail(transaction),
                        title: Text(
                          'Pesanan #${transaction['id']}',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kasir: ${transaction['cashier_name']}',
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Pelanggan: ${transaction['customer_name']}',
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Metode Pembayaran: ${transaction['payment_method']}',
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Total: Rp ${transaction['total']}',
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Tanggal: ${DateFormat('dd MMM, HH:mm').format(DateTime.parse(transaction['created_at']))}',
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class TransactionDetailPage extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionDetailPage({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail Transaksi',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pesanan #${transaction['id']}',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Kasir: ${transaction['cashier_name']}',
              style: GoogleFonts.montserrat(
                fontSize: 16,
              ),
            ),
            Text(
              'Pelanggan: ${transaction['customer_name']}',
              style: GoogleFonts.montserrat(
                fontSize: 16,
              ),
            ),
            Text(
              'Metode Pembayaran: ${transaction['payment_method']}',
              style: GoogleFonts.montserrat(
                fontSize: 16,
              ),
            ),
            Text(
              'Total: Rp ${transaction['total']}',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Tanggal: ${DateFormat('dd MMM, HH:mm').format(DateTime.parse(transaction['created_at']))}',
              style: GoogleFonts.montserrat(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Status: ${transaction['order_status']}',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}