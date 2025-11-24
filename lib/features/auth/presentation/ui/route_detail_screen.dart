import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../providers/route_provider.dart';
import '../../../../shared/widgets/custom_drawer.dart';
import '../../../../shared/utils/polyline_decoder.dart';

/// Pantalla de detalle de ruta seleccionada
class RouteDetailScreen extends ConsumerStatefulWidget {
  const RouteDetailScreen({super.key});

  @override
  ConsumerState<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends ConsumerState<RouteDetailScreen>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};

  // Simulation state
  AnimationController? _animationController;
  List<LatLng> _routeCoordinates = [];
  int _currentIndex = 0;
  BitmapDescriptor? _busIcon;

  @override
  void initState() {
    super.initState();
    _loadCustomMarker();
  }

  Future<void> _loadCustomMarker() async {
    final icon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/bus_icon.png',
    );
    setState(() => _busIcon = icon);
  }

  // Ubicación inicial: Bello, Antioquia
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(6.333, -75.55),
    zoom: 14.0,
  );

  /// Ajusta la cámara para mostrar toda la polilínea
  void _fitPolylineBounds(List<LatLng> points) {
    if (points.isEmpty || _mapController == null) return;

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      minLat = minLat < point.latitude ? minLat : point.latitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      minLng = minLng < point.longitude ? minLng : point.longitude;
      maxLng = maxLng > point.longitude ? maxLng : point.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100.0));
  }

  /// Carga la polilínea y los marcadores de la ruta
  void _loadRoutePolyline(String? polylinePoints, int? routeColor) {
    if (polylinePoints == null || polylinePoints.isEmpty) {
      setState(() {
        _polylines = {};
        _markers = {};
      });
      return;
    }

    // Decodificar la polilínea
    final points = PolylineDecoder.decodePolyline(polylinePoints);

    if (points.isEmpty) {
      setState(() {
        _polylines = {};
        _markers = {};
      });
      return;
    }

    // Crear la polilínea con el color de la ruta o azul por defecto
    final polyline = Polyline(
      polylineId: const PolylineId('route'),
      points: points,
      color: routeColor != null ? Color(routeColor) : Colors.blue,
      width: 5,
    );

    // Crear marcadores en el inicio y final de la ruta
    final startMarker = Marker(
      markerId: const MarkerId('start'),
      position: points.first,
      infoWindow: const InfoWindow(title: 'Inicio'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    final endMarker = Marker(
      markerId: const MarkerId('end'),
      position: points.last,
      infoWindow: const InfoWindow(title: 'Fin'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      _polylines = {polyline};
      _markers = {startMarker, endMarker};
    });

    // Ajustar la cámara para mostrar toda la ruta
    _fitPolylineBounds(points);

    // Iniciar simulación
    _routeCoordinates = points;
    _currentIndex = 0;
    _startSimulation();
  }

  void _startSimulation() {
    _animationController?.dispose();
    _animateToNextPoint();
  }

  void _animateToNextPoint() {
    if (_routeCoordinates.isEmpty ||
        _currentIndex >= _routeCoordinates.length - 1) {
      return;
    }

    final start = _routeCoordinates[_currentIndex];
    final end = _routeCoordinates[_currentIndex + 1];

    // Calculate distance to adjust duration (constant speed)
    // For simplicity, we can use a fixed duration per segment or calculate it.
    // Let's use a fixed duration of 1 second per segment for now, or faster if segments are short.
    // A better approach is distance-based duration.
    // const double speed = 0.0001; // degrees per millisecond (approx)
    // double dist = sqrt(pow(end.latitude - start.latitude, 2) + pow(end.longitude - start.longitude, 2));
    // int durationMs = (dist / speed).round();
    // durationMs = durationMs < 500 ? 500 : durationMs; // Min duration

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000), // 2 seconds per segment
    );

    final latTween = Tween<double>(begin: start.latitude, end: end.latitude);
    final lngTween = Tween<double>(begin: start.longitude, end: end.longitude);

    _animationController!.addListener(() {
      final value = _animationController!.value;
      final newPos = LatLng(
        latTween.transform(value),
        lngTween.transform(value),
      );
      _updateMarkerPosition(newPos);
    });

    _animationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _currentIndex++;
        _animationController!.dispose();
        _animateToNextPoint();
      }
    });

    _animationController!.forward();
  }

  void _updateMarkerPosition(LatLng position) {
    // Update only the bus marker, keeping start/end markers
    setState(() {
      _markers.removeWhere((m) => m.markerId.value == 'bus');
      _markers.add(
        Marker(
          markerId: const MarkerId('bus'),
          position: position,
          icon: _busIcon ?? BitmapDescriptor.defaultMarker,
          anchor: const Offset(0.5, 0.5),
          zIndex: 2, // Ensure bus is on top
        ),
      );
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routeState = ref.watch(routeNotifierProvider);
    final selectedRoute = routeState.selectedRoute;

    // Cargar la polilínea cuando cambia la ruta seleccionada
    if (selectedRoute != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadRoutePolyline(
          selectedRoute.polylinePoints,
          selectedRoute.routeColor,
        );
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de Ruta')),
      drawer: const CustomDrawer(),
      body: selectedRoute == null
          ? const Center(child: Text('No hay ruta seleccionada'))
          : Stack(
              children: [
                // Mapa de Google Maps que ocupa toda la pantalla
                GoogleMap(
                  initialCameraPosition: _initialCameraPosition,
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                    // Cargar la polilínea después de que el mapa esté listo
                    if (selectedRoute.polylinePoints != null) {
                      _loadRoutePolyline(
                        selectedRoute.polylinePoints,
                        selectedRoute.routeColor,
                      );
                    }
                  },
                  polylines: _polylines,
                  markers: _markers,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                ),
                // Card superpuesto con información de la ruta
                Positioned(
                  bottom: 16.0,
                  left: 16.0,
                  right: 16.0,
                  child: Card(
                    elevation: 8.0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ruta: ${selectedRoute.code}',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            selectedRoute.name,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Recorrido: ${selectedRoute.name}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
