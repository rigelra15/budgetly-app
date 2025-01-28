import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BalanceCard extends StatefulWidget {
  final double totalBalance;
  final double income;
  final double expenses;

  const BalanceCard({
    super.key,
    required this.totalBalance,
    required this.income,
    required this.expenses,
  });

  @override
  _BalanceCardState createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  String _currentCurrency = 'IDR';
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
    } catch (error) {}
  }

  double _convertCurrency(double amount, String toCurrency) {
    double targetRate = _currencyRates[toCurrency] ?? 1.0;
    double baseRate = _currencyRates['IDR'] ?? 1.0;

    return amount / baseRate * targetRate;
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 400;
    final currentDate = DateFormat('MMMM yyyy', 'id_ID').format(DateTime.now());

    final totalBalanceConverted =
        _convertCurrency(widget.totalBalance, _currentCurrency);
    final incomeConverted = _convertCurrency(widget.income, _currentCurrency);
    final expensesConverted =
        _convertCurrency(widget.expenses, _currentCurrency);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3F8C92), Color(0xFF1F4649)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  currentDate,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(1.0)),
                ),
                child: Row(
                  children: [
                    _buildCurrencyToggleButton('IDR'),
                    _buildCurrencyToggleButton('USD'),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Saldo Total',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Tooltip(
            message: NumberFormat.currency(
                    locale: 'id_ID', symbol: _currentCurrency, decimalDigits: 2)
                .format(totalBalanceConverted),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$_currentCurrency ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    TextSpan(
                      text: _formatShortCurrency(totalBalanceConverted),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 28 : 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildIncomeExpenseRow(
                icon: Icons.arrow_downward,
                iconColor: Colors.green,
                label: 'Pemasukan',
                amount: incomeConverted,
              ),
              _buildIncomeExpenseRow(
                icon: Icons.arrow_upward,
                iconColor: Colors.red,
                label: 'Pengeluaran',
                amount: expensesConverted,
                isRightAlign: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required double amount,
    bool isRightAlign = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isRightAlign)
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: iconColor),
          ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment:
              isRightAlign ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            Tooltip(
              message:
                  '$_currentCurrency ${NumberFormat.currency(locale: 'en_US', symbol: '', decimalDigits: 0).format(amount)}',
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '$_currentCurrency ${_formatShortCurrency(amount)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (isRightAlign) const SizedBox(width: 8),
        if (isRightAlign)
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: iconColor),
          ),
      ],
    );
  }

  Widget _buildCurrencyToggleButton(String currency) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentCurrency = currency;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color:
              _currentCurrency == currency ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          currency,
          style: TextStyle(
            color: _currentCurrency == currency
                ? const Color(0xFF3F8C92)
                : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
