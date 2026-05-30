import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../models/route_model.dart';
import '../models/route_point.dart';
import '../providers/tracking_provider.dart';
import '../services/route_service.dart';
import '../services/statistics_service.dart';
import '../services/step_service.dart';
import '../services/user_service.dart';
import '../theme/app_colors.dart';
import '../utils/map_utils.dart';
import '../utils/permission_helper.dart';
import '../widgets/map_header.dart';
import '../widgets/map_tool_button.dart';
import '../widgets/route_control_panel.dart';
import '../widgets/route_data.dart';
import '../widgets/tracking_stats.dart';
import 'result_screen.dart';

const double DEFAULT_ZOOM = 18;

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final Location _locationController = Location();
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();
  final StepService _stepService = StepService();

  LatLng? _currentPos;
  StreamSubscription<LocationData>? _uiLocationSubscription;

  bool _followUser = true;
  bool _isProgrammaticMove = false;
  bool _isSavingRoute = false;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _checkLocationPermissions();
    _initializeMapRenderer();
  }

  void _initializeMapRenderer() {
    final GoogleMapsFlutterPlatform mapsImplementation =
        GoogleMapsFlutterPlatform.instance;

    if (mapsImplementation is GoogleMapsFlutterAndroid) {
      mapsImplementation.useAndroidViewSurface = true;
    }
  }

  @override
  void dispose() {
    _uiLocationSubscription?.cancel();
    _stepService.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  Future<void> _checkLocationPermissions() async {
    bool serviceEnabled = await _locationController.serviceEnabled();

    if (!serviceEnabled) {
      serviceEnabled = await _locationController.requestService();

      if (!serviceEnabled) {
        return;
      }
    }

    PermissionStatus permissionGranted =
        await _locationController.hasPermission();

    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();

      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    final locationData = await _locationController.getLocation();

    if (mounted &&
        locationData.latitude != null &&
        locationData.longitude != null) {
      setState(() {
        _currentPos = LatLng(
          locationData.latitude!,
          locationData.longitude!,
        );
      });
    }

    _uiLocationSubscription = _locationController.onLocationChanged.listen(
      (location) {
        if (location.latitude == null || location.longitude == null) {
          return;
        }

        if (!mounted) {
          return;
        }

        final newPos = LatLng(
          location.latitude!,
          location.longitude!,
        );

        setState(() {
          _currentPos = newPos;
        });

        if (_followUser) {
          _updateCameraPosition(newPos);
        }
      },
    );
  }

  Future<void> _updateCameraPosition(LatLng position) async {
    final GoogleMapController controller = await _mapController.future;

    _isProgrammaticMove = true;
    controller.animateCamera(
      CameraUpdate.newLatLng(position),
    );
  }

  Future<void> _startRoute(TrackingProvider trackingProvider) async {
    if (_isSavingRoute) {
      return;
    }

    final hasBgPerm =
        await PermissionHelper.requestBackgroundLocationPermission(context);

    if (!hasBgPerm) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Taustal asukoha õigus on jälgimise alustamiseks vajalik.',
          ),
        ),
      );
      return;
    }

    _stepService.startCounting();
    await trackingProvider.startTracking();
  }

  Future<void> _stopRoute(TrackingProvider trackingProvider) async {
    if (_isSavingRoute) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kasutaja pole sisse logitud'),
        ),
      );
      return;
    }

    setState(() {
      _isSavingRoute = true;
    });

    try {
      final GoogleMapController controller = await _mapController.future;

      // 1. Calculate bounds to fit the entire route
      if (trackingProvider.routePoints.isNotEmpty) {
        final bounds = MapUtils.getBounds(trackingProvider.routePoints);

        // Move camera and wait for animation
        _isProgrammaticMove = true;
        await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
        await Future.delayed(const Duration(milliseconds: 600));
      }

      // 2. Take a snapshot of the map
      final Uint8List? imageBytes = await controller.takeSnapshot();

      final endTime = DateTime.now();
      final trackedDuration = trackingProvider.duration;

      final summary = trackingProvider.getSummary();
      await trackingProvider.stopTracking();

      final steps = await _stepService.stopCounting();

      final distanceKm = trackingProvider.totalDistance / 1000;
      final durationSeconds = trackedDuration.inSeconds;

      final startTime = summary.date;

      final averageSpeed =
          durationSeconds <= 0 ? 0.0 : distanceKm / (durationSeconds / 3600);

      final profile = await UserService().getUserProfile(user.uid);
      final profileWeight = profile?.weightKg ?? 70.0;
      final weightKg = profileWeight <= 0 ? 70.0 : profileWeight;

      final calories = weightKg * distanceKm * 0.9;

      final routeId = 'route_${DateTime.now().millisecondsSinceEpoch}';

      final route = RouteModel(
        routeId: routeId,
        userId: user.uid,
        title: 'Uus marsruut',
        startTime: startTime,
        endTime: endTime,
        distanceKm: distanceKm,
        durationSeconds: durationSeconds,
        steps: steps,
        calories: calories,
        averageSpeed: averageSpeed,
        activityType: 'walking',
        createdAt: endTime,
      );

      final savedPoints = List<LatLng>.from(trackingProvider.routePoints);

      final pointInterval =
          savedPoints.length <= 1
              ? 0.0
              : durationSeconds / (savedPoints.length - 1);

      final routePoints =
          savedPoints.asMap().entries.map((entry) {
            final index = entry.key;
            final point = entry.value;

            return RoutePoint(
              pointId: 'point_$index',
              routeId: routeId,
              latitude: point.latitude,
              longitude: point.longitude,
              accuracy: 0,
              altitude: 0,
              timestamp: startTime.add(
                Duration(seconds: (pointInterval * index).round()),
              ),
            );
          }).toList();

      await RouteService().saveRoute(
        route: route,
        points: routePoints,
      );

      await StatisticsService().calculateAndSaveDailySummary(
        userId: user.uid,
        date: endTime,
      );

      if (!mounted) return;

      final finalSummary = RouteSummary(
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

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ResultScreen(route: finalSummary, mapImage: imageBytes),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Marsruudi salvestamine ebaõnnestus: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSavingRoute = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final trackingProvider = Provider.of<TrackingProvider>(context);

    return DecoratedBox(
      decoration: const BoxDecoration(color: RouteFitColors.trackingBackground),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              top: 90,
              child:
                  _currentPos == null
                      ? const Center(
                        child: CircularProgressIndicator(
                          color: RouteFitColors.trackingLime,
                        ),
                      )
                      : GoogleMap(
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        mapToolbarEnabled: false,
                        polylines: {
                          Polyline(
                            polylineId: const PolylineId("route"),
                            points: trackingProvider.routePoints,
                            color: RouteFitColors.trackingLime,
                            width: 5,
                          ),
                        },
                        onMapCreated: (controller) {
                          if (!_mapController.isCompleted) {
                            _mapController.complete(controller);
                          }
                        },
                        initialCameraPosition: CameraPosition(
                          target: _currentPos!,
                          zoom: DEFAULT_ZOOM,
                        ),
                        onCameraMoveStarted: () {
                          // If movement is NOT programmatic, it's a gesture (REASON_GESTURE)
                          if (!_isProgrammaticMove && _followUser) {
                            setState(() => _followUser = false);
                          }
                          _isProgrammaticMove =
                              false; // Reset for the next movement
                        },
                      ),
            ),
            Positioned.fill(
              top: 90,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        RouteFitColors.trackingBackground.withValues(
                          alpha: 0.16,
                        ),
                        Colors.transparent,
                        RouteFitColors.trackingBackground.withValues(
                          alpha: 0.20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Column(
              children: [
                const MapHeader(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TopStats(
                          distanceKm: trackingProvider.totalDistance / 1000,
                          duration: trackingProvider.duration,
                        ),
                        const SizedBox(height: 16),
                        MapToolButton(
                          icon:
                              _followUser
                                  ? Icons.my_location
                                  : Icons.location_searching,
                          active: _followUser,
                          onPressed: () {
                            setState(() {
                              _followUser = true;
                            });

                            if (_currentPos != null) {
                              _updateCameraPosition(_currentPos!);
                            }
                          },
                        ),
                        const Spacer(),
                        RouteControlPanel(
                          tracking: trackingProvider.isTracking,
                          paused: trackingProvider.isPaused,
                          onPause: () async {
                            if (trackingProvider.isTracking) {
                              if (trackingProvider.isPaused) {
                                await trackingProvider.resumeTracking();
                              } else {
                                await trackingProvider.pauseTracking();
                              }
                            } else {
                              await _startRoute(trackingProvider);
                            }
                          },
                          onStop:
                              trackingProvider.isTracking && !_isSavingRoute
                                  ? () {
                                    _stopRoute(trackingProvider);
                                  }
                                  : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (_isSavingRoute)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.42),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: RouteFitColors.trackingLime,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Salvestan marsruuti...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
