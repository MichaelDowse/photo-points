import 'package:json_annotation/json_annotation.dart';

part 'photo.g.dart';

enum PhotoOrientation {
  portrait,
  landscape;
  
  String get displayName {
    switch (this) {
      case PhotoOrientation.portrait:
        return 'Portrait';
      case PhotoOrientation.landscape:
        return 'Landscape';
    }
  }
}

@JsonSerializable()
class Photo {
  final String id;
  final String photoPointId;
  final String? filePath;
  final String? assetId;
  final double latitude;
  final double longitude;
  final double compassDirection;
  final DateTime takenAt;
  final bool isInitial;
  final PhotoOrientation orientation;

  Photo({
    required this.id,
    required this.photoPointId,
    this.filePath,
    this.assetId,
    required this.latitude,
    required this.longitude,
    required this.compassDirection,
    required this.takenAt,
    required this.isInitial,
    required this.orientation,
  });

  factory Photo.fromJson(Map<String, dynamic> json) => _$PhotoFromJson(json);

  Map<String, dynamic> toJson() => _$PhotoToJson(this);

  Photo copyWith({
    String? id,
    String? photoPointId,
    String? filePath,
    String? assetId,
    double? latitude,
    double? longitude,
    double? compassDirection,
    DateTime? takenAt,
    bool? isInitial,
    PhotoOrientation? orientation,
  }) {
    return Photo(
      id: id ?? this.id,
      photoPointId: photoPointId ?? this.photoPointId,
      filePath: filePath ?? this.filePath,
      assetId: assetId ?? this.assetId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      compassDirection: compassDirection ?? this.compassDirection,
      takenAt: takenAt ?? this.takenAt,
      isInitial: isInitial ?? this.isInitial,
      orientation: orientation ?? this.orientation,
    );
  }
}