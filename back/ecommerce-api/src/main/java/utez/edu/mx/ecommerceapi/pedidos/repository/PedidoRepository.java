package utez.edu.mx.ecommerceapi.pedidos.repository;

import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import utez.edu.mx.ecommerceapi.pedidos.entity.Pedido;
import utez.edu.mx.ecommerceapi.pedidos.entity.PedidoEstadoEnum;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

public interface PedidoRepository extends JpaRepository<Pedido, Long> {
    @Query("select p from Pedido p where p.cliente.id = :clienteId order by p.id desc")
    List<Pedido> findByCliente(Long clienteId);

    @Query("select p from Pedido p where p.cliente.id = :clienteId and p.estado = :estado order by p.id desc")
    List<Pedido> findByClienteAndEstado(Long clienteId, PedidoEstadoEnum estado);

    List<Pedido> findAllByOrderByIdDesc();

    List<Pedido> findByEstadoOrderByIdDesc(PedidoEstadoEnum estado);

    List<Pedido> findByEstadoIn(Collection<PedidoEstadoEnum> estados);

    Optional<Pedido> findByCodigoQr(String codigoQr);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select p from Pedido p where p.id = :id")
    Optional<Pedido> findForUpdate(Long id);
}
