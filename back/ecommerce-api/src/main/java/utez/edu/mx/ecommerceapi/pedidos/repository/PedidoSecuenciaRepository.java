package utez.edu.mx.ecommerceapi.pedidos.repository;

import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import utez.edu.mx.ecommerceapi.pedidos.entity.PedidoSecuencia;

import java.util.Optional;

public interface PedidoSecuenciaRepository extends JpaRepository<PedidoSecuencia, Long> {
    /**
     * Bloquea la fila hasta el fin de la transacción para que dos pedidos simultáneos
     * no obtengan el mismo número. El servicio actualiza el conteo en la misma transacción,
     * así un rollback no deja huecos (ya no se usan incrementar()/decrementar()).
     */
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    Optional<PedidoSecuencia> findFirstBy();
}
