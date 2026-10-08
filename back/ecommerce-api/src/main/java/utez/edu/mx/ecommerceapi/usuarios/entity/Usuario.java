package utez.edu.mx.ecommerceapi.usuarios.entity;


import jakarta.persistence.*;
import lombok.*;
import utez.edu.mx.ecommerceapi.shared.audit.AuditableEntity;


@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Table(name = "Usuarios")
public class Usuario extends AuditableEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;


    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "rolId", nullable = false)
    private Rol rol;


    @Column(name = "nombre", nullable = false, length = 50)
    private String nombre;


    @Column(name = "apellido_p", nullable = false, length = 100)
    private String apellidoP;

    @Column(name = "apellido_m", nullable = false, length = 100)
    private String apellidoM;


    @Column(name = "correo", nullable = false, unique = true, length = 255)
    private String correo;


    @Column(name = "telefono", nullable = false, unique = true, length = 15)
    private String telefono;

    @Column(name = "contrasena", nullable = false, length = 255)
    private String contrasena;

    @Column(name = "foto_perfil", nullable = false, columnDefinition = "TEXT")
    private String fotoPerfil;




    @Column(name = "status", nullable = false)
    private boolean status = true;

}
