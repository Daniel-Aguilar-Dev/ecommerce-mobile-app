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
final class ErrorAutenticacion extends ApiException{
  const ErrorAutenticacion({ required super.statusCode, required super.message });
}

final class SinConexion extends ApiException{
  const SinConexion({required super.message});
}

final class TiempoAgotado extends ApiException{
  const TiempoAgotado({required super.message});
}

final class ErrorSerivdor extends ApiException{
  const ErrorSerivdor({ required super.statusCode, required super.message });
}

final class PeticionRechazada extends ApiException{
  const PeticionRechazada({ required super.statusCode, required super.message });
}

final class RespuestaInvalida extends ApiException{
  const RespuestaInvalida({required super.message});
}

final class DtoInvalido extends ApiException{
  const DtoInvalido({required super.message, required super.fieldErrors});
}