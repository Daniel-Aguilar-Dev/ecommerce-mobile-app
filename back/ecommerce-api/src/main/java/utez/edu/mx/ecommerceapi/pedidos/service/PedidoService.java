package utez.edu.mx.ecommerceapi.pedidos.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import utez.edu.mx.ecommerceapi.carrito.dto.CarritoDto;
import utez.edu.mx.ecommerceapi.carrito.entity.Carrito;
import utez.edu.mx.ecommerceapi.carrito.entity.CarritoItem;
import utez.edu.mx.ecommerceapi.pedidos.dto.PedidoPublicDto;
import utez.edu.mx.ecommerceapi.pedidos.entity.Pedido;
import utez.edu.mx.ecommerceapi.pedidos.entity.PedidoEstadoEnum;
import utez.edu.mx.ecommerceapi.pedidos.entity.PedidoSecuencia;
import utez.edu.mx.ecommerceapi.pedidos.repository.PedidoRepository;
import utez.edu.mx.ecommerceapi.pedidos.repository.PedidoSecuenciaRepository;
import utez.edu.mx.ecommerceapi.pedidos.service.VentaPedidoPort.LineaVentaPedido;
import utez.edu.mx.ecommerceapi.pedidos.sse.PedidoCreadoEvent;
import utez.edu.mx.ecommerceapi.productos.entity.Producto;
import utez.edu.mx.ecommerceapi.productos.service.ProductoService;
import utez.edu.mx.ecommerceapi.shared.exception.BusinessException;
import utez.edu.mx.ecommerceapi.shared.exception.ErrorCode;
import utez.edu.mx.ecommerceapi.shared.exception.RecursoNoEncontradoException;
import utez.edu.mx.ecommerceapi.shared.response.ApiResponse;
import utez.edu.mx.ecommerceapi.usuarios.entity.Usuario;
import utez.edu.mx.ecommerceapi.usuarios.repository.UsuarioRepository;

import java.math.BigDecimal;
import java.sql.Time;
import java.time.LocalDateTime;
import java.util.*;

@Service
public class PedidoService {
    private static final Set<PedidoEstadoEnum> RECHAZABLES = EnumSet.of(
            PedidoEstadoEnum.PED_PENDIENTE, PedidoEstadoEnum.PED_CONFIRMADO, PedidoEstadoEnum.PED_LISTO);

    /** Estados en los que el pedido tiene stock reservado en Producto.stockReservado. */
    private static final Set<PedidoEstadoEnum> CON_RESERVA = EnumSet.of(
            PedidoEstadoEnum.PED_CONFIRMADO, PedidoEstadoEnum.PED_LISTO);

    @Autowired
    private PedidoRepository pedidoRepository;

    @Autowired
    private PedidoSecuenciaRepository pedidoSecuenciaRepository;

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private ProductoService productoService;

    @Autowired
    private VentaPedidoPort ventaPedidoPort;

    @Autowired
    private ApplicationEventPublisher eventPublisher;

    // ======================= CONSULTAS =======================

    @Transactional(readOnly = true)
    public ApiResponse<List<PedidoPublicDto>> getPedidosByCliente(Long clienteId, PedidoEstadoEnum estado) {
        List<Pedido> pedidos = (estado == null)
                ? pedidoRepository.findByCliente(clienteId)
                : pedidoRepository.findByClienteAndEstado(clienteId, estado);

        return ApiResponse.ok("Pedidos recuperados",
                pedidos.stream().map(PedidoPublicDto::fromEntityParaCliente).toList());
    }

    /** HU-6.4: pedidos entrantes para ADMIN/EMPLEADO, filtrables por estado. */
    @Transactional(readOnly = true)
    public ApiResponse<List<PedidoPublicDto>> getPedidosEntrantes(PedidoEstadoEnum estado) {
        List<Pedido> pedidos = (estado == null)
                ? pedidoRepository.findAllByOrderByIdDesc()
                : pedidoRepository.findByEstadoOrderByIdDesc(estado);

        return ApiResponse.ok("Pedidos recuperados", pedidos.stream().map(PedidoPublicDto::fromEntity).toList());
    }

