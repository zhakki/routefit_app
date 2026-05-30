import 'package:cloud_firestore/cloud_firestore.dart';

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
      date: (map['date'] as Timestamp).toDate(),
      totalSteps: map['totalSteps'] ?? 0,
      stepGoal: map['stepGoal'] ?? 10000,
      progressPercent: (map['progressPercent'] ?? 0).toDouble(),
      calories: (map['calories'] ?? 0).toDouble(),
      distanceKm: (map['distanceKm'] ?? 0).toDouble(),
      durationSeconds: map['durationSeconds'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }
}