package utez.edu.mx.ecommerceapi.inventario.dto;

import java.util.List;

import jakarta.validation.constraints.NotEmpty;

public record EntradaRequest(
    @NotEmpty 
    List<DetalleEntradaRequest> detalles
) {}
