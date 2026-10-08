package utez.edu.mx.ecommerceapi.usuarios.entity;


import jakarta.persistence.*;
import lombok.*;

import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Table(name = "rol")
public class Rol {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;


    @Enumerated(EnumType.STRING)
    @Column(name = "nombreRol", nullable = false, unique = true, length = 30)
    private RolEnum nombreRol;


    @OneToMany(mappedBy = "rol")
    private List<Usuario> usuarios = new ArrayList<>();

}
