package utez.edu.mx.ecommerceapi.productos.service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.*;

import com.github.slugify.Slugify;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import org.springframework.web.multipart.MultipartFile;
import utez.edu.mx.ecommerceapi.carrito.entity.Carrito;
import utez.edu.mx.ecommerceapi.categorias.entity.Categoria;
import utez.edu.mx.ecommerceapi.categorias.service.CategoriaService;
import utez.edu.mx.ecommerceapi.productos.dto.ProductoDto;
import utez.edu.mx.ecommerceapi.productos.dto.ProductoPublicDto;
import utez.edu.mx.ecommerceapi.productos.dto.StockLineaDto;
import utez.edu.mx.ecommerceapi.productos.entity.Imagen;
import utez.edu.mx.ecommerceapi.productos.entity.Producto;
import utez.edu.mx.ecommerceapi.productos.entity.ProductoEstadoEnum;
import utez.edu.mx.ecommerceapi.productos.repository.ProductoRepository;
import utez.edu.mx.ecommerceapi.shared.exception.BusinessException;
import utez.edu.mx.ecommerceapi.shared.exception.ErrorCode;
import utez.edu.mx.ecommerceapi.shared.exception.RecursoNoEncontradoException;
import utez.edu.mx.ecommerceapi.shared.response.ApiResponse;
import utez.edu.mx.ecommerceapi.shared.util.ImagenUrlBuilder;

@Service
public class ProductoService {
    Slugify slugify = Slugify.builder().build();

    @Autowired
    private ProductoRepository productoRepository;

    @Autowired
    private CloudinaryService cloudinaryService;

    @Autowired
    private CategoriaService categoriaService;

    @Autowired
    private ImagenUrlBuilder urlBuilder;

    /*
     * CRUD del producto
     * */
    @Transactional(readOnly = true)
    public ApiResponse<List<ProductoDto>> getAllProducts(
            boolean stockBajo,
            boolean stockCero,
            boolean descontinuados,
            boolean activos,
            String query,
            String orden,
            String marca,
            Long categoriaId
    ) {
        boolean hasCategoriaId = categoriaId != null && categoriaId > 0;
        boolean hasQuery = query != null && !query.isBlank();
        boolean hasOrden = orden != null && !orden.isBlank();
        boolean hasMarca = marca != null && !marca.isBlank();

        List<Producto> productos = productoRepository.findAll();

        if (hasQuery) {
            if (hasCategoriaId) {
                Categoria categoria = categoriaService.obtenerCategoriaPorId(categoriaId);
                productos = productoRepository.findByNombreContainingIgnoreCaseAndCategoria(query, categoria);
            } else {
                productos = productoRepository.findByNombreContainingIgnoreCase(query);
            }
        } else if (hasMarca) {
            if (hasCategoriaId) {
                Categoria categoria = categoriaService.obtenerCategoriaPorId(categoriaId);
                productos = productoRepository.findByMarcaIgnoreCaseAndCategoria(query, categoria);
            } else {
                productos = productoRepository.findByMarcaIgnoreCase(query);
            }
        } else if (hasCategoriaId) {
            productos = productoRepository.findByCategoriaId(categoriaId);
        }

        if (hasOrden) {
            if (orden.equals("nombre_asc")) productos.sort(Comparator.comparing(Producto::getNombre).reversed());
            if (orden.equals("nombre_desc")) productos.sort(Comparator.comparing(Producto::getNombre));
        }

        List<ProductoDto> productoDtos = productos.stream()
                .filter(p -> p.getEstado() != ProductoEstadoEnum.PROD_ELIMINADO)
                .map(p -> {
                    String url = urlBuilder.thumbnail(p.getImagenPublicId(), p.getImagenVersion());
                    return ProductoDto.fromEntity(p, url);
                })
                .filter(p -> !stockBajo || p.getStockActual() <= p.getStockMinimo())
                .filter(p -> !stockCero || p.getStockActual() <= 0)
                .filter(p -> {
                    //Solo descontinuados
                    if (descontinuados) return p.getEstado() == ProductoEstadoEnum.PROD_DESCONTINUADO;
                    //Solo activos
                    if (activos) return p.getEstado() == ProductoEstadoEnum.PROD_ACTIVO;
                    //Todos
                    return true;
                })
                .toList();

        return ApiResponse.ok("Productos encontrados", productoDtos);
    }

