import 'package:flutter/material.dart';

class RouteSummary {
  const RouteSummary({
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.distanceKm,
    required this.duration,
    required this.steps,
    required this.calories,
    required this.averageSpeed,
  });

  final String title;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final double distanceKm;
  final Duration duration;
  final int steps;
  final int calories;
  final double averageSpeed;
}

final demoRoutes = <RouteSummary>[
  RouteSummary(
    title: 'Õhtune jalutuskäik',
    date: DateTime(2026, 5, 22),
    startTime: const TimeOfDay(hour: 18, minute: 10),
    endTime: const TimeOfDay(hour: 18, minute: 40),
    distanceKm: 3.25,
    duration: const Duration(minutes: 30, seconds: 15),
    steps: 4200,
    calories: 420,
    averageSpeed: 6.4,
  ),
  RouteSummary(
    title: 'Hommikune marsruut',
    date: DateTime(2026, 5, 21),
    startTime: const TimeOfDay(hour: 7, minute: 20),
    endTime: const TimeOfDay(hour: 7, minute: 58),
    distanceKm: 4.1,
    duration: const Duration(minutes: 38),
    steps: 5300,
    calories: 510,
    averageSpeed: 6.5,
  ),
  RouteSummary(
    title: 'Pargi treening',
    date: DateTime(2026, 5, 20),
    startTime: const TimeOfDay(hour: 19, minute: 0),
    endTime: const TimeOfDay(hour: 19, minute: 46),
    distanceKm: 5.2,
    duration: const Duration(minutes: 46),
    steps: 6800,
    calories: 620,
    averageSpeed: 6.8,
  ),
];

String formatNumber(int value) {
  return value.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ' ',
  );
}

String formatDuration(Duration duration) {
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  if (duration.inHours > 0) {
    return '${duration.inHours}:$minutes:$seconds';
  }
  return '$minutes:$seconds';
}

String formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day.$month.${date.year}';
}
