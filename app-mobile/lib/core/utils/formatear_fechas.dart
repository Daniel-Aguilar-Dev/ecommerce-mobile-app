import 'package:intl/intl.dart';

String fechaNormal(String datetime){
  final parsed = DateTime.parse(datetime);
  final fecha = DateFormat("d 'de' MMMM 'de' y", 'es_MX').format(parsed);
  return fecha;
  // 2 de noviembre de 2026
}

String fechaHora(String datetime){
  final parsed = DateTime.parse(datetime);
  final fechaHora = DateFormat("dd/MM/yyyy HH:mm", 'es_MX').format(parsed);
  return fechaHora;
  // 02/11/2026 00:02
}

String fechaHora12(String datetime){
  final parsed = DateTime.parse(datetime);
  final fechaHora12 = DateFormat("d MMM y, h:mm a", 'es_MX').format(parsed);
  return fechaHora12;
  // 2 nov 2026, 12:02 a.m.
}
