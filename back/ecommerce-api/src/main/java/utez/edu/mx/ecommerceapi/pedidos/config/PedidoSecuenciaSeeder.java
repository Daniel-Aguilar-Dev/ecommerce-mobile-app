package utez.edu.mx.ecommerceapi.pedidos.config;

import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;
import utez.edu.mx.ecommerceapi.pedidos.entity.PedidoSecuencia;
import utez.edu.mx.ecommerceapi.pedidos.repository.PedidoRepository;
import utez.edu.mx.ecommerceapi.pedidos.repository.PedidoSecuenciaRepository;

/** Garantiza que la numeración esté lista antes de aceptar el primer pedido. */
@Component
public class PedidoSecuenciaSeeder implements ApplicationRunner {

    private final PedidoSecuenciaRepository secuenciaRepository;
    private final PedidoRepository pedidoRepository;

    public PedidoSecuenciaSeeder(
            PedidoSecuenciaRepository secuenciaRepository,
            PedidoRepository pedidoRepository
    ) {
        this.secuenciaRepository = secuenciaRepository;
        this.pedidoRepository = pedidoRepository;
    }

    @Override
    @Transactional
    public void run(ApplicationArguments args) {
        if (secuenciaRepository.findFirstBy().isPresent()) return;

        PedidoSecuencia secuencia = new PedidoSecuencia();
        secuencia.setConteo(pedidoRepository.findMaxNumPedido() + 1);
        secuenciaRepository.save(secuencia);
    }
}
