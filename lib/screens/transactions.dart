import 'package:budgetly/screens/add_edit_transaction.dart';
import 'package:flutter/material.dart';
import 'package:budgetly/components/transaction_list.dart';
import 'package:provider/provider.dart';
import 'package:budgetly/provider/provider_user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
        setState(() {
          transactionDatas['transactions'] = data['transactions'] ?? [];
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

  @override
  Widget build(BuildContext context) {
    final transactions =
        transactionDatas['transactions'] as List<dynamic>? ?? [];

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            if (!isLoading)
              RefreshIndicator(
                onRefresh: fetchUserTransactions,
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Daftar Transaksi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Lihat Semua',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
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
                  )),
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
