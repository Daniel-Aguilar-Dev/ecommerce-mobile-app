package utez.edu.mx.ecommerceapi.auth.dto;




public record LoginResponse(
        String token,
        String tipo,
        UsuarioInfo usuario
) {
    public record UsuarioInfo(Long id, String correo, String rol) {}
}