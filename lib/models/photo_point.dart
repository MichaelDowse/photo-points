import 'package:json_annotation/json_annotation.dart';
import 'photo.dart';

part 'photo_point.g.dart';

@JsonSerializable()
class PhotoPoint {
  final String id;
  final String name;
  final String? notes;
  final double? latitude;
  final double? longitude;
  final double? compassDirection;
  final DateTime createdAt;
  final List<Photo> photos;

  PhotoPoint({
    required this.id,
    required this.name,
    this.notes,
    this.latitude,
    this.longitude,
    this.compassDirection,
    required this.createdAt,
    required this.photos,
  });

  factory PhotoPoint.fromJson(Map<String, dynamic> json) =>
      _$PhotoPointFromJson(json);

  Map<String, dynamic> toJson() => _$PhotoPointToJson(this);

  PhotoPoint copyWith({
    String? id,
    String? name,
    String? notes,
    double? latitude,
    double? longitude,
    double? compassDirection,
    DateTime? createdAt,
    List<Photo>? photos,
  }) {
    return PhotoPoint(
      id: id ?? this.id,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      compassDirection: compassDirection ?? this.compassDirection,
      createdAt: createdAt ?? this.createdAt,
      photos: photos ?? this.photos,
    );
  }

  Photo? get initialPhoto => photos.isNotEmpty ? photos.first : null;

  String? get compassCardinalDirection {
    if (compassDirection == null) return null;
    final direction = compassDirection!;
    if (direction >= 348.75 || direction < 11.25) {
      return 'N';
    } else if (direction >= 11.25 && direction < 33.75) {
      return 'NNE';
    } else if (direction >= 33.75 && direction < 56.25) {
      return 'NE';
    } else if (direction >= 56.25 && direction < 78.75) {
      return 'ENE';
    } else if (direction >= 78.75 && direction < 101.25) {
      return 'E';
    } else if (direction >= 101.25 && direction < 123.75) {
      return 'ESE';
    } else if (direction >= 123.75 && direction < 146.25) {
      return 'SE';
    } else if (direction >= 146.25 && direction < 168.75) {
      return 'SSE';
    } else if (direction >= 168.75 && direction < 191.25) {
      return 'S';
    } else if (direction >= 191.25 && direction < 213.75) {
      return 'SSW';
    } else if (direction >= 213.75 && direction < 236.25) {
      return 'SW';
    } else if (direction >= 236.25 && direction < 258.75) {
      return 'WSW';
    } else if (direction >= 258.75 && direction < 281.25) {
      return 'W';
    } else if (direction >= 281.25 && direction < 303.75) {
      return 'WNW';
    } else if (direction >= 303.75 && direction < 326.25) {
      return 'NW';
    } else {
      return 'NNW';
    }
  }

  String? get compassDisplayText {
    if (compassDirection == null) return null;
    return '$compassCardinalDirection ${compassDirection!.toStringAsFixed(1)}°';
  }

  bool get hasLocation => latitude != null && longitude != null;
  bool get hasCompassDirection => compassDirection != null;
}