    /** HU-6.11: el CLIENTE solo ve los suyos; el personal ve cualquiera. */
    @Transactional(readOnly = true)
    public ApiResponse<PedidoPublicDto> getPedido(Long id, Long usuarioId, boolean esPersonal) {
        Pedido pedido = findByIdOrThrow(id);
        if (!esPersonal && !pedido.getCliente().getId().equals(usuarioId))
            throw new RecursoNoEncontradoException("Pedido no encontrado con el id: ", id);

        return ApiResponse.ok("Pedido recuperado",
                esPersonal ? PedidoPublicDto.fromEntity(pedido) : PedidoPublicDto.fromEntityParaCliente(pedido));
    }

    /** HU-6.9: identifica el pedido a partir del QR. */
    @Transactional(readOnly = true)
    public ApiResponse<PedidoPublicDto> getPedidoByQr(String codigoQr) {
        Pedido pedido = pedidoRepository.findByCodigoQr(codigoQr)
                .orElseThrow(() -> new RecursoNoEncontradoException("El código no corresponde a un pedido válido: ", codigoQr));
        return ApiResponse.ok("Pedido recuperado", PedidoPublicDto.fromEntity(pedido));
    }

    // ======================= CLIENTE =======================

    /**
     * HU-6.1 (+ validaciones de HU-5.5). El cliente sale del usuario autenticado.
     * Aquí NO se reserva stock: solo se valida la disponibilidad (la reserva ocurre al confirmar).
     */
    @Transactional
    public ApiResponse<PedidoPublicDto> postPedido(PedidoPublicDto dto, Long clienteId) {
        Usuario cliente = usuarioRepository.findById(clienteId)
                .orElseThrow(() -> new RecursoNoEncontradoException("Cliente no encontrado con el id: ", clienteId));

        CarritoDto carritoDto = dto.getCarrito();
        if (carritoDto == null || carritoDto.getItems() == null || carritoDto.getItems().isEmpty())
            throw new BusinessException(ErrorCode.PEDIDO_SIN_PRODUCTOS, "El carrito no tiene productos");

        BigDecimal total = BigDecimal.ZERO;
        List<String> problemas = new ArrayList<>();
        Map<Long, Integer> pedidoPorProducto = new HashMap<>();

        for (CarritoItem item : carritoDto.getItems()) {
            // Todo se valida contra la BD: el precio y el stock del body no son confiables.
            Producto producto = productoService.findEntityByIdOrThrow(item.getProducto().getId());
            int cantidad = item.getCantidad();

            if (cantidad < 1) {
                problemas.add(producto.getNombre() + ": cantidad inválida");
                continue;
            }
            // El JSON del carrito es el snapshot del pedido: su precio debe ser el vigente.
            if (producto.getPrecioVenta().compareTo(item.getProducto().getPrecioVenta()) != 0) {
                problemas.add(producto.getNombre() + ": el precio cambió, actualiza tu carrito");
                continue;
            }
            // TODO HU-2.6: rechazar productos descontinuados.

            long disponible = producto.getStockActual() - producto.getStockReservado();
            int acumulado = pedidoPorProducto.merge(producto.getId(), cantidad, Integer::sum);
            if (acumulado > disponible) {
                problemas.add(producto.getNombre() + ": disponibles " + Math.max(disponible, 0));
                continue;
            }
            total = total.add(producto.getPrecioVenta().multiply(BigDecimal.valueOf(cantidad)));
        }
        if (!problemas.isEmpty())
            throw new BusinessException(ErrorCode.STOCK_INSUFICIENTE,
                    "No se puede generar el pedido: " + String.join("; ", problemas));

        // Bloquea la fila de la secuencia: números sin duplicados aunque haya pedidos simultáneos.
        PedidoSecuencia seq = pedidoSecuenciaRepository.findFirstBy()
                .orElseThrow(() -> new BusinessException(ErrorCode.ERROR_INTERNO,
                        "No se pudo obtener la secuencia de pedidos"));
        long numero = seq.getConteo();
        Date ahora = new Date();

        Pedido pedido = new Pedido();
        pedido.setCliente(cliente);
        pedido.setCarrito(new Carrito(carritoDto.getItems(), carritoDto.getCantidad()));
        pedido.setCosto(total);
        pedido.setFecha(ahora);
        pedido.setHora(new Time(ahora.getTime()));
        pedido.setEstado(PedidoEstadoEnum.PED_PENDIENTE);
        pedido.setNumPedido(numero);
        pedido.setTextPedido(String.format("%05d", numero));
        seq.setConteo(numero + 1); // misma transacción: un rollback no deja huecos

        pedidoRepository.save(pedido);

        // AFTER_COMMIT: el SSE solo avisa si el pedido realmente se guardó.
        eventPublisher.publishEvent(
                new PedidoCreadoEvent(pedido.getId(), pedido.getEstado(), LocalDateTime.now()));

        return ApiResponse.ok("Pedido registrado correctamente", PedidoPublicDto.fromEntityParaCliente(pedido));
    }

