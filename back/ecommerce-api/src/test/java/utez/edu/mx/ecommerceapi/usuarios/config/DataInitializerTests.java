package utez.edu.mx.ecommerceapi.usuarios.config;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.security.crypto.factory.PasswordEncoderFactories;
import utez.edu.mx.ecommerceapi.shared.exception.RecursoNoEncontradoException;
import utez.edu.mx.ecommerceapi.usuarios.entity.Rol;
import utez.edu.mx.ecommerceapi.usuarios.entity.RolEnum;
import utez.edu.mx.ecommerceapi.usuarios.entity.Usuario;
import utez.edu.mx.ecommerceapi.usuarios.repository.RolRepository;
import utez.edu.mx.ecommerceapi.usuarios.repository.UsuarioRepository;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

class DataInitializerTests {

    private UsuarioRepository usuarioRepository;
    private RolRepository rolRepository;
    private DataInitializer initializer;
    private final Map<String, Usuario> usuarios = new HashMap<>();

    @BeforeEach
    void setUp() {
        usuarioRepository = mock(UsuarioRepository.class);
        rolRepository = mock(RolRepository.class);
        initializer = new DataInitializer(usuarioRepository, rolRepository,
                PasswordEncoderFactories.createDelegatingPasswordEncoder());
        when(usuarioRepository.existsByCorreoIgnoreCase(anyString()))
                .thenAnswer(invocation -> usuarios.containsKey(invocation.getArgument(0)));
        when(usuarioRepository.save(any(Usuario.class))).thenAnswer(invocation -> {
            Usuario usuario = invocation.getArgument(0);
            usuarios.put(usuario.getCorreo(), usuario);
            return usuario;
        });
        when(rolRepository.findByNombreRol(any(RolEnum.class))).thenAnswer(invocation -> {
            Rol rol = new Rol();
            rol.setNombreRol(invocation.getArgument(0));
            // Los IDs del catálogo no necesitan coincidir con los del SQL original.
            rol.setId(100L + rol.getNombreRol().ordinal());
            return Optional.of(rol);
        });
    }

    @Test
    void creaLosTresUsuariosConCredencialesRolesYAuditoriaSolicitados() {
        initializer.run(null);

        assertEquals(3, usuarios.size());
        verificarUsuario("admin@example.com", "Leo", "Román", "7772653123",
                RolEnum.ADMINISTRADOR, "admin123");
        verificarUsuario("salem.barrera@example.com", "Salem", "Barrera Cangrejo", "7771234567",
                RolEnum.EMPLEADO, "empleado123");
        verificarUsuario("juan.aguilar@example.com", "Juan", "Aguilar", "7772394065",
                RolEnum.CLIENTE, "cliente123");
    }

    @Test
    void reiniciarNoDuplicaNiSobrescribeUsuariosExistentes() {
        initializer.run(null);
        Usuario admin = usuarios.get("admin@example.com");
        admin.setContrasena("hash-cambiado");
        admin.setStatus(false);

        initializer.run(null);

        assertEquals(3, usuarios.size());
        assertSame(admin, usuarios.get("admin@example.com"));
        assertEquals("hash-cambiado", admin.getContrasena());
        assertFalse(admin.isStatus());
        verify(usuarioRepository, times(3)).save(any(Usuario.class));
    }

    @Test
    void completaUsuariosFaltantesEnUnaBaseParcialmenteInicializada() {
        Usuario admin = new Usuario();
        usuarios.put("admin@example.com", admin);

        initializer.run(null);

        assertEquals(3, usuarios.size());
        assertSame(admin, usuarios.get("admin@example.com"));
        verify(usuarioRepository, times(2)).save(any(Usuario.class));
    }

    @Test
    void fallaSiNoSeInicializoElCatalogoDeRoles() {
        when(rolRepository.findByNombreRol(RolEnum.ADMINISTRADOR)).thenReturn(Optional.empty());

        assertThrows(RecursoNoEncontradoException.class, () -> initializer.run(null));
        verify(usuarioRepository, never()).save(any(Usuario.class));
    }

    private void verificarUsuario(String correo, String nombre, String apellidos, String telefono,
                                  RolEnum rol, String contrasena) {
        Usuario usuario = usuarios.get(correo);
        assertNotNull(usuario);
        assertEquals(nombre, usuario.getNombre());
        assertEquals(apellidos, usuario.getApellidos());
        assertEquals(telefono, usuario.getTelefono());
        assertEquals(rol, usuario.getRol().getNombreRol());
        assertTrue(usuario.isStatus());
        assertEquals(1L, usuario.getCreatedBy());
        assertEquals(1L, usuario.getUpdatedBy());
        assertNotEquals(contrasena, usuario.getContrasena());
        assertTrue(usuario.getContrasena().startsWith("{bcrypt}"));
        assertTrue(PasswordEncoderFactories.createDelegatingPasswordEncoder()
                .matches(contrasena, usuario.getContrasena()));
    }
}
