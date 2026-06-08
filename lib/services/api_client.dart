// file: lib/services/api_client.dart

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../utils/session_manager.dart';

// ─── Custom exception ─────────────────────────────────────────────────────────
class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => message;
}

// ─── Client ───────────────────────────────────────────────────────────────────
class ApiClient {

  // ==============================================================
  // Common method to get headers with auth token
  // ==============================================================
  static Future<Map<String, String>> _headers() async {
    final token = await SessionManager.getToken();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ==============================================================
  // Response handler to decode JSON and handle errors
  // ==============================================================
  static dynamic _handleResponse(http.Response response) {
    final body = response.body;
    final statusCode = response.statusCode;

    // Decode JSON — throw if body is not valid JSON
    dynamic decoded;
    try {
      decoded = jsonDecode(body);
    } catch (_) {
      throw ApiException(
        statusCode: statusCode,
        message: 'Invalid JSON response (status $statusCode): $body',
      );
    }

    // Success range: 200–299
    if (statusCode >= 200 && statusCode < 300) {
      return decoded;
    }

    // Extract message from API error body if available
    String errorMessage = _extractErrorMessage(decoded, statusCode);
    throw ApiException(statusCode: statusCode, message: errorMessage);
  }

  // ==============================================================
  // Helper to extract error message 
  // ==============================================================
  static String _extractErrorMessage(dynamic decoded, int statusCode) {
    if (decoded is Map) {
      // Common API error shapes:
      // { "message": "..." }
      // { "error": "..." }
      // { "errors": { "field": ["msg"] } }
      if (decoded['message'] != null) return decoded['message'].toString();
      if (decoded['error'] != null) return decoded['error'].toString();
      if (decoded['errors'] != null) {
        final errors = decoded['errors'];
        if (errors is Map) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) return first.first.toString();
        }
        return errors.toString();
      }
    }
    return 'Request failed with status $statusCode';
  }

  // ==============================================================
  // GET
  // ==============================================================
  static Future<dynamic> get(String endpoint) async {
    try {
      final response = await http
          .get(
            Uri.parse('${AppConfig.apiUrl}$endpoint'),
            headers: await _headers(),
          )
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } on SocketException {
      throw const ApiException(
        statusCode: 0,
        message: 'No internet connection',
      );
    } catch (e) {
      throw ApiException(statusCode: 0, message: e.toString());
    }
  }

  // ==============================================================
  // POST
  // ==============================================================
  static Future<dynamic> post({required String endpoint, dynamic body}) async {
    try {
      final response = await http
          .post(
            Uri.parse('${AppConfig.apiUrl}$endpoint'),
            headers: await _headers(),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } on SocketException {
      throw const ApiException(
        statusCode: 0,
        message: 'No internet connection',
      );
    } catch (e) {
      throw ApiException(statusCode: 0, message: e.toString());
    }
  }

  // ==============================================================
  // PATCH
  // ==============================================================
  static Future<dynamic> patch({required String endpoint, dynamic body}) async {
    try {
      final response = await http
          .patch(
            Uri.parse('${AppConfig.apiUrl}$endpoint'),
            headers: await _headers(),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } on SocketException {
      throw const ApiException(
        statusCode: 0,
        message: 'No internet connection',
      );
    } catch (e) {
      throw ApiException(statusCode: 0, message: e.toString());
    }
  }

  // ==============================================================
  // DELETE
  // ==============================================================
  static Future<dynamic> delete(String endpoint) async {
    try {
      final response = await http
          .delete(
            Uri.parse('${AppConfig.apiUrl}$endpoint'),
            headers: await _headers(),
          )
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } on SocketException {
      throw const ApiException(
        statusCode: 0,
        message: 'No internet connection',
      );
    } catch (e) {
      throw ApiException(statusCode: 0, message: e.toString());
    }
  }
}

// import 'dart:convert';

// import 'package:http/http.dart' as http;

// import '../config/app_config.dart';
// import '../utils/session_manager.dart';

// class ApiClient {
//     static Future<Map<String, String>>
//         _headers() async {
//         final token =
//             await SessionManager.getToken();

//         return {
//             'Content-Type':
//                 'application/json',

//             'Accept':
//                 'application/json',

//             if (token != null)
//                 'Authorization':
//                     'Bearer $token',
//         };
//     }

//     static Future<dynamic> get(
//         String endpoint,
//     ) async {
//         final response = await http.get(
//             Uri.parse(
//                 '${AppConfig.apiUrl}$endpoint',
//             ),

//             headers: await _headers(),
//         );

//         return jsonDecode(response.body);
//     }

//     static Future<dynamic> post({
//         required String endpoint,
//         dynamic body,
//     }) async {
//         final response = await http.post(
//             Uri.parse(
//                 '${AppConfig.apiUrl}$endpoint',
//             ),

//             headers: await _headers(),

//             body: jsonEncode(body),
//         );

//         return jsonDecode(response.body);
//     }

//     static Future<dynamic> patch({
//         required String endpoint,
//         dynamic body,
//     }) async {
//         final response = await http.patch(
//             Uri.parse(
//                 '${AppConfig.apiUrl}$endpoint',
//             ),

//             headers: await _headers(),

//             body: jsonEncode(body),
//         );

//         return jsonDecode(response.body);
//     }

//     static Future<dynamic> delete(
//         String endpoint,
//     ) async {
//         final response = await http.delete(
//             Uri.parse(
//                 '${AppConfig.apiUrl}$endpoint',
//             ),

//             headers: await _headers(),
//         );

//         return jsonDecode(response.body);
//     }
// }