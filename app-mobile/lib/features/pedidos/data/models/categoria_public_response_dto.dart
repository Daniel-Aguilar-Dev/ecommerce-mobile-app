class CategoriaPublicResponseDto {
  const CategoriaPublicResponseDto({
    required this.nombre,
    required this.id,
    required this.descripcion,
  });

  final String nombre;
  final int id;
  final String descripcion;

  factory CategoriaPublicResponseDto.fromJson(Map<String, dynamic> json) {
    return CategoriaPublicResponseDto(
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
      id: json['id'] as int
    );
  }
}