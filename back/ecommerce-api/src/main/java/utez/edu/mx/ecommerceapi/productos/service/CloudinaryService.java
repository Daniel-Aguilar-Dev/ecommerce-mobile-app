package utez.edu.mx.ecommerceapi.productos.service;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import net.coobird.thumbnailator.Thumbnails;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import utez.edu.mx.ecommerceapi.productos.entity.Imagen;
import utez.edu.mx.ecommerceapi.productos.repository.CloudinaryRepository;

import javax.imageio.ImageIO;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.*;

import utez.edu.mx.ecommerceapi.shared.exception.ImagenException;

@Service
public class CloudinaryService implements CloudinaryRepository {
    @Autowired
    private Cloudinary cloudinary;
    private static final Set<String> TIPOS_PERMITIDOS = Set.of("image/jpeg", "image/png");
    private static final long MAX_BYTES = 5L * 1024 * 1024; // 5 MB

    @Override
    public Imagen guardar(String prodSlug, MultipartFile file) {
        validarTipo(file); // image/jpeg, png, webp
        try {
            ByteArrayOutputStream out = new ByteArrayOutputStream();
            Thumbnails.of(file.getInputStream())
                    .size(1000, 1000).outputFormat("jpg").outputQuality(0.8)
                    .toOutputStream(out);

            Map<?, ?> r = cloudinary.uploader().upload(out.toByteArray(), ObjectUtils.asMap(
                    "public_id", publicId(prodSlug),
                    "overwrite", true,
                    "invalidate", true,
                    "resource_type", "image"));

            return new Imagen((String) r.get("public_id"),
                    ((Number) r.get("version")).longValue());
        } catch (IOException e) {
            throw new ImagenException("No se pudo subir la imagen", e);
        }
    }

    @Override
    public void eliminar(String publicId) {
        try {
            cloudinary.uploader().destroy(publicId, ObjectUtils.emptyMap());
        } catch (IOException e) { /* log; no bloquear la operación de negocio */ }
    }

    private void validarTipo(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new ImagenException("La imagen es obligatoria");
        }
        if (file.getSize() > MAX_BYTES) {
            throw new ImagenException("La imagen no puede superar 5 MB");
        }
        String tipo = file.getContentType();
        if (tipo == null || !TIPOS_PERMITIDOS.contains(tipo.toLowerCase())) {
            throw new ImagenException("Formato no permitido. Usa JPG o PNG");
        }
        try (InputStream in = file.getInputStream()) {
            if (ImageIO.read(in) == null) {
                throw new ImagenException("El archivo no es una imagen válida");
            }
        } catch (IOException e) {
            throw new ImagenException("No se pudo leer la imagen", e);
        }
    }

    private String publicId(String slug) {
        if (slug == null || slug.isBlank()) slug = "producto";
        String sufijo = UUID.randomUUID().toString().substring(0, 8);
        if (slug.length() > 50) slug = slug.substring(0, 50);
        return "productos/" + slug + "-" + sufijo;
    }
}
