package utez.edu.mx.ecommerceapi.shared.util;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import utez.edu.mx.ecommerceapi.shared.exception.BusinessException;
import utez.edu.mx.ecommerceapi.shared.exception.ErrorCode;

import java.util.Optional;

public final class SecurityUtils {

    private SecurityUtils() {
    }

    public static UsuarioAutenticado usuarioActual() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !(auth.getPrincipal() instanceof UsuarioAutenticado usuario)) {
            throw new BusinessException(ErrorCode.NO_AUTENTICADO, "No hay un usuario autenticado");
        }
        return usuario;
    }

    public static Long usuarioActualId() {
        return usuarioActual().id();
    }

    public static Optional<Long> usuarioActualIdOpcional() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.getPrincipal() instanceof UsuarioAutenticado usuario) {
            return Optional.of(usuario.id());
        }
        return Optional.empty();
    }

    public static boolean tieneRol(String rol) {
        return usuarioActual().rol().equals(rol);
    }
}
