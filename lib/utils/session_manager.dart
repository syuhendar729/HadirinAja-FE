import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
    static Future<void> saveLoginSession(
        String token,
    ) async {
        final prefs =
            await SharedPreferences.getInstance();

        await prefs.setString(
            'token',
            token,
        );

        await prefs.setInt(
            'login_time',
            DateTime.now()
                .millisecondsSinceEpoch,
        );
    }

    static Future<String?> getToken() async {
        final prefs =
            await SharedPreferences.getInstance();

        return prefs.getString('token');
    }

    static Future<int?> getLoginTime() async {
        final prefs =
            await SharedPreferences.getInstance();

        return prefs.getInt('login_time');
    }

    static Future<void> clearSession() async {
        final prefs =
            await SharedPreferences.getInstance();

        await prefs.clear();
    }
}