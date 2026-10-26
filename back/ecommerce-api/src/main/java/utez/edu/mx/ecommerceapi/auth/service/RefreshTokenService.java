package utez.edu.mx.ecommerceapi.auth.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import utez.edu.mx.ecommerceapi.auth.entity.RefreshToken;
import utez.edu.mx.ecommerceapi.auth.repository.RefreshTokenRepository;
import utez.edu.mx.ecommerceapi.shared.exception.BusinessException;
import utez.edu.mx.ecommerceapi.shared.exception.ErrorCode;
import utez.edu.mx.ecommerceapi.usuarios.entity.Usuario;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.Instant;
import java.util.Base64;
import java.util.HexFormat;
import java.util.UUID;

/** Emite, rota y revoca refresh tokens opacos asociados a un usuario. */
@Service
public class RefreshTokenService {

    private static final int TOKEN_BYTES = 32;

    private final RefreshTokenRepository refreshTokenRepository;
    private final long expirationMs;
    private final SecureRandom secureRandom = new SecureRandom();

    public RefreshTokenService(
            RefreshTokenRepository refreshTokenRepository,
            @Value("${app.jwt.refresh-expiration-ms:2592000000}") long expirationMs
    ) {
        if (expirationMs <= 0) {
            throw new IllegalArgumentException("La duración del refresh token debe ser mayor que cero");
        }
        this.refreshTokenRepository = refreshTokenRepository;
        this.expirationMs = expirationMs;
    }

    /** Crea un token aleatorio; en la base solo se conserva su hash SHA-256. */
    @Transactional
    public Rotacion emitir(Usuario usuario) {
        Instant ahora = Instant.now();
        String sessionId = UUID.randomUUID().toString();
        String tokenEnClaro = generarTokenAleatorio();
        guardarHash(tokenEnClaro, sessionId, usuario, ahora);
        return new Rotacion(usuario, tokenEnClaro, sessionId);
    }

    /** Invalida el token presentado y emite uno nuevo dentro de la misma transacción. */
    @Transactional
    public Rotacion rotar(String tokenEnClaro) {
        if (tokenEnClaro == null || tokenEnClaro.isBlank()) {
            throw refreshTokenInvalido();
        }

        Instant ahora = Instant.now();
        RefreshToken tokenActual = refreshTokenRepository
                .findByTokenHashForUpdate(calcularHash(tokenEnClaro))
                .orElseThrow(this::refreshTokenInvalido);

        if (!tokenActual.estaVigenteEn(ahora)) {
            throw refreshTokenInvalido();
        }

        // Los refresh tokens emitidos antes de incorporar sessionId no pueden
        // asociarse a sus access JWT. Exigimos iniciar sesión otra vez.
        String sessionId = tokenActual.getSessionId();
        if (sessionId == null || sessionId.isBlank()) {
            tokenActual.revocar(ahora);
            throw refreshTokenInvalido();
        }

        Usuario usuario = tokenActual.getUsuario();
        if (!usuario.isStatus()) {
            throw new BusinessException(
                    ErrorCode.USUARIO_DESACTIVADO,
                    "El usuario está desactivado"
            );
        }

        tokenActual.revocar(ahora);
        String nuevoToken = generarTokenAleatorio();
        guardarHash(nuevoToken, sessionId, usuario, ahora);

        return new Rotacion(usuario, nuevoToken, sessionId);
    }

    /** Revoca el refresh token si existe; la operación es idempotente. */
    @Transactional
    public void revocar(String tokenEnClaro) {
        if (tokenEnClaro == null || tokenEnClaro.isBlank()) {
            return;
        }

        refreshTokenRepository.findByTokenHashForUpdate(calcularHash(tokenEnClaro))
                .ifPresent(token -> token.revocar(Instant.now()));
    }

    /** Consulta si un access JWT sigue perteneciendo a una sesión activa. */
    @Transactional(readOnly = true)
    public boolean sesionActiva(String sessionId) {
        return sessionId != null
                && !sessionId.isBlank()
                && refreshTokenRepository.existsBySessionIdAndRevokedAtIsNullAndExpiresAtAfter(
                        sessionId,
                        Instant.now()
                );
    }

    private void guardarHash(String tokenEnClaro, String sessionId, Usuario usuario, Instant ahora) {
        refreshTokenRepository.save(new RefreshToken(
                calcularHash(tokenEnClaro),
                sessionId,
                usuario,
                ahora,
                ahora.plusMillis(expirationMs)
        ));
    }

    private String generarTokenAleatorio() {
        byte[] bytes = new byte[TOKEN_BYTES];
        secureRandom.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    private String calcularHash(String tokenEnClaro) {
        try {
            byte[] digest = MessageDigest.getInstance("SHA-256")
                    .digest(tokenEnClaro.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(digest);
        } catch (NoSuchAlgorithmException ex) {
            throw new IllegalStateException("SHA-256 no está disponible", ex);
        }
    }

    private BusinessException refreshTokenInvalido() {
        return new BusinessException(
                ErrorCode.REFRESH_TOKEN_INVALIDO,
                "El refresh token no es válido o ha expirado"
        );
    }

    public record Rotacion(Usuario usuario, String refreshToken, String sessionId) {
    }
}
