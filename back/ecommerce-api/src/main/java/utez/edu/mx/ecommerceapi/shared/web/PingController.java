package utez.edu.mx.ecommerceapi.shared.web;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import utez.edu.mx.ecommerceapi.shared.response.ApiResponse;

import java.time.LocalDateTime;
import java.util.Map;

/** Endpoint para probar swagger sirve de ejemplo para los controllers */
@Tag(name = "Sistema")
@RestController
@RequestMapping("/api/v1/ping")
public class PingController {

    @Operation(summary = "Verifica que la API está arriba")
    @GetMapping
    public ApiResponse<Map<String, Object>> ping() {
        return ApiResponse.ok("pong", Map.of("fecha", LocalDateTime.now().toString()));
    }
}
