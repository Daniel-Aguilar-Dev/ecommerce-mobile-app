package utez.edu.mx.ecommerceapi.shared.exception;

import org.springframework.http.HttpStatus;

public enum ErrorCode {
    RECURSO_NO_ENCONTRADO(HttpStatus.NOT_FOUND),
    VALIDACION_FALLIDA(HttpStatus.BAD_REQUEST),
    ACCESO_DENEGADO(HttpStatus.FORBIDDEN),
    NO_AUTENTICADO(HttpStatus.UNAUTHORIZED),
    ERROR_INTERNO(HttpStatus.INTERNAL_SERVER_ERROR),
    STOCK_INSUFICIENTE(HttpStatus.CONFLICT),
    PRODUCTO_DESCONTINUADO(HttpStatus.CONFLICT),
    PRODUCTO_CON_MOVIMIENTOS(HttpStatus.CONFLICT),
    PEDIDO_ESTADO_INVALIDO(HttpStatus.CONFLICT),
    VENTA_YA_ANULADA(HttpStatus.CONFLICT),
    PAGO_EXCEDE_SALDO(HttpStatus.BAD_REQUEST),
    CREDENCIALES_INVALIDAS(HttpStatus.UNAUTHORIZED),
    USUARIO_DESACTIVADO(HttpStatus.FORBIDDEN),
    DATO_DUPLICADO(HttpStatus.CONFLICT);

    private final HttpStatus status;

    ErrorCode(HttpStatus status) {
        this.status = status;
    }

    public HttpStatus getStatus() {
        return status;
    }
}
