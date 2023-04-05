import 'package:financial_accounting/screen_arguments.dart';
import 'package:financial_accounting/shared_preferences_control.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: MediaQuery(
        data: MediaQuery.of(context).copyWith(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'User name',
                ),
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      child: const Text('Login'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void _login() async {
    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final Map<String, dynamic> requestData = {
      'userName': email,
      'password': password
    };

    final response = await http.post(
      Uri.parse('http://localhost:8888/token'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestData),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      // Login successful
      String refreshToken = '';

      final jsonData = json.decode(response.body);
      refreshToken = jsonData['data']['refreshToken'];
      SharedPreferencesControl.saveData(refreshToken);
      SharedPreferencesControl.loadData().then((String value) {
        setState(() {
          refreshToken = value;
        });
      });

      Navigator.pushNamed(context, '/financial-accounting',
          arguments: ScreenArguments(refreshToken));
    } else {
      // Login failed, show error message
      final error = response.body;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Error'),
          content: Text(error),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
