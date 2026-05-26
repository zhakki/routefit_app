import 'dart:async';

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

  // Getters
  bool get isTracking => _isTracking;
  List<LatLng> get routePoints => _routePoints;
  Duration get duration => _duration;

  void startTracking() {
    if (_isTracking) return;

    _isTracking = true;
    _routePoints.clear();
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

  void stopTracking() {
    if (!_isTracking) return;

    _isTracking = false;
    _stopwatch.stop();
    _timer?.cancel();
    _locationSubscription?.cancel();
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
          _routePoints.add(pos);
          notifyListeners();
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
