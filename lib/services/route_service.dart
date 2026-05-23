import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/route_model.dart';
import '../models/route_point.dart';

class RouteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _routesCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('routes');
  }

  Future<void> saveRoute({
    required RouteModel route,
    required List<RoutePoint> points,
  }) async {
    final batch = _firestore.batch();

    final routeRef = _routesCollection(route.userId).doc(route.routeId);

    batch.set(routeRef, route.toMap());

    for (final point in points) {
      final pointRef = routeRef.collection('points').doc(point.pointId);
      batch.set(pointRef, point.toMap());
    }

    await batch.commit();
  }

  Future<List<RouteModel>> getUserRoutes(String userId) async {
    final snapshot = await _routesCollection(userId)
        .orderBy('startTime', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => RouteModel.fromMap(doc.data()))
        .toList();
  }

  Future<List<RoutePoint>> getRoutePoints({
    required String userId,
    required String routeId,
  }) async {
    final snapshot = await _routesCollection(userId)
        .doc(routeId)
        .collection('points')
        .orderBy('timestamp')
        .get();

    return snapshot.docs
        .map((doc) => RoutePoint.fromMap(doc.data()))
        .toList();
  }

  Future<void> deleteRoute({
    required String userId,
    required String routeId,
  }) async {
    final routeRef = _routesCollection(userId).doc(routeId);

    final pointsSnapshot = await routeRef.collection('points').get();

    final batch = _firestore.batch();

    for (final doc in pointsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    batch.delete(routeRef);

    await batch.commit();
  }
}