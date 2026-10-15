package utez.edu.mx.ecommerceapi.categorias.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import utez.edu.mx.ecommerceapi.categorias.entity.Categoria;

public interface CategoriaRepository extends JpaRepository<Categoria, Long> {
    /**
     * Busca una categoría por su nombre, ignorando mayúsculas y minúsculas
     */
    Optional<Categoria> findByNombreIgnoreCase(String nombre);

    /**
     * Busca categorías que contengan un nombre específico, ignorando mayúsculas y
     * minúsculas
     */
    List<Categoria> findByNombreContainingIgnoreCase(String nombre);

    /**
     * Verifica si existe una categoría con un nombre específico, ignorando
     * mayúsculas y minúsculas, excluyendo una categoría con un ID específico
     */
    boolean existsByNombreIgnoreCaseAndIdNot(String nombre, Long id);
}
