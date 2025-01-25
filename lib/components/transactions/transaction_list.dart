import 'package:flutter/material.dart';
import 'package:tab_indicator_styler/tab_indicator_styler.dart';
import 'transaction_item.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TransactionListWithTabs extends StatefulWidget {
  final List<dynamic> transactions;
  final String currency;
  final VoidCallback onTransactionDeleted;

  const TransactionListWithTabs({
    super.key,
    required this.transactions,
    required this.currency,
    required this.onTransactionDeleted,
  });

  @override
  State<TransactionListWithTabs> createState() =>
      _TransactionListWithTabsState();
}

class _TransactionListWithTabsState extends State<TransactionListWithTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedCategory;
  final String _currentCurrency = 'IDR';
  Map<String, double> _currencyRates = {};

  final List<String> _incomeCategories = [
    'Allowance',
    'Salary',
    'Bonus',
    'Other',
  ];

  final List<String> _expenseCategories = [
    'Food',
    'Social Life',
    'Pets',
    'Transport',
    'Culture',
    'Household',
    'Apparel',
    'Beauty',
    'Health',
    'Education',
    'Gift',
    'Other',
  ];

  List<String> get _allCategories =>
      (_incomeCategories + _expenseCategories).toSet().toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _fetchCurrencyRates();
  }

  void _onTabChanged() {
    setState(() {
      _selectedCategory = null;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  double _convertCurrency(int amount, String toCurrency) {
    double targetRate = _currencyRates[toCurrency] ?? 1.0;
    double baseRate = _currencyRates['IDR'] ?? 1.0;

    return amount / baseRate * targetRate;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.black,
          tabs: const [
            Tab(text: 'Semua'),
            Tab(text: 'Pemasukan'),
            Tab(text: 'Pengeluaran'),
          ],
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: RectangularIndicator(
            bottomLeftRadius: 100,
            bottomRightRadius: 100,
            topLeftRadius: 100,
            topRightRadius: 100,
            color: Theme.of(context).primaryColor,
          ),
          overlayColor: WidgetStatePropertyAll(Colors.white.withOpacity(0.2)),
          indicatorColor: Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  hint: const Text('Pilih kategori...'),
                  onChanged: (String? value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  items: _getCurrentCategories()
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(color: Color(0xFF3F8C92)),
                      ),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Filter by category',
                      hintStyle: const TextStyle(color: Color(0xFF3F8C92)),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFF3F8C92), width: 0.2),
                      ),
                      focusedBorder: null),
                  menuMaxHeight: 200,
                ),
              ),
              if (_selectedCategory != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = null;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: const Icon(
                      Icons.clear,
                      color: Colors.red,
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTransactionList(widget.transactions),
              _buildTransactionList(widget.transactions
                  .where((t) => t['type'] == 'income')
                  .toList()),
              _buildTransactionList(widget.transactions
                  .where((t) => t['type'] == 'expense')
                  .toList()),
            ],
          ),
        ),
      ],
    );
  }

  List<String> _getCurrentCategories() {
    List<String> categories;
    if (_tabController.index == 0) {
      categories = _allCategories;
    } else if (_tabController.index == 1) {
      categories = _incomeCategories;
    } else {
      categories = _expenseCategories;
    }

    categories.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return categories;
  }

  Widget _buildTransactionList(List<dynamic> transactions) {
    if (_selectedCategory != null) {
      transactions = transactions
          .where((t) => t['category'] == _selectedCategory)
          .toList();
    }

    if (transactions.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada transaksi',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    Map<String, List<dynamic>> groupedTransactions = {};
    for (var transaction in transactions) {
      String transactionDate;
      if (transaction['date'] is DateTime) {
        transactionDate = DateFormat('dd MMM yyyy').format(transaction['date']);
      } else if (transaction['date'] is String) {
        transactionDate = DateFormat('dd MMM yyyy').format(
          DateTime.parse(transaction['date']),
        );
      } else {
        continue;
      }

      groupedTransactions.putIfAbsent(transactionDate, () => []);
      groupedTransactions[transactionDate]!.add(transaction);
    }

    return ListView.builder(
      itemCount: groupedTransactions.keys.length,
      itemBuilder: (context, index) {
        final date = groupedTransactions.keys.toList()[index];
        final transactionsOnDate = groupedTransactions[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 6, top: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              child: Text(
                date,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            ...transactionsOnDate.map((transaction) {
              final type = transaction['type'] ?? 'expense';
              final icon =
                  type == 'income' ? Icons.arrow_downward : Icons.arrow_upward;
              final color = type == 'income' ? Colors.green : Colors.red;
              final amount = transaction['amount'] ?? 0;

              final convertedAmount = _convertCurrency(amount, 'USD');

              String formattedDate;
              if (transaction['date'] is DateTime) {
                formattedDate =
                    DateFormat('dd/MM/yyyy HH:mm').format(transaction['date']);
              } else if (transaction['date'] is String) {
                formattedDate = DateFormat('dd/MM/yyyy HH:mm')
                    .format(DateTime.parse(transaction['date']));
              } else {
                formattedDate = 'Unknown Date';
              }

              return TransactionItem(
                icon: icon,
                transactionId: transaction['transactionId'] as String,
                mainCurrency: _currentCurrency,
                amount: amount.toDouble(),
                subAmount: convertedAmount,
                subCurrency: 'USD',
                date: formattedDate,
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
      },
    );
  }

  Widget buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
