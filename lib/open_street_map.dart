import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';

class OpenStreetMap extends StatefulWidget {
  const OpenStreetMap({super.key});

  @override
  State<OpenStreetMap> createState() => _OpenStreetMapState();
}

class _OpenStreetMapState extends State<OpenStreetMap> {
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  Future<void> _userCurrentLocation() async {
    if(_currentLocation != null){
      _mapController.move(_currentLocation!, 15);
    } else{
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Current Location not available"),),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text('Disha'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
          options: MapOptions(
            initialCenter: LatLng(0, 0),
            initialZoom: 2,
            minZoom: 0,
            maxZoom: 100,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            ),
            CurrentLocationLayer(
              style: LocationMarkerStyle(
                marker: DefaultLocationMarker(
                  child: Icon(Icons.location_pin, color: Colors.white,),
                ),
                markerSize: Size(30, 30),
                markerDirection: MarkerDirection.heading,
              ),
            ),
          ]
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0,
          onPressed: _userCurrentLocation,
        backgroundColor: Colors.blue,
        child: Icon(
          Icons.my_location,
          size: 30,
          color: Colors.white,
        ),
      ),
    );
  }
}