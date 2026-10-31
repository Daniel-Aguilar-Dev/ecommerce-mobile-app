class StockLineaResponseDto {
  const StockLineaResponseDto({
    required this.productoId,
    required this.nombre,
    required this.solicitado,
    required this.disponible,
    required this.suficiente,
    required this.motivo
  });

  final int productoId;
  final String nombre;
  final int solicitado;
  final int disponible;
  final bool suficiente;
  final String motivo;

  factory StockLineaResponseDto.fromJson(Map<String, dynamic> json) {
    return StockLineaResponseDto(
      productoId: json['productoId'] as int,
      nombre: json['nombre'] as String,
      solicitado: json['solicitado'] as int,
      disponible: json['disponible'] as int,
      suficiente: json['suficiente'] as bool,
      motivo: json['motivo'] as String,
    );
  }
}