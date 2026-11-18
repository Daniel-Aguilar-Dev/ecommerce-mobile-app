package utez.edu.mx.ecommerceapi.pedidos.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;
import utez.edu.mx.ecommerceapi.carrito.dto.CarritoDto;
import utez.edu.mx.ecommerceapi.pedidos.entity.Pedido;
import utez.edu.mx.ecommerceapi.pedidos.entity.PedidoEstadoEnum;

import java.math.BigDecimal;
import java.sql.Time;
import java.util.Date;

/**
 * Entrada: solo se usa "carrito". El cliente sale del usuario autenticado, nunca del body.
 * Salida: no expone la entidad Usuario (evita filtrar datos y errores de lazy loading).
 */
@Data
public class PedidoPublicDto {
    private Long id;

    @NotNull(message = "El carrito del cliente no puede estar vacío")
    private CarritoDto carrito;

    private Long clienteId;
    private String clienteNombre;
    private PedidoEstadoEnum estado;
    private BigDecimal costo;
    private Date fecha;
    private Time hora;
    private Long numPedido;
    private String textPedido;
    private String motivoRechazo;

    /** Solo se envía al CLIENTE dueño y con el pedido en PED_LISTO (HU-6.8). */
    private String codigoQr;

    /** true cuando el pedido puede entregarse (PED_LISTO). Útil al escanear el QR (HU-6.9). */
    private boolean entregable;

    /** Vista del personal: sin código QR. */
    public static PedidoPublicDto fromEntity(Pedido pedido) {
        PedidoPublicDto dto = new PedidoPublicDto();
        CarritoDto carritoDto = new CarritoDto();
        carritoDto.setItems(pedido.getCarrito().getItems());
        carritoDto.setCantidad(pedido.getCarrito().getCantidad());

        dto.setId(pedido.getId());
        dto.setCarrito(carritoDto);
        dto.setClienteId(pedido.getCliente().getId());
        dto.setClienteNombre(pedido.getCliente().getNombre()); // AJUSTAR al getter real de Usuario
        dto.setEstado(pedido.getEstado());
        dto.setCosto(pedido.getCosto());
        dto.setFecha(pedido.getFecha());
        dto.setHora(pedido.getHora());
        dto.setNumPedido(pedido.getNumPedido());
        dto.setTextPedido(pedido.getTextPedido());
        dto.setMotivoRechazo(pedido.getMotivoRechazo());
        dto.setEntregable(pedido.getEstado() == PedidoEstadoEnum.PED_LISTO);
        return dto;
    }

    /** Vista del CLIENTE dueño: incluye el QR solo si el pedido está listo. */
    public static PedidoPublicDto fromEntityParaCliente(Pedido pedido) {
        PedidoPublicDto dto = fromEntity(pedido);
        if (pedido.getEstado() == PedidoEstadoEnum.PED_LISTO) {
            dto.setCodigoQr(pedido.getCodigoQr());
        }
        dto.setEntregable(false);
        return dto;
    }
}
