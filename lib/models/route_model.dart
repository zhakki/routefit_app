import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/firestore_parser.dart';

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
      startTime: FirestoreParser.parseDateTime(map['startTime']),
      endTime: FirestoreParser.parseDateTime(map['endTime']),
      distanceKm: FirestoreParser.parseDouble(map['distanceKm']),
      durationSeconds: FirestoreParser.parseInt(map['durationSeconds']),
      steps: FirestoreParser.parseInt(map['steps']),
      calories: FirestoreParser.parseDouble(map['calories']),
      averageSpeed: FirestoreParser.parseDouble(map['averageSpeed']),
      activityType: map['activityType'] ?? 'walking',
      createdAt: FirestoreParser.parseDateTime(map['createdAt']),
    );
  }
}