    /** HU-6.3: solo PED_PENDIENTE, que aún no tiene reserva (nada que liberar). */
    @Transactional
    public ApiResponse<Void> cancelarPedido(Long id, Long clienteId) {
        Pedido pedido = lockOrThrow(id);
        if (!pedido.getCliente().getId().equals(clienteId))
            throw new RecursoNoEncontradoException("Pedido no encontrado con el id: ", id);
        if (pedido.getEstado() != PedidoEstadoEnum.PED_PENDIENTE)
            throw new BusinessException(ErrorCode.PEDIDO_ESTADO_INVALIDO, "Tu pedido ya no se puede cancelar");

        pedido.setEstado(PedidoEstadoEnum.PED_CANCELADO);
        pedidoRepository.save(pedido);
        return ApiResponse.ok("Pedido cancelado correctamente");
    }

    // ======================= PERSONAL =======================

    /** HU-6.5: reserva el stock (valida disponibilidad real y producto activo). Todo o nada. */
    @Transactional
    public ApiResponse<PedidoPublicDto> confirmarPedido(Long id, Long userId) {
        Usuario responsable = usuarioOrThrow(userId);
        Pedido pedido = lockOrThrow(id);
        exigirEstado(pedido, PedidoEstadoEnum.PED_PENDIENTE, "Solo se pueden confirmar pedidos pendientes");

        // Si algún producto no alcanza, la excepción revierte también las reservas previas.
        for (LineaAgrupada l : agrupar(pedido)) {
            productoService.reserveProductStock(l.productoId(), l.cantidad());
        }

        pedido.setResponsable(responsable);
        pedido.setEstado(PedidoEstadoEnum.PED_CONFIRMADO);
        return ApiResponse.ok("Pedido confirmado", PedidoPublicDto.fromEntity(pedidoRepository.save(pedido)));
    }

    /** HU-6.6: motivo obligatorio; libera la reserva solo si el pedido la tenía. */
    @Transactional
    public ApiResponse<PedidoPublicDto> rechazarPedido(Long id, Long userId, String motivo) {
        if (motivo == null || motivo.isBlank())
            throw new BusinessException(ErrorCode.VALIDACION_FALLIDA, "El motivo de rechazo es obligatorio");

        Usuario responsable = usuarioOrThrow(userId);
        Pedido pedido = lockOrThrow(id);
        if (!RECHAZABLES.contains(pedido.getEstado()))
            throw new BusinessException(ErrorCode.PEDIDO_ESTADO_INVALIDO, "El pedido ya no puede rechazarse");

        // Desde PED_PENDIENTE no hay reserva: liberar aquí robaría la reserva de otros pedidos.
        if (CON_RESERVA.contains(pedido.getEstado())) {
            for (LineaAgrupada l : agrupar(pedido)) {
                productoService.liberateProductStock(l.productoId(), l.cantidad());
            }
        }

        pedido.setResponsable(responsable);
        pedido.setMotivoRechazo(motivo.trim());
        pedido.setEstado(PedidoEstadoEnum.PED_RECHAZADO);
        return ApiResponse.ok("Pedido rechazado", PedidoPublicDto.fromEntity(pedidoRepository.save(pedido)));
    }

    /** HU-6.7 + HU-6.8: la reserva se mantiene; se genera el código opaco del QR. */
    @Transactional
    public ApiResponse<PedidoPublicDto> marcarListo(Long id, Long userId) {
        Usuario responsable = usuarioOrThrow(userId);
        Pedido pedido = lockOrThrow(id);
        exigirEstado(pedido, PedidoEstadoEnum.PED_CONFIRMADO, "Solo un pedido confirmado puede marcarse como listo");

        pedido.setResponsable(responsable);
        if (pedido.getCodigoQr() == null) pedido.setCodigoQr(UUID.randomUUID().toString());
        pedido.setEstado(PedidoEstadoEnum.PED_LISTO);
        return ApiResponse.ok("Pedido listo para recoger", PedidoPublicDto.fromEntity(pedidoRepository.save(pedido)));
    }

