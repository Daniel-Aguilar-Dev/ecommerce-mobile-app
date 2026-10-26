package utez.edu.mx.ecommerceapi.pedidos.entity;

import jakarta.persistence.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import utez.edu.mx.ecommerceapi.carrito.entity.Carrito;
import utez.edu.mx.ecommerceapi.shared.audit.AuditableEntity;

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

    // Poner demás atributos para el que le toque hacer esto

    @Column(nullable = false, name = "carrito", columnDefinition = "json")
    @JdbcTypeCode(SqlTypes.JSON)
    private Carrito carrito;
}
