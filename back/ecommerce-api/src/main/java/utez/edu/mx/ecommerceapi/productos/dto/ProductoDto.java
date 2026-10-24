package utez.edu.mx.ecommerceapi.productos.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import org.hibernate.validator.constraints.Length;

import jakarta.validation.constraints.*;
import lombok.Data;

import utez.edu.mx.ecommerceapi.categorias.dto.CategoriaDto;
import utez.edu.mx.ecommerceapi.categorias.entity.Categoria;
import utez.edu.mx.ecommerceapi.productos.entity.Producto;
import utez.edu.mx.ecommerceapi.productos.entity.ProductoEstadoEnum;
import utez.edu.mx.ecommerceapi.shared.decorators.interfaces.NullButNotBlank;

@Data
public class ProductoDto {
    private Long id;

    @Length(max = 50, message = "El nombre del producto no puede tener más de 50 caracteres")
    @NotBlank(message = "El nombre del producto no puede estar vacío")
    private String nombre;

    @Length(max = 150, message = "La descripción del producto no puede tener más de 150 caracteres")
    @NotBlank(message = "La descripción del producto no puede estar vacía")
    private String descripcion;

    @Length(max = 25, message = "La marca del producto no puede tener más de 25 caracteres")
    @NotBlank(message = "La marca del producto no puede estar vacía")
    private String marca;

    @Length(max = 25, message = "El SKU del producto no puede tener más de 25 caracteres")
    @NullButNotBlank(message = "El SKU del producto no puede estar vacío")
    @Pattern(regexp = "^(\\d{8}|\\d{12}|\\d{13})$", message = "El código debe tener 8, 12 o 13 dígitos")
    private String sku;

    @NotNull(message = "El stock actual del producto no puede estar vacío")
    @Min(value = 1, message = "El stock actual del producto no puede ser negativo ni cero")
    private Integer stockActual;

    @NotNull(message = "El stock mínimo del producto no puede estar vacío")
    @Min(value = 1, message = "El stock mínimo del producto no puede ser negativo ni cero")
    private Integer stockMinimo;

    @NotNull(message = "El precio de compra del producto no puede estar vacío")
    @DecimalMin(value = "0. ", inclusive = true, message = "El precio de compra del producto no puede ser negativo ni cero")
    private BigDecimal precioCompra;

    @NotNull(message = "El precio de venta del producto no puede estar vacío")
    @DecimalMin(value = "0.1", inclusive = true, message = "El precio de venta del producto no puede ser negativo ni cero")
    private BigDecimal precioVenta;

    @Length(max = 25, message = "La unidad de medida del producto no puede tener más de 25 caracteres")
    @NotBlank(message = "La unidad de medida del producto no puede estar vacía")
    private String unidadMedida;

    // Campos de imagen que no deberían venir en el request
    private String imagenPublicId;
    private Long imagenVersion;

    private ProductoEstadoEnum estado = ProductoEstadoEnum.PROD_ACTIVO;

    @NotNull(message = "La categoría del producto no puede estar vacía")
    private CategoriaDto categoria;

    // Campos auditables
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private Long createdBy;
    private Long updatedBy;

    public Producto toEntity() {
        Categoria categoriaEntity = new Categoria();
        if (this.categoria != null) {
            categoriaEntity = this.categoria.toEntity();
        }
        Producto producto = new Producto();
        producto.setId(this.id);
        producto.setNombre(this.nombre.trim());
        producto.setDescripcion(this.descripcion.trim());
        producto.setMarca(this.marca.trim());
        if (this.sku != null) {
            producto.setSku(this.sku.trim());
        }
        producto.setStockActual(this.stockActual);
        producto.setStockMinimo(this.stockMinimo);
        producto.setPrecioCompra(this.precioCompra);
        producto.setPrecioVenta(this.precioVenta);
        producto.setUnidadMedida(this.unidadMedida);
        producto.setCategoria(categoriaEntity);
        producto.setEstado(this.estado);
        return producto;
    }

    public static ProductoDto fromEntity(Producto producto) {
        ProductoDto productoDto = new ProductoDto();
        productoDto.setId(producto.getId());
        productoDto.setNombre(producto.getNombre());
        productoDto.setDescripcion(producto.getDescripcion());
        productoDto.setMarca(producto.getMarca());
        productoDto.setSku(producto.getSku());
        if (productoDto.getSku() != null) {
            productoDto.setSku(producto.getSku());
        }
        productoDto.setStockActual(producto.getStockActual());
        productoDto.setStockMinimo(producto.getStockMinimo());
        productoDto.setPrecioCompra(producto.getPrecioCompra());
        productoDto.setPrecioVenta(producto.getPrecioVenta());
        productoDto.setUnidadMedida(producto.getUnidadMedida());
        productoDto.setImagenPublicId(producto.getImagenPublicId());
        productoDto.setImagenPublicId(producto.getImagenPublicId());
        productoDto.setEstado(producto.getEstado());
        productoDto.setCategoria(CategoriaDto.fromEntity(producto.getCategoria()));
        // Campos auditables
        productoDto.setCreatedAt(producto.getCreatedAt());
        productoDto.setUpdatedAt(producto.getUpdatedAt());
        productoDto.setCreatedBy(producto.getCreatedBy());
        productoDto.setUpdatedBy(producto.getUpdatedBy());
        return productoDto;
    }
}
