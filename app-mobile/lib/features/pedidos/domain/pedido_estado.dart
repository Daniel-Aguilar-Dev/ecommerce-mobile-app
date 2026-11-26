enum PedidoEstado {
  PED_PENDIENTE,
  PED_CONFIRMADO,
  PED_LISTO,
  PED_ENTREGADO,
  PED_RECHAZADO,
  PED_CANCELADO;

  static PedidoEstado fromJson(String value) =>
      PedidoEstado.values.byName(value);
}
