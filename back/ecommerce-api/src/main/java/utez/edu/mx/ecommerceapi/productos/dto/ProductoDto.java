package utez.edu.mx.ecommerceapi.productos.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

import org.hibernate.validator.constraints.Length;

import jakarta.validation.constraints.*;
import lombok.Data;
import utez.edu.mx.ecommerceapi.categorias.dto.CategoriaDto;
import utez.edu.mx.ecommerceapi.categorias.entity.Categoria;
import utez.edu.mx.ecommerceapi.productos.entity.Producto;
import utez.edu.mx.ecommerceapi.productos.entity.ProductoEstadoEnum;

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
    @NotBlank(message = "El SKU del producto no puede estar vacío")
    @Pattern(regexp = "^(\\d{8}|\\d{12}|\\d{13})$", message = "El código debe tener 8, 12 o 13 dígitos")
    private String sku;

    @NotNull(message = "El stock actual del producto no puede estar vacío")
    @Min(value = 0, message = "El stock actual del producto no puede ser negativo")
    private Integer stockActual;

    @NotNull(message = "El stock mínimo del producto no puede estar vacío")
    @Min(value = 0, message = "El stock mínimo del producto no puede ser negativo")
    private Integer stockMinimo;

    @NotNull(message = "El precio de compra del producto no puede estar vacío")
    @DecimalMin(value = "0.0", inclusive = true, message = "El precio de compra del producto no puede ser negativo")
    private BigDecimal precioCompra;

    @NotNull(message = "El precio de venta del producto no puede estar vacío")
    @DecimalMin(value = "0.0", inclusive = true, message = "El precio de venta del producto no puede ser negativo")
    private BigDecimal precioVenta;

    @Length(max = 25, message = "La unidad de medida del producto no puede tener más de 25 caracteres")
    @NotBlank(message = "La unidad de medida del producto no puede estar vacía")
    private String unidadMedida;

    @NotBlank(message = "La imagen del producto no puede estar vacía")
    private String imagen;

    private ProductoEstadoEnum estado = ProductoEstadoEnum.PROD_ACTIVO;

    @NotNull(message = "La categoría del producto no puede estar vacía")
    private CategoriaDto categoria;

    @NotEmpty(message = "Debe incluir al menos una etiqueta")
    @Size(max = 10, message = "No puede incluir más de 10 etiquetas")
    private List<@NotBlank(message = "Las etiquetas no pueden estar vacías") @Size(max = 20, message = "Cada etiqueta debe tener máximo 20 caracteres") String> etiquetas;

    private boolean status = true;

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
        producto.setNombre(this.nombre);
        producto.setDescripcion(this.descripcion);
        producto.setMarca(this.marca);
        producto.setSku(this.sku);
        producto.setStockActual(this.stockActual);
        producto.setStockMinimo(this.stockMinimo);
        producto.setPrecioCompra(this.precioCompra);
        producto.setPrecioVenta(this.precioVenta);
        producto.setUnidadMedida(this.unidadMedida);
        producto.setImagen(this.imagen);
        producto.setCategoria(categoriaEntity);
        producto.setEtiquetas(this.etiquetas);
        producto.setEstado(this.estado);
        producto.setStatus(this.status);
        return producto;
    }

    public static ProductoDto fromEntity(Producto producto) {
        ProductoDto productoDto = new ProductoDto();
        productoDto.setId(producto.getId());
        productoDto.setNombre(producto.getNombre());
        productoDto.setDescripcion(producto.getDescripcion());
        productoDto.setMarca(producto.getMarca());
        productoDto.setSku(producto.getSku());
        productoDto.setStockActual(producto.getStockActual());
        productoDto.setStockMinimo(producto.getStockMinimo());
        productoDto.setPrecioCompra(producto.getPrecioCompra());
        productoDto.setPrecioVenta(producto.getPrecioVenta());
        productoDto.setUnidadMedida(producto.getUnidadMedida());
        productoDto.setImagen(producto.getImagen());
        productoDto.setEstado(producto.getEstado());
        productoDto.setCategoria(CategoriaDto.fromEntity(producto.getCategoria()));
        productoDto.setEtiquetas(producto.getEtiquetas());
        productoDto.setStatus(producto.isStatus());
        // Campos auditables
        productoDto.setCreatedAt(producto.getCreatedAt());
        productoDto.setUpdatedAt(producto.getUpdatedAt());
        productoDto.setCreatedBy(producto.getCreatedBy());
        productoDto.setUpdatedBy(producto.getUpdatedBy());
        return productoDto;
    }
}
