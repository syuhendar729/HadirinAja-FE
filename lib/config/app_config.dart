import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static const _apiModeKey = 'api_url_mode';
  static int _apiMode = 1;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _apiMode = prefs.getInt(_apiModeKey) ?? 1;
  }

  static int get apiMode => _apiMode;

  static String get apiUrl {
    final selected = dotenv.env['API_URL$_apiMode'];
    if (selected?.trim().isNotEmpty == true) return selected!.trim();
    return dotenv.env['API_URL']?.trim() ?? '';
  }

  static List<({int mode, String label, String url})> get apiOptions {
    return [
      (mode: 1, label: 'API URL 1', url: dotenv.env['API_URL1'] ?? ''),
      (mode: 2, label: 'API URL 2', url: dotenv.env['API_URL2'] ?? ''),
    ];
  }

  static Future<void> setApiMode(int mode) async {
    _apiMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_apiModeKey, mode);
  }

  static String get appEnv =>
      dotenv.env['APP_ENV']?.toLowerCase().trim() ?? 'production';

  static bool get isDevelopment => appEnv == 'development';
}

class AppFonts {
  static const display = 'SF Pro Display';
  static const body = 'SF Mono';
  static const mono = body;
}

class AppColors {
  static const primary = 0xFF4E73DF;
  static const success = 0xFF1CC88A;
  static const warning = 0xFFF6C23E;
  static const danger = 0xFFE74A3B;
  static const background = 0xFFF8F9FC;
  static const card = 0xFFFFFFFF;
  static const textPrimary = 0xFF5A5C69;
  static const textSecondary = 0xFF858796;
  static const border = 0xFFEAECF4;
  static const late = 0xFF6E707E;

  static const teal = primary;
}
