import '../../domain/models/user_model.dart';

/// Datos hardcoded de usuarios para autenticación
class HardcodedUsers {
  /// Lista de usuarios disponibles en el sistema
  static final List<UserModel> users = [
    const UserModel(
      email: 'conductor.jhonatan@transporte.co',
      password: 'Cb2025',
      role: 'driver',
      name: 'Jhonatan Valencia',
    ),
    const UserModel(
      email: 'supervisor.andres@transporte.co',
      password: 'Sa2025',
      role: 'supervisor',
      name: 'Andrés Felipe Rojas',
    ),
  ];

  /// Busca un usuario por email, password y role
  /// Retorna el usuario si existe, null si no se encuentra
  static UserModel? findUser({
    required String email,
    required String password,
    required String role,
  }) {
    try {
      return users.firstWhere(
        (user) =>
            user.email == email &&
            user.password == password &&
            user.role == role,
      );
    } catch (e) {
      return null;
    }
  }
}

