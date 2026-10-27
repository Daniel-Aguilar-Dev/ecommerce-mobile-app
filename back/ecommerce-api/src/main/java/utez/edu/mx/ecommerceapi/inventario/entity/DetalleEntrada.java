package utez.edu.mx.ecommerceapi.inventario.entity;

import java.math.BigDecimal;

import jakarta.persistence.*;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.PositiveOrZero;
import lombok.*;
import utez.edu.mx.ecommerceapi.productos.entity.Producto;
import utez.edu.mx.ecommerceapi.shared.audit.AuditableEntity;


@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Table(name = "DetalleEntrada")
public class DetalleEntrada {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_entrada", nullable = false)
    private Entrada entrada;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_producto", nullable = false)
    private Producto producto;
    
    @Positive
    @Column(nullable = false)
    private int cantidad;

    @PositiveOrZero
    @Column(name = "precio_unitario", nullable = false, precision = 12, scale = 4)
    private Double precioUnitario;
}
