package utez.edu.mx.ecommerceapi.pedidos.sse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.MediaType;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Conexiones SSE del personal. Requiere @EnableScheduling en la aplicación (heartbeat).
 * Funciona con UNA instancia del backend; con varias habría que propagar el evento (Redis, etc.).
 */
@Component
public class PedidoStreamBroadcaster {
    private static final Logger log = LoggerFactory.getLogger(PedidoStreamBroadcaster.class);

    private final Set<SseEmitter> emitters = ConcurrentHashMap.newKeySet();

    public SseEmitter subscribe() {
        SseEmitter emitter = new SseEmitter(0L); // sin timeout; el heartbeat detecta conexiones muertas
        emitters.add(emitter);
        emitter.onCompletion(() -> emitters.remove(emitter));
        emitter.onTimeout(() -> emitters.remove(emitter));
        emitter.onError(e -> emitters.remove(emitter));
        try {
            // La app, al recibirlo, vuelve a consultar la lista (recupera lo perdido en una desconexión).
            emitter.send(SseEmitter.event().name("connected").data("ok"));
        } catch (IOException e) {
            emitters.remove(emitter);
        }
        return emitter;
    }

    // AFTER_COMMIT: si el envío falla, el pedido ya quedó guardado.
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void onPedidoCreado(PedidoCreadoEvent event) {
        broadcast(SseEmitter.event()
                .name("pedido-creado")
                .id(String.valueOf(event.pedidoId()))
                .data(event, MediaType.APPLICATION_JSON));
    }

    @Scheduled(fixedRate = 25_000)
    public void heartbeat() {
        broadcast(SseEmitter.event().comment("hb"));
    }

    private void broadcast(SseEmitter.SseEventBuilder event) {
        for (SseEmitter e : emitters) {
            try {
                e.send(event);
            } catch (Exception ex) {
                log.debug("Conexión SSE descartada: {}", ex.getMessage());
                emitters.remove(e);
                try { e.completeWithError(ex); } catch (Exception ignored) { }
            }
        }
    }
}
