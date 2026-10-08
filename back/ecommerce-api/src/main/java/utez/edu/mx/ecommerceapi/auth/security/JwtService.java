package utez.edu.mx.ecommerceapi.auth.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import utez.edu.mx.ecommerceapi.shared.util.UsuarioAutenticado;

import javax.crypto.SecretKey;
import java.time.Instant;
import java.util.Date;

@Service
public class JwtService {

    private final SecretKey signingKey;
    private final io.jsonwebtoken.JwtParser parser;
    private final long expirationMs;

    public JwtService(
            @Value("${app.jwt.secret}") String secretBase64,
            @Value("${app.jwt.expiration-ms}") long expirationMs
    ) {
        if (expirationMs <= 0) {
            throw new IllegalArgumentException(
                    "La duración del token debe ser mayor que cero"
            );
        }

        byte[] keyBytes = Decoders.BASE64.decode(secretBase64);

        // JJWT rechazará una clave demasiado corta para la firma HMAC.
        this.signingKey = Keys.hmacShaKeyFor(keyBytes);
        this.parser = Jwts.parser()
                .verifyWith(signingKey)
                .build();
        this.expirationMs = expirationMs;
    }

    public String generarToken(UsuarioAutenticado usuario) {
        Instant ahora = Instant.now();

        return Jwts.builder()
                .subject(usuario.id().toString())
                .claim("correo", usuario.correo())
                // El valor es CLIENTE, EMPLEADO o ADMINISTRADOR;
                // el filtro añadirá ROLE_ al crear la autoridad.
                .claim("rol", usuario.rol())
                .issuedAt(Date.from(ahora))
                .expiration(Date.from(ahora.plusMillis(expirationMs)))
                .signWith(signingKey)
                .compact();
    }

    public UsuarioAutenticado leerUsuario(String token) {
        Claims claims = parser.parseSignedClaims(token).getPayload();

        Long id = Long.valueOf(claims.getSubject());
        String correo = claims.get("correo", String.class);
        String rol = claims.get("rol", String.class);

        if (correo == null || rol == null) {
            throw new IllegalArgumentException(
                    "El token no contiene los datos requeridos"
            );
        }

        return new UsuarioAutenticado(id, correo, rol);
    }

    public boolean esValido(String token) {
        try {
            leerUsuario(token);
            return true;
        } catch (JwtException | IllegalArgumentException ex) {
            return false;
        }
    }
}