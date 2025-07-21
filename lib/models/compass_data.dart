import 'package:json_annotation/json_annotation.dart';

part 'compass_data.g.dart';

@JsonSerializable()
class CompassData {
  final double heading;
  final double accuracy;
  final DateTime timestamp;

  CompassData({
    required this.heading,
    required this.accuracy,
    required this.timestamp,
  });

  factory CompassData.fromJson(Map<String, dynamic> json) =>
      _$CompassDataFromJson(json);

  Map<String, dynamic> toJson() => _$CompassDataToJson(this);

  double get normalizedHeading {
    double normalized = heading % 360;
    return normalized < 0 ? normalized + 360 : normalized;
  }

  double differenceTo(CompassData other) {
    double diff = (other.normalizedHeading - normalizedHeading).abs();
    return diff > 180 ? 360 - diff : diff;
  }

  double differenceTo180(double otherHeading) {
    double otherNormalized = otherHeading % 360;
    if (otherNormalized < 0) otherNormalized += 360;
    
    double diff = (otherNormalized - normalizedHeading).abs();
    return diff > 180 ? 360 - diff : diff;
  }

  bool isAlignedWith(CompassData other, {double toleranceDegrees = 1.0}) {
    return differenceTo(other) <= toleranceDegrees;
  }

  bool isAlignedWith180(double otherHeading, {double toleranceDegrees = 1.0}) {
    return differenceTo180(otherHeading) <= toleranceDegrees;
  }

  String get cardinalDirection {
    double normalized = normalizedHeading;
    if (normalized >= 348.75 || normalized < 11.25) {
      return 'N';
    } else if (normalized >= 11.25 && normalized < 33.75) {
      return 'NNE';
    } else if (normalized >= 33.75 && normalized < 56.25) {
      return 'NE';
    } else if (normalized >= 56.25 && normalized < 78.75) {
      return 'ENE';
    } else if (normalized >= 78.75 && normalized < 101.25) {
      return 'E';
    } else if (normalized >= 101.25 && normalized < 123.75) {
      return 'ESE';
    } else if (normalized >= 123.75 && normalized < 146.25) {
      return 'SE';
    } else if (normalized >= 146.25 && normalized < 168.75) {
      return 'SSE';
    } else if (normalized >= 168.75 && normalized < 191.25) {
      return 'S';
    } else if (normalized >= 191.25 && normalized < 213.75) {
      return 'SSW';
    } else if (normalized >= 213.75 && normalized < 236.25) {
      return 'SW';
    } else if (normalized >= 236.25 && normalized < 258.75) {
      return 'WSW';
    } else if (normalized >= 258.75 && normalized < 281.25) {
      return 'W';
    } else if (normalized >= 281.25 && normalized < 303.75) {
      return 'WNW';
    } else if (normalized >= 303.75 && normalized < 326.25) {
      return 'NW';
    } else {
      return 'NNW';
    }
  }

  String get displayText {
    return '$cardinalDirection ${normalizedHeading.toStringAsFixed(1)}°';
  }
}