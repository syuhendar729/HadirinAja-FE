import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../services/auth_service.dart';
import '../utils/session_manager.dart';
import 'main_page.dart';

const _navy = Color(AppColors.primary);
const _muted = Color(AppColors.textSecondary);
const _line = Color(AppColors.border);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    setState(() => isLoading = true);

    try {
      final response = await AuthService.login(
        email: emailController.text,
        password: passwordController.text,
      );

      if (!mounted) return;
      setState(() => isLoading = false);

      if (response['success'] == true) {
        await SessionManager.saveLoginSession(response['data']['token']);
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Login successful!')));
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const MainPage()));
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message']?.toString() ?? 'Login failed'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: _navy,
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.36,
                width: double.infinity,
                child: SafeArea(
                  bottom: false,
                  child: Center(
                    child: Text(
                      'HadirinAja',
                      textAlign: TextAlign.center,
                      style: text.displaySmall?.copyWith(
                        color: Colors.white,
                        fontFamily: AppFonts.display,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 42, 24, 24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(56),
                    ),
                  ),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _field(
                        controller: emailController,
                        label: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      _field(
                        controller: passwordController,
                        label: 'Password',
                        icon: Icons.lock_outline,
                        obscureText: true,
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ResetPasswordPage(),
                            ),
                          ),
                          child: const Text('Forgot password?'),
                        ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: isLoading ? null : login,
                        style: FilledButton.styleFrom(
                          backgroundColor: _navy,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          textStyle: text.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Login'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(top: 0, right: 0, child: SafeArea(child: _apiSwitcher())),
        ],
      ),
    );
  }

  Widget _apiSwitcher() {
    return SizedBox(
      width: 56,
      height: 56,
      child: PopupMenuButton<int>(
        initialValue: AppConfig.apiMode,
        tooltip: '',
        color: const Color(AppColors.card),
        elevation: 8,
        icon: const Opacity(opacity: 0, child: Icon(Icons.settings_rounded)),
        onSelected: (mode) async {
          await AppConfig.setApiMode(mode);
          if (!mounted) return;
          setState(() {});
          final selected = AppConfig.apiOptions.firstWhere(
            (option) => option.mode == mode,
          );
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Using ${selected.label}')));
        },
        itemBuilder: (context) => [
          for (final option in AppConfig.apiOptions)
            PopupMenuItem<int>(
              value: option.mode,
              child: Row(
                children: [
                  Icon(
                    AppConfig.apiMode == option.mode
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: const Color(AppColors.primary),
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      option.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _muted),
        prefixIcon: Icon(icon, color: _muted),
        filled: true,
        fillColor: const Color(AppColors.background),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _navy, width: 1.4),
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
