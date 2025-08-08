import 'package:json_annotation/json_annotation.dart';
import 'dart:math' as math;

part 'location_data.g.dart';

@JsonSerializable()
class LocationData {
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) =>
      _$LocationDataFromJson(json);

  Map<String, dynamic> toJson() => _$LocationDataToJson(this);

  double distanceTo(LocationData other) {
    const double earthRadius = 6371000; // Earth's radius in meters

    double lat1Rad = latitude * math.pi / 180;
    double lat2Rad = other.latitude * math.pi / 180;
    double deltaLatRad = (other.latitude - latitude) * math.pi / 180;
    double deltaLonRad = (other.longitude - longitude) * math.pi / 180;

    double a =
        math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.sin(deltaLonRad / 2) *
            math.sin(deltaLonRad / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  bool isWithinAccuracy(LocationData other, {double toleranceMeters = 5.0}) {
    return distanceTo(other) <= toleranceMeters;
  }

  String get formattedCoordinates {
    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }
}
