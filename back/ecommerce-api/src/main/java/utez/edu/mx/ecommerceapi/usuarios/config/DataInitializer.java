package utez.edu.mx.ecommerceapi.usuarios.config;

import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.core.annotation.Order;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;
import utez.edu.mx.ecommerceapi.shared.exception.RecursoNoEncontradoException;
import utez.edu.mx.ecommerceapi.usuarios.entity.Rol;
import utez.edu.mx.ecommerceapi.usuarios.entity.RolEnum;
import utez.edu.mx.ecommerceapi.usuarios.entity.Usuario;
import utez.edu.mx.ecommerceapi.usuarios.repository.RolRepository;
import utez.edu.mx.ecommerceapi.usuarios.repository.UsuarioRepository;

@Component
@Order(2)
public class DataInitializer implements ApplicationRunner {

    private final UsuarioRepository usuarioRepository;
    private final RolRepository rolRepository;
    private final PasswordEncoder passwordEncoder;

    public DataInitializer(UsuarioRepository usuarioRepository, RolRepository rolRepository,
                           PasswordEncoder passwordEncoder) {
        this.usuarioRepository = usuarioRepository;
        this.rolRepository = rolRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    @Transactional
    public void run(ApplicationArguments args) {
        crearUsuarioSiNoExiste(
                "Leo", "Román", "admin@example.com", "7772653123", RolEnum.ADMINISTRADOR,
                "admin123");
        crearUsuarioSiNoExiste(
                "Salem", "Barrera Cangrejo", "salem.barrera@example.com", "7771234567", RolEnum.EMPLEADO,
                "empleado123");
        crearUsuarioSiNoExiste(
                "Juan", "Aguilar", "juan.aguilar@example.com", "7772394065", RolEnum.CLIENTE,
                "cliente123");
    }

    private void crearUsuarioSiNoExiste(
            String nombre, String apellidos, String correo, String telefono,
            RolEnum nombreRol, String contrasena) {
        if (usuarioRepository.existsByCorreoIgnoreCase(correo)) {
            return;
        }

        Rol rol = rolRepository.findByNombreRol(nombreRol)
                .orElseThrow(() -> new RecursoNoEncontradoException("Rol", nombreRol));

        Usuario usuario = new Usuario();
        usuario.setNombre(nombre);
        usuario.setApellidos(apellidos);
        usuario.setCorreo(correo);
        usuario.setTelefono(telefono);
        usuario.setRol(rol);
        usuario.setContrasena(passwordEncoder.encode(contrasena));
        usuario.setStatus(true);
        usuario.setCreatedBy(1L);
        usuario.setUpdatedBy(1L);
        // createdAt y updatedAt los completa la auditoría JPA al insertar.
        usuarioRepository.save(usuario);
    }
}
