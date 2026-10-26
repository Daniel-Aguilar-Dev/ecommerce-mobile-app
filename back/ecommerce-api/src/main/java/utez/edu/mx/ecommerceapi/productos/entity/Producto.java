package utez.edu.mx.ecommerceapi.productos.entity;

import java.math.BigDecimal;

import jakarta.persistence.*;

import jakarta.validation.constraints.PositiveOrZero;
import lombok.*;
import utez.edu.mx.ecommerceapi.categorias.entity.Categoria;
import utez.edu.mx.ecommerceapi.shared.audit.AuditableEntity;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Table(
        name = "productos",
        check = {
                @CheckConstraint(
                        name = "chk_stock_reservado",
                        constraint = "stock_reservado >= stock_actual"
                )
        }
)
public class Producto extends AuditableEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 50, unique = true)
    private String nombre;

    @Column(nullable = false, length = 150)
    private String descripcion;

    @Column(nullable = false, length = 25)
    private String marca;

    @Column(length = 25, unique = true)
    private String sku;

    @PositiveOrZero
    @Column(nullable = false, name = "stock_actual")
    private int stockActual;

    @PositiveOrZero
    @Column(nullable = false, name = "stock_minimo")
    private int stockMinimo;

    @PositiveOrZero
    @Column(nullable = false, name = "stock_reservado")
    private int stockReservado = 0;

    @PositiveOrZero
    @Column(nullable = false, name = "precio_compra", precision = 12, scale = 4)
    private BigDecimal precioCompra;

    @PositiveOrZero
    @Column(nullable = false, name = "precio_venta", precision = 12, scale = 4)
    private BigDecimal precioVenta;

    @Column(nullable = false, length = 25, name = "unidad_medida")
    private String unidadMedida;

    @Column(nullable = false, name = "imagen_public_id")
    private String imagenPublicId;

    @Column(nullable = false, name = "imagen_version")
    private Long imagenVersion;

    @Column(nullable = false, name = "estado")
    private ProductoEstadoEnum estado;

    @Column(name = "costo_promedio", nullable = false, precision = 12, scale = 4)
    private BigDecimal costoPromedio = BigDecimal.ZERO;

    @ManyToOne(optional = false, fetch = FetchType.EAGER)
    @JoinColumn(nullable = false, name = "categoria_id")
    private Categoria categoria;

    public int getStockDisponible() {
        return stockActual - stockReservado;
    }
}
