import 'package:budgetly/components/balance_card.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:budgetly/provider/provider_user.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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

  int calculateTotalBalance(Map userDatas) {
    if (userDatas['transactions'] == null) return 0;

    final transactions = userDatas['transactions'] as List;

    int totalIncome = 0;
    int totalExpense = 0;

    for (var transaction in transactions) {
      if (transaction['type'] == 'income') {
        totalIncome += transaction['amount'] as int;
      } else if (transaction['type'] == 'expense') {
        totalExpense += transaction['amount'] as int;
      }
    }

    return totalIncome - totalExpense;
  }

  @override
  Widget build(BuildContext context) {
    final transactions = userDatas['transactions'] as List<dynamic>? ?? [];
    final income = transactions.where((t) => t['type'] == 'income').fold<int>(
          0,
          (sum, t) => sum + ((t['amount'] ?? 0) as int),
        );

    final expenses =
        transactions.where((t) => t['type'] == 'expense').fold<int>(
              0,
              (sum, t) => sum + ((t['amount'] ?? 0) as int),
            );

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
                                  Text(
                                    userDatas['displayName'] ?? 'User',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.settings),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      BalanceCard(
                        totalBalance: calculateTotalBalance(userDatas),
                        income: income,
                        expenses: expenses,
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
