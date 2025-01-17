import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BalanceCard extends StatefulWidget {
  final int totalBalance;
  final int income;
  final int expenses;

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
    } catch (error) {
    }
  }

  double _convertCurrency(int amount, String toCurrency) {
    double targetRate = _currencyRates[toCurrency] ?? 1.0;
    double baseRate = _currencyRates['IDR'] ?? 1.0;

    return amount / baseRate * targetRate;
  }

  String _formatShortCurrency(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return NumberFormat.currency(
      locale: 'en_US',
      symbol: '',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
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
      padding: const EdgeInsets.all(20),
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
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
                    _buildCurrencyToggleButton('CAD'),
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
                    locale: 'en_US', symbol: 'Rp', decimalDigits: 0)
                .format(totalBalanceConverted),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$_currentCurrency ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  TextSpan(
                    text: _formatShortCurrency(totalBalanceConverted),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child:
                        const Icon(Icons.arrow_downward, color: Colors.green),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pemasukan',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      Tooltip(
                        message:
                            '$_currentCurrency ${NumberFormat.currency(locale: 'en_US', symbol: '', decimalDigits: 0).format(incomeConverted)}',
                        child: Text(
                          '$_currentCurrency ${_formatShortCurrency(incomeConverted)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Pengeluaran',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      Tooltip(
                        message:
                            '$_currentCurrency ${NumberFormat.currency(locale: 'en_US', symbol: '', decimalDigits: 0).format(expensesConverted)}',
                        child: Text(
                          '$_currentCurrency ${_formatShortCurrency(expensesConverted)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.arrow_upward, color: Colors.red),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
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
