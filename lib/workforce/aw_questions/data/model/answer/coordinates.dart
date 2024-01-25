class Coordinates {
  Coordinates({
    required this.latitude,
    required this.longitude,
    this.accuracy,
  });

  late double latitude;
  late double longitude;
  late int? accuracy;
}