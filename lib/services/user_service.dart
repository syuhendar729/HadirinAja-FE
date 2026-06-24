import 'api_client.dart';
import '../models/user_model.dart';

class UserService {
  static Future<UserModel> getUser() async {
    final response = await ApiClient.get('/user');
    final data = response['data'];

    if (data is! Map<String, dynamic>) {
      throw const ApiException(
        statusCode: 0,
        message: 'Invalid user data response',
      );
    }

    return UserModel.fromJson(data);
  }

  static Future<dynamic> updateUser({
    required String name,
    required String email,
    required String nik,
  }) async {
    return await ApiClient.patch(
      endpoint: '/user',

      body: {'name': name, 'email': email, 'nik': nik},
    );
  }

  static Future<dynamic> deleteUser() async {
    return await ApiClient.delete('/user');
  }

  static Future<dynamic> getAllUsers() async {
    return await ApiClient.get('/users');
  }
}
