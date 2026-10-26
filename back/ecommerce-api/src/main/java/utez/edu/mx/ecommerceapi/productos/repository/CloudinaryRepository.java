package utez.edu.mx.ecommerceapi.productos.repository;

import org.springframework.web.multipart.MultipartFile;
import utez.edu.mx.ecommerceapi.productos.entity.Imagen;

public interface CloudinaryRepository {
    Imagen guardar(String prodSlig, MultipartFile file);

    void eliminar(String publicId);
}
