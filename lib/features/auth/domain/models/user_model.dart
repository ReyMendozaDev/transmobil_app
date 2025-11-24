/// Modelo de usuario para la aplicación
class UserModel {
  final String email;
  final String password;
  final String role;
  final String name;

  const UserModel({
    required this.email,
    required this.password,
    required this.role,
    required this.name,
  });

  /// Crea una copia del usuario con campos opcionales modificados
  UserModel copyWith({
    String? email,
    String? password,
    String? role,
    String? name,
  }) {
    return UserModel(
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      name: name ?? this.name,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.email == email &&
        other.password == password &&
        other.role == role &&
        other.name == name;
  }

  @override
  int get hashCode {
    return email.hashCode ^
        password.hashCode ^
        role.hashCode ^
        name.hashCode;
  }
}

