import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/route_model.dart';

part 'route_provider.g.dart';

/// Estado del provider de rutas
class RouteState {
  final List<RouteModel> routes;
  final RouteModel? selectedRoute;

  const RouteState({
    required this.routes,
    this.selectedRoute,
  });

  /// Crea una copia del estado con campos opcionales modificados
  RouteState copyWith({
    List<RouteModel>? routes,
    RouteModel? selectedRoute,
    bool clearSelectedRoute = false,
  }) {
    return RouteState(
      routes: routes ?? this.routes,
      selectedRoute: clearSelectedRoute
          ? null
          : (selectedRoute ?? this.selectedRoute),
    );
  }
}

/// Lista estática de rutas hardcodeadas
class HardcodedRoutes {
  /// Lista de todas las rutas disponibles en el sistema
  static final List<RouteModel> allRoutes = [
    RouteModel(
      id: 'R1033',
      code: 'M1PC',
      internalNumber: '1033',
      name: 'La 33 - Barrio Obrero',
      assignedToDriver: 'conductor.jhonatan@transporte.co',
      polylinePoints: 'oxse@xedlM`CqBjC}@lB[}BsKeBw@uGtBuEpBbF~LpBS',
      routeColor: 0xFF2196F3, // Azul
    ),
    RouteModel(
      id: 'R1352',
      code: 'M1C',
      internalNumber: '1352',
      name: 'Comfama Bello - Centro',
      assignedToDriver: 'conductor.jhonatan@transporte.co',
      polylinePoints: 'c_te@|udlMkCgPuKrAaId@sCTt@jOb@hI|BkD~C}A`Im@xH_ADy@',
      routeColor: 0xFF2196F3, // Azul
    ),
    RouteModel(
      id: 'R1356',
      code: 'M2C',
      internalNumber: '1356',
      name: 'Barrio Riachuelos - Estación Niquía',
      assignedToDriver: 'conductor.jhonatan@transporte.co',
      polylinePoints: 'uipe@ngdlMxD`@J|@KzBk@`I[|E?dNXfPiJjCwEDQgVJ}MjAwL|B[\\oG??|CH',
      routeColor: 0xFF2196F3, // Azul
    ),
    const RouteModel(
      id: 'R1359',
      code: 'M5A',
      internalNumber: '1359',
      name: 'Alpujarra - Terminal Norte',
      assignedToDriver: 'supervisor.andres@transporte.co',
    ),
    const RouteModel(
      id: 'R1040',
      code: 'C2 006',
      internalNumber: '1040',
      name: 'Estación Madera - Barrio Obrero',
      assignedToDriver: 'supervisor.andres@transporte.co',
    ),
  ];
}

/// Provider de rutas usando Riverpod con anotaciones
@riverpod
class RouteNotifier extends _$RouteNotifier {
  @override
  RouteState build() {
    return RouteState(
      routes: HardcodedRoutes.allRoutes,
    );
  }

  /// Obtiene las rutas asignadas a un conductor por su email
  List<RouteModel> getAssignedRoutes(String driverEmail) {
    return state.routes
        .where((route) => route.assignedToDriver == driverEmail)
        .toList();
  }

  /// Selecciona una ruta
  void selectRoute(RouteModel route) {
    state = state.copyWith(selectedRoute: route);
  }
}

