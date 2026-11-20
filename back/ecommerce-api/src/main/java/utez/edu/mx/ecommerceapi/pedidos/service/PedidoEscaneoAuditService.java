package utez.edu.mx.ecommerceapi.pedidos.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import utez.edu.mx.ecommerceapi.pedidos.entity.Pedido;
import utez.edu.mx.ecommerceapi.pedidos.entity.PedidoEscaneo;
import utez.edu.mx.ecommerceapi.pedidos.repository.PedidoEscaneoRepository;
import utez.edu.mx.ecommerceapi.shared.util.SecurityUtils;
import utez.edu.mx.ecommerceapi.usuarios.entity.Usuario;
import utez.edu.mx.ecommerceapi.usuarios.repository.UsuarioRepository;

import java.time.LocalDateTime;

@Service
public class PedidoEscaneoAuditService {
    private final PedidoEscaneoRepository escaneoRepository;
    private final UsuarioRepository usuarioRepository;

    public PedidoEscaneoAuditService(PedidoEscaneoRepository escaneoRepository,
                                     UsuarioRepository usuarioRepository) {
        this.escaneoRepository = escaneoRepository;
        this.usuarioRepository = usuarioRepository;
    }

    /** Persiste incluso intentos inválidos aunque la consulta termine en 404. */
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void registrar(String codigoQr, Pedido pedido, String resultado) {
        String codigoGuardado = codigoQr.length() > 255 ? codigoQr.substring(0, 255) : codigoQr;
        Usuario usuario = usuarioRepository.getReferenceById(SecurityUtils.usuarioActualId());
        escaneoRepository.save(new PedidoEscaneo(
                codigoGuardado, pedido, usuario, resultado, LocalDateTime.now()));
    }
}
