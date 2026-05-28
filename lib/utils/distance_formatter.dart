String formatDistance(double distanceKm) {
  final normalizedDistanceKm = distanceKm.isFinite && distanceKm > 0
      ? distanceKm
      : 0.0;

  if (normalizedDistanceKm < 1) {
    return '${(normalizedDistanceKm * 1000).round()} m';
  }

  if (normalizedDistanceKm < 10) {
    return '${normalizedDistanceKm.toStringAsFixed(1)} km';
  }

  return '${normalizedDistanceKm.round()} km';
}

String formatDistanceValue(double distanceKm) {
  return formatDistance(distanceKm).split(' ').first;
}

String formatDistanceUnit(double distanceKm) {
  return formatDistance(distanceKm).split(' ').last;
}
