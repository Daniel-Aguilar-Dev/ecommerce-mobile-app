package utez.edu.mx.ecommerceapi.auth.controller;


import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import utez.edu.mx.ecommerceapi.auth.dto.LoginRequest;
import utez.edu.mx.ecommerceapi.auth.dto.LoginResponse;
import utez.edu.mx.ecommerceapi.auth.dto.RegistroRequest;
import utez.edu.mx.ecommerceapi.auth.dto.RegistroResponse;
import utez.edu.mx.ecommerceapi.auth.service.AuthService;
import utez.edu.mx.ecommerceapi.shared.response.ApiResponse;

@Tag(name = "Auth")
@Controller
@AllArgsConstructor
@RequestMapping("api/v1/auth")
public class AuthController {

    private final AuthService authService;

    @Operation(summary = "Registro de usuario")
    @PostMapping("/registro")
    public ResponseEntity<ApiResponse<RegistroResponse>> registrar(@Valid @RequestBody RegistroRequest solicitud){
        RegistroResponse respuesta = authService.registrar(solicitud);

        return  ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok("Usuario registrado correctamente", respuesta));
    }


    @Operation(summary = "Login")
    @PostMapping("/login")
    public ResponseEntity<ApiResponse<LoginResponse>> login(@Valid @RequestBody LoginRequest solicitud) {
        LoginResponse respuesta =  authService.login(solicitud);

        return ResponseEntity.ok(ApiResponse.ok("Inicio de sesión correcto", respuesta));
    }
}
