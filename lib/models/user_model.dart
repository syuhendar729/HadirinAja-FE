class UserModel {
  final int id;
  final int roleId;
  final String name;
  final String email;
  final String? emailVerifiedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? profilePicture;
  final String? nik;
  final String? position;
  final String? phone;
  final String? alamat;
  final UserAttendanceTotal total;

  const UserModel({
    required this.id,
    required this.roleId,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.profilePicture,
    this.nik,
    this.position,
    this.phone,
    this.alamat,
    required this.total,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: _toInt(json['id']),
      roleId: _toInt(json['role_id']),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      emailVerifiedAt: json['email_verified_at']?.toString(),
      createdAt: _toDateTime(json['created_at']),
      updatedAt: _toDateTime(json['updated_at']),
      profilePicture: json['profile_picture']?.toString(),
      nik: json['nik']?.toString(),
      position: json['position']?.toString(),
      phone: json['phone']?.toString(),
      alamat: json['alamat']?.toString(),
      total: UserAttendanceTotal.fromJson(
        json['total'] is Map<String, dynamic>
            ? json['total'] as Map<String, dynamic>
            : const {},
      ),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) {
      return null;
    }
    return DateTime.tryParse(value.toString());
  }
}

class UserAttendanceTotal {
  final int present;
  final int late;
  final int leave;
  final int absent;

  const UserAttendanceTotal({
    required this.present,
    required this.late,
    required this.leave,
    required this.absent,
  });

  factory UserAttendanceTotal.fromJson(Map<String, dynamic> json) {
    return UserAttendanceTotal(
      present: UserModel._toInt(json['present']),
      late: UserModel._toInt(json['late']),
      leave: UserModel._toInt(json['leave']),
      absent: UserModel._toInt(json['absent']),
    );
  }
}
