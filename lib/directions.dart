// ignore_for_file: non_constant_identifier_names

/*
class ViaWaypoint {
  final int waypoint_index;
  final double distance_from_start;
  final int geometry_index;
}

class MaxSpeed {
  final int speed;
  final String unit;
  final bool unknown;
}

class Annotation {
  final String congestion;
  final int congestion_numeric;
  final int distance;
  final int duration;
  final MaxSpeed mapspeed;
  final int speed;
}

class Closure {}

class Incident {}

class Admin {}

class Step {}

class Leg {
  final int distance;
  final int duration;
  final int weight;
  final int duration_typical;
  final int steps;
  final List<Step> steps;
  final String summary;
  final List<Admin> admins;
  final List<Incident> incidents;
  final List<Closure> closures;
  final Annotation annotation;
  final List<ViaWaypoint> via_waypoints;
}
*/

class Location {
  final double latitude;
  final double longitude;

  const Location({required this.latitude, required this.longitude});

  factory Location.fromJson(dynamic json) {
    return Location(latitude: json[0] as double, longitude: json[1] as double);
  }
}

class Waypoint {
  final String name;
  final Location location;
  final double distance;
  // final Meta metadata;

  const Waypoint(
      {required this.name, required this.location, required this.distance});

  factory Waypoint.fromJson(dynamic json) {
    Location location = Location.fromJson(json['location']);

    return Waypoint(
      name: json['name'] as String,
      location: location,
      distance: json['distance'] as double,
    );
  }
}

class Route {
  final double duration;
  final double distance;
  final String weight_name;
  final double weight;
  final double duration_typical;
  final double weight_typical;
  final String geometry;
  // final List<Leg> legs;
  final String voiceLocale;
  final List<Waypoint> waypoints;

  const Route(
      {required this.duration,
      required this.distance,
      required this.weight_name,
      required this.weight,
      required this.duration_typical,
      required this.weight_typical,
      required this.geometry,
      required this.voiceLocale,
      required this.waypoints});

  factory Route.fromJson(dynamic json) {
    var waypointsJsonObs = json['waypoints'] as List;
    List<Waypoint> waypoints = waypointsJsonObs
        .map((waypointJson) => Waypoint.fromJson(waypointJson))
        .toList();

    return Route(
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

class Directions {
  final String code;
  final List<Route> routes;

  const Directions({
    required this.code,
    required this.routes,
  });

  factory Directions.fromJson(dynamic json) {
    var routesJsonObs = json['routes'] as List;
    List<Route> routes =
        routesJsonObs.map((routeJson) => Route.fromJson(routeJson)).toList();

    return Directions(
      code: json['code'],
      routes: routes,
    );
  }
}
