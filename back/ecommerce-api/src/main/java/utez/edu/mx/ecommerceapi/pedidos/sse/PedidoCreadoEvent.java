package utez.edu.mx.ecommerceapi.pedidos.sse;

import utez.edu.mx.ecommerceapi.pedidos.entity.PedidoEstadoEnum;

import java.time.LocalDateTime;

/**
 * Datos mínimos (HU-6.13): el detalle se consulta con los permisos habituales.
 */
public record PedidoCreadoEvent(Long pedidoId, PedidoEstadoEnum estado, LocalDateTime fecha) {
}
