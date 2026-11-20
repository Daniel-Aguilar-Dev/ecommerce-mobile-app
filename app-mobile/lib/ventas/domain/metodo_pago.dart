enum MetodoPago {
  M_EFECTIVO,
  M_TARJETA,
  M_TRANSFERENCIA;

  static MetodoPago fromJson(String value) =>
      MetodoPago.values.byName(value);
}