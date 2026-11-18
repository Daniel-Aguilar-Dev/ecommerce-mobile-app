package utez.edu.mx.ecommerceapi.pedidos.dto;

import lombok.Data;
import utez.edu.mx.ecommerceapi.carrito.entity.Carrito;
import utez.edu.mx.ecommerceapi.pedidos.entity.Pedido;
import utez.edu.mx.ecommerceapi.pedidos.entity.PedidoEstadoEnum;
import utez.edu.mx.ecommerceapi.usuarios.entity.Usuario;

import java.math.BigDecimal;
import java.sql.Time;
import java.time.LocalDateTime;
import java.util.Date;

@Data
public class PedidoDto {
    private Long id;
    private BigDecimal costo;
    private Date fecha;
    private Time hora;
    private Usuario cliente;
    private Usuario responsable;
    private PedidoEstadoEnum estado;
    private Carrito carrito;
    private Long numPedido;
    private String textPedido;

    // Campos auditables
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private Long createdBy;
    private Long updatedBy;

    public Pedido toEntity() {
        Pedido pedido = new Pedido();
        Carrito carrito = new Carrito(this.carrito.getItems(), this.carrito.getCantidad());
        pedido.setId(this.id);
        pedido.setCosto(this.costo);
        pedido.setFecha(this.fecha);
        pedido.setHora(this.hora);
        pedido.setCliente(this.cliente);
        pedido.setResponsable(this.responsable);
        pedido.setEstado(this.estado);
        pedido.setCarrito(carrito);
        pedido.setNumPedido(this.numPedido);
        pedido.setTextPedido(String.format("%05d", this.numPedido));
        pedido.setEstado(this.estado);
        return pedido;
    }

    public static PedidoDto fromEntity(Pedido pedido) {
        PedidoDto pedidoDto = new PedidoDto();
        pedidoDto.setId(pedido.getId());
        pedidoDto.setCarrito(pedido.getCarrito());
        pedidoDto.setCosto(pedido.getCosto());
        pedidoDto.setFecha(pedido.getFecha());
        pedidoDto.setHora(pedido.getHora());
        pedidoDto.setCliente(pedido.getCliente());
        pedidoDto.setResponsable(pedido.getResponsable());
        pedidoDto.setNumPedido(pedido.getNumPedido());
        pedidoDto.setTextPedido(pedido.getTextPedido());
        pedidoDto.setEstado(pedido.getEstado());
        // Campos auditables
        pedidoDto.setCreatedAt(pedido.getCreatedAt());
        pedidoDto.setUpdatedAt(pedido.getUpdatedAt());
        pedidoDto.setCreatedBy(pedido.getCreatedBy());
        pedidoDto.setUpdatedBy(pedido.getUpdatedBy());
        return pedidoDto;
    }
}
