package utez.edu.mx.ecommerceapi.inventario.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.PositiveOrZero;

public record DetalleEntradaRequest(
    @NotNull 
    Long productoId,

    @Positive 
    int cantidad,

    @NotNull 
    @PositiveOrZero 
    Double precioUnitario
) {}