    @Transactional(readOnly = true)
    public ApiResponse<List<ProductoPublicDto>> getAllProductsPublic(String query, Long categoriaId) {
        boolean hasQuery = query != null && !query.isBlank();
        List<Producto> productos;

        if (categoriaId != null) {
            Categoria categoria = categoriaService.obtenerCategoriaPorId(categoriaId);
            productos = hasQuery
                    ? productoRepository.findByNombreContainingIgnoreCaseAndCategoria(query, categoria)
                    : productoRepository.findByCategoriaId(categoria.getId());
        } else if (hasQuery) {
            productos = productoRepository.findByNombreContainingIgnoreCase(query);
        } else {
            productos = productoRepository.findAll();
        }

        Collections.shuffle(productos);

        List<ProductoPublicDto> dtos = productos.stream()
                .filter(p -> p.getEstado() != ProductoEstadoEnum.PROD_ELIMINADO)
                .map(p -> {
                    String url = urlBuilder.thumbnail(p.getImagenPublicId(), p.getImagenVersion());
                    return ProductoPublicDto.fromEntity(p, url);
                })
                .toList();

        return ApiResponse.ok("Productos obtenidos", dtos);
    }

    @Transactional(readOnly = true)
    public ApiResponse<List<String>> getMarcas() {
        List<String> marcas = productoRepository.findMarcasDistintasExceptoEstado(ProductoEstadoEnum.PROD_ELIMINADO);

        String mensaje = marcas.isEmpty() ? "Sin marcas registradas" : "Marcas obtenidas";

        return ApiResponse.ok(mensaje, marcas);
    }

    @Transactional(readOnly = true)
    public ApiResponse<ProductoPublicDto> getProductByIdPublic(Long id) {
        Producto existente = findByIdOrThrow(id);

        String cloudinaryUrl = urlBuilder.detalle(existente.getImagenPublicId(), existente.getImagenVersion());

        ProductoPublicDto dto = ProductoPublicDto.fromEntity(existente, cloudinaryUrl);

        return ApiResponse.ok("Producto recuperado", dto);
    }

    @Transactional(readOnly = true)
    public ApiResponse<ProductoDto> getProductById(Long id) {
        Producto existente = findByIdOrThrow(id);

        String cloudinaryUrl = urlBuilder.detalle(existente.getImagenPublicId(), existente.getImagenVersion());

        ProductoDto dto = ProductoDto.fromEntity(existente, cloudinaryUrl);

        return ApiResponse.ok("Producto encontrado por id", dto);
    }

    @Transactional(readOnly = true)
    public ApiResponse<ProductoDto> getProductByName(String nombre) {
        Producto existente = findByNombreOrThrow(nombre);

        String cloudinaryUrl = urlBuilder.detalle(existente.getImagenPublicId(), existente.getImagenVersion());

        ProductoDto dto = ProductoDto.fromEntity(existente, cloudinaryUrl);

        return ApiResponse.ok("Producto encontrado por nombre", dto);
    }

    @Transactional(readOnly = true)
    public ApiResponse<ProductoDto> getProductBySKU(String sku) {
        Producto existente = findBySKUOrThrow(sku);

        String cloudinaryUrl = urlBuilder.thumbnail(existente.getImagenPublicId(), existente.getImagenVersion());

        ProductoDto dto = ProductoDto.fromEntity(existente, cloudinaryUrl);

        return ApiResponse.ok("Producto encontrado por código de barras", dto);
    }

    @Transactional
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
        producto.setEstado(ProductoEstadoEnum.PROD_ACTIVO);
        producto.setCostoPromedio(dto.getPrecioCompra());

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

