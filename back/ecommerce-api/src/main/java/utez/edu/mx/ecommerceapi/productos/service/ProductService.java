package utez.edu.mx.ecommerceapi.productos.service;

import java.text.Normalizer;
import java.util.List;
import java.util.Optional;

import com.github.slugify.Slugify;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import org.springframework.web.multipart.MultipartFile;
import utez.edu.mx.ecommerceapi.categorias.dto.CategoriaDto;
import utez.edu.mx.ecommerceapi.categorias.entity.Categoria;
import utez.edu.mx.ecommerceapi.categorias.repository.CategoriaRepository;
import utez.edu.mx.ecommerceapi.categorias.service.CategoriaService;
import utez.edu.mx.ecommerceapi.productos.dto.ProductoDto;
import utez.edu.mx.ecommerceapi.productos.entity.Imagen;
import utez.edu.mx.ecommerceapi.productos.entity.Producto;
import utez.edu.mx.ecommerceapi.productos.repository.ProductoRepository;
import utez.edu.mx.ecommerceapi.shared.exception.BusinessException;
import utez.edu.mx.ecommerceapi.shared.exception.ErrorCode;
import utez.edu.mx.ecommerceapi.shared.exception.RecursoNoEncontradoException;
import utez.edu.mx.ecommerceapi.shared.response.ApiResponse;
import utez.edu.mx.ecommerceapi.shared.util.ImagenUrlBuilder;

@Service
public class ProductService {
    Slugify slugify = Slugify.builder().build();

    @Autowired
    private ProductoRepository productoRepository;

    @Autowired
    private CloudinaryService cloudinaryService;

    @Autowired
    private ImagenUrlBuilder urlBuilder;

    @Autowired
    private CategoriaService categoriaService;

    @Transactional(readOnly = true)
    public ApiResponse<List<ProductoDto>> getAllProducts() {
        return ApiResponse.ok("Lista por devolver");
    }

    @Transactional(readOnly = true)
    public ApiResponse<List<ProductoDto>> getProductsByMarca(String marca) {
        return ApiResponse.ok("Lista por devolver por marca");
    }

    @Transactional(readOnly = true)
    public ApiResponse<List<ProductoDto>> getProductsByCategoria(Long categoriaId) {
        return ApiResponse.ok("Lista por devolver por categoría");
    }

    @Transactional(readOnly = true)
    public ApiResponse<ProductoDto> getProductById(Long id) {
        return ApiResponse.ok("Producto por devolver");
    }

    @Transactional(readOnly = true)
    public ApiResponse<ProductoDto> getProductByName(String nombre) {
        return ApiResponse.ok("Producto por devolver");
    }

    @Transactional()
    public ApiResponse<ProductoDto> postProduct(ProductoDto dto, MultipartFile file) {
        Categoria categoria = categoriaService.obtenerCategoriaPorId(dto.getCategoria().getId());

        if (existByName(dto.getNombre())) throw new BusinessException(
                ErrorCode.DATO_DUPLICADO,
                "El producto " + dto.getNombre() + " ya fue registrado"
        );

        if (dto.getSku() != null && existsBySku(dto.getSku())) throw new BusinessException(
                ErrorCode.DATO_DUPLICADO,
                "El código de barras " + dto.getSku() + " ya fue registrado para otro producto"
        );

        Producto producto = dto.toEntity();
        producto.setCategoria(categoria);

        String prodSlug = slugify.slugify(dto.getNombre());

        Imagen img = cloudinaryService.guardar(prodSlug, file);

        Producto post;
        try {
            producto.setImagenPublicId(img.publicId());
            producto.setImagenVersion(img.version());
            post = productoRepository.saveAndFlush(producto);
        } catch (DataIntegrityViolationException e) {
            cloudinaryService.eliminar(img.publicId());
            throw new BusinessException(ErrorCode.DATO_DUPLICADO,
                    "El producto o su código de barras ya fueron registrados");
        } catch (RuntimeException e) {
            cloudinaryService.eliminar(img.publicId());
            throw e;
        }

        return ApiResponse.ok("Producto registrado correctamente", ProductoDto.fromEntity(post));
    }

    @Transactional
    public ApiResponse<ProductoDto> patch(ProductoDto dto, MultipartFile file, Long id) {
        Producto existente = findByIdOrThrow(id);
        Categoria categoria = categoriaService.obtenerCategoriaPorId(dto.getCategoria().getId());

        if (existOtherByName(dto.getNombre(), id)) throw new BusinessException(
                ErrorCode.DATO_DUPLICADO,
                "El producto " + dto.getNombre() + " ya fue registrado en otro producto"
        );

        if (dto.getSku() != null) {
            if (existsOtherBySku(dto.getSku(), id)) throw new BusinessException(
                    ErrorCode.DATO_DUPLICADO,
                    "El código de barras " + dto.getSku() + " ya fue registrado para otro producto");
        }

        existente.setNombre(dto.getNombre().trim());
        existente.setDescripcion(dto.getDescripcion().trim());
        existente.setMarca(dto.getMarca().trim());
        if (dto.getSku() != null) {
            existente.setSku(dto.getSku().trim());
        }
        existente.setUnidadMedida(dto.getUnidadMedida().trim());
        existente.setCategoria(categoria);
        existente.setPrecioCompra(dto.getPrecioCompra());
        existente.setPrecioCompra(dto.getPrecioVenta());
        existente.setStockMinimo(dto.getStockMinimo());

        if (file != null && !file.isEmpty()) {
            cloudinaryService.eliminar(existente.getImagenPublicId());
            String prodSlug = slugify.slugify(existente.getNombre());
            Imagen img = cloudinaryService.guardar(prodSlug, file);
            existente.setImagenVersion(img.version());
            existente.setImagenPublicId(img.publicId());
        }

        Producto patch;

        try {
            patch = productoRepository.saveAndFlush(existente);
        } catch (DataIntegrityViolationException e) {
            if (file != null && !file.isEmpty()) {
                cloudinaryService.eliminar(existente.getImagenPublicId());
            }
            throw new BusinessException(ErrorCode.DATO_DUPLICADO,
                    "El producto o su código de barras ya fueron registrados por otro producto diferente");
        } catch (RuntimeException e) {
            if (file != null && !file.isEmpty()) {
                cloudinaryService.eliminar(existente.getImagenPublicId());
            }
            throw e;
        }

        return ApiResponse.ok("Producto actualizado correctamente", ProductoDto.fromEntity(patch));
    }

    private boolean existByName(String nombre) {
        return productoRepository.findByNombreIgnoreCase(nombre).isPresent();
    }

    private boolean existsBySku(String sku) {
        return productoRepository.findBySkuIgnoreCase(sku).isPresent();
    }

    private boolean existOtherByName(String nombre, Long id) {
        return productoRepository.findByNombreIgnoreCaseAndIdNot(nombre, id).isPresent();
    }

    private boolean existsOtherBySku(String sku, Long id) {
        return productoRepository.findBySkuIgnoreCaseAndIdNot(sku, id).isPresent();
    }

    private Producto findByIdOrThrow(Long id) {
        return productoRepository.findById(id).orElseThrow(() ->
                new RecursoNoEncontradoException("Producto no encontrado con el id: ", id));
    }
}
