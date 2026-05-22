import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/route_model.dart';
import '../models/route_point.dart';

class RouteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveRoute({
    required RouteModel route,
    required List<RoutePoint> points,
  }) async {
    final batch = _firestore.batch();

    final routeRef = _firestore.collection('routes').doc(route.routeId);
    batch.set(routeRef, route.toMap());

    for (final point in points) {
      final pointRef = _firestore.collection('route_points').doc(point.pointId);
      batch.set(pointRef, point.toMap());
    }

    await batch.commit();
  }

  Future<List<RouteModel>> getUserRoutes(String userId) async {
    final snapshot = await _firestore
        .collection('routes')
        .where('userId', isEqualTo: userId)
        .orderBy('startTime', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => RouteModel.fromMap(doc.data()))
        .toList();
  }

  Future<List<RoutePoint>> getRoutePoints(String routeId) async {
    final snapshot = await _firestore
        .collection('route_points')
        .where('routeId', isEqualTo: routeId)
        .orderBy('timestamp')
        .get();

    return snapshot.docs
        .map((doc) => RoutePoint.fromMap(doc.data()))
        .toList();
  }

  Future<void> deleteRoute(String routeId) async {
    final pointsSnapshot = await _firestore
        .collection('route_points')
        .where('routeId', isEqualTo: routeId)
        .get();

    final batch = _firestore.batch();

    for (final doc in pointsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    final routeRef = _firestore.collection('routes').doc(routeId);
    batch.delete(routeRef);

    await batch.commit();
  }
}