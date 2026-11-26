String? numeroPositivoValidator(String? value, String nonEmptyMessage, int max, bool aceptaCero) {
  if (value == null || value.trim().isEmpty) {
    return nonEmptyMessage;
  }
  double? valor = double.tryParse(value);
  if(aceptaCero){
    if (valor! < 0) {
      return 'El valor no debe ser negativo';
    }
  } else {
    if (valor! <= 0) {
      return 'El valor no debe ser negativo o cero';
    }
  }
  if (valor > max) {
    return 'El valor es mayor al límite: $max';
  }
  return null;
}