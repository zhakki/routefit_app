import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/firestore_parser.dart';

class DailyStepSummary {
  final String summaryId;
  final String userId;
  final DateTime date;
  final int totalSteps;
  final int stepGoal;
  final double progressPercent;
  final double calories;
  final double distanceKm;
  final int durationSeconds;
  final DateTime createdAt;
  final DateTime updatedAt;

  DailyStepSummary({
    required this.summaryId,
    required this.userId,
    required this.date,
    required this.totalSteps,
    required this.stepGoal,
    required this.progressPercent,
    required this.calories,
    required this.distanceKm,
    required this.durationSeconds,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'summaryId': summaryId,
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'totalSteps': totalSteps,
      'stepGoal': stepGoal,
      'progressPercent': progressPercent,
      'calories': calories,
      'distanceKm': distanceKm,
      'durationSeconds': durationSeconds,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory DailyStepSummary.fromMap(Map<String, dynamic> map) {
    return DailyStepSummary(
      summaryId: map['summaryId'] ?? '',
      userId: map['userId'] ?? '',
      date: FirestoreParser.parseDateTime(map['date']),
      totalSteps: FirestoreParser.parseInt(map['totalSteps']),
      stepGoal: FirestoreParser.parseInt(
        map['stepGoal'],
        defaultValue: 10000,
      ),
      progressPercent: FirestoreParser.parseDouble(map['progressPercent']),
      calories: FirestoreParser.parseDouble(map['calories']),
      distanceKm: FirestoreParser.parseDouble(map['distanceKm']),
      durationSeconds: FirestoreParser.parseInt(map['durationSeconds']),
      createdAt: FirestoreParser.parseDateTime(map['createdAt']),
      updatedAt: FirestoreParser.parseDateTime(map['updatedAt']),
    );
  }
}