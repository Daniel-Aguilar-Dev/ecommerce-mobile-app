enum ProductoEstado {
  PROD_ACTIVO,
  PROD_DESCONTINUADO,
  PROD_ELIMINADO;

  static ProductoEstado fromJson(String value) =>
    ProductoEstado.values.byName(value);
}