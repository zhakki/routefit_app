import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/firestore_parser.dart';

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
      saveRoutes: FirestoreParser.parseBool(
        map['saveRoutes'],
        defaultValue: true,
      ),
      allowLocation: FirestoreParser.parseBool(
        map['allowLocation'],
        defaultValue: true,
      ),
      dailyStepGoal: FirestoreParser.parseInt(
        map['dailyStepGoal'],
        defaultValue: 10000,
      ),
      updatedAt: FirestoreParser.parseDateTime(map['updatedAt']),
    );
  }
}