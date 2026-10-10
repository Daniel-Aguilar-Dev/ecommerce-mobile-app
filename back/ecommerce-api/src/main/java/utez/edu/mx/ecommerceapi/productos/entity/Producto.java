package utez.edu.mx.ecommerceapi.productos.entity;

import java.math.BigDecimal;
import java.util.List;

import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.validation.constraints.PositiveOrZero;
import lombok.*;
import utez.edu.mx.ecommerceapi.categorias.entity.Categoria;
import utez.edu.mx.ecommerceapi.shared.audit.AuditableEntity;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Entity
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

    @Column(nullable = false, length = 25, unique = true)
    private String sku;

    @PositiveOrZero
    @Column(nullable = false, name = "stock_actual")
    private int stockActual;

    @PositiveOrZero
    @Column(nullable = false, name = "stock_minimo")
    private int stockMinimo;

    @PositiveOrZero
    @Column(nullable = false, name = "precio_compra")
    private BigDecimal precioCompra;

    @PositiveOrZero
    @Column(nullable = false, name = "precio_venta")
    private BigDecimal precioVenta;

    @Column(nullable = false, length = 25, name = "unidad_medida")
    private String unidadMedida;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String imagen;

    @Column(nullable = false, name = "estado")
    private ProductoEstadoEnum estado;

    @ManyToOne(optional = false, fetch = FetchType.EAGER)
    @JoinColumn (nullable = false, name = "categoria_id")
    private Categoria categoria;

    @Column(nullable = false, name = "etiquetas", columnDefinition = "json")
    @JdbcTypeCode(SqlTypes.JSON)
    private List<String> etiquetas;

    @Column(nullable = false)
    private boolean status;
}
