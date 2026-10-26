package utez.edu.mx.ecommerceapi.productos.dto;

import java.math.BigDecimal;

import lombok.Data;
import utez.edu.mx.ecommerceapi.categorias.dto.CategoriaPublicDto;
import utez.edu.mx.ecommerceapi.productos.entity.Producto;
import utez.edu.mx.ecommerceapi.productos.entity.ProductoEstadoEnum;

@Data
public class ProductoPublicDto {
    private Long id;
    private String nombre;
    private String descripcion;
    private String marca;
    private String sku;
    private Integer stock;
    private BigDecimal precio;
    private String unidadMedida;
    private String imagen;
    private ProductoEstadoEnum estado = ProductoEstadoEnum.PROD_ACTIVO;
    private CategoriaPublicDto categoria;
    private String estadoStock;

    public static ProductoPublicDto fromEntity(Producto producto, String imagenUrl) {
        ProductoPublicDto productoDto = new ProductoPublicDto();
        String estadoStock = "Disponible";
        if (producto.getStockActual() == 0) {
            estadoStock = "Agotado";
        } else if (producto.getStockActual() <= producto.getStockMinimo()) {
            estadoStock = "Pocas unidades";
        }
        productoDto.setId(producto.getId());
        productoDto.setNombre(producto.getNombre());
        productoDto.setDescripcion(producto.getDescripcion());
        productoDto.setMarca(producto.getMarca());
        if (producto.getSku() != null) {
            productoDto.setSku(producto.getSku());
        }
        productoDto.setStock(producto.getStockActual());
        productoDto.setPrecio(producto.getPrecioVenta());
        productoDto.setUnidadMedida(producto.getUnidadMedida());
        productoDto.setEstado(producto.getEstado());
        productoDto.setCategoria(CategoriaPublicDto.fromEntity(producto.getCategoria()));
        productoDto.setEstadoStock(estadoStock);
        productoDto.setImagen(imagenUrl);
        return productoDto;
    }
}
