import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../providers/tracking_provider.dart';
import '../theme/app_colors.dart';
import '../utils/map_utils.dart';
import '../utils/permission_helper.dart';
import '../widgets/map_header.dart';
import '../widgets/map_tool_button.dart';
import '../widgets/route_control_panel.dart';
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

  LatLng? _currentPos;
  StreamSubscription<LocationData>? _uiLocationSubscription;
  bool _followUser = true;
  bool _isProgrammaticMove = false;

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
    WakelockPlus.disable();
    super.dispose();
  }

  Future<void> _checkLocationPermissions() async {
    bool serviceEnabled = await _locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await _locationController
        .hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    // Get initial position
    final locationData = await _locationController.getLocation();
    if (mounted) {
      setState(() {
        _currentPos = LatLng(locationData.latitude!, locationData.longitude!);
      });
    }

    // Listen for current position updates for UI display
    _uiLocationSubscription = _locationController.onLocationChanged.listen((
      location,
    ) {
      if (location.latitude != null && location.longitude != null && mounted) {
        final newPos = LatLng(location.latitude!, location.longitude!);
        setState(() {
          _currentPos = newPos;
        });

        if (_followUser) {
          _updateCameraPosition(newPos);
        }
      }
    });
  }

  Future<void> _updateCameraPosition(LatLng position) async {
    final GoogleMapController controller = await _mapController.future;
    _isProgrammaticMove = true;
    controller.animateCamera(CameraUpdate.newLatLng(position));
  }

  Future<void> _stopRoute(TrackingProvider trackingProvider) async {
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
    final imageBytes = await controller.takeSnapshot();

    // 3. Get summary and stop tracking
    final routeSummary = trackingProvider.getSummary();
    trackingProvider.stopTracking();

    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              ResultScreen(route: routeSummary, mapImage: imageBytes),
        ),
      );
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
              child: _currentPos == null
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
                      onMapCreated: (controller) =>
                          _mapController.complete(controller),
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
                          icon: _followUser
                              ? Icons.my_location
                              : Icons.location_searching,
                          active: _followUser,
                          onPressed: () {
                            setState(() => _followUser = true);
                            if (_currentPos != null) {
                              _updateCameraPosition(_currentPos!);
                            }
                          },
                        ),
                        const Spacer(),
                        RouteControlPanel(
                          tracking: trackingProvider.isTracking,
                          onPause: () async {
                            if (trackingProvider.isTracking) {
                              trackingProvider.stopTracking();
                            } else {
                              bool hasBgPerm =
                                  await PermissionHelper.requestBackgroundLocationPermission(
                                    context,
                                  );
                              if (hasBgPerm) {
                                trackingProvider.startTracking();
                              } else {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Taustal asukoha õigus on jälgimise alustamiseks vajalik.",
                                      ),
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          onStop: trackingProvider.isTracking
                              ? () => _stopRoute(trackingProvider)
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
