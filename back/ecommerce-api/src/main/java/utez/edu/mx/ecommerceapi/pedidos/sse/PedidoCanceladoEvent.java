package utez.edu.mx.ecommerceapi.pedidos.sse;

import utez.edu.mx.ecommerceapi.pedidos.entity.PedidoEstadoEnum;

import java.time.LocalDateTime;

public record PedidoCanceladoEvent(Long pedidoId, PedidoEstadoEnum estado, LocalDateTime fecha) {
}
