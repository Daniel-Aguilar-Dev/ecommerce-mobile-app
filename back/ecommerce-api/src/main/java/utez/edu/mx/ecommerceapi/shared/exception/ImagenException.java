package utez.edu.mx.ecommerceapi.shared.exception;

public class ImagenException extends RuntimeException {
    public ImagenException(String message) {
        super(message);
    }

    public ImagenException(String mensaje, Throwable causa) {
        super(mensaje, causa);
    }
}
