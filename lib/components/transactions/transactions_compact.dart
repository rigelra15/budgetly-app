import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'transaction_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TransactionsCompact extends StatefulWidget {
  final List<dynamic> transactions;
  final String currency;
  final VoidCallback onViewMore;
  final VoidCallback onTransactionDeleted;

  const TransactionsCompact({
    super.key,
    required this.transactions,
    required this.currency,
    required this.onViewMore,
    required this.onTransactionDeleted,
  });

  @override
  _TransactionsCompactState createState() => _TransactionsCompactState();
}

class _TransactionsCompactState extends State<TransactionsCompact> {
  Map<String, double> _currencyRates = {};

  @override
  void initState() {
    super.initState();
    _fetchCurrencyRates();
  }

  Future<void> _fetchCurrencyRates() async {
    try {
      final response = await http.get(
        Uri.parse('https://budgetly-api-pa7n.vercel.app/api/currency'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final currencies = data['currencies'] as List<dynamic>;

        setState(() {
          _currencyRates = {
            for (var currency in currencies)
              currency['currency']: (currency['rate'] is int
                  ? (currency['rate'] as int).toDouble()
                  : currency['rate'] as double)
          };
        });
      } else {
        throw Exception('Gagal mengambil data mata uang');
      }
    } catch (error) {
      debugPrint('Error fetching currency rates: $error');
    }
  }

  double _convertCurrency(int amount, String toCurrency) {
    double targetRate = _currencyRates[toCurrency] ?? 1.0;
    double baseRate = _currencyRates['IDR'] ?? 1.0;

    return amount / baseRate * targetRate;
  }

  @override
  Widget build(BuildContext context) {
    final todayTransactions = widget.transactions.where((t) {
      DateTime? transactionDate;

      if (t['date'] is Map<String, dynamic>) {
        transactionDate = DateTime.fromMillisecondsSinceEpoch(
          (t['date']['_seconds'] as int) * 1000,
        );
      } else if (t['date'] is DateTime) {
        transactionDate = t['date'] as DateTime;
      }

      if (transactionDate == null) return false;

      final now = DateTime.now();
      return transactionDate.year == now.year &&
          transactionDate.month == now.month &&
          transactionDate.day == now.day;
    }).toList();

    final incomeTransactions =
        todayTransactions.where((t) => t['type'] == 'income').toList();
    final expenseTransactions =
        todayTransactions.where((t) => t['type'] == 'expense').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTransactionSection(
          context,
          title: "Pemasukan",
          transactions: incomeTransactions,
        ),
        const SizedBox(height: 16),
        _buildTransactionSection(
          context,
          title: "Pengeluaran",
          transactions: expenseTransactions,
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: widget.onViewMore,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Lihat Transaksi Lainnya",
                  style: TextStyle(
                    color: Color(0xFF3F8C92),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.chevron_right, color: Color(0xFF3F8C92)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionSection(
    BuildContext context, {
    required String title,
    required List<dynamic> transactions,
  }) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 400;

    double totalAmount = transactions.fold<double>(
      0,
      (prev, t) => prev + (t['amount'] as num).toDouble(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 8),
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12 : 16,
            vertical: isSmallScreen ? 6 : 8,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3F8C92), Color(0xFF1F4649)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade400,
                width: 0.5,
              ),
            ),
          ),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Wrap(
                spacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Icon(
                    title == "Pemasukan"
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                    color: Colors.white,
                    size: isSmallScreen ? 16 : 20,
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                  Text(
                    "(${transactions.length} transaksi)",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                  ),
                ],
              ),
              Tooltip(
                message: NumberFormat.currency(
                        locale: 'id_ID',
                        symbol: widget.currency,
                        decimalDigits: 2)
                    .format(totalAmount),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "${widget.currency}${_formatShortCurrency(totalAmount)}",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 16 : 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (transactions.isEmpty)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Tidak ada transaksi",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
        ...transactions.take(3).map((transaction) {
          final type = transaction['type'] ?? 'expense';
          final icon =
              type == 'income' ? Icons.arrow_downward : Icons.arrow_upward;
          final color = type == 'income' ? Colors.green : Colors.red;
          final amount = transaction['amount'] ?? 0;

          final convertedAmount = _convertCurrency(amount, 'USD');

          return TransactionItem(
            icon: icon,
            transactionId: transaction['transactionId'] as String,
            mainCurrency: widget.currency,
            amount: amount.toDouble(),
            subAmount: convertedAmount,
            subCurrency: 'USD',
            date: DateFormat('dd/MM/yyyy HH:mm').format(transaction['date']),
            account: transaction['account'] ?? 'Unknown',
            category: transaction['category'] ?? 'Unknown',
            photos: transaction['photos']?.cast<String>() ?? [],
            title: transaction['description'] ?? 'No description',
            color: color,
            onTransactionDeleted: () {
              widget.onTransactionDeleted();
            },
          );
        }),
      ],
    );
  }

  String _formatShortCurrency(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(2)}B';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(2)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(2)}K';
    } else if (amount <= -1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(2)}B';
    } else if (amount <= -1000000) {
      return '${(amount / 1000000).toStringAsFixed(2)}M';
    } else if (amount <= -1000) {
      return '${(amount / 1000).toStringAsFixed(2)}K';
    }

    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 3,
    ).format(amount);
  }
}
