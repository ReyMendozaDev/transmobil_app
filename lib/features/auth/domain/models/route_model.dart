/// Modelo de ruta para la aplicación
class RouteModel {
  final String id;
  final String code;
  final String internalNumber;
  final String name;
  final String assignedToDriver;
  final String? polylinePoints;
  final int? routeColor;

  const RouteModel({
    required this.id,
    required this.code,
    required this.internalNumber,
    required this.name,
    required this.assignedToDriver,
    this.polylinePoints,
    this.routeColor,
  });

  /// Crea una copia de la ruta con campos opcionales modificados
  RouteModel copyWith({
    String? id,
    String? code,
    String? internalNumber,
    String? name,
    String? assignedToDriver,
    String? polylinePoints,
    int? routeColor,
  }) {
    return RouteModel(
      id: id ?? this.id,
      code: code ?? this.code,
      internalNumber: internalNumber ?? this.internalNumber,
      name: name ?? this.name,
      assignedToDriver: assignedToDriver ?? this.assignedToDriver,
      polylinePoints: polylinePoints ?? this.polylinePoints,
      routeColor: routeColor ?? this.routeColor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RouteModel &&
        other.id == id &&
        other.code == code &&
        other.internalNumber == internalNumber &&
        other.name == name &&
        other.assignedToDriver == assignedToDriver &&
        other.polylinePoints == polylinePoints &&
        other.routeColor == routeColor;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        code.hashCode ^
        internalNumber.hashCode ^
        name.hashCode ^
        assignedToDriver.hashCode ^
        (polylinePoints?.hashCode ?? 0) ^
        (routeColor?.hashCode ?? 0);
  }
}

