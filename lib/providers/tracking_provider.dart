import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../models/route_model.dart';
import '../models/route_point.dart';
import '../services/route_service.dart';
import '../services/statistics_service.dart';
import '../services/step_service.dart';
import '../services/user_service.dart';
import '../widgets/route_data.dart';

class TrackingProvider extends ChangeNotifier {
  final Location _locationController = Location();
  final StepService _stepService = StepService();
  final RouteService _routeService = RouteService();
  final UserService _userService = UserService();
  final StatisticsService _statisticsService = StatisticsService();

  StreamSubscription<LocationData>? _locationSubscription;

  // State variables
  bool _isTracking = false;
  bool _isPaused = false;
  final List<LatLng> _routePoints = [];
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  Duration _duration = Duration.zero;
  double _totalDistance = 0.0;
  int _steps = 0;
  DateTime? _startTime;

  // Getters
  bool get isTracking => _isTracking;
  bool get isPaused => _isPaused;
  List<LatLng> get routePoints => _routePoints;
  Duration get duration => _duration;
  double get totalDistance => _totalDistance;
  int get steps => _isTracking ? _stepService.currentRouteSteps : _steps;
  DateTime? get startTime => _startTime;

  RouteSummary getSummary() {
    final now = DateTime.now();
    final start = _startTime ?? now;
    final distanceKm = _totalDistance / 1000;

    return RouteSummary(
      title: 'Uus marsruut',
      date: start,
      startTime: TimeOfDay.fromDateTime(start),
      endTime: TimeOfDay.fromDateTime(now),
      distanceKm: distanceKm,
      duration: _duration,
      steps: steps,
      calories: 0, // Placeholder - calculated during save
      averageSpeed: _duration.inSeconds > 0
          ? (distanceKm / (_duration.inSeconds / 3600))
          : 0,
    );
  }

  double _calculateDistance(LatLng p1, LatLng p2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a =
        0.5 -
        c((p2.latitude - p1.latitude) * p) / 2 +
        c(p1.latitude * p) *
            c(p2.latitude * p) *
            (1 - c((p2.longitude - p1.longitude) * p)) /
            2;
    return 12742000 * asin(sqrt(a)); // 2 * R; R = 6371000 meters
  }

  void _addPoint(LatLng point) {
    if (_routePoints.isNotEmpty) {
      _totalDistance += _calculateDistance(_routePoints.last, point);
    }
    _routePoints.add(point);
  }

