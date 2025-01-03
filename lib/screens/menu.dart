import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:budgetly/screens/home.dart';
import 'package:budgetly/screens/profile.dart';
import 'package:budgetly/screens/transactions.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;

  final List<IconData> _iconList = [
    Icons.home,
    Icons.list,
    Icons.chat,
    Icons.person,
  ];

  final List<String> _labels = [
    'Beranda',
    'Transaksi',
    'AI Chatbot',
    'Profil',
  ];

  final List<Widget> _pages = [
    const HomeScreen(),
    const TransactionScreen(),
    const Center(child: Text('AI Chatbot')),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: _iconList.length,
        height: 64,
        tabBuilder: (int index, bool isActive) {
          final color =
              isActive ? Theme.of(context).colorScheme.primary : Colors.grey;
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _iconList[index],
                size: 22,
                color: color,
              ),
              const SizedBox(height: 4),
              Text(
                _labels[index],
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          );
        },
        backgroundColor: Colors.white,
        activeIndex: _currentIndex,
        splashColor: Colors.transparent,
        splashSpeedInMilliseconds: 150,
        notchSmoothness: NotchSmoothness.softEdge,
        leftCornerRadius: 24,
        rightCornerRadius: 24,
        gapLocation: GapLocation.none,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        shadow: const BoxShadow(
          offset: Offset(0, 1),
          blurRadius: 5,
          spreadRadius: 0.3,
          color: Colors.black12,
        ),
      ),
    );
  }
}
