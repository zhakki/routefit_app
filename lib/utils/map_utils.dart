import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapUtils {
  /// Calculates the LatLngBounds that encompass all provided points.
  static LatLngBounds getBounds(List<LatLng> points) {
    if (points.isEmpty) {
      // Fallback to a default position if no points exist
      return LatLngBounds(
        southwest: const LatLng(0, 0),
        northeast: const LatLng(0, 0),
      );
    }

    if (points.length == 1) {
      return LatLngBounds(southwest: points.first, northeast: points.first);
    }

    double minLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLat = points.first.latitude;
    double maxLng = points.first.longitude;

    for (var point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }
}
