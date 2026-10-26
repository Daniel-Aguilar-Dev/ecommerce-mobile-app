/// Error propio de la app para representar fallos de comunicación con la API.
///
/// Agrupa en un solo tipo el mensaje, el estado HTTP y los errores por campo,
/// para que las capas superiores no dependan de detalles de `package:http`.
class ApiException implements Exception {
  /// Mensaje entendible para registrar o mostrar en la interfaz.
  final String message;

  /// Estado HTTP, por ejemplo 400 o 401; puede faltar si no hubo respuesta.
  final int? statusCode;

  /// Código de error definido por el backend, si vino en la respuesta.
  final String? code;

  /// Errores de validación indexados por nombre del campo.
  final Map<String, String> fieldErrors;

  /// Solo [message] es obligatorio; los otros datos dependen del tipo de fallo.
  const ApiException({
    required this.message,
    this.statusCode,
    this.code,
    this.fieldErrors = const {},
  });

  /// Hace que imprimir la excepción muestre el mensaje principal.
  @override
  String toString() => message;
}
