package utez.edu.mx.ecommerceapi.auth.dto;

public record RegistroResponse (
        Long id,
        String nombre,
        String correo,
        String rol
){
}
