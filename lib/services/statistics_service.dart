import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../models/daily_step_summary.dart';
import '../models/route_model.dart';

class StatisticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _userDoc(String userId) {
    return _firestore.collection('users').doc(userId);
  }

  Future<int> getDailyStepGoal(String userId) async {
    final doc = await _userDoc(userId).collection('settings').doc('main').get();

    if (!doc.exists || doc.data() == null) {
      return 10000;
    }

    final data = doc.data()!;
    return data['dailyStepGoal'] ?? 10000;
  }

  Future<DailyStepSummary> calculateDailySummary({
    required String userId,
    required DateTime date,
  }) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await _userDoc(userId)
        .collection('routes')
        .where(
          'startTime',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where('startTime', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    int totalSteps = 0;
    int totalDurationSeconds = 0;
    double totalCalories = 0.0;
    double totalDistanceKm = 0.0;

    for (final doc in snapshot.docs) {
      final route = RouteModel.fromMap(doc.data());

      totalSteps += route.steps;
      totalDurationSeconds += route.durationSeconds;
      totalCalories += route.calories;
      totalDistanceKm += route.distanceKm;
    }

    final stepGoal = await getDailyStepGoal(userId);

    final progressPercent = stepGoal == 0
        ? 0.0
        : (totalSteps / stepGoal * 100).clamp(0, 100).toDouble();

    final now = DateTime.now();
    final summaryId = DateFormat('yyyy-MM-dd').format(startOfDay);

    return DailyStepSummary(
      summaryId: summaryId,
      userId: userId,
      date: startOfDay,
      totalSteps: totalSteps,
      stepGoal: stepGoal,
      progressPercent: progressPercent,
      calories: totalCalories,
      distanceKm: totalDistanceKm,
      durationSeconds: totalDurationSeconds,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<void> saveDailySummary(DailyStepSummary summary) async {
    await _userDoc(summary.userId)
        .collection('daily_summaries')
        .doc(summary.summaryId)
        .set(summary.toMap(), SetOptions(merge: true));
  }

  Future<DailyStepSummary> calculateAndSaveDailySummary({
    required String userId,
    required DateTime date,
  }) async {
    final summary = await calculateDailySummary(userId: userId, date: date);

    await saveDailySummary(summary);

    return summary;
  }

  Future<List<DailyStepSummary>> calculateWeeklySummary({
    required String userId,
    required DateTime selectedDate,
  }) async {
    final List<DailyStepSummary> summaries = [];
    final weekStart = selectedDate.subtract(
      Duration(days: selectedDate.weekday - 1),
    );

    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));

      final summary = await calculateDailySummary(userId: userId, date: date);

      summaries.add(summary);
    }

    return summaries;
  }

  int calculateTotalWeeklySteps(List<DailyStepSummary> summaries) {
    return summaries.fold(0, (total, item) => total + item.totalSteps);
  }

  double calculateTotalWeeklyDistance(List<DailyStepSummary> summaries) {
    return summaries.fold(0.0, (total, item) => total + item.distanceKm);
  }

  double calculateTotalWeeklyCalories(List<DailyStepSummary> summaries) {
    return summaries.fold(0.0, (total, item) => total + item.calories);
  }

  int calculateTotalWeeklyDuration(List<DailyStepSummary> summaries) {
    return summaries.fold(0, (total, item) => total + item.durationSeconds);
  }

  int calculateCompletedGoalDays(List<DailyStepSummary> summaries) {
    return summaries.where((item) => item.totalSteps >= item.stepGoal).length;
  }
}
