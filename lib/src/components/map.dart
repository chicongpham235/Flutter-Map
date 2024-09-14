import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:turf/helpers.dart';
import 'package:turf/turf.dart' as turf;
import 'dart:math' as math;
import 'dart:async';
import 'dart:convert';

const apiKey = "pkSvWOg9kuOA4I7sZSOV";
const styleUrl =
    "https://api.maptiler.com/maps/5d40e708-f08e-4fc2-b36b-01d6f46eb11b/style.json";

class MapComponentPage extends StatelessWidget {
  const MapComponentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MapComponent();
  }
}

class MapComponent extends StatefulWidget {
  const MapComponent({super.key});

  @override
  State createState() => MapComponentState();
}

class MapComponentState extends State<MapComponent> {
  MaplibreMapController? controller;
  Map<String, dynamic> geojson = {
    "type": "FeatureCollection",
    "features": [
      {
        "type": "Feature",
        "geometry": {
          "coordinates": [106.845861, -6.198122],
          "type": "Point"
        }
      },
      {
        "type": "Feature",
        "geometry": {
          "coordinates": [108.845861, -28.198122],
          "type": "Point"
        }
      },
      {
        "type": "Feature",
        "geometry": {
          "coordinates": [40.845861, -7.198122],
          "type": "Point"
        }
      },
      {
        "type": "Feature",
        "geometry": {
          "coordinates": [92.845861, 80.198122],
          "type": "Point"
        }
      },
    ]
  };

  void _onMapCreated(MaplibreMapController controller) {
    this.controller = controller;
  }

  void _onStyleLoadedCallback() async {
    BBox bounds = turf.bbox(GeoJSONObject.fromJson(geojson));

    fitBounds(controller!, bounds);

    await controller!.addSource(
      "projects",
      GeojsonSourceProperties(
        data: geojson,
      ),
    );

    controller!.addCircleLayer("projects", "projects",
        const CircleLayerProperties(circleRadius: 4, circleColor: '#ffffff'));

    var opacity = 0.6;
    var radius = 6;

    controller!.addCircleLayer(
        "projects",
        "projects-pulse",
        CircleLayerProperties(
            circleRadius: radius,
            circleColor: "#ffffff",
            circleOpacity: opacity));

    pulseDot(opacity: opacity, radius: radius);
  }

  void pulseDot({double opacity = 0.6, int radius = 6, bool isBlossom = true}) {
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      // debugPrint("$radius");
      if (isBlossom) {
        opacity = opacity - 0.05;
        radius = radius + 1;
      } else {
        opacity = opacity + 0.05;
        radius = radius - 1;
      }
      if (opacity <= 0.2) {
        isBlossom = false;
      }
      if (opacity >= 0.6) {
        isBlossom = true;
      }
      controller!.setLayerProperties(
          "projects-pulse",
          CircleLayerProperties(
              circleRadius: radius,
              circleColor: "#ffffff",
              circleOpacity: opacity));
    });
  }

  void fitBounds(MaplibreMapController mapController, BBox bounds) {
    var maxLat = bounds.lat1.toDouble() > bounds.lat2.toDouble()
        ? bounds.lat1.toDouble()
        : bounds.lat2.toDouble();
    var minLat = bounds.lat1.toDouble() <= bounds.lat2.toDouble()
        ? bounds.lat1.toDouble()
        : bounds.lat2.toDouble();
    var maxLng = bounds.lng1.toDouble() > bounds.lng2.toDouble()
        ? bounds.lng1.toDouble()
        : bounds.lng2.toDouble();
    var minLng = bounds.lng1.toDouble() <= bounds.lng2.toDouble()
        ? bounds.lng1.toDouble()
        : bounds.lng2.toDouble();

    mapController.setCameraBounds(
        north: maxLat, south: minLat, east: maxLng, west: minLng, padding: 100);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MaplibreMap(
        styleString: "$styleUrl?key=$apiKey",
        trackCameraPosition: true,
        myLocationEnabled: true,
        initialCameraPosition:
            const CameraPosition(target: LatLng(0, 0), zoom: 1),
        rotateGesturesEnabled: false,
        scrollGesturesEnabled: false,
        zoomGesturesEnabled: false,
        tiltGesturesEnabled: false,
        doubleClickZoomEnabled: false,
        attributionButtonMargins: const math.Point(-200, 0),
        onMapCreated: _onMapCreated,
        onStyleLoadedCallback: _onStyleLoadedCallback,
        minMaxZoomPreference: const MinMaxZoomPreference(1.0, 12.0),
      ),
    );
  }
}
