// ignore_for_file: non_constant_identifier_names

import 'package:rallyrouter/directions.dart';

class MapboxTracepoint {
  final int matchings_index;
  final int waypoint_index;
  final int alternatives_count;
  final String name;
  final List<MapboxLocation> location;

  factory MapboxTracepoint.fromJson(dynamic json) {}
}

class MapboxMatch {
  final double confidence;
  final double distance;
  final double duration;
  final double weight;
  final String weight_name;
  final String geometry;
  final List<MapboxLeg> legs;

  const MapboxMatch({
    required this.confidence,
    required this.distance,
    required this.duration,
    required this.weight,
    required this.weight_name,
    required this.geometry,
    required this.legs,
  });

  factory MapboxMatch.fromJson(dynamic json) {
    var legsJsonObs = json['legs'] as List;
    List<MapboxLeg> legs =
        legsJsonObs.map((legsJson) => MapboxLeg.fromJson(legsJson)).toList();

    return MapboxMatch(
      confidence: json['confidence'],
      distance: json['distance'],
      duration: json['duration'],
      weight: json['weight'],
      weight_name: json['weight_name'],
      geometry: json['geometry'],
      legs: legs,
    );
  }
}

class MapboxMapMatching {
  final String code;
  final List<MapboxMatch> matchings;
  final List<MapboxTracepoint> tracepoints;

  const MapboxMapMatching({
    required this.code,
    required this.matchings,
    required this.tracepoints,
  });

  factory MapboxMapMatching.fromJson(dynamic json) {
    var matchingsJsonList = json['matchings'] as List;
    List<MapboxMatch> matchings = matchingsJsonList
        .map((matchJson) => MapboxMatch.fromJson(matchJson))
        .toList();

    var tracepointJsonList = json['tracepoints'] as List;
    List<MapboxTracepoint> tracepoints = tracepointJsonList
        .map((pointJson) => MapboxTracepoint.fromJson(pointJson))
        .toList();

    return MapboxMapMatching(
      code: json['code'] as String,
      matchings: matchings,
      tracepoints: tracepoints,
    );
  }
}
