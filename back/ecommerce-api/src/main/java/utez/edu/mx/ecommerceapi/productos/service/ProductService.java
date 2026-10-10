package utez.edu.mx.ecommerceapi.productos.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import utez.edu.mx.ecommerceapi.productos.dto.ProductoDto;
import utez.edu.mx.ecommerceapi.productos.repository.ProductoRepository;
import utez.edu.mx.ecommerceapi.shared.response.ApiResponse;

@Service
public class ProductService {
    private final ProductoRepository productoRepository;

    public ProductService(ProductoRepository productoRepository) {
        this.productoRepository = productoRepository;
    }

    @Transactional(readOnly = true)
    public ApiResponse<List<ProductoDto>> getAllProducts() {
        return ApiResponse.ok("Lista por devolver");
    }

    @Transactional(readOnly = true)
    public ApiResponse<ProductoDto> getProductById(Long id) {
        return ApiResponse.ok("Producto por devolver");
    }

    @Transactional(readOnly = true)
    public ApiResponse<ProductoDto> getProductoByName(String nombre) {
        return ApiResponse.ok("Producto por devolver");
    }
}
