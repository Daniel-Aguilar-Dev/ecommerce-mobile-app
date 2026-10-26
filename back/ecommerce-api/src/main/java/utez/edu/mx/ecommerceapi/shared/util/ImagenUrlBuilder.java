package utez.edu.mx.ecommerceapi.shared.util;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class ImagenUrlBuilder {

    private static final String THUMB = "w_300,h_300,c_fill,f_auto,q_auto,g_auto";
    private static final String DETALLE = "w_800,c_limit,f_auto,q_auto";

    private final String base;

    public ImagenUrlBuilder(@Value("${cloudinary.cloud-name}") String cloudName) {
        this.base = "https://res.cloudinary.com/" + cloudName + "/image/upload/";
    }

    public String thumbnail(String publicId, Long version) {
        return construir(THUMB, publicId, version);
    }

    public String detalle(String publicId, Long version) {
        return construir(DETALLE, publicId, version);
    }

    private String construir(String transformacion, String publicId, Long version) {
        if (publicId == null || version == null) return null;
        return base + transformacion + "/v" + version + "/" + publicId;
    }
}