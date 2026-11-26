String? codigoBarrasValidator(String? value) {
  final v = value?.trim() ?? '';
  if (v.isNotEmpty && !RegExp(r'^(\d{8}|\d{12}|\d{13})$').hasMatch(v)) {
    return 'El código debe tener 8, 12 o 13 dígitos';
  }
  return null;
}