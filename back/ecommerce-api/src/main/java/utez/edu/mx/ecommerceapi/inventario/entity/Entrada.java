package utez.edu.mx.ecommerceapi.inventario.entity;

import java.sql.Date;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import jakarta.persistence.*;
import jakarta.validation.constraints.PositiveOrZero;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import utez.edu.mx.ecommerceapi.usuarios.entity.Usuario;

@Getter 
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Table(name = "entradas")
public class Entrada {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_usuario", nullable = false)
    private Usuario usuario;

    @Column(name = "fecha_entrada", nullable = false)
    private LocalDateTime fechaEntrada;

    @OneToMany(mappedBy = "entrada", cascade = CascadeType.ALL)
    private List<DetalleEntrada> detalles = new ArrayList<>();
}
