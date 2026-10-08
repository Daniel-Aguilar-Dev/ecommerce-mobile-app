package utez.edu.mx.ecommerceapi.usuarios.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import utez.edu.mx.ecommerceapi.usuarios.entity.Rol;
import utez.edu.mx.ecommerceapi.usuarios.entity.RolEnum;

import java.util.Optional;

public interface RolRepository extends JpaRepository<Rol, Long> {

    boolean existsByNombreRol(RolEnum nombreRol);

    Optional<Rol> findByNombreRol(RolEnum nombreRol);
}
