package utez.edu.mx.ecommerceapi.inventario.dto;

import java.time.LocalDateTime;
import java.util.List;

public record EntradaResponse(
    Long id,
    LocalDateTime fecha,
    String usuarioResponsable,
    List<DetalleResponse> detalles
) {
    public record DetalleResponse(
        Long id,
        Long productoId,
        String productoNombre,
        int cantidad,
        Double precioUnitario
    ) {}
}
