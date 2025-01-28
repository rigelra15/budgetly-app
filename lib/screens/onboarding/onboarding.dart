import 'package:budgetly/screens/auth/login.dart';
import 'package:budgetly/screens/auth/register.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

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
            child: SafeArea(
              child: Center(
                child: Text(
                  'Welcome to Budgetly!',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                itemCount: 4,
                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return SingleChildScrollView(
                    child: OnboardingSlide(
                      image: 'assets/slide${index + 1}.webp',
                      title: [
                        'Track Your Expenses',
                        'Set Your Goals',
                        'Save Smartly',
                        'Analyze Your Financial Health'
                      ][index],
                      description: [
                        'Pantau dan catat pengeluaran harianmu dengan mudah. Dengan fitur pencatatan yang intuitif, kamu dapat mengetahui ke mana uangmu pergi dan memastikan setiap pengeluaran sesuai dengan rencanamu.',
                        'Buat tujuan finansialmu dan pantau progresnya dengan mudah. Tetapkan target untuk menabung, investasi, atau pengeluaran besar, lalu pantau sejauh mana kamu telah mencapainya secara real-time.',
                        'Dapatkan rekomendasi pintar untuk menabung lebih efektif. Aplikasi ini menganalisis kebiasaan belanja dan menawarkan tips untuk memaksimalkan tabungan dan meminimalkan pengeluaran yang tidak perlu.',
                        'Lihat gambaran lengkap finansialmu kapan saja dan di mana saja. Analisis data yang visual dan informatif membantu kamu memahami kesehatan keuanganmu dan membuat keputusan yang lebih baik untuk masa depan.'
                      ][index],
                    ),
                  );
                },
              ),
            ),
            DotsIndicator(dotCount: 4, currentPage: currentPage),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.05,
                vertical: size.height * 0.02,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 12 : 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Daftar',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: size.width * 0.05),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: Theme.of(context).colorScheme.primary),
                        padding: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 12 : 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Masuk',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingSlide extends StatelessWidget {
  final String image;
  final String title;
  final String description;

  const OnboardingSlide({
    required this.image,
    required this.title,
    required this.description,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Padding(
      padding: EdgeInsets.all(size.width * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 400,
              maxHeight: 400,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                image,
                fit: BoxFit.contain,
                width: size.width * 0.8,
                height: size.width * 0.8,
              ),
            ),
          ),
          SizedBox(height: size.height * 0.02),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmallScreen ? 20 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: size.height * 0.01),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              color: Colors.grey,
            ),
            softWrap: true,
          ),
        ],
      ),
    );
  }
}

class DotsIndicator extends StatelessWidget {
  final int dotCount;
  final int currentPage;

  const DotsIndicator({
    required this.dotCount,
    required this.currentPage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(dotCount, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: index == currentPage
                ? Theme.of(context).colorScheme.primary
                : const Color(0xFFD0D0D0),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}
