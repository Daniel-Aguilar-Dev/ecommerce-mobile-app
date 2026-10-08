package utez.edu.mx.ecommerceapi.shared.exception;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.security.web.access.AccessDeniedHandler;
import org.springframework.stereotype.Component;
import java.io.IOException;
import java.nio.charset.StandardCharsets;

@Component
public class ApiSecurityErrorHandler implements AuthenticationEntryPoint, AccessDeniedHandler {

    @Override
    public void commence(
            HttpServletRequest request,
            HttpServletResponse response,
            AuthenticationException exception
    ) throws IOException, ServletException {
        escribirError(
                response,
                HttpStatus.UNAUTHORIZED,
                "Se requiere un token válido para acceder a este recurso",
                ErrorCode.NO_AUTENTICADO
        );
    }

    @Override
    public void handle(
            HttpServletRequest request,
            HttpServletResponse response,
            AccessDeniedException exception
    ) throws IOException, ServletException {
        escribirError(
                response,
                HttpStatus.FORBIDDEN,
                "No tienes permiso para realizar esta acción",
                ErrorCode.ACCESO_DENEGADO
        );
    }

    private void escribirError(
            HttpServletResponse response,
            HttpStatus status,
            String message,
            ErrorCode errorCode
    ) throws IOException {
        response.setStatus(status.value());
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        response.setCharacterEncoding(StandardCharsets.UTF_8.name());
        // Los valores escritos aquí son mensajes y códigos internos constantes.
        response.getWriter().write(
                "{\"success\":false,\"message\":\"" + message
                        + "\",\"error\":\"" + errorCode.name() + "\"}"
        );
    }
}
