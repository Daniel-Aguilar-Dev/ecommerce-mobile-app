package utez.edu.mx.ecommerceapi.carrito.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;
import utez.edu.mx.ecommerceapi.carrito.entity.CarritoItem;

import java.util.List;

@Data
public class CarritoDto {
    @NotNull(message = "La lista de productos no puede estar vacía")
    @Size(min = 1, message = "La lista de productos debe tener al menos un producto")
    private List<CarritoItem> items;
    @NotNull(message = "La cantidad no puede estar vacía")
    @Min(value = 1, message = "La cantidad no puede ser negativa o cero")
    private int cantidad;
}
