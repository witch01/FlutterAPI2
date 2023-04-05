import 'package:financial_accounting/presentation/financial_accounting_control_page.dart';
import 'package:financial_accounting/presentation/login_page.dart';
import 'package:financial_accounting/presentation/profile_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Financial Accounting App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
      routes: {
        '/profile': (context) => const ProfilePage(),
        '/financial-accounting': (context) =>
            const FinancialAccountingControlPage(),
      },
    );
  }
}
