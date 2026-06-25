// File main.dart
import 'package:flutter/material.dart';
import 'package:hadirinaja_fe/config/app_config.dart';
import 'package:hadirinaja_fe/services/auth_service.dart';
import 'package:hadirinaja_fe/utils/session_manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'pages/main_page.dart';
import 'pages/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await AppConfig.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget? startPage;

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {
    final token = await SessionManager.getToken();

    final loginTime = await SessionManager.getLoginTime();

    if (token == null || loginTime == null) {
      setState(() {
        startPage = const LoginPage();
      });

      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;

    const sessionDuration = 3600000;
    // const sessionDuration = 60000;

    final isExpired = now - loginTime > sessionDuration;

    if (isExpired) {
      try {
        await AuthService.logout();
      } catch (e) {
        debugPrint(e.toString());
      }

      await SessionManager.clearSession();

      setState(() {
        startPage = const LoginPage();
      });
    } else {
      setState(() {
        startPage = const MainPage();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HadirinAja',
      themeMode: ThemeMode.light,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(AppColors.background),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(AppColors.primary),
          primary: const Color(AppColors.primary),
          surface: const Color(AppColors.card),
        ),
        fontFamily: AppFonts.body,
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
            fontFamily: AppFonts.display,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(AppColors.textPrimary),
          ),
        ),
      ),
      home:
          startPage ??
          const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
