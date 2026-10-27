package utez.edu.mx.ecommerceapi.inventario.repository;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import utez.edu.mx.ecommerceapi.inventario.entity.Entrada;

public interface EntradaRepository extends JpaRepository<Entrada, Long> {
    // Consulta el historial aplicando los filtros seleccionados
    @Query("""
        SELECT DISTINCT e
        FROM Entrada e
        JOIN FETCH e.usuario
        LEFT JOIN FETCH e.detalles d
        LEFT JOIN FETCH d.producto
        WHERE (:id_producto IS NULL OR EXISTS (
            SELECT d2.id
            FROM DetalleEntrada d2
            WHERE d2.entrada = e
              AND d2.producto.id = :id_producto
        ))
        AND (:fechaInicio IS NULL OR e.fecha_entrada >= :fechaInicio)
        AND (:fechaFin IS NULL OR e.fecha_entrada <= :fechaFin)
        ORDER BY e.fecha_entrada DESC
        """)
    List<Entrada> buscarHistorial(
        @Param("id_producto") Long productoId,
        @Param("fechaInicio") LocalDateTime fechaInicio,
        @Param("fechaFin") LocalDateTime fechaFin
    );
}
