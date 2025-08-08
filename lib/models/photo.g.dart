// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Photo _$PhotoFromJson(Map<String, dynamic> json) => Photo(
  id: json['id'] as String,
  photoPointId: json['photoPointId'] as String,
  filePath: json['filePath'] as String?,
  assetId: json['assetId'] as String?,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  compassDirection: (json['compassDirection'] as num).toDouble(),
  takenAt: DateTime.parse(json['takenAt'] as String),
  isInitial: json['isInitial'] as bool,
  orientation: $enumDecode(_$PhotoOrientationEnumMap, json['orientation']),
);

Map<String, dynamic> _$PhotoToJson(Photo instance) => <String, dynamic>{
  'id': instance.id,
  'photoPointId': instance.photoPointId,
  'filePath': instance.filePath,
  'assetId': instance.assetId,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'compassDirection': instance.compassDirection,
  'takenAt': instance.takenAt.toIso8601String(),
  'isInitial': instance.isInitial,
  'orientation': _$PhotoOrientationEnumMap[instance.orientation]!,
};

const _$PhotoOrientationEnumMap = {
  PhotoOrientation.portrait: 'portrait',
  PhotoOrientation.landscape: 'landscape',
};
