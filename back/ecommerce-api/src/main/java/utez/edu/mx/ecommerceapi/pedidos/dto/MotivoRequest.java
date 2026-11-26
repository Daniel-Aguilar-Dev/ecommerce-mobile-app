package utez.edu.mx.ecommerceapi.pedidos.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;
import org.hibernate.validator.constraints.Length;

@Data
public class MotivoRequest {
    @NotBlank(message = "El motivo no puede estar vacío")
    @Length(max = 50, message = "El motivo no puede tener más de 50 carácteres")
    private String motivo;
}
