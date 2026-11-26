package utez.edu.mx.ecommerceapi.pedidos.service;

import utez.edu.mx.ecommerceapi.pedidos.entity.Pedido;

import java.math.BigDecimal;
import java.util.List;

/**
 * Lo implementa el módulo de ventas. Debe crear la venta (origen "pedido de cliente entregado")
 * y registrar los movimientos de salida (HU-4.3), vinculados al pedido.
 * <p>
 * IMPORTANTE: el stock ya fue descontado por ProductoService#deliverProductStock antes de llamar
 * a este puerto. La implementación NO debe volver a descontarlo; solo persiste venta y movimientos,
 * guardando el costo promedio de cada línea para calcular la utilidad.
 * Debe correr en la transacción de quien lo llama y devolver el id de la venta.
 */
public interface VentaPedidoPort {

    Long crearVentaDesdePedido(Pedido pedido, List<LineaVentaPedido> lineas, Long usuarioId, String metodoPago);

    record LineaVentaPedido(Long productoId, int cantidad, BigDecimal precioUnitario, BigDecimal costoPromedio) {
    }
}
