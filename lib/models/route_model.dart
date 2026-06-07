import 'package:cloud_firestore/cloud_firestore.dart';

class RouteModel {
  final String routeId;
  final String userId;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final double distanceKm;
  final int durationSeconds;
  final int steps;
  final double calories;
  final double averageSpeed;
  final String activityType;
  final DateTime createdAt;

  RouteModel({
    required this.routeId,
    required this.userId,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.distanceKm,
    required this.durationSeconds,
    required this.steps,
    required this.calories,
    required this.averageSpeed,
    required this.activityType,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'routeId': routeId,
      'userId': userId,
      'title': title,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'distanceKm': distanceKm,
      'durationSeconds': durationSeconds,
      'steps': steps,
      'calories': calories,
      'averageSpeed': averageSpeed,
      'activityType': activityType,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory RouteModel.fromMap(Map<String, dynamic> map) {
    return RouteModel(
      routeId: map['routeId'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      startTime: _parseDateTime(map['startTime']),
      endTime: _parseDateTime(map['endTime']),
      distanceKm: (map['distanceKm'] ?? 0).toDouble(),
      durationSeconds: map['durationSeconds'] ?? 0,
      steps: map['steps'] ?? 0,
      calories: (map['calories'] ?? 0).toDouble(),
      averageSpeed: (map['averageSpeed'] ?? 0).toDouble(),
      activityType: map['activityType'] ?? 'walking',
      createdAt: _parseDateTime(map['createdAt']),
    );
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