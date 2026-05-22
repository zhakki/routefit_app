import 'package:cloud_firestore/cloud_firestore.dart';

class RoutePoint {
  final String pointId;
  final String routeId;
  final double latitude;
  final double longitude;
  final double accuracy;
  final double altitude;
  final DateTime timestamp;

  RoutePoint({
    required this.pointId,
    required this.routeId,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.altitude,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'pointId': pointId,
      'routeId': routeId,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'altitude': altitude,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory RoutePoint.fromMap(Map<String, dynamic> map) {
    return RoutePoint(
      pointId: map['pointId'] ?? '',
      routeId: map['routeId'] ?? '',
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      accuracy: (map['accuracy'] ?? 0).toDouble(),
      altitude: (map['altitude'] ?? 0).toDouble(),
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}