package utez.edu.mx.ecommerceapi.usuarios.config;

import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;
import utez.edu.mx.ecommerceapi.usuarios.entity.Rol;
import utez.edu.mx.ecommerceapi.usuarios.entity.RolEnum;
import utez.edu.mx.ecommerceapi.usuarios.repository.RolRepository;

@Component
public class RolSeeder implements ApplicationRunner {

    private final RolRepository rolRepository;

    public RolSeeder(RolRepository rolRepository) {
        this.rolRepository = rolRepository;
    }

    @Override
    public void run(ApplicationArguments args) {
        for (RolEnum nombreRol : RolEnum.values()) {
            if (!rolRepository.existsByNombreRol(nombreRol)) {
                Rol rol = new Rol();
                rol.setNombreRol(nombreRol);
                rolRepository.save(rol);
            }
        }
    }
}
