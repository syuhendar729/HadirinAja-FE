// File: attendance_model.dart
import 'package:flutter/material.dart';

enum AttendanceStatus { hadir, izin, alpha }

class AttendanceModel {
  final int? id;

  final DateTime? createdAt;

  final AttendanceStatus status;

  final String? location;

  final String? notes;

  final String? imageUrl;

  AttendanceModel({
    this.id,
    this.createdAt,
    required this.status,
    this.location,
    this.notes,
    this.imageUrl,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'],

      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,

      status: _parseStatus(json['status']),

      location: json['location'],

      notes: json['notes'],

      imageUrl: json['url_image'],
    );
  }

  static AttendanceStatus _parseStatus(String status) {
    switch (status) {
      case 'HADIR':
        return AttendanceStatus.hadir;

      case 'IZIN':
        return AttendanceStatus.izin;

      default:
        return AttendanceStatus.alpha;
    }
  }
}



extension AttendanceStatusExtension on AttendanceStatus {
  String get label {
    switch (this) {
      case AttendanceStatus.hadir:
        return 'P';

      case AttendanceStatus.izin:
        return 'L';

      case AttendanceStatus.alpha:
        return 'A';
    }
  }

  Color get color {
    switch (this) {
      case AttendanceStatus.hadir:
        return Colors.green.shade200;

      case AttendanceStatus.izin:
        return Colors.orange.shade200;

      case AttendanceStatus.alpha:
        return Colors.red.shade200;
    }
  }

  String get apiValue {
    switch (this) {
      case AttendanceStatus.hadir:
        return 'HADIR';

      case AttendanceStatus.izin:
        return 'IZIN';

      case AttendanceStatus.alpha:
        return 'ALPHA';
    }
  }
}
