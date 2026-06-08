import 'api_client.dart';

class AuthService {
    static Future<dynamic> login({
        required String email,
        required String password,
    }) async {
        return await ApiClient.post(
            endpoint: '/login',

            body: {
                'email': email,
                'password': password,
            },
        );
    }

    static Future<dynamic> register({
        required String name,
        required String email,
        required String password,
        required String passwordConfirmation,
    }) async {
        return await ApiClient.post(
            endpoint: '/register',

            body: {
                'name': name,
                'email': email,
                'password': password,
                'password_confirmation':
                    passwordConfirmation,
            },
        );
    }

    static Future<dynamic> logout() async {
        return await ApiClient.delete(
            '/logout',
        );
    }
}