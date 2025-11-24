import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/hardcoded_users.dart';
import '../../domain/models/user_model.dart';

part 'auth_provider.g.dart';

/// Estado de autenticación
class AuthState {
  final UserModel? user;
  final String? selectedRole;

  const AuthState({
    this.user,
    this.selectedRole,
  });

  /// Indica si el usuario está autenticado
  bool get isAuthenticated => user != null;

  /// Crea una copia del estado con campos opcionales modificados
  AuthState copyWith({
    UserModel? user,
    String? selectedRole,
    bool clearUser = false,
    bool clearRole = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      selectedRole: clearRole ? null : (selectedRole ?? this.selectedRole),
    );
  }
}

/// Provider de autenticación usando Riverpod con anotaciones
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    return const AuthState();
  }

  /// Inicia sesión con email, password y role
  /// Lanza una excepción si las credenciales son incorrectas
  Future<void> signIn({
    required String email,
    required String password,
    required String role,
  }) async {
    // Buscar usuario en los datos hardcoded
    final user = HardcodedUsers.findUser(
      email: email,
      password: password,
      role: role,
    );

    if (user == null) {
      throw Exception(
        'Credenciales incorrectas o rol no coincide. Verifique email, contraseña y rol.',
      );
    }

    // Actualizar estado con el usuario autenticado
    state = state.copyWith(
      user: user,
      selectedRole: role,
    );
  }

  /// Cierra la sesión del usuario
  void signOut() {
    state = state.copyWith(
      clearUser: true,
      clearRole: true,
    );
  }
}

