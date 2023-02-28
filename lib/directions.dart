// ignore_for_file: non_constant_identifier_names

import 'package:flutter/rendering.dart';

class MapboxViaWaypoint {
  final int waypoint_index;
  final double distance_from_start;
  final int geometry_index;

  const MapboxViaWaypoint({
    required this.waypoint_index,
    required this.distance_from_start,
    required this.geometry_index,
  });

  factory MapboxViaWaypoint.fromJson(dynamic json) {
    return MapboxViaWaypoint(
      waypoint_index: json['waypoint_index'],
      distance_from_start: json['distance_from_start'],
      geometry_index: json['geometry_index'],
    );
  }
}

class MapboxMaxSpeed {
  final int speed;
  final String unit;
  final bool unknown;

  const MapboxMaxSpeed({
    required this.speed,
    required this.unit,
    required this.unknown,
  });

  factory MapboxMaxSpeed.fromJson(dynamic json) {
    return MapboxMaxSpeed(
      speed: json['speed'],
      unit: json['unit'],
      unknown: json['unknown'],
    );
  }
}

class MapboxAnnotation {
  final String congestion;
  final int congestion_numeric;
  final int distance;
  final int duration;
  final MapboxMaxSpeed maxspeed;
  final int speed;

  const MapboxAnnotation({
    required this.congestion,
    required this.congestion_numeric,
    required this.distance,
    required this.duration,
    required this.maxspeed,
    required this.speed,
  });

  factory MapboxAnnotation.fromJson(dynamic json) {
    return MapboxAnnotation(
      congestion: json['congestion'],
      congestion_numeric: json['congestion_numeric'],
      distance: json['distance'],
      duration: json['duration'],
      maxspeed: MapboxMaxSpeed.fromJson(json['maxspeed']),
      speed: json['speed'],
    );
  }
}

// class MapboxClosure {}

// class MapboxIncident {}

// class MapboxAdmin {}

// class MapboxManeuver {}

// class MapboxIntersection {}

class MapboxStep {
  // final MapboxManeuver maneuver;
  final double distance;
  final double duration;
  final double weight;
  final double duration_typical;
  final double weight_typical;
  final String geometry;
  final String name;
  final String ref;
  final String destinations;
  final String exits;
  final String driving_side;
  final String mode;
  final String pronunciation;
  // final List<MapboxIntersection> intersections;
  final String speedLimitSign;
  final String speedLimitUnit;

  const MapboxStep({
    required this.distance,
    required this.duration,
    required this.weight,
    required this.duration_typical,
    required this.weight_typical,
    required this.geometry,
    required this.name,
    required this.ref,
    required this.destinations,
    required this.exits,
    required this.driving_side,
    required this.mode,
    required this.pronunciation,
    required this.speedLimitSign,
    required this.speedLimitUnit,
  });

  factory MapboxStep.fromJson(dynamic json) {
    return MapboxStep(
      distance: json['distance'],
      duration: json['duration'],
      weight: json['weight'],
      duration_typical: json['duration_typical'],
      weight_typical: json['weight_typical'],
      geometry: json['geometry'],
      name: json['name'],
      ref: json['ref'],
      destinations: json['destinations'],
      exits: json['exits'],
      driving_side: json['driving_side'],
      mode: json['mode'],
      pronunciation: json['pronunciation'],
      speedLimitSign: json['speedLimitSign'],
      speedLimitUnit: json['speedLimitUnit'],
    );
  }
}

class MapboxLeg {
  final double distance;
  final double duration;
  final double weight;
  final double duration_typical;
  final double weight_typical;
  final List<MapboxStep> steps;
  final String summary;
  // final List<MapboxAdmin> admins;
  // final List<MapboxIncident> incidents;
  // final List<MapboxClosure> closures;
  final MapboxAnnotation annotation;
  final List<MapboxViaWaypoint> via_waypoints;

  const MapboxLeg({
    required this.distance,
    required this.duration,
    required this.weight,
    required this.duration_typical,
    required this.weight_typical,
    required this.steps,
    required this.summary,
    required this.annotation,
    required this.via_waypoints,
  });

  factory MapboxLeg.fromJson(dynamic json) {
    var stepsJsonObs = json['steps'] as List;
    List<MapboxStep> steps =
        stepsJsonObs.map((wJson) => MapboxStep.fromJson(wJson)).toList();

    var vwJsonObs = json['via_waypoints'] as List;
    List<MapboxViaWaypoint> via_waypoints =
        vwJsonObs.map((wJson) => MapboxViaWaypoint.fromJson(wJson)).toList();

    return MapboxLeg(
      distance: json['distance'],
      duration: json['duration'],
      weight: json['weight'],
      duration_typical: json['duration_typical'],
      weight_typical: json['weight_typical'],
      steps: steps,
      summary: json['summary'],
      annotation: MapboxAnnotation.fromJson(json['annotation']),
      via_waypoints: via_waypoints,
    );
  }
}

class MapboxLocation {
  final double latitude;
  final double longitude;

  const MapboxLocation({required this.latitude, required this.longitude});

  factory MapboxLocation.fromJson(dynamic json) {
    return MapboxLocation(
        latitude: json[0] as double, longitude: json[1] as double);
  }
}

class MapboxWaypoint {
  final String name;
  final MapboxLocation location;
  final double distance;
  // final Meta metadata;

  const MapboxWaypoint(
      {required this.name, required this.location, required this.distance});

  factory MapboxWaypoint.fromJson(dynamic json) {
    MapboxLocation location = MapboxLocation.fromJson(json['location']);

    return MapboxWaypoint(
      name: json['name'] as String,
      location: location,
      distance: json['distance'] as double,
    );
  }
}

class MapboxRoute {
  final double duration;
  final double distance;
  final String weight_name;
  final double weight;
  final double duration_typical;
  final double weight_typical;
  final String geometry;
  // final List<Leg> legs;
  final String voiceLocale;
  final List<MapboxWaypoint> waypoints;

  const MapboxRoute(
      {required this.duration,
      required this.distance,
      required this.weight_name,
      required this.weight,
      required this.duration_typical,
      required this.weight_typical,
      required this.geometry,
      required this.voiceLocale,
      required this.waypoints});

  factory MapboxRoute.fromJson(dynamic json) {
    var waypointsJsonObs = json['waypoints'] as List;
    List<MapboxWaypoint> waypoints = waypointsJsonObs
        .map((waypointJson) => MapboxWaypoint.fromJson(waypointJson))
        .toList();

    return MapboxRoute(
      duration: json['duration'] as double,
      distance: json['distance'] as double,
      weight_name: json['weight_name'] as String,
      weight: json['weight'] as double,
      duration_typical: json['duration_typical'] != null
          ? json['duration_typical'] as double
          : 0.0,
      weight_typical: json['weight_typical'] != null
          ? json['weight_typical'] as double
          : 0.0,
      geometry: json['geometry'] as String,
      voiceLocale:
          json['voiceLocale'] != null ? json['voiceLocale'] as String : "",
      waypoints: waypoints,
    );
  }
}

class MapboxDirections {
  final String code;
  final List<MapboxRoute> routes;

  const MapboxDirections({
    required this.code,
    required this.routes,
  });

  factory MapboxDirections.fromJson(dynamic json) {
    var routesJsonObs = json['routes'] as List;
    List<MapboxRoute> routes = routesJsonObs
        .map((routeJson) => MapboxRoute.fromJson(routeJson))
        .toList();

    return MapboxDirections(
      code: json['code'],
      routes: routes,
    );
  }
}
