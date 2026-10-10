package utez.edu.mx.ecommerceapi.productos.dto;

import java.math.BigDecimal;
import java.util.List;

import lombok.Data;
import utez.edu.mx.ecommerceapi.categorias.dto.CategoriaPublicDto;
import utez.edu.mx.ecommerceapi.categorias.entity.Categoria;
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
    private List<String> etiquetas;
    private boolean status;
    private String estadoStock;

    public static ProductoPublicDto fromEntity(Producto producto) {
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
        productoDto.setSku(producto.getSku());
        productoDto.setStock(producto.getStockActual());
        productoDto.setPrecio(producto.getPrecioVenta());
        productoDto.setUnidadMedida(producto.getUnidadMedida());
        productoDto.setImagen(producto.getImagen());
        productoDto.setEstado(producto.getEstado());
        productoDto.setCategoria(CategoriaPublicDto.fromEntity(producto.getCategoria()));
        productoDto.setEtiquetas(producto.getEtiquetas());
        productoDto.setStatus(producto.isStatus());
        productoDto.setEstadoStock(estadoStock);
        return productoDto;
    }
}
