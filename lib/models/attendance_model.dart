// File: attendance_model.dart
import 'package:flutter/material.dart';

import '../config/app_config.dart';

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
        return const Color(AppColors.success);
      case AttendanceStatus.late:
        return const Color(AppColors.late);
      case AttendanceStatus.leave:
        return const Color(AppColors.warning);
      case AttendanceStatus.absent:
        return const Color(AppColors.danger);
    }
  }

  Color get foregroundColor {
    switch (this) {
      case AttendanceStatus.present:
        return Colors.white;
      case AttendanceStatus.late:
        return Colors.white;
      case AttendanceStatus.leave:
        return const Color(AppColors.textPrimary);
      case AttendanceStatus.absent:
        return Colors.white;
    }
  }

  Color get accentColor {
    switch (this) {
      case AttendanceStatus.present:
        return const Color(AppColors.success);
      case AttendanceStatus.late:
        return const Color(AppColors.late);
      case AttendanceStatus.leave:
        return const Color(AppColors.warning);
      case AttendanceStatus.absent:
        return const Color(AppColors.danger);
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
