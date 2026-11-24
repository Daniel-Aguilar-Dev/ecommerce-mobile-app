package utez.edu.mx.ecommerceapi.pedidos.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import utez.edu.mx.ecommerceapi.pedidos.entity.Pedido;

import java.util.List;

/**
 * TEMPORAL: permite arrancar y probar pedidos mientras no exista el módulo de ventas.
 * BORRAR esta clase cuando ventas implemente VentaPedidoPort (si quedan dos beans, Spring no arranca).
 * <p>
 * Al entregar un pedido el stock SÍ se descuenta (lo hace ProductoService), pero NO se crea
 * ninguna venta: no uses esto con datos reales.
 */
@Component
public class VentaPedidoPortTemporal implements VentaPedidoPort {
    private static final Logger log = LoggerFactory.getLogger(VentaPedidoPortTemporal.class);

    @Override
    public Long crearVentaDesdePedido(Pedido pedido, List<LineaVentaPedido> lineas,
                                      Long usuarioId, String metodoPago) {
        if (log.isWarnEnabled())
            log.warn("VentaPedidoPortTemporal: pedido {} entregado SIN crear venta (módulo de ventas pendiente)",
                    pedido.getId());
        return null; // Pedido.ventaId es nullable
    }
}
