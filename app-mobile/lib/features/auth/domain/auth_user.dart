class AuthUser {
  const AuthUser({
    required this.id,
    this.nombre,
    required this.correo,
    required this.rol,
  });

  final int id;
  final String? nombre;
  final String correo;
  final String rol;
}