  Future<void> startTracking() async {
    if (_isTracking) return;

    _routePoints.clear();
    _totalDistance = 0.0;
    _steps = 0;
    _isPaused = false;
    _startTime = DateTime.now();

    // Enable background mode and notification for background tracking
    try {
      await _locationController.enableBackgroundMode(enable: true);
      await _locationController.changeNotificationOptions(
        title: 'RouteFit is active',
        subtitle: 'Tracking your route in the background',
        onTapBringToFront: true,
      );
      debugPrint("Enabled background mode");
    } catch (e) {
      debugPrint("Error enabling background mode: $e");
    }

    // Get current location to start the path immediately
    try {
      final locationData = await _locationController.getLocation();
      if (locationData.latitude != null && locationData.longitude != null) {
        _addPoint(LatLng(locationData.latitude!, locationData.longitude!));
      }
    } catch (e) {
      debugPrint("Could not get initial location: $e");
    }

    _isTracking = true;
    _stepService.startCounting();
    _duration = Duration.zero;
    _stopwatch.reset();
    _stopwatch.start();

    // Start a timer to update duration every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        _duration = _stopwatch.elapsed;
        notifyListeners();
      }
    });

    _startLocationUpdates();
    notifyListeners();
  }

  Future<void> pauseTracking() async {
    if (!_isTracking || _isPaused) return;

    _isPaused = true;
    _stopwatch.stop();

    // Capture location at the moment of pausing
    try {
      final locationData = await _locationController.getLocation().timeout(
        const Duration(seconds: 2),
      );
      if (locationData.latitude != null && locationData.longitude != null) {
        _addPoint(LatLng(locationData.latitude!, locationData.longitude!));
      }
    } catch (e) {
      debugPrint("Could not get pause location: $e");
    }

    notifyListeners();
  }

  Future<void> resumeTracking() async {
    if (!_isTracking || !_isPaused) return;

    // Capture location to start tracking again without adding to distance
    try {
      final locationData = await _locationController.getLocation();
      if (locationData.latitude != null && locationData.longitude != null) {
        // Add point to route points but DON'T use _addPoint to avoid distance increment
        _routePoints.add(
          LatLng(locationData.latitude!, locationData.longitude!),
        );
      }
    } catch (e) {
      debugPrint("Could not get resume location: $e");
    }

    _isPaused = false;
    _stopwatch.start();

    notifyListeners();
  }

  Future<void> stopTracking() async {
    if (!_isTracking) return;

    // Get current location to finalize the path (only if not already finalized by pause)
    if (!_isPaused) {
      try {
        final locationData = await _locationController.getLocation().timeout(
          const Duration(seconds: 2),
        );
        if (locationData.latitude != null && locationData.longitude != null) {
          _addPoint(LatLng(locationData.latitude!, locationData.longitude!));
        }
      } catch (e) {
        debugPrint("Could not get final location (timeout or error): $e");
      }
    }

    _isTracking = false;
    _isPaused = false;
    _stopwatch.stop();
    _timer?.cancel();
    _locationSubscription?.cancel();
    _steps = await _stepService.stopCounting();

    // Disable background mode when tracking stops
    try {
      await _locationController.enableBackgroundMode(enable: false);
    } catch (e) {
      debugPrint("Error disabling background mode: $e");
    }

    notifyListeners();
  }

  Future<RouteSummary> saveTrackedRoute() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Kasutaja pole sisse logitud');

    final endTime = DateTime.now();
    final distanceKm = _totalDistance / 1000;
    final durationSeconds = _duration.inSeconds;

    final profile = await _userService.getUserProfile(user.uid);
    final profileWeight = profile?.weightKg ?? 70.0;
    final weightKg = profileWeight <= 0 ? 70.0 : profileWeight;
    final calories = weightKg * distanceKm * 0.9;

    final routeId = 'route_${DateTime.now().millisecondsSinceEpoch}';

    final route = RouteModel(
      routeId: routeId,
      userId: user.uid,
      title: 'Uus marsruut',
      startTime: _startTime ?? endTime,
      endTime: endTime,
      distanceKm: distanceKm,
      durationSeconds: durationSeconds,
      steps: _steps,
      calories: calories,
      averageSpeed: durationSeconds <= 0
          ? 0
          : distanceKm / (durationSeconds / 3600),
      activityType: 'walking',
      createdAt: endTime,
    );

    final routePoints = _routePoints.asMap().entries.map((entry) {
      return RoutePoint(
        pointId: 'point_${entry.key}',
        routeId: routeId,
        latitude: entry.value.latitude,
        longitude: entry.value.longitude,
        accuracy: 0,
        altitude: 0,
        timestamp: route.startTime.add(
          Duration(seconds: entry.key),
        ), // Approximation
      );
    }).toList();

    await _routeService.saveRoute(route: route, points: routePoints);
    await _statisticsService.calculateAndSaveDailySummary(
      userId: user.uid,
      date: endTime,
    );

    return RouteSummary(
      title: route.title,
      date: route.startTime,
      startTime: TimeOfDay.fromDateTime(route.startTime),
      endTime: TimeOfDay.fromDateTime(route.endTime),
      distanceKm: route.distanceKm,
      duration: Duration(seconds: route.durationSeconds),
      steps: route.steps,
      calories: route.calories.round(),
      averageSpeed: route.averageSpeed,
    );
  }

  void _startLocationUpdates() {
    _locationController.changeSettings(
      accuracy: LocationAccuracy.high,
      interval: 2000,
      distanceFilter: 2,
    );

    _locationSubscription = _locationController.onLocationChanged.listen((
      location,
    ) {
      if (location.latitude != null && location.longitude != null) {
        final pos = LatLng(location.latitude!, location.longitude!);
        if (_isTracking && !_isPaused) {
          _addPoint(pos);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _locationSubscription?.cancel();
    _stepService.dispose();
    super.dispose();
  }
}
