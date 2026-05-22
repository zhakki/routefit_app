class CalorieCalculator {
  static double calculateCalories({
    required double weightKg,
    required double distanceKm,
  }) {
    return weightKg * distanceKm * 0.9;
  }
}