class RegisterRequestDto {
  const RegisterRequestDto({
    required this.nombre,
    required this.apellidos,
    required this.correo,
    required this.telefono,
    required this.contrasena,
  });

  final String nombre;
  final String apellidos;
  final String correo;
  final String telefono;
  final String contrasena;

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'apellidos': apellidos,
      'correo': correo,
      'telefono': telefono,
      'contrasena': contrasena,
    };
  }
}
