import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class TrackingProvider extends ChangeNotifier {
  final Location _locationController = Location();
  StreamSubscription<LocationData>? _locationSubscription;

  // State variables
  bool _isTracking = false;
  List<LatLng> _routePoints = [];
  Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  Duration _duration = Duration.zero;
  double _totalDistance = 0.0;
  DateTime? _startTime;

  // Getters
  bool get isTracking => _isTracking;

  List<LatLng> get routePoints => _routePoints;

  Duration get duration => _duration;

  double get totalDistance => _totalDistance;

  DateTime? get startTime => _startTime;

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

  double calculateRouteDistance() {
    double distance = 0.0;
    for (int i = 0; i < _routePoints.length - 1; i++) {
      distance += _calculateDistance(_routePoints[i], _routePoints[i + 1]);
    }
    return distance; // Returns distance in meters
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
    _startTime = DateTime.now();
    _duration = Duration.zero;
    _stopwatch.reset();
    _stopwatch.start();

    // Start a timer to update duration every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _duration = _stopwatch.elapsed;
      notifyListeners();
    });

    _startLocationUpdates();
    notifyListeners();
  }

  Future<void> stopTracking() async {
    if (!_isTracking) return;

    // Get current location to finalize the path
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

    _isTracking = false;
    _stopwatch.stop();
    _timer?.cancel();
    _locationSubscription?.cancel();

    // Disable background mode when tracking stops
    try {
      await _locationController.enableBackgroundMode(enable: false);
    } catch (e) {
      debugPrint("Error disabling background mode: $e");
    }

    notifyListeners();
  }

  void _startLocationUpdates() {
    // Configure location settings for tracking
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
        if (_isTracking) {
          _addPoint(pos);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _locationSubscription?.cancel();
    super.dispose();
  }
}
