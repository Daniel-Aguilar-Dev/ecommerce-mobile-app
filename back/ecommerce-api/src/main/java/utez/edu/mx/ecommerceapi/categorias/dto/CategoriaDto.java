package utez.edu.mx.ecommerceapi.categorias.dto;

import java.time.LocalDateTime;

import org.hibernate.validator.constraints.Length;

import jakarta.validation.constraints.*;
import lombok.Data;
import utez.edu.mx.ecommerceapi.categorias.entity.Categoria;

@Data
public class CategoriaDto {
    private Long id;

    @Length(max = 50, message = "El nombre del producto no puede tener más de 50 caracteres")
    @NotBlank(message = "El nombre del producto no puede estar vacío")
    private String nombre;

    @Length(max = 150, message = "La descripción del producto no puede tener más de 150 caracteres")
    @NotBlank(message = "La descripción del producto no puede estar vacía")
    private String descripcion;

    private boolean tieneProductos;

    // Campos auditables
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private Long createdBy;
    private Long updatedBy;

    public Categoria toEntity() {
        Categoria categoria = new Categoria();
        categoria.setId(this.id);
        categoria.setNombre(this.nombre);
        categoria.setDescripcion(this.descripcion);
        return categoria;
    }

    public static CategoriaDto fromEntity(Categoria categoria) {
        CategoriaDto categoriaDto = new CategoriaDto();
        categoriaDto.setId(categoria.getId());
        categoriaDto.setNombre(categoria.getNombre());
        categoriaDto.setDescripcion(categoria.getDescripcion());
        // Campos auditables
        categoriaDto.setCreatedAt(categoria.getCreatedAt());
        categoriaDto.setUpdatedAt(categoria.getUpdatedAt());
        categoriaDto.setCreatedBy(categoria.getCreatedBy());
        categoriaDto.setUpdatedBy(categoria.getUpdatedBy());
        return categoriaDto;
    }
}
