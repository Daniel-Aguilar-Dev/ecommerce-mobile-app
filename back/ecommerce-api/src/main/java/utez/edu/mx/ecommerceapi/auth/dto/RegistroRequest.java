package utez.edu.mx.ecommerceapi.auth.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record RegistroRequest (
        @NotBlank
        @Size(max = 50)
        String nombre,

        @NotBlank
        @Size(max = 100)
        String apellidos,

        @NotBlank
        @Size(max = 255)
        @Email(message = "Debe tener un formato de corre válido")
        String correo,

        @NotBlank
        @Size(max = 15)
        @Pattern(
                regexp = "^\\+?[0-9]{10,15}$",
                message = "El teléfono debe contener entre 10 y 15 dígitos numéricos y puede incluir el prefijo '+'"
        )
        String telefono,

        @NotBlank
        @Size(min = 8, max = 255)
        String contrasena
) {
}
