// file: lib/services/attendance_service.dart

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/attendance_model.dart';
import '../config/app_config.dart';
import '../utils/session_manager.dart';

import 'api_client.dart';

class AttendanceService {
  // ==============================================================
  // Get Attendance
  // ==============================================================
  static Future<List<AttendanceModel>> getAttendances() async {
    final response = await ApiClient.get('/attendance');

    final List data = response['data'] ?? [];

    return data.map((json) => AttendanceModel.fromJson(json)).toList();
  }

  // ==============================================================
  // Get Attendance Detail
  // ==============================================================
  static Future<AttendanceModel> getAttendanceDetail(int id) async {
    final response = await ApiClient.get('/attendance/$id');

    return AttendanceModel.fromJson(response['data']);
  }

  // ==============================================================
  // Create Attendance
  // ==============================================================
  static Future<AttendanceModel> createAttendance({
    String status = 'ALPHA',
    required String location,
    String notes = 'On time',
    required String imageUrl,
    required double latitude,
    required double longitude,
  }) async {
    print('createAttendance - Image URL: $imageUrl');
    final response = await ApiClient.post(
      endpoint: '/attendance', // endpoint
      body: {
        'status': status,
        'location': location,
        'notes': notes,
        'url_image': imageUrl,
        'latitude': latitude,
        'longitude': longitude,
      },
    );

    if (response == null) {
      throw Exception('No response from server');
    }

    final data = response['data'];
    if (data == null || data is List) {
      // API mengembalikan "data": [] saat error — pesan ada di "message"
      final message = response['message'] ?? 'Failed create attendance';
      throw Exception(message);
    }

    return AttendanceModel.fromJson(data as Map<String, dynamic>);
  }

  // ==============================================================
  // Upload Image
  // ==============================================================
  static Future<String> uploadImage(String imagePath) async {
    final token = await SessionManager.getToken();

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${AppConfig.apiUrl}/attendance/image'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('image', imagePath));

    final streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.bytesToString();

    // Guard: HTTP error
    if (streamedResponse.statusCode < 200 ||
        streamedResponse.statusCode >= 300) {
      throw Exception(
        'Upload failed (${streamedResponse.statusCode}): $responseBody',
      );
    }

    // Guard: body kosong
    if (responseBody.trim().isEmpty) {
      throw Exception('Empty response from upload endpoint');
    }

    Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(responseBody) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Invalid JSON from upload endpoint: $responseBody');
    }

    // Guard: field "data" null atau tidak ada
    final data = decoded['data'];
    if (data == null) {
      throw Exception('Missing "data" in upload response: $responseBody');
    }

    // Guard: field "url_image" null atau tidak ada
    final urlImage = data['url_image'];
    if (urlImage == null) {
      throw Exception('Missing "url_image" in upload response: $responseBody');
    }

    return urlImage as String;
  }
}
