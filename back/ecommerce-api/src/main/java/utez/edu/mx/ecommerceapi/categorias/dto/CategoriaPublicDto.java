package utez.edu.mx.ecommerceapi.categorias.dto;

import lombok.Data;
import utez.edu.mx.ecommerceapi.categorias.entity.Categoria;

@Data
public class CategoriaPublicDto {
    private Long id;
    private String nombre;
    private String descripcion;

    public static CategoriaPublicDto fromEntity(Categoria categoria) {
        CategoriaPublicDto categoriaDto = new CategoriaPublicDto();
        categoriaDto.setId(categoria.getId());
        categoriaDto.setNombre(categoria.getNombre());
        categoriaDto.setDescripcion(categoria.getDescripcion());
        return categoriaDto;
    }
}
