package utez.edu.mx.ecommerceapi.productos.repository;

import java.util.List;
import java.util.Optional;

import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;

import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import utez.edu.mx.ecommerceapi.categorias.entity.Categoria;
import utez.edu.mx.ecommerceapi.productos.entity.Producto;

public interface ProductoRepository extends JpaRepository<Producto, Long> {
    // Busca un producto por su nombre, ignorando mayúsculas y minúsculas
    Optional<Producto> findByNombreIgnoreCase(String nombre);

    // Busca un producto por su mcódigo de barras (SKU), ignorando mayúsculas y minúsculas
    Optional<Producto> findBySkuIgnoreCase(String sku);

    // Busca un producto por su nombre, pero que no sea el del id dado
    Optional<Producto> findByNombreIgnoreCaseAndIdNot(String nombre, Long id);

    // Busca un producto por su nombre, pero que no sea el del id dado
    Optional<Producto> findBySkuIgnoreCaseAndIdNot(String sku, Long id);

    // Busca productos por su categoría, devolviendo una lista de productos
    List<Producto> findByCategoriaId(Long categoriaId);

    // Busca productos por su marca, devolviendo una lista de productos
    List<Producto> findByMarcaIgnoreCase(String marca);

    // Busca productos que contengan el nombre del producto
    List<Producto> findByNombreContainingIgnoreCase(String nombre);

    // Busca productos que contengan el nombre del producto y el id de la categoría
    List<Producto> findByNombreContainingIgnoreCaseAndCategoria(String nombre, Categoria categoria);

    // Busca productos que contengan la marca del producto y el id de la categoría
    List<Producto> findByMarcaIgnoreCaseAndCategoria(String marca, Categoria categoria);

    // Busca las marcas preregistradas
    @Query("SELECT DISTINCT LOWER(p.marca) FROM Producto p ORDER BY LOWER(p.marca) ASC")
    List<String> findMarcasDistintas();

    // Verifica si existen productos asociados a una categoría específica
    boolean existsByCategoriaId(Long categoriaId);

    // Verifica si existen ventas asociadas a un producto
    @Query("SELECT EXISTS (SELECT d FROM DetalleVenta d WHERE d.producto.id = :id)")
    boolean existSalesWithProduct(@Param("id") Long id);

    // Verifica si existen pedidos asociadas a un producto
    @Query(value = """
            SELECT EXISTS (
                SELECT 1
                FROM pedidos p
                JOIN JSON_TABLE(
                    p.carrito,
                    '$.items[*]'
                    COLUMNS (
                        productoId BIGINT PATH '$.producto.id'
                    )
                ) AS item
                WHERE item.productoId = :productoId
            )
            """, nativeQuery = true)
    boolean existOrdersWithProduct(
            @Param("productoId") Long productoId
    );

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select p from Producto p where p.id = :id")
    Optional<Producto> findByIdForUpdate(@Param("id") Long id);

    Long id(Long id);
}
