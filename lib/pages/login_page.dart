// File login_page.dart

// import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

import 'main_page.dart';
import '../services/auth_service.dart';
import '../utils/session_manager.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> login() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await AuthService.login(
        email: emailController.text,
        password: passwordController.text,
      );

      setState(() {
        isLoading = false;
      });

      if (response['success'] == true) {
        final token = response['data']['token'];

        await SessionManager.saveLoginSession(token);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Login successful!')));

        if (!mounted) return;
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const MainPage()));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response['message'])));
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));

      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                const Text(
                  'HadirinAja',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 50),

                // EMAIL
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                ),

                const SizedBox(height: 20),

                // PASSWORD
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                ),

                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ResetPasswordPage(),
                        ),
                      );
                    },
                    child: const Text('Forgot password?'),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : login,
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Login'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: const Center(child: Text('Reset Password Page')),
    );
  }
}
