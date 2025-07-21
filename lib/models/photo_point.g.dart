// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_point.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PhotoPoint _$PhotoPointFromJson(Map<String, dynamic> json) => PhotoPoint(
  id: json['id'] as String,
  name: json['name'] as String,
  notes: json['notes'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  compassDirection: (json['compassDirection'] as num?)?.toDouble(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  photos: (json['photos'] as List<dynamic>)
      .map((e) => Photo.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PhotoPointToJson(PhotoPoint instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'notes': instance.notes,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'compassDirection': instance.compassDirection,
      'createdAt': instance.createdAt.toIso8601String(),
      'photos': instance.photos,
    };
