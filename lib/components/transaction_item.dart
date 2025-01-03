import 'package:budgetly/components/custom_transaction_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionItem extends StatelessWidget {
  final IconData icon;
  final String transactionId;
  final String title; // Title menggantikan description
  final String mainCurrency;
  final double amount; // Nilai jumlah dalam mainCurrency
  final double subAmount; // Nilai konversi ke subCurrency
  final String subCurrency;
  final String date;
  final String account; // Akun yang digunakan
  final String category; // Kategori transaksi
  final List<String>? photos; // Foto transaksi (null jika tidak ada)
  final Color color;
  final VoidCallback onTransactionDeleted;

  const TransactionItem({
    super.key,
    required this.icon,
    required this.transactionId,
    required this.title,
    required this.mainCurrency,
    required this.amount,
    required this.subAmount,
    required this.subCurrency,
    required this.date,
    required this.account,
    required this.category,
    this.photos,
    required this.color,
    required this.onTransactionDeleted,
  });

  Color _getCategoryColor(String category) {
    final incomeColors = {
      'Allowance': Colors.blue,
      'Salary': Colors.green,
      'Petty Cash': Colors.purple,
      'Bonus': Colors.orange,
      'Other': Colors.teal,
    };

    final expenseColors = {
      'Food': Colors.red,
      'Social Life': Colors.pink,
      'Pets': Colors.brown,
      'Transport': Colors.indigo,
      'Culture': Colors.deepPurple,
      'Household': Colors.cyan,
      'Apparel': Colors.amber,
      'Beauty': Colors.lime,
      'Health': Colors.lightGreen,
      'Education': Colors.blueAccent,
      'Gift': Colors.deepOrange,
      'Other': Colors.grey,
    };

    return incomeColors[category] ?? expenseColors[category] ?? Colors.black;
  }

  IconData _getAccountIcon(String account) {
    switch (account) {
      case 'card':
        return Icons.credit_card;
      case 'cash':
        return Icons.attach_money;
      case 'e-wallet':
        return Icons.account_balance_wallet;
      default:
        return Icons.help;
    }
  }

  String _formatCurrency(double amount, String currency) {
    final currencyFormats = {
      'IDR': NumberFormat.currency(
          locale: 'id_ID', symbol: 'IDR ', decimalDigits: 0),
      'USD': NumberFormat.currency(
          locale: 'en_US', symbol: 'USD ', decimalDigits: 2),
      'EUR': NumberFormat.currency(
          locale: 'de_DE', symbol: 'EUR ', decimalDigits: 2),
    };

    final formatter = currencyFormats[currency] ??
        NumberFormat.currency(
            locale: 'en_US', symbol: currency, decimalDigits: 2);

    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          _showTransactionDetails(context);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, width: 1),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ikon transaksi
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: color.withOpacity(0.2),
                    child: Icon(icon, color: color),
                  ),
                  const SizedBox(width: 16),

                  // Detail transaksi
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Judul transaksi
                        Row(
                          mainAxisSize: MainAxisSize
                              .min, // Pastikan hanya memuat konten seukuran isinya
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            if (photos != null && photos!.isNotEmpty)
                              const Padding(
                                padding: EdgeInsets.only(
                                    left: 8.0), // Tambahkan jarak 8px
                                child: Icon(
                                  Icons.photo,
                                  color: Colors.blueGrey,
                                  size: 16,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Label kategori, akun, dan ikon foto
                        Row(
                          children: [
                            // Label kategori
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(category),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                category,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Ikon akun
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.grey.shade200,
                              child: Icon(
                                _getAccountIcon(account),
                                size: 16,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Tanggal transaksi
                        Text(
                          date,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Jumlah transaksi
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatCurrency(amount, mainCurrency),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        _formatCurrency(subAmount, subCurrency),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  void _showTransactionDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return CustomTransactionDialog(
          title: title,
          transactionId: transactionId,
          category: category,
          date: date,
          account: account,
          mainCurrency: mainCurrency,
          amount: amount,
          subCurrency: subCurrency,
          subAmount: subAmount,
        );
      },
    ).then((result) {
      if (result == true) {
        onTransactionDeleted(); // Panggil callback jika berhasil dihapus
      }
    });
  }
}
