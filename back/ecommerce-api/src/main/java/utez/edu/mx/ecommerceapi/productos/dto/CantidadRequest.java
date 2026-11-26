package utez.edu.mx.ecommerceapi.productos.dto;

import jakarta.validation.constraints.*;

import lombok.Data;

@Data
public class CantidadRequest {
    @NotNull(message = "Este campo no puede estar vacío")
    @PositiveOrZero(message = "Este campo no puede ser negativo")
    private int cantidad;
}
