import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../providers/tracking_provider.dart';
import '../utils/permission_helper.dart';

const double DEFAULT_ZOOM = 18;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Location _locationController = Location();
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  LatLng? _currentPos;
  StreamSubscription<LocationData>? _uiLocationSubscription;

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

    // Listen for current position updates just for UI display (the blue dot/marker)
    _uiLocationSubscription = _locationController.onLocationChanged.listen((
      location,
    ) {
      if (location.latitude != null && location.longitude != null && mounted) {
        setState(() {
          _currentPos = LatLng(location.latitude!, location.longitude!);
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return hours == "00" ? "$minutes:$seconds" : "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final trackingProvider = Provider.of<TrackingProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          _currentPos == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  polylines: {
                    Polyline(
                      polylineId: const PolylineId("id"),
                      points: trackingProvider.routePoints,
                      color: Colors.blue,
                      width: 5,
                    ),
                  },
                  onMapCreated: (controller) =>
                      _mapController.complete(controller),
                  initialCameraPosition: CameraPosition(
                    target: _currentPos!,
                    zoom: DEFAULT_ZOOM,
                  ),
                ),

          // Timer and Distance display
          Positioned(
            top: 50,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    _formatDuration(trackingProvider.duration),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Courier',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    "${trackingProvider.totalDistance.toStringAsFixed(0)} m",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Courier',
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Control Button
          if (_currentPos != null)
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 40.0, bottom: 40.0),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: trackingProvider.isTracking
                          ? Colors.red
                          : Colors.green,
                      width: 2,
                    ),
                  ),
                  child: FloatingActionButton(
                    heroTag: "trackBtn",
                    onPressed: () async {
                      if (trackingProvider.isTracking) {
                        trackingProvider.stopTracking();
                      } else {
                        // Use the permission helper
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
                                  "Background permission required to start tracking.",
                                ),
                              ),
                            );
                          }
                        }
                      }
                    },
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    child: Icon(
                      trackingProvider.isTracking
                          ? Icons.stop
                          : Icons.play_arrow,
                      color: trackingProvider.isTracking
                          ? Colors.red
                          : Colors.green,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
