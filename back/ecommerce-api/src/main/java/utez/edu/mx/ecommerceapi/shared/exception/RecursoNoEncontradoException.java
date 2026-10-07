package utez.edu.mx.ecommerceapi.shared.exception;

public class RecursoNoEncontradoException extends BusinessException {

    public RecursoNoEncontradoException(String recurso, Object id) {
        super(ErrorCode.RECURSO_NO_ENCONTRADO, recurso + " con id " + id + " no existe");
    }
}
