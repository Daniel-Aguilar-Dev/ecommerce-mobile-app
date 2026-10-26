class LoginResponseDto {
  const LoginResponseDto({
    required this.token,
    required this.tipo,
    required this.refreshToken,
    required this.user,
  });

  final String token;
  final String tipo;
  final String refreshToken;
  final LoginUserDto user;

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDto(
      token: json['token'] as String,
      tipo: json['tipo'] as String,
      refreshToken: json['refreshToken'] as String,
      user: LoginUserDto.fromJson(json['usuario'] as Map<String, dynamic>),
    );
  }
}

class LoginUserDto {
  const LoginUserDto({
    required this.id,
    required this.correo,
    required this.rol,
  });

  final int id;
  final String correo;
  final String rol;

  factory LoginUserDto.fromJson(Map<String, dynamic> json) {
    return LoginUserDto(
      id: json['id'] as int,
      correo: json['correo'] as String,
      rol: json['rol'] as String,
    );
  }
}
