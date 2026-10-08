package utez.edu.mx.ecommerceapi.usuarios.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import utez.edu.mx.ecommerceapi.usuarios.entity.Usuario;

import java.util.Optional;

public interface UsuarioRepository extends JpaRepository<Usuario, Long> {

    Optional<Usuario> findByCorreoIgnoreCase(String correo);

    boolean existsByCorreoIgnoreCase(String correo);

    boolean existsByTelefono(String telefono);
}