        return ApiResponse.ok("Producto registrado correctamente", ProductoDto.fromEntity(post, null));
    }

    @Transactional
    public ApiResponse<ProductoDto> putProduct(ProductoDto dto, MultipartFile file, Long id) {
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

        Producto put;

        try {
            put = productoRepository.saveAndFlush(existente);
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

        return ApiResponse.ok("Producto actualizado correctamente", ProductoDto.fromEntity(put, null));
    }

    public ApiResponse<Void> patchProduct(Long id) {
        Producto existente = findByIdOrThrow(id);

        switch (existente.getEstado()) {
            case PROD_ACTIVO -> existente.setEstado(ProductoEstadoEnum.PROD_DESCONTINUADO);
            case PROD_DESCONTINUADO -> existente.setEstado(ProductoEstadoEnum.PROD_ACTIVO);
            case PROD_ELIMINADO -> throw new RecursoNoEncontradoException("Producto no encontrado con el id: ", id);
        }

        String mensaje = existente.getEstado() == ProductoEstadoEnum.PROD_ACTIVO ?
                "¡Producto disponible nuevamente!"
                :
                "¡Producto descontinuado";

        productoRepository.save(existente);
        return ApiResponse.ok(mensaje);
    }

    public ApiResponse<Void> deleteProduct(Long id) {
        Producto existente = findByIdOrThrow(id);
        existente.setEstado(ProductoEstadoEnum.PROD_ELIMINADO);
        productoRepository.save(existente);
        return ApiResponse.ok("Producto eliminado correctamente");
    }

    /*
     * Manejo de stocks
     * */
    @Transactional(readOnly = true)
    public ApiResponse<Integer> validarStockIndividual(Long id, Integer cantidad) {
        validateQuantity(cantidad);
        validateQuantityNotNull(cantidad);
        Producto p = findByIdOrThrow(id);

        if (p.getEstado() == ProductoEstadoEnum.PROD_DESCONTINUADO)
            throw new BusinessException(ErrorCode.PRODUCTO_DESCONTINUADO, "¡Este producto está descontinuado!");

        int disponible = p.getStockDisponible();
        String mensaje = cantidad <= disponible ? "Stock suficiente" : "Stock insuficiente";
        return ApiResponse.ok(mensaje, disponible);
    }

    @Transactional(readOnly = true)
    public ApiResponse<List<StockLineaDto>> validarStockCarrito(Carrito carrito) {
        if (carrito == null)
            throw new BusinessException(ErrorCode.VALIDACION_FALLIDA, "No se pudo recibir tu carrito");

        List<StockLineaDto> lineas = carrito.getItems().stream().map(item -> {
            Producto p = findByIdOrThrow(item.getProducto().getId());
            int cant = item.getCantidad();
            int disp = p.getStockDisponible();

            if (p.getEstado() == ProductoEstadoEnum.PROD_DESCONTINUADO)
                return new StockLineaDto(p.getId(), p.getNombre(), cant, 0, false, "DESCONTINUADO");

            boolean ok = cant <= disp;
            return new StockLineaDto(p.getId(), p.getNombre(), cant, disp, ok, ok ? null : "STOCK_INSUFICIENTE");
        }).toList();

        boolean todoOk = lineas.stream().allMatch(StockLineaDto::suficiente);
        return ApiResponse.ok(todoOk ? "Carrito verificado" : "Hay productos sin stock suficiente", lineas);
    }

    @Transactional
    public BigDecimal increaseProductStock(Long id, int cantidad, BigDecimal costoUnitario) {
        validateQuantity(cantidad);

        if (costoUnitario == null || costoUnitario.compareTo(BigDecimal.ZERO) <= 0)
            throw new BusinessException(ErrorCode.VALIDACION_FALLIDA, "El costo unitario debe ser mayor a cero");

        Producto existente = findActiveLockedOrThrow(id);

        BigDecimal nuevoCosto = calcularCostoPromedio(existente, cantidad, costoUnitario);

        existente.setCostoPromedio(nuevoCosto);
        existente.setStockActual(existente.getStockActual() + cantidad);

        return nuevoCosto;
    }

    @Transactional
    public BigDecimal decreaseProductStock(Long id, int cantidad) {
        validateQuantity(cantidad);
        Producto p = findByIdLockedOrThrow(id);
        requireAvailable(p, cantidad);
        p.setStockActual(p.getStockActual() - cantidad);
        return p.getCostoPromedio();
    }

    @Transactional
    public void reserveProductStock(Long id, int cantidad) {
        validateQuantity(cantidad);
        Producto p = findActiveLockedOrThrow(id);
        requireAvailable(p, cantidad);
        p.setStockReservado(p.getStockReservado() + cantidad);
    }

    @Transactional
    public void liberateProductStock(Long id, int cantidad) {
        validateQuantity(cantidad);
        Producto p = findByIdLockedOrThrow(id);
        if (cantidad > p.getStockReservado())
            throw new BusinessException(ErrorCode.VALIDACION_FALLIDA, "La cantidad excede el stock reservado");
        p.setStockReservado(p.getStockReservado() - cantidad);
    }

    @Transactional
    public BigDecimal deliverProductStock(Long id, int cantidad) {
        validateQuantity(cantidad);
        Producto p = findByIdLockedOrThrow(id);
        if (cantidad > p.getStockReservado())
            throw new BusinessException(ErrorCode.VALIDACION_FALLIDA, "La cantidad excede el stock reservado");
        p.setStockActual(p.getStockActual() - cantidad);
        p.setStockReservado(p.getStockReservado() - cantidad);
        return p.getCostoPromedio();
    }

    /*
     * Si existen por X campo
     * */
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

    /*
     * Funciones de apoyo para no repetir código a lo marrano
     * */
    private Producto findByIdOrThrow(Long id) {
        return productoRepository.findById(id)
                .filter(producto -> producto.getEstado() != ProductoEstadoEnum.PROD_ELIMINADO)
                .orElseThrow(() ->
                new RecursoNoEncontradoException("Producto no encontrado con el id: ", id));
    }

    private Producto findBySKUOrThrow(String sku) {
        return productoRepository.findBySkuIgnoreCase(sku)
                .filter(producto -> producto.getEstado() != ProductoEstadoEnum.PROD_ELIMINADO)
                .orElseThrow(() ->
                new RecursoNoEncontradoException("Producto no encontrado con el código: ", sku));
    }

    private Producto findByNombreOrThrow(String nombre) {
        return productoRepository.findByNombreIgnoreCase(nombre)
                .filter(producto -> producto.getEstado() != ProductoEstadoEnum.PROD_ELIMINADO)
                .orElseThrow(() ->
                new RecursoNoEncontradoException("Producto no encontrado con el nombre: ", nombre));
    }

    private Producto findByIdLockedOrThrow(Long id) {
        return productoRepository.findByIdForUpdate(id).orElseThrow(() ->
                new RecursoNoEncontradoException("Producto no encontrado con el id: ", id));
    }

    private Producto findActiveLockedOrThrow(Long id) {
        Producto p = findByIdLockedOrThrow(id);
        if (p.getEstado() == ProductoEstadoEnum.PROD_ELIMINADO)
            throw new RecursoNoEncontradoException("Producto no encontrado con el id: ", id);
        if (p.getEstado() == ProductoEstadoEnum.PROD_DESCONTINUADO)
            throw new BusinessException(ErrorCode.PRODUCTO_DESCONTINUADO, "¡Este producto está descontinuado!");
        return p;
    }

    private void validateQuantity(int cantidad) {
        if (cantidad <= 0)
            throw new BusinessException(ErrorCode.VALIDACION_FALLIDA, "No se aceptan cantidades menores a 1");
    }

    private void validateQuantityNotNull(Integer cantidad) {
        if (cantidad == null)
            throw new BusinessException(ErrorCode.VALIDACION_FALLIDA, "Ingresa una cantidad valida");
    }

    private void requireAvailable(Producto p, int cantidad) {
        if (cantidad > p.getStockDisponible())
            throw new BusinessException(ErrorCode.STOCK_INSUFICIENTE,
                    "Stock disponible insuficiente (disponible: " + p.getStockDisponible() + ")");
    }

    private BigDecimal calcularCostoPromedio(Producto p, int cantidad, BigDecimal costoUnitario) {
        BigDecimal valorActual = p.getCostoPromedio().multiply(BigDecimal.valueOf(p.getStockActual()));
        BigDecimal valorEntrada = costoUnitario.multiply(BigDecimal.valueOf(cantidad));
        return valorActual.add(valorEntrada)
                .divide(BigDecimal.valueOf(p.getStockActual() + cantidad), 4, RoundingMode.HALF_UP);
    }

}
