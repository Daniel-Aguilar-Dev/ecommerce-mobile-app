package utez.edu.mx.ecommerceapi.auth.service;

import lombok.AllArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import utez.edu.mx.ecommerceapi.auth.dto.LoginRequest;
import utez.edu.mx.ecommerceapi.auth.dto.LoginResponse;
import utez.edu.mx.ecommerceapi.auth.dto.RefreshTokenRequest;
import utez.edu.mx.ecommerceapi.auth.dto.RegistroRequest;
import utez.edu.mx.ecommerceapi.auth.dto.RegistroResponse;
import utez.edu.mx.ecommerceapi.auth.security.JwtService;
import utez.edu.mx.ecommerceapi.shared.exception.BusinessException;
import utez.edu.mx.ecommerceapi.shared.exception.ErrorCode;
import utez.edu.mx.ecommerceapi.shared.exception.RecursoNoEncontradoException;
import utez.edu.mx.ecommerceapi.shared.util.UsuarioAutenticado;
import utez.edu.mx.ecommerceapi.usuarios.entity.Rol;
import utez.edu.mx.ecommerceapi.usuarios.entity.RolEnum;
import utez.edu.mx.ecommerceapi.usuarios.entity.Usuario;
import utez.edu.mx.ecommerceapi.usuarios.repository.RolRepository;
import utez.edu.mx.ecommerceapi.usuarios.repository.UsuarioRepository;

import java.util.Locale;

@Service
@AllArgsConstructor
public class AuthService {

    private final UsuarioRepository usuarioRepository;
    private final RolRepository rolRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final RefreshTokenService refreshTokenService;



    @Transactional
    public RegistroResponse registrar(RegistroRequest solicitud) {
        String correo = solicitud.correo()
                .trim()
                .toLowerCase(Locale.ROOT);

        if (usuarioRepository.existsByCorreoIgnoreCase(correo)) {
            throw new BusinessException(
                    ErrorCode.DATO_DUPLICADO,
                    "El correo ya está registrado"
            );
        }

        if (usuarioRepository.existsByTelefono(solicitud.telefono())) {
            throw new BusinessException(
                    ErrorCode.DATO_DUPLICADO,
                    "El teléfono ya está registrado"
            );
        }

        Rol rolCliente = rolRepository.findByNombreRol(RolEnum.CLIENTE)
                .orElseThrow(() ->
                        new RecursoNoEncontradoException("Rol", RolEnum.CLIENTE));

        Usuario usuario = new Usuario();
        usuario.setNombre(solicitud.nombre().trim());
        usuario.setApellidos(solicitud.apellidos().trim());
        usuario.setCorreo(correo);
        usuario.setTelefono(solicitud.telefono().trim());
        usuario.setContrasena(passwordEncoder.encode(solicitud.contrasena()));
        usuario.setRol(rolCliente);
        usuario.setStatus(true);

        Usuario guardado = usuarioRepository.save(usuario);

        return new RegistroResponse(
                guardado.getId(),
                guardado.getNombre(),
                guardado.getCorreo(),
                guardado.getRol().getNombreRol().name()
        );
    }


    @Transactional
    public LoginResponse login(LoginRequest solicitud) {
        String correo = solicitud.correo()
                .trim()
                .toLowerCase(Locale.ROOT);

        Usuario usuario = usuarioRepository.findByCorreoIgnoreCase(correo)
                .orElseThrow(() -> new BusinessException(
                        ErrorCode.CREDENCIALES_INVALIDAS,
                        "Correo o contraseña incorrectos"
                ));

        if (!usuario.isStatus()) {
            throw new BusinessException(
                    ErrorCode.USUARIO_DESACTIVADO,
                    "El usuario está desactivado"
            );
        }

        if (!passwordEncoder.matches(
                solicitud.contrasena(),
                usuario.getContrasena()
        )) {
            throw new BusinessException(
                    ErrorCode.CREDENCIALES_INVALIDAS,
                    "Correo o contraseña incorrectos"
            );
        }

        RefreshTokenService.Rotacion sesion = refreshTokenService.emitir(usuario);
        return crearRespuestaTokens(usuario, sesion.refreshToken(), sesion.sessionId());
    }

    @Transactional
    public LoginResponse renovar(RefreshTokenRequest solicitud) {
        RefreshTokenService.Rotacion rotacion = refreshTokenService.rotar(solicitud.refreshToken());
        return crearRespuestaTokens(
                rotacion.usuario(),
                rotacion.refreshToken(),
                rotacion.sessionId()
        );
    }

    @Transactional
    public void cerrarSesion(RefreshTokenRequest solicitud) {
        refreshTokenService.revocar(solicitud.refreshToken());
    }

    private LoginResponse crearRespuestaTokens(
            Usuario usuario,
            String refreshToken,
            String sessionId
    ) {
        String rol = usuario.getRol().getNombreRol().name();
        UsuarioAutenticado principal = new UsuarioAutenticado(
                usuario.getId(),
                usuario.getCorreo(),
                rol
        );

        String accessToken = jwtService.generarToken(principal, sessionId);

        return new LoginResponse(
                accessToken,
                "Bearer",
                refreshToken,
                new LoginResponse.UsuarioInfo(
                        usuario.getId(),
                        usuario.getCorreo(),
                        rol
                )
        );
    }
}
