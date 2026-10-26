package utez.edu.mx.ecommerceapi.auth.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;
import utez.edu.mx.ecommerceapi.usuarios.entity.Usuario;

import java.time.Instant;

/** Persiste únicamente el hash del refresh token, nunca el secreto en claro. */
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Entity
@Table(
        name = "refresh_tokens",
        uniqueConstraints = @UniqueConstraint(name = "uk_refresh_token_hash", columnNames = "token_hash"),
        indexes = {
                @Index(name = "idx_refresh_token_usuario", columnList = "usuario_id"),
                @Index(name = "idx_refresh_token_session", columnList = "session_id, revoked_at, expires_at")
        }
)
public class RefreshToken {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "token_hash", nullable = false, length = 64)
    private String tokenHash;

    /** Identificador estable compartido por el refresh token y sus access JWT. */
    // Nullable para que ddl-auto=update pueda arrancar sobre una tabla creada
    // por la versión previa. Los tokens antiguos sin sesión se rechazan al rotar.
    @Column(name = "session_id", length = 36)
    private String sessionId;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "usuario_id", nullable = false)
    private Usuario usuario;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    @Column(name = "expires_at", nullable = false)
    private Instant expiresAt;

    @Column(name = "revoked_at")
    private Instant revokedAt;

    public RefreshToken(
            String tokenHash,
            String sessionId,
            Usuario usuario,
            Instant createdAt,
            Instant expiresAt
    ) {
        this.tokenHash = tokenHash;
        this.sessionId = sessionId;
        this.usuario = usuario;
        this.createdAt = createdAt;
        this.expiresAt = expiresAt;
    }

    public boolean estaVigenteEn(Instant instante) {
        return revokedAt == null && expiresAt.isAfter(instante);
    }

    public void revocar(Instant instante) {
        if (revokedAt == null) {
            revokedAt = instante;
        }
    }
}
