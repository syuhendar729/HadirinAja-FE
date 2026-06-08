import 'api_client.dart';

class UserService {
    static Future<dynamic> getUser() async {
        return await ApiClient.get(
            '/user',
        );
    }

    static Future<dynamic> updateUser({
        required String name,
        required String email,
        required String nik,
    }) async {
        return await ApiClient.patch(
            endpoint: '/user',

            body: {
                'name': name,
                'email': email,
                'nik': nik,
            },
        );
    }

    static Future<dynamic> deleteUser() async {
        return await ApiClient.delete(
            '/user',
        );
    }

    static Future<dynamic>
        getAllUsers() async {
        return await ApiClient.get(
            '/users',
        );
    }
}