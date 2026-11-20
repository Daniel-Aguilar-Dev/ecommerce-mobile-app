package utez.edu.mx.ecommerceapi.pedidos.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class MetodoPagoRequest {

    @NotBlank(message = "El método de pago no puede estar vacío")
    private String metodo;
}
