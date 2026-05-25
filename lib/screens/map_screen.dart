import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:location/location.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

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

  //static const LatLng _vk = LatLng(59.40157830303976, 27.291015175644905);
  LatLng? _currentPos;

  final List<LatLng> _pointsOnMap = [];

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable(); // Prevent the screen from sleeping while on the map
    getLocationsUpdates();
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
    WakelockPlus.disable(); // Allow the screen to sleep again when leaving the map
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentPos == null
          ? const Center(child: Text("Loading ..."))
          : GoogleMap(
              polylines: {
                Polyline(
                  polylineId: PolylineId("id"),
                  points: _pointsOnMap,
                  color: Colors.blue,
                  width: 5,
                ),
              },
              onMapCreated: ((GoogleMapController controller) =>
                  _mapController.complete(controller)),
              initialCameraPosition: CameraPosition(
                target: _currentPos!,
                zoom: DEFAULT_ZOOM,
              ),
              markers: {
                Marker(
                  markerId: MarkerId("_currentPos"),
                  icon: BitmapDescriptor.defaultMarker,
                  position: _currentPos!,
                ),
              },
            ),
    );
  }

  Future<void> _cameraToPosition(LatLng position) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition newCameraPosition = CameraPosition(
      target: position,
      zoom: DEFAULT_ZOOM,
    );
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(newCameraPosition),
    );
  }

  Future<void> getLocationsUpdates() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _locationController.serviceEnabled();
    if (serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
    } else {
      return;
    }
    permissionGranted = await _locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
      _locationController.changeSettings(
        accuracy: LocationAccuracy.high,
        interval: 500,
        distanceFilter: 0.5,
      );

      _locationController.onLocationChanged.listen((
        LocationData currentLocation,
      ) {
        if (currentLocation.latitude != null &&
            currentLocation.longitude != null) {
          setState(() {
            _currentPos = LatLng(
              currentLocation.latitude!,
              currentLocation.longitude!,
            );
            //print(_currentPos);
            _cameraToPosition(_currentPos!);
            _pointsOnMap.add(_currentPos!);
            //print(_pointsOnMap.length);
          });
        }
      });
    }
  }
}
