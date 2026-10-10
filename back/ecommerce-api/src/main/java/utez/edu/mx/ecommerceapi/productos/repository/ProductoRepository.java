package utez.edu.mx.ecommerceapi.productos.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import utez.edu.mx.ecommerceapi.productos.entity.Producto;

public interface ProductoRepository extends JpaRepository<Producto, Long> {
    // Busca un producto por su nombre, ignorando mayúsculas y minúsculas
    Optional<Producto> findByNombreIgnoreCase(String nombre);

    // Busca un producto por su mcódigo de barras (SKU), ignorando mayúsculas y
    // minúsculas
    Optional<Producto> findBySkuIgnoreCase(String sku);

    // Busca productos por su categoría, devolviendo una lista de productos
    List<Producto> findByCategoriaId(Long categoriaId);

    // Busca productos por su marca, devolviendo una lista de productos
    List<Producto> findByMarcaContainingIgnoreCase(String marca);

    // Verifica si existen productos asociados a una categoría específica
    boolean existsByCategoriaId(Long categoriaId);
}
