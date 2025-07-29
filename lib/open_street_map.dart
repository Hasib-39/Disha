import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class OpenStreetMap extends StatefulWidget {
  const OpenStreetMap({super.key});

  @override
  State<OpenStreetMap> createState() => _OpenStreetMapState();
}

class _OpenStreetMapState extends State<OpenStreetMap> {
  final MapController _mapController = MapController();

  // ValueNotifier to hold current location marker position
  final ValueNotifier<LocationMarkerPosition> _locationPositionNotifier =
  ValueNotifier<LocationMarkerPosition>(
    const LocationMarkerPosition(
      latitude: 23.8103,
      longitude: 90.4125,
      accuracy: 0,
    ),
  );

  StreamSubscription<Position>? _positionSubscription;

  @override
  void initState() {
    super.initState();
    _startListeningLocation();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _locationPositionNotifier.dispose();
    super.dispose();
  }

  void _startListeningLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled.')));
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied.')));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Location permission permanently denied.')));
      return;
    }

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((position) {
      final locPos = LocationMarkerPosition(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
      );
      _locationPositionNotifier.value = locPos;
    });
  }

  Future<void> _goToCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      final userLocation = LatLng(position.latitude, position.longitude);
      _mapController.move(userLocation, 15);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to get current location')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disha'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: const LatLng(23.8103, 90.4125),
          initialZoom: 10,
        ),
        children: [
          TileLayer(
            urlTemplate:
            'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=CA2SB7JRT4tDeoi2xAtd',
            userAgentPackageName: 'com.hasib.disha_app',
          ),

          // Listen to ValueNotifier to update location marker position
          ValueListenableBuilder<LocationMarkerPosition>(
            valueListenable: _locationPositionNotifier,
            builder: (context, position, _) {
              return LocationMarkerLayer(
                position: position,
                style: const LocationMarkerStyle(
                  marker: DefaultLocationMarker(
                    child: Icon(Icons.location_pin, color: Colors.white),
                  ),
                  markerSize: Size(30, 30),
                  markerDirection: MarkerDirection.heading,
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToCurrentLocation,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.my_location, color: Colors.white, size: 30),
      ),
    );
  }
}
