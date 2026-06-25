// File: attendance_model.dart
import 'package:flutter/material.dart';

enum AttendanceStatus { present, late, leave, absent }

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

  static AttendanceStatus _parseStatus(dynamic status) {
    switch (status?.toString().toUpperCase()) {
      case 'PRESENT':
        return AttendanceStatus.present;
      case 'LATE':
        return AttendanceStatus.late;
      case 'LEAVE':
        return AttendanceStatus.leave;
      case 'ABSENT':
      default:
        return AttendanceStatus.absent;
    }
  }
}

extension AttendanceStatusExtension on AttendanceStatus {
  String get label {
    switch (this) {
      case AttendanceStatus.present:
        return 'P';
      case AttendanceStatus.late:
        return 'L';
      case AttendanceStatus.leave:
        return 'LV';
      case AttendanceStatus.absent:
        return 'A';
    }
  }

  Color get color {
    switch (this) {
      case AttendanceStatus.present:
        return const Color(0xFFBBF7D0);
      case AttendanceStatus.late:
        return const Color(0xFFE5E7EB);
      case AttendanceStatus.leave:
        return const Color(0xFFFDE68A);
      case AttendanceStatus.absent:
        return const Color(0xFFFCA5A5);
    }
  }

  Color get foregroundColor {
    switch (this) {
      case AttendanceStatus.present:
        return const Color(0xFF166534);
      case AttendanceStatus.late:
        return const Color(0xFF374151);
      case AttendanceStatus.leave:
        return const Color(0xFF92400E);
      case AttendanceStatus.absent:
        return const Color(0xFF991B1B);
    }
  }

  Color get accentColor {
    switch (this) {
      case AttendanceStatus.present:
        return const Color(0xFF22C55E);
      case AttendanceStatus.late:
        return const Color(0xFF6B7280);
      case AttendanceStatus.leave:
        return const Color(0xFFF59E0B);
      case AttendanceStatus.absent:
        return const Color(0xFFDC2626);
    }
  }

  String get apiValue {
    switch (this) {
      case AttendanceStatus.present:
        return 'PRESENT';
      case AttendanceStatus.late:
        return 'LATE';
      case AttendanceStatus.leave:
        return 'LEAVE';
      case AttendanceStatus.absent:
        return 'ABSENT';
    }
  }
}