    /** HU-6.10 (+ HU-4.3): consume la reserva, crea la venta y los movimientos en una sola transacción. */
    @Transactional
    public ApiResponse<PedidoPublicDto> entregarPedido(Long id, Long userId, String metodoPago) {
        if (metodoPago == null || metodoPago.isBlank())
            throw new BusinessException(ErrorCode.ACCESO_DENEGADO, "El método de pago es obligatorio");

        Usuario responsable = usuarioOrThrow(userId);
        Pedido pedido = lockOrThrow(id);

        // Idempotente: repetir la entrega no duplica la venta ni vuelve a descontar stock.
        if (pedido.getEstado() == PedidoEstadoEnum.PED_ENTREGADO)
            return ApiResponse.ok("El pedido ya había sido entregado", PedidoPublicDto.fromEntity(pedido));

        exigirEstado(pedido, PedidoEstadoEnum.PED_LISTO, "El pedido no está listo para recoger");

        // stockActual -= cantidad y stockReservado -= cantidad; devuelve el costo promedio para la utilidad.
        List<LineaVentaPedido> lineasVenta = new ArrayList<>();
        for (LineaAgrupada l : agrupar(pedido)) {
            BigDecimal costoPromedio = productoService.deliverProductStock(l.productoId(), l.cantidad());
            lineasVenta.add(new LineaVentaPedido(l.productoId(), l.cantidad(), l.precio(), costoPromedio));
        }

        Long ventaId = ventaPedidoPort.crearVentaDesdePedido(pedido, lineasVenta, userId, metodoPago);

        pedido.setVentaId(ventaId);
        pedido.setFechaEntrega(LocalDateTime.now());
        pedido.setResponsable(responsable);
        pedido.setEstado(PedidoEstadoEnum.PED_ENTREGADO);
        return ApiResponse.ok("Pedido entregado", PedidoPublicDto.fromEntity(pedidoRepository.save(pedido)));
    }

    /*
     * Reutilizables
     * */

    private record LineaAgrupada(Long productoId, int cantidad, BigDecimal precio) {}

    /**
     * Agrupa las líneas por producto y las ordena por id. El orden fijo evita interbloqueos:
     * dos transacciones que bloquean los mismos productos siempre los toman en el mismo orden.
     */
    private List<LineaAgrupada> agrupar(Pedido pedido) {
        Map<Long, LineaAgrupada> porProducto = new TreeMap<>();
        for (CarritoItem item : pedido.getCarrito().getItems()) {
            Long productoId = item.getProducto().getId();
            porProducto.merge(productoId,
                    new LineaAgrupada(productoId, item.getCantidad(), item.getProducto().getPrecioVenta()),
                    (a, b) -> new LineaAgrupada(productoId, a.cantidad() + b.cantidad(), a.precio()));
        }
        return new ArrayList<>(porProducto.values());
    }

    private Usuario usuarioOrThrow(Long id) {
        return usuarioRepository.findById(id)
                .orElseThrow(() -> new BusinessException(ErrorCode.ACCESO_DENEGADO,
                        "La persona que realiza la acción no está registrada"));
    }

    private void exigirEstado(Pedido pedido, PedidoEstadoEnum esperado, String mensaje) {
        if (pedido.getEstado() != esperado)
            throw new BusinessException(ErrorCode.PEDIDO_ESTADO_INVALIDO, mensaje);
    }

    private Pedido findByIdOrThrow(Long id) {
        return pedidoRepository.findById(id)
                .orElseThrow(() ->
                        new RecursoNoEncontradoException("Pedido no encontrado con el id: ", id));
    }

    /** Igual que findByIdOrThrow, pero bloquea la fila para que dos empleados no cambien el estado a la vez. */
    private Pedido lockOrThrow(Long id) {
        return pedidoRepository.findForUpdate(id)
                .orElseThrow(() ->
                        new RecursoNoEncontradoException("Pedido no encontrado con el id: ", id));
    }
}
