package utez.edu.mx.ecommerceapi.categorias.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import utez.edu.mx.ecommerceapi.categorias.dto.CategoriaDto;
import utez.edu.mx.ecommerceapi.categorias.dto.CategoriaPublicDto;
import utez.edu.mx.ecommerceapi.categorias.service.CategoriaService;
import utez.edu.mx.ecommerceapi.shared.response.ApiResponse;

import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

@Tag(name = "Categorías", description = "Consulta y administración de categorías de productos")
@RestController
@RequestMapping("/api/v1/categorias")
public class CategoriaController {

    @Autowired
    private CategoriaService categoriaService;

    @Operation(summary = "Obtiene todas las categorias de productos para el personal adminstrativo")
    @GetMapping()
    public ResponseEntity<ApiResponse<List<CategoriaDto>>> getCategorias(
            @RequestParam(required = false) String nombre) {
        ApiResponse<List<CategoriaDto>> response = categoriaService.findAll(nombre);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Obtiene todas las categorias de productos para el público en general")
    @GetMapping("/public")
    public ResponseEntity<ApiResponse<List<CategoriaPublicDto>>> getCategoriasPublic() {
        ApiResponse<List<CategoriaPublicDto>> response = categoriaService.findAllPublic();
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Obtiene una categoría de producto por su ID para el personal administrativo")
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<CategoriaDto>> getCategoriaById(@PathVariable Long id) {
        ApiResponse<CategoriaDto> response = categoriaService.findById(id);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Obtiene una categoría de producto por su ID para el público en general")
    @GetMapping("/public/{id}")
    public ResponseEntity<ApiResponse<CategoriaPublicDto>> getCategoriaByIdPublic(@PathVariable Long id) {
        ApiResponse<CategoriaPublicDto> response = categoriaService.findByIdPublic(id);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Crea una nueva categoría de producto")
    @PostMapping()
    public ResponseEntity<ApiResponse<CategoriaDto>> postCategoria(@Valid @RequestBody CategoriaDto categoriaDto) {
        ApiResponse<CategoriaDto> response = categoriaService.save(categoriaDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @Operation(summary = "Actualiza una categoría de producto existente")
    @PatchMapping("/{id}")
    public ResponseEntity<ApiResponse<CategoriaDto>> patchCategoria(@PathVariable Long id,
            @Valid @RequestBody CategoriaDto categoriaDto) {
        ApiResponse<CategoriaDto> response = categoriaService.update(id, categoriaDto);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Elimina una categoría de producto por su ID")
    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteCategoria(@PathVariable Long id) {
        ApiResponse<Void> response = categoriaService.delete(id);
        return ResponseEntity.status(HttpStatus.NO_CONTENT).body(response);
    }
}
