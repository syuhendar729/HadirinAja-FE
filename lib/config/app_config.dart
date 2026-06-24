import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get apiUrl => dotenv.env['API_URL'] ?? '';

  static String get appEnv =>
      dotenv.env['APP_ENV']?.toLowerCase().trim() ?? 'production';

  static bool get isDevelopment => appEnv == 'development';
}
