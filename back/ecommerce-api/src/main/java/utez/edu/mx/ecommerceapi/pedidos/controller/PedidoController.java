package utez.edu.mx.ecommerceapi.pedidos.controller;

import io.swagger.v3.oas.annotations.Operation;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;
import utez.edu.mx.ecommerceapi.pedidos.dto.MetodoPagoRequest;
import utez.edu.mx.ecommerceapi.pedidos.dto.MotivoRequest;
import utez.edu.mx.ecommerceapi.pedidos.dto.PedidoPublicDto;
import utez.edu.mx.ecommerceapi.pedidos.entity.PedidoEstadoEnum;
import utez.edu.mx.ecommerceapi.pedidos.service.PedidoService;
import utez.edu.mx.ecommerceapi.pedidos.sse.PedidoStreamBroadcaster;
import utez.edu.mx.ecommerceapi.shared.response.ApiResponse;

import java.util.List;

/**
 * La autorización por rol vive en SecurityConfig. Las rutas /one/cliente y /one/personal DEBEN
 * quedar restringidas ahí a CLIENTE y a EMPLEADO/ADMINISTRADOR respectivamente: el servicio
 * recibe "esPersonal" según la ruta y confía en que SecurityConfig la protege.
 */
@RestController
@RequestMapping("/api/v1/pedidos")
public class PedidoController {
    @Autowired
    private PedidoService pedidoService;

    @Autowired
    private PedidoStreamBroadcaster broadcaster;

    // ======================= CLIENTE =======================

    @Operation(summary = "Obtiene los pedidos del cliente autenticado, filtrables por estado")
    @GetMapping("/cliente")
    public ResponseEntity<ApiResponse<List<PedidoPublicDto>>> getPedidosCliente(
            @RequestParam(required = false) PedidoEstadoEnum estado
    ) {
        ApiResponse<List<PedidoPublicDto>> response = pedidoService.getPedidosByCliente(estado);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Obtiene un pedido para el cliente")
    @GetMapping("/one/cliente/{id}")
    public ResponseEntity<ApiResponse<PedidoPublicDto>> getOnePedidoCliente(
            @PathVariable Long id
    ) {
        ApiResponse<PedidoPublicDto> response = pedidoService.getPedido(id, false);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Registra un pedido")
    @PostMapping
    public ResponseEntity<ApiResponse<PedidoPublicDto>> postPedido(
            @Valid @RequestBody PedidoPublicDto dto
    ) {
        ApiResponse<PedidoPublicDto> response = pedidoService.postPedido(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @Operation(summary = "Cancela un pedido")
    @PatchMapping("/cancelar/{id}")
    public ResponseEntity<ApiResponse<Void>> cancelarPedido(
            @PathVariable Long id
    ) {
        ApiResponse<Void> response = pedidoService.cancelarPedido(id);
        return ResponseEntity.ok(response);
    }

    // ======================= PERSONAL =======================

    @Operation(summary = "Obtiene los pedidos entrantes para el personal, filtrables por estado")
    @GetMapping("/personal")
    public ResponseEntity<ApiResponse<List<PedidoPublicDto>>> getPedidosPersonal(
            @RequestParam(required = false) PedidoEstadoEnum estado
    ) {
        ApiResponse<List<PedidoPublicDto>> response = pedidoService.getPedidosEntrantes(estado);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Canal SSE: avisa al personal cuando un cliente genera un pedido")
    @GetMapping(value = "/personal/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public SseEmitter stream(HttpServletResponse response) {
        response.setHeader("Cache-Control", "no-cache");
        response.setHeader("X-Accel-Buffering", "no"); // evita que nginx bufferice el stream
        return broadcaster.subscribe();
    }

    @Operation(summary = "Obtiene un pedido para el personal")
    @GetMapping("/one/personal/{id}")
    public ResponseEntity<ApiResponse<PedidoPublicDto>> getOnePedidoPersonal(
            @PathVariable Long id
    ) {
        ApiResponse<PedidoPublicDto> response = pedidoService.getPedido(id, true);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Obtiene un pedido mediante QR")
    @GetMapping("/qr/{qr}")
    public ResponseEntity<ApiResponse<PedidoPublicDto>> getPedidoByQR(
            @PathVariable String qr
    ) {
        ApiResponse<PedidoPublicDto> response = pedidoService.getPedidoByQr(qr);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Confirma un pedido")
    @PatchMapping("/confirmar/{id}")
    public ResponseEntity<ApiResponse<PedidoPublicDto>> confirmarPedido(
            @PathVariable Long id
    ) {
        ApiResponse<PedidoPublicDto> response = pedidoService.confirmarPedido(id);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Rechaza un pedido")
    @PatchMapping("/rechazar/{id}")
    public ResponseEntity<ApiResponse<PedidoPublicDto>> rechazarPedido(
            @PathVariable Long id,
            @Valid @RequestBody MotivoRequest motivo
    ) {
        ApiResponse<PedidoPublicDto> response = pedidoService.rechazarPedido(id, motivo.getMotivo());
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Marca un pedido cómo listo")
    @PatchMapping("/listo/{id}")
    public ResponseEntity<ApiResponse<PedidoPublicDto>> marcarListoPedido(
            @PathVariable Long id
    ) {
        ApiResponse<PedidoPublicDto> response = pedidoService.marcarListo(id);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Entregar un pedido")
    @PatchMapping("/entregar/qr/{qr}")
    public ResponseEntity<ApiResponse<PedidoPublicDto>> entregarPedido(
            @PathVariable String qr,
            @Valid @RequestBody MetodoPagoRequest metodoPagoRequest
    ) {
        ApiResponse<PedidoPublicDto> response = pedidoService.entregarPedidoPorQr(qr, metodoPagoRequest.getMetodo());
        return ResponseEntity.ok(response);
    }
}
