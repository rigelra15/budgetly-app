import 'package:budgetly/components/shared/custom_info_dialog.dart';
import 'package:budgetly/components/shared/balance_card.dart';
import 'package:budgetly/components/transactions/transactions_compact.dart';
import 'package:budgetly/screens/menu.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:budgetly/provider/provider_user.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String profilePicUrl = 'https://via.placeholder.com/150';
  Map<String, dynamic> userDatas = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });
    try {
      await Future.wait([
        fetchUserData(),
        fetchProfilePic(),
      ]);
    } catch (e) {
      debugPrint('Error fetching data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchUserData() async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    final String url =
        'https://budgetly-api-pa7n.vercel.app/api/users/user/$userId';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userDatas = data;
        });
      } else {
        debugPrint('Failed to fetch user data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  Future<void> fetchProfilePic() async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    final String url =
        'https://budgetly-api-pa7n.vercel.app/api/users/user/$userId/profile-pic';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          profilePicUrl = data['signedUrl'] ?? profilePicUrl;
        });
      } else {
        debugPrint('Failed to fetch profile picture: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching profile picture: $e');
    }
  }

  double calculateTotalBalance(Map userDatas) {
    if (userDatas['transactions'] == null) return 0;

    final transactions = userDatas['transactions'] as List;

    double totalIncome = 0.0;
    double totalExpense = 0.0;

    for (var transaction in transactions) {
      if (transaction['type'] == 'income') {
        totalIncome += (transaction['amount'] as num).toDouble();
      } else if (transaction['type'] == 'expense') {
        totalExpense += (transaction['amount'] as num).toDouble();
      }
    }

    return totalIncome - totalExpense;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final transactions = userDatas['transactions'] as List<dynamic>? ?? [];
    final income =
        transactions.where((t) => t['type'] == 'income').fold<double>(
              0.0,
              (sum, t) => sum + (t['amount'] as num).toDouble(),
            );

    final expenses =
        transactions.where((t) => t['type'] == 'expense').fold<double>(
              0.0,
              (sum, t) => sum + (t['amount'] as num).toDouble(),
            );

    List<dynamic> processedTransactions = transactions.map((transaction) {
      final rawDate = transaction['date'];
      DateTime? date;

      if (rawDate != null && rawDate is Map<String, dynamic>) {
        date = DateTime.fromMillisecondsSinceEpoch(
          (rawDate['_seconds'] as int) * 1000,
        );
      }

      return {
        ...transaction,
        'date': date,
      };
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            if (!isLoading)
              RefreshIndicator(
                onRefresh: fetchData,
                child: ListView(padding: const EdgeInsets.all(16.0), children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(profilePicUrl),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Selamat Datang,',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 150,
                                    child: Text(
                                      userDatas['displayName'] ?? 'User',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.info),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CustomInfoDialog(
                                    title: 'Informasi',
                                    messages: const [
                                      'Pemasukan adalah uang yang masuk ke dalam akun Anda, seperti gaji, bonus, atau hadiah.',
                                      'Pengeluaran adalah uang yang keluar dari akun Anda, seperti belanja, tagihan, atau cicilan.',
                                      'Saldo adalah jumlah uang yang Anda miliki setelah dikurangi dengan pengeluaran.',
                                      'Tips: Tekan dan tahan lama pada angka untuk melihat nominal lengkap.',
                                      'Tips: Klik pada transaksi untuk melihat detailnya.',
                                      'B: Miliar (contoh: 1B = 1.000.000.000)',
                                      'M: Juta (contoh: 1M = 1.000.000)',
                                      'K: Ribu (contoh: 1K = 1.000)',
                                      'Kurs IDR ke USD dan sebaliknya sewaktu-waktu dapat berubah.',
                                    ],
                                    onClose: () {
                                      Navigator.of(context).pop();
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
                                .format(now),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      BalanceCard(
                        totalBalance: calculateTotalBalance(userDatas),
                        income: income,
                        expenses: expenses,
                      ),
                      const SizedBox(height: 20),
                      TransactionsCompact(
                        transactions: processedTransactions,
                        currency: 'IDR',
                        onViewMore: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }

                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const MenuScreen(),
                              settings: const RouteSettings(
                                arguments: {'index': 1},
                              ),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        },
                        onTransactionDeleted: () async {
                          await fetchData();
                        },
                      ),
                    ],
                  ),
                ]),
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
                          'Memuat ringkasan...',
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
    );
  }
}
