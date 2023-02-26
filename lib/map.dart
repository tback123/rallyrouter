import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:rallyrouter/keys.dart';
import 'package:http/http.dart' as http;
import 'package:rallyrouter/directions.dart';

class RoutePlanningPage extends StatefulWidget {
  @override
  State createState() => RoutePlanningPageState();
}

class RoutePlanningPageState extends State<RoutePlanningPage> {
  MapboxMapController? mapController;
  var isLight = true;
  var myAccessToken = MapboxAccessToken;
  final String directionBase =
      'https://api.mapbox.com/directions/v5/mapbox/driving/';

  List<LatLng> markers = [];

  setMarkers(List<LatLng> markers) {
    setState(() {
      this.markers = markers;
    });
    mapController!.clearCircles();
    for (var marker in markers) {
      var cOptions =
          CircleOptions(circleColor: "red", geometry: marker, draggable: true);
      mapController!.addCircle(cOptions);
    }
  }

  getRoute() async {
    // Snackbar to show route in progress
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Center(child: Text("Getting Route...")),
      duration: Duration(seconds: 1),
    ));

    // Form request URL
    String request_url = directionBase;
    for (var marker in markers) {
      request_url += '${marker.longitude},${marker.latitude}';
      if (marker == markers.last) {
        request_url += '?';
      } else {
        request_url += ';';
      }
    }
    request_url += 'waypoints_per_route=true&';
    request_url += 'access_token=$myAccessToken';

    print(request_url);

    try {
      final response = await http.get(Uri.parse(request_url));
      if (response.statusCode == 200) {
        print(response.body.toString());
        final Directions dir = Directions.fromJson(jsonDecode(response.body));
        print(dir.code);
        print(dir.routes[0].waypoints[0].location.latitude);
        print(dir.routes[0].waypoints[0].location.longitude);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  _onMapCreated(MapboxMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  _onMapClick(Point<double> point, LatLng coordinates) {
    setState(() {
      markers.add(coordinates);
    });
    print(markers);

    var cOptions = CircleOptions(
        circleColor: "red", geometry: coordinates, draggable: true);
    mapController!.addCircle(cOptions);
  }

  _onStyleLoadedCallback() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Style loaded :)"),
      duration: Duration(seconds: 1),
    ));

    for (var marker in markers) {
      var cOptions =
          CircleOptions(circleColor: "red", geometry: marker, draggable: true);
      mapController!.addCircle(cOptions);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(children: [
        Expanded(
          flex: 7,
          child: Scaffold(
            floatingActionButton: Padding(
              padding: const EdgeInsets.all(32.0),
              child: FloatingActionButton(
                child: Icon(Icons.swap_horiz),
                onPressed: () => setState(
                  () => isLight = !isLight,
                ),
              ),
            ),
            body: MapboxMap(
              styleString: isLight
                  ? MapboxStyles.MAPBOX_STREETS
                  : MapboxStyles.SATELLITE_STREETS,
              accessToken: myAccessToken,
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(
                  target: LatLng(-33.865143, 151.209900), zoom: 13),
              onStyleLoadedCallback: _onStyleLoadedCallback,
              onMapClick: _onMapClick,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: MarkerPanel(
            markers: markers,
            setMarkers: setMarkers,
            getRoute: getRoute,
          ),
        ),
      ]),
    );
  }
}

class ElevatedCardExample extends StatelessWidget {
  const ElevatedCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Card(
        child: SizedBox(
          width: 300,
          height: 100,
          child: Center(child: Text('Elevated Card')),
        ),
      ),
    );
  }
}

class MarkerPanel extends StatelessWidget {
  final Function(List<LatLng> newMarkers)? setMarkers;
  final List<LatLng> markers;

  final Function() getRoute;

  MarkerPanel(
      {Key? key,
      required this.markers,
      required this.setMarkers,
      required this.getRoute});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
        flex: 1,
        child: Text(
          'Markers',
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      Expanded(
          flex: 10,
          child: Card(
              child: MarkerList(markers: markers, setMarkers: setMarkers))),
      ElevatedButton(onPressed: getRoute, child: Text('Get Route')),
    ]);
  }
}

class MarkerList extends StatelessWidget {
  final Function(List<LatLng> newMarkers)? setMarkers;
  final List<LatLng> markers;

  removeMarker(int index) {
    markers.removeAt(index);
    setMarkers!(markers);
  }

  MarkerList({Key? key, required this.markers, required this.setMarkers});

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      children: <Widget>[
        for (int index = 0; index < markers.length; index += 1)
          MarkerItem(
            index: index,
            point: markers[index],
            removeMarker: removeMarker,
          )
      ],
      onReorder: (int oldIndex, int newIndex) {
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }
        final LatLng item = markers.removeAt(oldIndex);
        markers.insert(newIndex, item);
        setMarkers!(markers);
      },
    );
  }
}

class MarkerItem extends StatelessWidget {
  final LatLng point;
  final int index;
  final Function removeMarker;

  MarkerItem(
      {required this.index, required this.point, required this.removeMarker})
      : super(key: Key('$index'));

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(children: [
        GestureDetector(
            onTap: () => {removeMarker(index)},
            child: Card(child: Icon(Icons.close))),
        Text("$index: ", style: TextStyle(fontWeight: FontWeight.bold)),
        Text("${point.latitude}, ${point.longitude}"),
      ]),
    );
  }
}
