// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compass_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompassData _$CompassDataFromJson(Map<String, dynamic> json) => CompassData(
  heading: (json['heading'] as num).toDouble(),
  accuracy: (json['accuracy'] as num).toDouble(),
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$CompassDataToJson(CompassData instance) =>
    <String, dynamic>{
      'heading': instance.heading,
      'accuracy': instance.accuracy,
      'timestamp': instance.timestamp.toIso8601String(),
    };
