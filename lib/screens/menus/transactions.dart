import 'package:budgetly/screens/transactions/add_edit_transaction.dart';
import 'package:flutter/material.dart';
import 'package:budgetly/components/transactions/transaction_list.dart';
import 'package:provider/provider.dart';
import 'package:budgetly/provider/provider_user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  String currency = 'IDR';
  Map<String, dynamic> transactionDatas = {};
  bool isLoading = true;

  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchUserTransactions();
  }

  Future<void> fetchUserTransactions() async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    final String url =
        'https://budgetly-api-pa7n.vercel.app/api/transactions/user/$userId';

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final transactions =
            (data['transactions'] as List<dynamic>).map((transaction) {
          final rawDate = transaction['date'];
          if (rawDate is Map && rawDate['_seconds'] != null) {
            final date = DateTime.fromMillisecondsSinceEpoch(
              (rawDate['_seconds'] as int) * 1000,
            );

            return {
              ...transaction,
              'date': date,
            };
          }
          return transaction;
        }).toList();

        final filteredTransactions = transactions.where((transaction) {
          final transactionDate = transaction['date'];
          if (transactionDate is DateTime) {
            return transactionDate.year == selectedDate.year &&
                transactionDate.month == selectedDate.month;
          }
          return false;
        }).toList();

        setState(() {
          transactionDatas['transactions'] = filteredTransactions;
        });
      } else {
        debugPrint('Failed to fetch user transactions: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching user transactions: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _pickMonthYear() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      locale: const Locale("id", "ID"),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: const Color(0xFF3F8C92),
                  onPrimary: Colors.white,
                  surface: Colors.white,
                ),
          ),
          child: child ?? const SizedBox(),
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = DateTime(pickedDate.year, pickedDate.month, 1);
      });

      await fetchUserTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactions =
        transactionDatas['transactions'] as List<dynamic>? ?? [];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF3F8C92),
                  Color(0xFF1F4649),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 5.0, left: 20.0, right: 10.0, bottom: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Daftar Transaksi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: _pickMonthYear,
                        icon: const Icon(Icons.calendar_today,
                            color: Colors.white),
                        label: Text(
                          DateFormat('MMMM yyyy', 'id_ID').format(selectedDate),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: () async {
                          await fetchUserTransactions();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            if (!isLoading)
              SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.73,
                      child: TransactionListWithTabs(
                        transactions: transactions,
                        currency: currency,
                        onTransactionDeleted: () async {
                          await fetchUserTransactions();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            if (isLoading)
              Container(
                color: Colors.white,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LoadingAnimationWidget.staggeredDotsWave(
                        size: 50,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Memuat transaksi...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(
          side: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditTransactionScreen(),
            ),
          );

          if (result == true) {
            await fetchUserTransactions();
          }
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
