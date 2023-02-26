import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:rallyrouter/keys.dart';

class FullMap extends StatefulWidget {
  @override
  State createState() => FullMapState();
}

class FullMapState extends State<FullMap> {
  MapboxMapController? mapController;
  var isLight = true;
  var myAccessToken = MapboxAccessToken;

  List<LatLng> markers = [];

  setMarkers(List<LatLng> markers) {
    setState(() {
      this.markers = markers;
    });
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
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(32.0),
          child: FloatingActionButton(
            child: Icon(Icons.swap_horiz),
            onPressed: () => setState(
              () => isLight = !isLight,
            ),
          ),
        ),
        body: Row(children: [
          Expanded(
            flex: 7,
            child: MapboxMap(
              styleString: isLight ? MapboxStyles.LIGHT : MapboxStyles.DARK,
              accessToken: myAccessToken,
              onMapCreated: _onMapCreated,
              initialCameraPosition:
                  const CameraPosition(target: LatLng(0.0, 0.0)),
              onStyleLoadedCallback: _onStyleLoadedCallback,
              onMapClick: _onMapClick,
            ),
          ),
          Expanded(
            flex: 2,
            child: MarkerList(
              markers: markers,
              setMarkers: setMarkers,
            ),
          )
        ]));
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

class MarkerList extends StatelessWidget {
  final Function(List<LatLng> newMarkers)? setMarkers;
  List<LatLng> markers;

  MarkerList({Key? key, required this.markers, required this.setMarkers});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color oddItemColor = colorScheme.primary.withOpacity(0.05);
    final Color evenItemColor = colorScheme.primary.withOpacity(0.15);

    return ReorderableListView(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      children: <Widget>[
        for (int index = 0; index < markers.length; index += 1)
          ListTile(
            key: Key('$index'),
            tileColor: oddItemColor,
            title: Text(
                '$index ${markers[index].latitude}, ${markers[index].longitude}'),
          ),
      ],
      onReorder: (int oldIndex, int newIndex) {
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }
        final LatLng item = markers.removeAt(oldIndex);
        markers.insert(newIndex, item);
      },
    );
  }
}
