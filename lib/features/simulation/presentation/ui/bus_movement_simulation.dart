import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

/// A widget that simulates a bus moving along a decoded polyline route.
///
/// Requirements:
/// 1. StatefulWidget with a [Timer] to update position.
/// 2. Uses `flutter_polyline_points` to decode the polyline.
/// 3. Loads a custom bus icon from assets.
/// 4. Fits the map bounds to the whole route on start.
/// 5. Performs simple interpolation between points for smoother movement.
class BusMovementSimulation extends StatefulWidget {
  const BusMovementSimulation({Key? key}) : super(key: key);

  @override
  State<BusMovementSimulation> createState() => _BusMovementSimulationState();
}

class _BusMovementSimulationState extends State<BusMovementSimulation> {
  Timer? _timer;
  List<LatLng> _routeCoordinates = [];
  int _currentIndex = 0;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  BitmapDescriptor? _busIcon;
  GoogleMapController? _mapController;

  // Sample encoded polyline (Bello, Colombia). Replace with your own.
  static const String _encodedPolyline =
      "_p~iF~ps|U_ulLnnqC_mqNvxq`@"; // simple example

  @override
  void initState() {
    super.initState();
    _loadCustomMarker();
    _decodePolyline();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Loads the custom bus icon from the assets folder.
  Future<void> _loadCustomMarker() async {
    final icon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/bus_icon.png',
    );
    setState(() => _busIcon = icon);
  }

  /// Decodes the polyline string into a list of [LatLng] points.
  void _decodePolyline() {
    final result = PolylinePoints().decodePolyline(_encodedPolyline);
    _routeCoordinates = result
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();
    // Add the polyline to the map.
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: _routeCoordinates,
        color: Colors.blueAccent,
        width: 4,
      ),
    );
    // Place the initial marker.
    if (_routeCoordinates.isNotEmpty) {
      _markers.add(
        Marker(
          markerId: const MarkerId('bus'),
          position: _routeCoordinates.first,
          icon: _busIcon ?? BitmapDescriptor.defaultMarker,
        ),
      );
    }
    setState(() {});
  }

  /// Fits the camera to the bounds of the whole route.
  Future<void> _fitBounds() async {
    if (_mapController == null || _routeCoordinates.isEmpty) return;
    final bounds = _createLatLngBounds(_routeCoordinates);
    final cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 50);
    await _mapController!.animateCamera(cameraUpdate);
  }

  /// Creates a [LatLngBounds] that contains all points in [points].
  LatLngBounds _createLatLngBounds(List<LatLng> points) {
    double? minLat, maxLat, minLng, maxLng;
    for (final p in points) {
      minLat = (minLat == null)
          ? p.latitude
          : (p.latitude < minLat ? p.latitude : minLat);
      maxLat = (maxLat == null)
          ? p.latitude
          : (p.latitude > maxLat ? p.latitude : maxLat);
      minLng = (minLng == null)
          ? p.longitude
          : (p.longitude < minLng ? p.longitude : minLng);
      maxLng = (maxLng == null)
          ? p.longitude
          : (p.longitude > maxLng ? p.longitude : maxLng);
    }
    return LatLngBounds(
      southwest: LatLng(minLat!, minLng!),
      northeast: LatLng(maxLat!, maxLng!),
    );
  }

  /// Starts the periodic timer that moves the bus.
  void _startSimulation() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) => _updateBusPosition(),
    );
  }

  double _fraction = 0.0;

  /// Updates the bus marker position, interpolating between points for smoother motion.
  void _updateBusPosition() {
    if (_routeCoordinates.isEmpty) return;
    if (_currentIndex >= _routeCoordinates.length - 1) {
      // Stop simulation when the end is reached.
      _timer?.cancel();
      return;
    }

    final current = _routeCoordinates[_currentIndex];
    final next = _routeCoordinates[_currentIndex + 1];

    // Move 10% of the segment each tick
    _fraction += 0.1;

    if (_fraction >= 1.0) {
      _fraction = 0.0;
      _currentIndex++;
      // If we reached the end of the segment, ensure we snap to the next point
      if (_currentIndex < _routeCoordinates.length) {
        _updateMarkerPosition(_routeCoordinates[_currentIndex]);
      }
      return;
    }

    final interpolated = LatLng(
      current.latitude + (next.latitude - current.latitude) * _fraction,
      current.longitude + (next.longitude - current.longitude) * _fraction,
    );
    _updateMarkerPosition(interpolated);
  }

  void _updateMarkerPosition(LatLng position) {
    setState(() {
      _markers.removeWhere((m) => m.markerId.value == 'bus');
      _markers.add(
        Marker(
          markerId: const MarkerId('bus'),
          position: position,
          icon: _busIcon ?? BitmapDescriptor.defaultMarker,
          anchor: const Offset(0.5, 0.5),
          rotation: 0, // Optional: Calculate bearing for rotation
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bus Movement Simulation')),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(0, 0), // temporary, will be moved by _fitBounds
          zoom: 14,
        ),
        markers: _markers,
        polylines: _polylines,
        onMapCreated: (controller) async {
          _mapController = controller;
          // Wait a short moment for the map to be ready before fitting bounds.
          await Future.delayed(const Duration(milliseconds: 300));
          await _fitBounds();
          _startSimulation();
        },
      ),
    );
  }
}
