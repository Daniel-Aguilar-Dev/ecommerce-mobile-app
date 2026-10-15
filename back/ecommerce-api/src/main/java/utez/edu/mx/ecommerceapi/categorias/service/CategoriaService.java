package utez.edu.mx.ecommerceapi.categorias.service;

import java.util.Comparator;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import utez.edu.mx.ecommerceapi.categorias.dto.CategoriaDto;
import utez.edu.mx.ecommerceapi.categorias.dto.CategoriaPublicDto;
import utez.edu.mx.ecommerceapi.categorias.entity.Categoria;
import utez.edu.mx.ecommerceapi.categorias.repository.CategoriaRepository;
import utez.edu.mx.ecommerceapi.productos.repository.ProductoRepository;
import utez.edu.mx.ecommerceapi.shared.exception.BusinessException;
import utez.edu.mx.ecommerceapi.shared.exception.ErrorCode;
import utez.edu.mx.ecommerceapi.shared.exception.RecursoNoEncontradoException;
import utez.edu.mx.ecommerceapi.shared.response.ApiResponse;

@Service
public class CategoriaService {

    @Autowired
    private CategoriaRepository categoriaRepository;

    @Autowired
    private ProductoRepository productoRepository;

    private static final Sort sortByNombreAsc = Sort.by(Sort.Direction.ASC, "nombre");

    private boolean tieneProductosAsociados(Long categoriaId) {
        return productoRepository.existsByCategoriaId(categoriaId);
    }

    private boolean existeCategoriaPorNombre(String nombre) {
        return categoriaRepository.findByNombreIgnoreCase(nombre).isPresent();
    }

    private boolean existeOtraCategoriaConMismoNombre(String nombre, Long id) {
        return categoriaRepository.existsByNombreIgnoreCaseAndIdNot(nombre, id);
    }

    private Categoria obtenerCategoriaPorId(Long id) throws RecursoNoEncontradoException {
        return categoriaRepository.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException("Categoría no encontrada", id));
    }

    @Transactional(readOnly = true)
    public ApiResponse<List<CategoriaDto>> findAll(String query) {
        List<Categoria> categorias;

        if (query != null && !query.isEmpty()) {
            categorias = categoriaRepository.findByNombreContainingIgnoreCase(
                    query);
        } else {
            categorias = categoriaRepository.findAll(sortByNombreAsc);
        }

        List<CategoriaDto> categoriaDtos = categorias.stream()
                .map(categoria -> {
                    CategoriaDto categoriaDto = CategoriaDto.fromEntity(categoria);
                    boolean tieneProductos = tieneProductosAsociados(categoria.getId());
                    categoriaDto.setTieneProductos(tieneProductos);
                    return categoriaDto;
                })
                .toList();

        categoriaDtos.sort(Comparator.comparing(CategoriaDto::isTieneProductos).reversed()
                .thenComparing(CategoriaDto::getNombre));

        return ApiResponse.ok("Categorías encontradas", categoriaDtos);
    }

    @Transactional(readOnly = true)
    public ApiResponse<List<CategoriaPublicDto>> findAllPublic() {
        List<Categoria> categorias = categoriaRepository.findAll(sortByNombreAsc);

        List<CategoriaPublicDto> categoriaDtos = categorias
                .stream()
                .map(CategoriaPublicDto::fromEntity)
                .toList();

        return ApiResponse.ok("Categorías encontradas", categoriaDtos);
    }

    @Transactional(readOnly = true)
    public ApiResponse<CategoriaDto> findById(Long id) {
        Categoria categoria = obtenerCategoriaPorId(id);

        CategoriaDto categoriaDto = CategoriaDto.fromEntity(categoria);

        boolean tieneProductos = tieneProductosAsociados(categoria.getId());
        categoriaDto.setTieneProductos(tieneProductos);

        return ApiResponse.ok("Categoría encontrada", categoriaDto);
    }

    @Transactional(readOnly = true)
    public ApiResponse<CategoriaPublicDto> findByIdPublic(Long id) {
        Categoria categoria = obtenerCategoriaPorId(id);

        CategoriaPublicDto categoriaDto = CategoriaPublicDto.fromEntity(categoria);

        return ApiResponse.ok("Categoría encontrada", categoriaDto);
    }

    @Transactional
    public ApiResponse<CategoriaDto> save(CategoriaDto categoriaDto) {
        if (existeCategoriaPorNombre(categoriaDto.getNombre())) {
            throw new BusinessException(ErrorCode.DATO_DUPLICADO,
                    "Ya existe una categoría con el mismo nombre");
        }

        Categoria categoria = categoriaDto.toEntity();
        Categoria savedCategoria = categoriaRepository.save(categoria);

        CategoriaDto savedCategoriaDto = CategoriaDto.fromEntity(savedCategoria);
        return ApiResponse.ok("Categoría registrada", savedCategoriaDto);
    }

    @Transactional
    public ApiResponse<CategoriaDto> update(Long id, CategoriaDto categoriaDto) {
        Categoria existingCategoria = obtenerCategoriaPorId(id);

        if (existeOtraCategoriaConMismoNombre(categoriaDto.getNombre(), id)) {
            throw new BusinessException(ErrorCode.DATO_DUPLICADO,
                    "Ya existe otra categoría con el mismo nombre");
        }

        existingCategoria.setNombre(categoriaDto.getNombre());
        existingCategoria.setDescripcion(categoriaDto.getDescripcion());

        Categoria updatedCategoria = categoriaRepository.save(existingCategoria);
        CategoriaDto updatedCategoriaDto = CategoriaDto.fromEntity(updatedCategoria);

        return ApiResponse.ok("Categoría actualizada", updatedCategoriaDto);
    }

    @Transactional
    public ApiResponse<Void> delete(Long id) {
        Categoria existingCategoria = obtenerCategoriaPorId(id);

        if (tieneProductosAsociados(id)) {
            throw new BusinessException(ErrorCode.CATEGORIA_TIENE_PRODUCTOS,
                    "No se puede eliminar la categoría porque tiene productos asociados");
        }

        categoriaRepository.delete(existingCategoria);
        return ApiResponse.ok("Categoría eliminada", null);
    }
}
