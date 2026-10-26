package utez.edu.mx.ecommerceapi.productos.dto;

public record StockLineaDto(Long productoId, String nombre, int solicitado, int disponible, boolean suficiente,
                            String motivo) {}