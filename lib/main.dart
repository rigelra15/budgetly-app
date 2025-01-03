import 'package:budgetly/screens/onboarding.dart';
import 'package:provider/provider.dart';
import 'package:budgetly/provider/provider_user.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  final userProvider = UserProvider();
  await userProvider.loadUserId();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => userProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prompt Generator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
            primary: Color(0xFF3F8C92), secondary: Colors.white),
        useMaterial3: true,
      ),
      home: const OnboardingScreen(),
    );
  }
}
