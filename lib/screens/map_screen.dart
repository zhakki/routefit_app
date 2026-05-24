import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const LatLng _vk = LatLng(59.40157830303976, 27.291015175644905);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: _vk, zoom: 18),
        markers: {
          Marker(
            markerId: MarkerId("_currentLocation "),
            icon: BitmapDescriptor.defaultMarker,
          ),
        },
      ),
    );
  }
}
