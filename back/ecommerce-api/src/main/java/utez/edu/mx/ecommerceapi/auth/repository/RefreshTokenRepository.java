package utez.edu.mx.ecommerceapi.auth.repository;

import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import utez.edu.mx.ecommerceapi.auth.entity.RefreshToken;

import java.util.Optional;
import java.time.Instant;

public interface RefreshTokenRepository extends JpaRepository<RefreshToken, Long> {

    /** Bloquea el registro durante la rotación para evitar usarlo dos veces en paralelo. */
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select token from RefreshToken token join fetch token.usuario where token.tokenHash = :tokenHash")
    Optional<RefreshToken> findByTokenHashForUpdate(@Param("tokenHash") String tokenHash);

    boolean existsBySessionIdAndRevokedAtIsNullAndExpiresAtAfter(String sessionId, Instant ahora);
}
