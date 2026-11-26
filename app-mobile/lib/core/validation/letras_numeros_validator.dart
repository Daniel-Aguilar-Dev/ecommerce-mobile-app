String? letrasNumerosValidator(String? value, String nonEmptyMessage) {
  if (value == null || value.trim().isEmpty) {
    return nonEmptyMessage;
  }
  final regex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ0-9. ]+$');
  if (!regex.hasMatch(value)) {
    return 'Solo se permiten letras, números y espacios';
  }
  return null;
}