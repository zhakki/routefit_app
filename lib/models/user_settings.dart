import 'package:cloud_firestore/cloud_firestore.dart';

class UserSettings {
  final String settingsId;
  final String userId;
  final String distanceUnit;
  final bool saveRoutes;
  final bool allowLocation;
  final int dailyStepGoal;
  final DateTime updatedAt;

  UserSettings({
    required this.settingsId,
    required this.userId,
    required this.distanceUnit,
    required this.saveRoutes,
    required this.allowLocation,
    required this.dailyStepGoal,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'settingsId': settingsId,
      'userId': userId,
      'distanceUnit': distanceUnit,
      'saveRoutes': saveRoutes,
      'allowLocation': allowLocation,
      'dailyStepGoal': dailyStepGoal,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      settingsId: map['settingsId'] ?? 'main',
      userId: map['userId'] ?? '',
      distanceUnit: map['distanceUnit'] ?? 'km',
      saveRoutes: _parseBool(map['saveRoutes'], defaultValue: true),
      allowLocation: _parseBool(map['allowLocation'], defaultValue: true),
      dailyStepGoal: _parseInt(map['dailyStepGoal'], defaultValue: 10000),
      updatedAt: _parseDateTime(map['updatedAt']),
    );
  }

  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static bool _parseBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return defaultValue;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) {
      return DateTime.now();
    }

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }

    if (value is double) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }

    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }

    return DateTime.now();
  }
}