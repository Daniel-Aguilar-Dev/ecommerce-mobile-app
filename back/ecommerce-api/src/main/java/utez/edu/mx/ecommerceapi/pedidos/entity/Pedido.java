package utez.edu.mx.ecommerceapi.pedidos.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import utez.edu.mx.ecommerceapi.carrito.entity.Carrito;
import utez.edu.mx.ecommerceapi.shared.audit.AuditableEntity;
import utez.edu.mx.ecommerceapi.usuarios.entity.Usuario;

import java.math.BigDecimal;
import java.sql.Time;
import java.time.LocalDateTime;
import java.util.Date;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Table(name = "pedidos")
public class Pedido extends AuditableEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, precision = 12, scale = 2)
    private BigDecimal costo;

    // Redundantes con createdAt de AuditableEntity; considera quitarlas.
    @Column(nullable = false)
    private Date fecha;

    @Column(nullable = false)
    private Time hora;

    // Sin @GeneratedValue: solo @Id puede generarse. El número lo asigna PedidoService.
    @Column(nullable = false, unique = true, name = "num_pedido")
    private Long numPedido;

    @Column(nullable = false, unique = true, name = "text_pedido")
    private String textPedido;

    @ManyToOne(optional = false, fetch = FetchType.LAZY)
    @JoinColumn(nullable = false, name = "cliente_id")
    private Usuario cliente;

    // Null mientras ningún empleado haya actuado sobre el pedido.
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "responsable_id")
    private Usuario responsable;

    // STRING: con ordinal (default) agregar o reordenar estados corrompe los datos.
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, name = "estado", length = 20)
    private PedidoEstadoEnum estado = PedidoEstadoEnum.PED_PENDIENTE;

    @Column(name = "motivo_rechazo", length = 300)
    private String motivoRechazo;

    /** UUID opaco que viaja en el QR; se genera al pasar a PED_LISTO (HU-6.8). */
    @Column(name = "codigo_qr", unique = true, length = 36)
    private String codigoQr;

    @Column(name = "fecha_entrega")
    private LocalDateTime fechaEntrega;

    /** Venta generada al entregar; el método de pago vive en la venta. */
    @Column(name = "venta_id")
    private Long ventaId;

    @Column(nullable = false, name = "carrito", columnDefinition = "json")
    @JdbcTypeCode(SqlTypes.JSON)
    private Carrito carrito;
}