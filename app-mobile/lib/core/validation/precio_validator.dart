String? precioValidator(String? value, String nonEmptyMessage) {
  if (value == null || value.trim().isEmpty) {
    return nonEmptyMessage;
  }
  double? valor = double.tryParse(value);
  if (valor! <= 0) {
    return 'El precio no debe ser negativo o cero';
  }
  if (valor > 999999) {
    return 'El precio es demasiado alto';
  }
  return null;
}