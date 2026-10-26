class RegisterResponseDto {
  const RegisterResponseDto({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.rol,
  });

  final int id;
  final String nombre;
  final String correo;
  final String rol;

  factory RegisterResponseDto.fromJson(Map<String, dynamic> json) {
    return RegisterResponseDto(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      correo: json['correo'] as String,
      rol: json['rol'] as String,
    );
  }
}
