class LoginRequestDto {
  const LoginRequestDto({required this.correo, required this.contrasena});

  final String correo;
  final String contrasena;

  Map<String, dynamic> toJson() {
    return {'correo': correo, 'contrasena': contrasena};
  }
}
