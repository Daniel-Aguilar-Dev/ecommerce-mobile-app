package utez.edu.mx.ecommerceapi.auth.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record RegistroRequest (
        @NotBlank
        @Size(max = 50)
        String nombre,

        @NotBlank
        @Size(max = 100)
        String apellidoP,

        @NotBlank
        @Size(max = 100)
        String apellidoM,

        @NotBlank
        @Size(max = 255)
        String correo,

        @NotBlank
        @Size(max = 15)
        String telefono,

        @NotBlank
        @Size(min = 8, max = 255)
        String contrasena,

        @NotBlank
        String fotoPerfil

) {
}
