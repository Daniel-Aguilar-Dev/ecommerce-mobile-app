package utez.edu.mx.ecommerceapi.productos.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import utez.edu.mx.ecommerceapi.carrito.entity.Carrito;

import utez.edu.mx.ecommerceapi.productos.dto.ProductoDto;
import utez.edu.mx.ecommerceapi.productos.dto.ProductoPublicDto;
import utez.edu.mx.ecommerceapi.productos.dto.StockLineaDto;
import utez.edu.mx.ecommerceapi.productos.service.ProductoService;
import utez.edu.mx.ecommerceapi.shared.response.ApiResponse;

import java.util.List;

@Tag(name = "Productos", description = "Consulta y administración de los productos del sistema")
@RestController
@RequestMapping("/api/v1/productos")
public class ProductoController {
    @Autowired
    private ProductoService productoService;

    @Operation(summary = "Obtiene todas los productos para el público en general")
    @GetMapping("/public")
    public ResponseEntity<ApiResponse<List<ProductoPublicDto>>> getProductosPublic(
            @RequestParam(required = false, defaultValue = "") String query,
            @RequestParam(required = false) Long categoria
    ) {
        ApiResponse<List<ProductoPublicDto>> response = productoService.getAllProductsPublic(query, categoria);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Obtiene un producto por su ID para el público en general")
    @GetMapping("/public/{id}")
    public ResponseEntity<ApiResponse<ProductoPublicDto>> getProductoByIdPublic(@PathVariable Long id) {
        ApiResponse<ProductoPublicDto> response = productoService.getProductByIdPublic(id);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Obtiene todas los productos para el uso del personal")
    @GetMapping()
    public ResponseEntity<ApiResponse<List<ProductoDto>>> getProductos(
            @RequestParam(required = false, defaultValue = "false") boolean stockBajo,
            @RequestParam(required = false, defaultValue = "false") boolean stockCero,
            @RequestParam(required = false, defaultValue = "false") boolean solo_descontinuados,
            @RequestParam(required = false, defaultValue = "false") boolean solo_vigentes,
            @RequestParam(required = false, defaultValue = "") String query,
            @RequestParam(required = false, defaultValue = "") String orden,
            @RequestParam(required = false, defaultValue = "") String marca,
            @RequestParam(required = false) Long categoria
    ) {
        ApiResponse<List<ProductoDto>> response = productoService.getAllProducts(
                stockBajo,
                stockCero,
                solo_descontinuados,
                solo_vigentes,
                query,
                orden,
                marca,
                categoria
        );
        return ResponseEntity.ok(response);
    }


    @Operation(summary = "Obtiene un producto por su ID para el uso del personal")
    @GetMapping("/id/{id}")
    public ResponseEntity<ApiResponse<ProductoDto>> getProductoById(@PathVariable Long id) {
        ApiResponse<ProductoDto> response = productoService.getProductById(id);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Obtiene un producto por su ID para el uso del personal")
    @GetMapping("/name/{name}")
    public ResponseEntity<ApiResponse<ProductoDto>> getProductoByName(@PathVariable String name) {
        ApiResponse<ProductoDto> response = productoService.getProductByName(name);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Obtiene un producto por su código de barras para el uso del personal")
    @GetMapping("/sku/{sku}")
    public ResponseEntity<ApiResponse<ProductoDto>> getProductoBySku(@PathVariable String sku) {
        ApiResponse<ProductoDto> response = productoService.getProductBySKU(sku);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Obtiene todas las distintas marcas para filtrar productos para personal")
    @GetMapping("/public/marcas")
    public ResponseEntity<ApiResponse<List<String>>> getMarcas() {
        ApiResponse<List<String>> response = productoService.getMarcas();
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Valida que un producto cuente con la cantidad solicitada en stock")
    @PostMapping("/public/validar/producto/{id}")
    public ResponseEntity<ApiResponse<Integer>> validarStockProducto(@RequestBody int cantidad, @PathVariable Long id) {
        ApiResponse<Integer> response = productoService.validarStockIndividual(id, cantidad);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Valida que el carrito dado pueda ser confirmado en un pedido")
    @PostMapping("/public/validar/carrito")
    public ResponseEntity<ApiResponse<List<StockLineaDto>>> validarStockCarrito(@RequestBody Carrito carrito) {
        ApiResponse<List<StockLineaDto>> response = productoService.validarStockCarrito(carrito);
        return ResponseEntity.ok(response);
    }

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<ProductoDto>> crearProducto(
            @Valid @RequestPart("data") ProductoDto data,
            @RequestPart("imagen") MultipartFile imagen
    ) {
        ApiResponse<ProductoDto> response = productoService.postProduct(data, imagen);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PutMapping(path = "/{id}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<ProductoDto>> modificarProducto(
            @PathVariable Long id,
            @Valid @RequestPart("data") ProductoDto data,
            @RequestPart(value = "imagen", required = false) MultipartFile imagen
    ) {
        ApiResponse<ProductoDto> response = productoService.putProduct(data, imagen, id);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Descontinua o reincorpora un producto")
    @PatchMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> cambiarEstadoProducto(@PathVariable Long id) {
        ApiResponse<Void> response = productoService.patchProduct(id);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Elimina un producto definitivamente")
    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> eliminarProducto(@PathVariable Long id) {
        ApiResponse<Void> response = productoService.deleteProduct(id);
        return ResponseEntity.ok(response);
    }
}
