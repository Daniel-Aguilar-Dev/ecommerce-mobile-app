String? nombreValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'El nombre es obligatorio';
  }
  final regex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ ]+$');
  if (!regex.hasMatch(value)) {
    return 'Solo se permiten letras y espacios';
  }
  return null;
}