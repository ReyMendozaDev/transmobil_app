import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Utilidad para decodificar polilíneas codificadas en formato de Google Maps
class PolylineDecoder {
  /// Decodifica una cadena de polilínea codificada en una lista de LatLng
  /// Retorna una lista vacía si la cadena es nula o vacía
  static List<LatLng> decodePolyline(String? encodedPolyline) {
    if (encodedPolyline == null || encodedPolyline.isEmpty) {
      return [];
    }

    try {
      final polylinePoints = PolylinePoints();
      final points = polylinePoints.decodePolyline(encodedPolyline);
      return points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
    } catch (e) {
      // Si hay un error al decodificar, retornar lista vacía
      return [];
    }
  }
}

